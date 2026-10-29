# AGENTS.md

This file provides project instructions and guidelines for coding agents working in this repository.

## Project Overview

SimsCraft is rebuilding the engine of The Sims Online in Swift, so the game can be played again.

Key entrypoints:

- ``NSOClient/`` - Swift packages, each independent:
  - ``TSOFiles/`` - file format readers (FAR, DBPF, IFF, and their chunks)
  - ``TSOFilesC/`` - a C ABI over TSOFiles
  - ``TSOFilesCheck/`` - ``tsofiles-check``, which scans a real install
  - ``TSOContent/`` - the content system, and the list of installs (``InstallKind``); its ``TSOConfig`` product reads them through swift-configuration
  - ``SimAntics/`` - the VM
  - ``SimsScript/`` - BHAV text assembly and an LSL-like compiler (proof of concept)
  - ``Interface/`` - the client's windows and controls on raylib-swift (see [The client](#the-client))
  - ``Client/`` - ``newso``, NewSO's client, which loads, runs, and shows a lot
  - ``FSO.Oracle/``, ``NSOOracle/``, ``ScriptOracle/`` - the oracles (see [The oracles](#the-oracles))
  - ``MockInstall/`` - a tiny made-up TSO install for tests and CI
  - ``Lots/`` - the owner's lots as blueprint XML
- ``TSOClient/`` - FreeSO's source, frozen at a snapshot (read-only)
- ``docs/`` - the documentation and development progress:
  - ``roadmap.md`` - milestones, the alpha gate, owner decisions
  - ``scorecard.md`` - status per feature with evidence (wins over the roadmap)
  - ``fso/`` - how the FreeSO snapshot works, project by project
  - ``nso/`` - how NSOClient behaves
  - ``results/`` - how NSOClient measures up against FreeSO
  - ``simantics/`` - the SimAntics Wiki in Markdown (CC BY-SA 3.0)
- ``.agents/skills/`` - Swift, C, and .NET conventions, and the ``raylib-swift`` skill for the client

``Charvatia/``, ``FSOInstaller/``, and ``Other/`` belong to the snapshot too. Build output (``.build/``, ``bin/``, ``obj/``, ``packages/``) is never committed.

## About this Project

SimsCraft started as a documentation fork of [FreeSO](https://github.com/riperiperi/FreeSO), a C# reimplementation of The Sims Online (TSO) on a forked MonoGame. FreeSO's servers have since shut down. The new game is **NewSO**, built from the NSOClient packages. Write the project's name as **SimsCraft**.

The goals, in order:

1. **Play The Sims Online again.** NewSO, playable with friends, is the end goal.
2. **Explain FreeSO's codebase** in ``docs/fso/``: the reference the reimplementation draws on.
3. **Reimplement the engine-free parts in Swift** (files, content, the VM). This is the current stage. It's a new implementation, not a line-by-line port.
4. **Then the rest of the game:** a lot server of our own, LAN play, and the client.
5. **Go past that baseline:** SimAntics extensions, scripting, and older games' data such as The Sims 1.

### Small and LAN first

TSO was an MMOG. NewSO doesn't assume that. Its default is a handful of players on one machine or a LAN, with nothing that depends on central accounts or services. MMOG scale may come, but only as an opt-in. When a FreeSO design exists only to serve a public city at scale (its database, city server, and web API), treat it as reference, not as the plan.

### FreeSO

"FreeSO" on its own means the snapshot in ``TSOClient/``: FreeSO beta/update-46 (August 2017), written for .NET Framework 4.5 on Windows. Call it "FreeSO beta/update-46 (August 2017)" on a page's first mention and "update-46" after that. Don't write "2017" as a stand-in for it (that's easily confused with Visual Studio 2017). FreeSO has kept going since; name that work explicitly ("FreeSO's later branches", or its update names), as ``docs/fso/future/`` and ``docs/fso/releases.md`` do. Swift names kept only for FreeSO compatibility use ``fsoCompat``, and ones kept only for the TSO beta use ``compat``.

FreeSO is the guide and the reference on the way to NewSO, not the limit. **NewSO is NewSO, not FreeSO:** the two share a goal, bringing The Sims Online back, but have creative differences on getting there, and NewSO isn't beholden to FreeSO's design or its bugs. What matters is that NewSO achieves the same thing while meeting its own goals. Where FreeSO and NewSO's own design decisions disagree, NewSO's win.

What NewSO must keep is what the game needs: TSO's file formats as the files actually are, and the behavior TSO's own objects and lots rely on, since they were scripted against TSO's original engine. FreeSO's results are the best evidence of that behavior, which is why the oracles measure against them. So before treating a FreeSO quirk as a bug, ask whether the game's content could depend on it; if it could, keep it, and when unsure, ask the owner.

Everything else is NewSO's to get right. Fix FreeSO's bugs rather than port them: a crash, a wrong mask, a value that's plainly off, a workaround for a problem NewSO doesn't have. The same goes for what FreeSO struggled with, patched, or invented (its PIFF patches, server-side systems). Record each difference in the scorecard's "Known differences from FreeSO" with why, and teach the oracle comparison to expect it, so it reads as a known difference, not a disagreement.

Two more baselines:

- **PIFF patches.** NewSO keeps applying FreeSO's PIFFs by default, for parity and for the content that uses them, but treats them as optional and replaceable.
- **The TSO beta.** The owner's 2002 beta install must keep working. Where its files differ from production, skip what doesn't fit, report it, and keep going. ``docs/results/install-differences.md`` lists the differences; check it before calling a beta mismatch a bug.

Learn from everything available: FreeSO's code, the SimAntics Wiki copy, [SimsWiki](https://simswiki.info/wiki.php?title=Main_Page) (its Sims 2 pages often apply), and [TheSimsOpenTechDoc](https://github.com/DnfJeff/TheSimsOpenTechDoc). Treat them as leads to verify against the code or the oracles.

## Common Commands

```sh
for package in TSOFiles TSOContent; do   # the packages you changed and those that depend on them (CI builds them all)
    swift build --package-path "NSOClient/$package" && swift test --package-path "NSOClient/$package"
done
grep -rnE 'try!|as!|fatalError|precondition|preconditionFailure' NSOClient/*/Sources  # must print nothing
swift run --package-path NSOClient/TSOFilesCheck -c release tsofiles-check            # scans every TSO_*_DIR install that's set
swift run --package-path NSOClient/Client -c release newso --headless --ticks 9000    # run a lot a game hour with no window; read the log
NSOClient/scripts/oracle-fixtures.sh /tmp/oracle                                       # FreeSO's side; needs TSO_GAME_DIR
TSO_ORACLE_DIR=/tmp/oracle swift test --package-path NSOClient/NSOOracle               # NSOClient's side, compared
NSOClient/scripts/oracle-review.sh --mock /tmp/review                                  # both oracles on MockInstall
NSOClient/scripts/scenario-oracle.sh --mock                                            # SimsScript scenarios on both VMs
git status --short -- TSOClient Charvatia FSOInstaller Other                           # must print nothing
```

Locally, build and test only what changed: the packages you touched and the ones that depend on them (TSOFiles, then TSOContent, then SimAntics, then SimsScript, NSOOracle, and ScriptOracle; ``TSOFilesC`` hangs off TSOFiles, and ``TSOFilesCheck`` off TSOFiles and TSOContent). CI builds and tests every package on each push. Build one package at a time, and don't clear ``.build`` folders without need: rebuilding every package from scratch at once can run the owner's machine out of memory. Real-install checks read ``TSO_GAME_DIR`` (production, 1.1097.1.0), ``TSO_CLASSIC_DIR`` (the 2002 copy), and ``TSO_BETA_DIR`` (the beta), as TSOContent's ``InstallKind`` lists them, and skip when they aren't set. The tests themselves read only ``TSO_GAME_DIR``; point it at another copy to test that one. TSOFiles' real-install tests live in TSOContent, since TSOFiles can't depend on it.

### The oracles

``fso-oracle`` (``NSOClient/FSO.Oracle``) is a small .NET tool that compiles FreeSO's SimAntics, Files, and Content sources headless and records what they do. ``nso-oracle`` runs the same experiments on NSOClient, and ``compare`` sets the two side by side. ``sso-oracle`` (``ScriptOracle``) asks smaller questions: each scenario is a SimsScript object with the values it should leave, compiled once and run on both VMs (``fso-oracle run-scenarios``).

Treat them as two sides of an experiment, not an answer key and a student:

- **A disagreement is a finding,** not a failure. Explain it before fixing it: it may be an NSOClient bug, a FreeSO bug NewSO fixes (record it, and make the comparison expect it), a quirk the game relies on, or another deliberate difference.
- **Inconclusive isn't agreement.** A case one side couldn't measure is counted by reason, never as a pass.
- **Keep the experiments repeatable.** Where FreeSO's own code isn't, change the oracle as little as possible and document it in its README.
- **The checks are a gate, not the goal.** They stop on a new disagreement so someone looks at it.

Write ``docs/results/nso-review.md`` (``oracle-review.sh --review``) only at the end of a phase or milestone, or when the owner asks.

Don't run ``dotnet``, ``msbuild``, ``mono``, or ``nuget``, except for ``FSO.Oracle`` (directly or through ``NSOClient/NSOClient.slnx``, which holds only the oracle). The snapshot doesn't build on Linux, and the oracle must never change a file under ``TSOClient/``.

## Golden rules

### Design Process

- **Design through iteration.** Treat a first pass at a design, a draft shape, or a first naming attempt as a starting point to revise. Expect to refine or rebuild clumsy parts as understanding improves.
- **Ask when decisions are open.** For ambiguous choices, unclear behavior, or tradeoffs between fidelity and clean design, flag them rather than deciding unilaterally. Keep critical thinking collaborative.
- **Adapt to the user's context.** Understand their tools, constraints, and workflow. Work with what they have rather than imposing external requirements.
- **Explain the reasoning.** Show the why behind suggestions and changes so the user can evaluate, learn, and steer the work; teach rather than just deliver.
- **Trust the user's judgment.** Defer to their domain expertise and priorities. Flag concerns when they matter, but don't override their decisions.
- **Favor simplicity.** Entities must not be multiplied beyond necessity. The simplest correct approach that matches observed behavior is almost always preferable to over-engineered alternatives.
- **Account for constraints.** Differences between source and target environments are real costs, not failures of design. Use workarounds only when necessary.
- **Make implicit things explicit.** State assumptions, unverified behavior, confidence levels, and what remains uncertain. Don't let important details stay hidden.
- **Suggest validation early.** Offer test cases, assertions, or verification approaches as understanding solidifies. A test that catches the problem before implementation is valuable feedback.
- **Let evidence carry weight.** Report what was tried, what succeeded, what failed, and what remains open. Let the results speak rather than over-interpreting or jumping to conclusions.
- **Flag blindspots.** Call out what you can't verify, what might break, what needs play-testing or expert review, and where the approach is unproven.

### Never crash (outranks feature work)

NSOClient reads files nobody controls: original installs, patched objects, user mods, and lot saves. A truncated archive, a corrupt chunk, or a hostile save must produce an error the caller can act on, never a trap. Fix a crash before building on top of it.

- **Library code never traps.** No force unwraps, ``try!``, ``as!``, implicitly unwrapped optionals, ``fatalError``, ``precondition``, or ``assert``-based control flow in ``Sources/``. Throw a typed error. Unfinished features throw rather than trap.
- **No silent fallbacks for bad data.** Report invalid input; don't quietly replace it. The exception is a tolerance FreeSO had and real files rely on: keep it and say so in the doc comment.
- **File-derived numbers are hostile.** Check every size, offset, and count against the bytes that remain before slicing or allocating, and watch for overflow.
- **Bound what data can drive:** decompression output, nested containers, call depth, graph walks, and BHAV execution (FreeSO stops a thread after 500,000 instructions in one tick).
- **Failures change nothing.** A reader that throws returns nothing partial.
- **Contain failures.** One bad file or entry doesn't stop a scan or a content load, and an error in one entity's thread stays in that entity, as in FreeSO.
- **Prove it.** Every crash or bad-input fix comes with a regression test that failed before the fix.

### Forward compatibility

FreeSO was built against TSO after its New & Improved update (October 2003), likely around 1.1097.1.0 (January 2005). The owner has 1.1097.1.0 (``TSO_GAME_DIR``), a 2002 copy (1.145.1.0, ``TSO_CLASSIC_DIR``), and the 2002 beta (1.3.2.121, ``TSO_BETA_DIR``), and NewSO will meet more data newer than any of them: FreeSO's content, mods, and later saves of its own. So write every reader for data newer than what's on hand. Being ready for what comes next is also what keeps older data working.

- **Port every version FreeSO reads,** not only the ones the installs hold. FreeSO is the only reference for files newer than the installs, so its version branches are the spec. Test the versions the installs lack with synthetic files, and mark them in the scorecard as unverified on real data.
- **Unknown isn't corrupt.** Data newer than a reader knows (a chunk type, a higher version, extra trailing fields, an enum value) is skipped or kept raw and reported wherever the format lets the rest be read. It's never a trap, and never dropped without a report. Data that is actually broken, such as a size past the end, is still an error. Where FreeSO does something else with unknown data (leaves it empty, say), do what serves NewSO, and record the difference.
- **Keep what you don't understand.** Anything that rewrites a file (patching, saving, re-encoding a BHAV) carries the parts it can't read through unchanged instead of dropping them.
- **NewSO's own formats stay readable by older NewSO.** When NewSO writes a format of its own, or extends one of FreeSO's, version it. Add new data as parts an older build can skip or keep, and say which is safe. A change an older build can't safely skip takes a new major version, which older builds refuse with a clear message. CityLimits' saves work this way (its ``docs/saving.md``, "Opening a newer save").

### Library rules

These apply to the NSOClient libraries. Tools (``tsofiles-check``, the oracles) may print, and are freer.

- **Engine-free.** No rendering, audio playback, UI, logging, or printing in library targets. Decode to plain values (RGBA pixels, PCM samples, typed chunks) and report through errors and results.
- **Deterministic.** SimAntics must give the same results on every machine for lockstep play: wrap 16-bit arithmetic (``&+``, ``&-``, ``&*``), never iterate a ``Dictionary`` or ``Set`` in VM logic, process entities in object ID order, take randomness only from the VM's seed, never read the clock, and review any floating point that feeds simulation state.
- **Values, not shared state.** ``Sendable`` structs and enums, immutable once loaded. No singletons: where FreeSO used ``Content.Get()``, pass the dependency in.
- **Say where it comes from.** A Swift type's doc comment names the FreeSO type it corresponds to. Where results differ on purpose, say so there and in the scorecard's "Known differences from FreeSO".
- **Independent packages.** Each package builds and tests on its own, and dependencies point one way (TSOFiles, then TSOContent, then SimAntics, then SimsScript). Libraries don't declare ``platforms:``.
- **Dependencies as needed.** Foundation and the standard library come first, but a package may take a dependency when it clearly earns its place, as the tools do with swift-argument-parser and swift-configuration. Say why in the change, prefer tagged releases, and call it out for the owner.
- **No EA data in the repository.** Tests build synthetic files in code or use ``MockInstall``. Results files hold names, sizes, chunk IDs, and GUIDs only.
- **Tests are the gate.** Swift Testing (``import Testing``), never XCTest. Cover every kept quirk and error path.
- **Public API is documented, and breaking changes are said out loud.** Removing or renaming public API, or adding a case to a public enum, breaks callers in the other packages: update them and call it out.
- **Measure before optimizing,** with a release build against a real install.
- **Follow the [Swift guidelines](./.agents/skills/swift-guidelines/SKILL.md)** (and the [C guidelines](./.agents/skills/c-guidelines/SKILL.md) for ``TSOFilesC``), and match the surrounding code when they disagree.

### The client

The client is ``NSOClient/Client`` (``newso``), built on ``NSOClient/Interface``. ``swift run --package-path NSOClient/Client newso`` opens a lot from ``TSO_GAME_DIR`` (or the beta, or MockInstall); ``--lot`` picks another, and ``--screenshot <file.png>`` saves a frame after ``--ticks`` ticks, framed with ``--zoom`` (1, TSO's near, to 5), ``--focus x,y``, and ``--rotation`` (0 to 3). ``--headless`` opens no window and needs no display: the lot runs ``--ticks`` ticks back to back (a game day, 216,000, by default; a game week at most) and logs to standard error, through swift-log, each system message as it arrives, a line each game hour, and a summary, every line stamped with the tick and game time rather than the clock; ``--verbose`` logs the same with the window open. Use it to check a lot's behavior over game time; a game day runs in seconds. What it shows is worked out in its ``LotScene`` target, without raylib, so it's tested without a window. It's built on [raylib-swift](https://github.com/tonytins/raylib-swift), the owner's own raylib binding, which keeps raylib's function names and adds Swift enums (``IsKeyDown(.space)``) and colors (``.rayWhite``). It will reuse the generalized parts of the owner's [CityLimits](https://github.com/tonytins/citylimits) interface library (``WindowFrame``, ``TextField``, ``TextArea``, ``ButtonRow``, its loading screen, and its map view), translated from C# and Raylib-cs by the owner's [cs2swift](https://github.com/tonytins/cs2swift). Its output is regenerated, never edited: change the C# in CityLimits and run cs2swift again, and keep Swift-only code in files of its own.

- **Syncing.** ``NSOClient/scripts/sync-interface.sh <CityLimits> <cs2swift>`` rewrites ``Interface/Sources/Interface/CityLimits/`` from CityLimits' files; NewSO's own Swift goes in ``Interface/Sources/Interface/NewSO/``. Read cs2swift's warnings at each sync.
- **Generated code is a temporary exception to "never crash".** cs2swift's output may hold force unwraps (after a null check such as ``x is null || x.Count``, which C#'s own checks prove safe, and for ``.Value``, which cs2swift warns about) and debug-only ``assert``s where the C# threw. It's a byproduct of the generator, not a license: fix each case to match the guidelines sooner rather than later, preferably by changing the C# in CityLimits (or cs2swift) so the next sync comes out clean.
- **TSO's interface.** These windows and controls are the base for NewSO's take on TSO's ``.uis`` screens.
- **Seeing it.** ``swift run --package-path NSOClient/Interface interface-demo`` opens a window with the controls; ``--screenshot <file.png>`` draws a few frames hidden and saves the last, for checking a change without anyone at the screen.
- **Building on Linux** needs the X11 and GL headers (``libx11-dev`` and friends, as in CI). On the owner's Atomic host they come from Homebrew: ``export CPATH="$(brew --prefix)/include:$(brew --prefix xorgproto)/include" LIBRARY_PATH="$(brew --prefix)/lib"``.

- **Use the ``raylib-swift`` skill** in ``.agents/skills/raylib-swift/`` for any work that imports Raylib: it covers the API's Swift shapes, the lifecycle, the frame, textures, render textures, input, the examples to read, and how to check a visual change on a private display. These rules win where the two disagree.
- **The libraries never import raylib.** Rendering reads simulation state and never writes it. If something can't be tested without a window, it belongs in the client.
- **raylib's examples are the reference.** Read the one closest to what you're writing. A frame is ``BeginDrawing``, the drawing, ``EndDrawing``; textures load after ``InitWindow`` and unload before ``CloseWindow``, never inside the frame loop.

### Documenting the snapshot

- **The source is the ground truth.** Every claim about FreeSO's behavior comes from the code in this repo, not memory of FreeSO or TSO lore. If you can't confirm it, mark it **Unverified**.
- **Cite where it lives,** with relative links to files and exact type and member names.
- **Describe the snapshot, not upstream,** and don't call something a bug unless the code shows it.
- **Don't change the snapshot.** Documentation work never edits ``TSOClient/``, ``Charvatia/``, ``FSOInstaller/``, or ``Other/``.
- **Account for what's missing.** The ``FSOMonoGame`` and ``FSOMina.NET`` submodules aren't checked out; describe them from how the snapshot uses them. Note dead code and projects outside ``FreeSO.sln`` as such. Folder names often differ from assembly names; [docs/fso/README.md](./docs/fso/README.md) maps them.
- **Respect the IP.** Document formats and how the code reads them, but never paste or reconstruct game data.
- Pages describe **How it works (update-46)**. The older "Modern .NET rewrite" sections are kept for reference; don't add to them.

Markdown: one ``#`` heading per file, lowercase kebab-case file names, plain short sentences without em dashes, relative links, tables for inventories, and Mermaid only where a diagram beats prose. Link every new page from [docs/fso/README.md](./docs/fso/README.md).

## Before you finish

- Every package you touched, and every package that depends on it, builds with no new warnings and passes its tests. Leave the rest to CI. If you touched a reader and an install is set, the scan reports 0 failures; without one, say you couldn't run it.
- Look over your diff for force unwraps by eye; the search can't tell ``!`` from ``!=``.
- Bring the docs up to date in the same change: flip the [scorecard](./docs/scorecard.md) rows you moved, with evidence; update the [roadmap](./docs/roadmap.md)'s milestone, focus, and revision history; and fix any ``docs/fso/`` page the port showed to be wrong.
- Update this file if the layout or these rules change. Leave ``README.md`` alone unless asked.

Sessions can end abruptly, so keep every package building and its tests green at every step.

## Calling things out

The owner reviews changes alone, so make review easy. List:

- what you did, what you skipped, and every **Unverified** claim;
- anything that would break compatibility: save and lot formats, reading the original TSO files, or an older NewSO build reading newer data (FreeSO's network protocol isn't a target);
- new dependencies and framework choices, with the alternative you weighed;
- every deliberate difference from FreeSO and every addition past the baseline, and which checks ran (tests, the install scan, the oracle comparisons);
- any risk you notice in the snapshot, such as a committed secret or a licensing question. Report it; don't fix it in the source.
