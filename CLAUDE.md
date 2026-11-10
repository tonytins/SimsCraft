# CLAUDE.md

This file provides project instructions and guidelines for coding agents working in this repository.

## Project Overview

SimsCraft is rebuilding the engine of The Sims Online in Swift, so the game can be played again.

Key entrypoints:

- Simburbia's packages, each independent, at the repository root:
  - ``TSOFiles/`` - file format readers (FAR, DBPF, IFF, and their chunks)
  - ``TSOFilesC/`` - a C ABI over TSOFiles
  - ``TSOFilesCheck/`` - ``tsofiles-check``, which scans a real install
  - ``TSOContent/`` - the content system, and the list of installs (``InstallKind``); its ``TSOConfig`` product reads them through swift-configuration
  - ``SimAntics/`` - the VM
  - ``SimsScript/`` - BHAV text assembly and an LSL-like compiler (proof of concept)
  - ``SBClient/`` - ``simburbia``, Simburbia's client, which loads, runs, and shows a lot
  - ``FSO.Oracle/``, ``SBOracle/``, ``ScriptOracle/`` - the oracles (see [The oracles](#the-oracles))
  - ``MockInstall/`` - a tiny made-up TSO install for tests and CI
  - ``Interface/`` - the client's top bar and windows, in Hudini's UIScript XML
  - ``Lots/`` - the owner's lots as blueprint XML: ``tonys-lot.xml`` (a recreation of their original TSO lot) and ``community-lot.xml`` (a lot for group events)
  - ``Tuning/`` - Simburbia's default global tuning (``tuning.xml``), laid under an install's ``tuning.dat``
  - ``packaging/`` - the scripts that build the client into packages players download
- ``FreeSO/TSOClient/`` - FreeSO's source, frozen at a snapshot (read-only)
- ``docs/`` - the documentation and development progress:
  - ``roadmap.md`` - milestones, the alpha gate, owner decisions
  - ``scorecard.md`` - status per feature with evidence (wins over the roadmap)
  - ``fso/`` - how the FreeSO snapshot works, project by project
  - ``sb/`` - how Simburbia behaves
  - ``results/`` - how Simburbia measures up against FreeSO
  - ``simantics/`` - the SimAntics Wiki in Markdown (CC BY-SA 3.0)
- ``.agents/skills/`` - Swift, C, and .NET conventions, and the ``raylib-swift`` skill for the client

``FreeSO/Charvatia/``, ``FreeSO/FSOInstaller/``, and ``FreeSO/Other/`` belong to the snapshot too. Build output (``.build/``, ``bin/``, ``obj/``, ``packages/``) is never committed.

## About this Project

[The Sims Online](https://en.wikipedia.org/wiki/The_Sims_Online) (TSO) was an MMORPG based on The Sims. When the servers shutdown, [FreeSO](https://github.com/riperiperi/FreeSO) (FSO) re-implementated the game with their own open source server and client. Now, their servers have shutdown. With no new alternatives, FSO has been refactoring the client to serve as an "archive" client that can be used for self-hosting.

SimsCraft started as FSOdoc, an early attempt to document a snapshot of FSO update-46 with AI, but has since grown to use that knowledge to start over fresh with a new client and server intended for small scale use, known as Simburbia (SB).

The goals:

- **Play The Sims Online again**. Simburbia, playable with friends, is the end goal.
- **Reimplement the game in Swift**. This is a new implementation, not a line-by-line port, that is intended for a lot server of our own, LAN play, and the client.
- **Explain Simburbia's codebase** in ``docs/sb/``: Make it easy for others tinker with the code to run their own server or client.
- **Go past that baseline:** SimAntics extensions, scripting, and older games' data such as The Sims 1.

### Small and LAN First

SB prioritizes small-scale, self-hosted deployments. The project aims for support local area network (LAN) and Internet multiplayer, co-operative and competitive, expecting roughly 1–50 players on average, with a maximum of 255, all while retaining TSO's core MMOG functionality. 

The self-hosted infrastructure is designed to scale upward for massively multiplayer servers when needed, rather than requiring it from the start. Design references include [Luanti](https://github.com/luanti-org), [Space Station 14](https://github.com/space-wizards), and [OpenTTD](https://github.com/OpenTTD/OpenTTD).

## Learn from Available Sources

Because TSO's servers shutdown decades ago now, FSO's code provides the only ground truth on how the game worked. Even though FSO took some creative liberties (as will SB), the underlining game remains the same.

Learn from everything available: FSO's code, [FreeSims](https://github.com/francot514/FreeSims), the [SimAntics Wiki](http://simantics.wikidot.com/wiki:introduction-to-simantics) copy, [SimsWiki](https://simswiki.info/wiki.php?title=Main_Page) (Sims 2 as well, the game's AI extends SimAntics), [Don Hopkins](https://github.com/SimHacker), [SimObliterator Suite](https://github.com/DnfJeff/SimObliterator_Suite), [TS1 Compiler](https://github.com/mixiate/ts1-compiler), [TS1 Renderer](https://github.com/mixiate/ts1-renderer) ([IO](https://github.com/mixiate/ts1-blender-io)), [TheSimsOpenTechDoc](https://github.com/DnfJeff/TheSimsOpenTechDoc), and [The Modding Guide](https://cyndersanity.github.io/sims-legacy-mod-guide/index.html).

Treat them as leads to verify against the code or the oracles.

### Gameplay: check TSO Mania

[TSO Mania](https://www.tsomania.net/) was the players' guide to TSO in its heyday: property categories, skills, jobs, pets, objects, and how each felt to play. Code tells you how something works; TSO Mania tells you how it played. Search it whenever a change touches gameplay or balance, and especially where FreeSO's data is missing or the installs disagree, as with the motive tuning the unpatched discs lack.

- **Cite it** where it informs a number or a behavior (a doc comment, the scorecard, a tuning file's comments), as the default tuning cites its category difficulties.
- **Mind the era.** Its guides span TSO, New & Improved, EA-Land, and FreeSO; say which a claim is from when it matters, and mark it **Unverified** when the page doesn't.
- **It describes, it doesn't specify.** "Easy" or "50% overfill" is a target to match, not a value to copy; Simburbia's own numbers meet it.

## Common Commands

```sh
for package in TSOFiles TSOContent; do   # the packages you changed and those that depend on them (CI builds them all)
    swift build --package-path "$package" && swift test --package-path "$package"
done
grep -rnE 'try!|as!|fatalError|precondition|preconditionFailure' */Sources  # must print nothing
swift run --package-path TSOFilesCheck -c release tsofiles-check            # scans every TSO_*_DIR install that's set
swift run --package-path SBClient -c release simburbia --headless --ticks 9000    # run a lot a game hour with no window; read the log
swift run --package-path SBClient -c release simburbia --headless --check         # the same over a game day, checking the lot's rules
packaging/linux/package.sh                                                   # the client as an AppImage and a .tar.gz, in dist/release
scripts/oracle-fixtures.sh /tmp/oracle                                       # FreeSO's side; needs TSO_GAME_DIR
TSO_ORACLE_DIR=/tmp/oracle swift test --package-path SBOracle               # Simburbia's side, compared
scripts/oracle-review.sh --mock /tmp/review                                  # both oracles on MockInstall
scripts/scenario-oracle.sh --mock                                            # SimsScript scenarios on both VMs
git status --short -- FreeSO/TSOClient FreeSO/Charvatia FreeSO/FSOInstaller FreeSO/Other                           # must print nothing
```

### The oracles

``fso-oracle`` (``FSO.Oracle``) is a small .NET tool that compiles FreeSO's SimAntics, Files, and Content sources headless and records what they do. ``sb-oracle`` runs the same experiments on Simburbia, and ``compare`` sets the two side by side. ``sso-oracle`` (``ScriptOracle``) asks smaller questions: each scenario is a SimsScript object with the values it should leave, compiled once and run on both VMs (``fso-oracle run-scenarios``).

Treat them as two witnesses, not an answer key and a student. FreeSO was the only earlier attempt, built without the tools this project has, and it was often wrong.

- **Triage disagreements**. Dig into the ones real content reaches, and log the rest. A FreeSO bug Simburbia fixes is a known difference the comparison expects.
- **The randomized study leads**. Prefer seeded, sampled experiments and checks that need Simburbia alone over hand-written cases. The hand-written case lists (``OracleCases/make_cases.py``) are kept as a regression set; don't grow them.
- **Inconclusive isn't agreement**. A case one side couldn't measure is counted by reason, never as a pass.
- **Keep the experiments repeatable**. Where FreeSO's own code isn't, change the oracle as little as possible and document it in its README.

Write ``docs/results/sb-review.md`` (``oracle-review.sh --review``) only at the end of a phase or milestone, or when the owner asks.

Don't run ``dotnet``, ``msbuild``, ``mono``, or ``nuget``, except for ``FSO.Oracle`` (directly or through ``Simburbia.slnx``, which holds only the oracle). The snapshot doesn't build on Linux, and the oracle must never change a file under ``FreeSO/TSOClient/``.

## Golden rules

These are lighter than they used to be. Two rules stay strict: never crash, and determinism. Use judgment for the rest.

### Design Process

- **Iterate**. A first design or name is a draft. Rebuild clumsy parts as understanding improves.
- **Ask when a decision is open**, and explain the reasoning behind what you suggest.
- **Keep it simple**. The simplest approach that matches what the game does wins.
- **Say what you're unsure of**: assumptions, unverified behavior, and what needs play-testing.

### Never crash (outranks feature work)

Simburbia reads files nobody controls: original installs, patched objects, user mods, and lot saves. A truncated archive, a corrupt chunk, or a hostile save must produce an error the caller can act on, never a trap. Fix a crash before building on top of it.

- **Library code never traps**. No force unwraps, ``try!``, ``as!``, implicitly unwrapped optionals, ``fatalError``, ``precondition``, or ``assert``-based control flow in ``Sources/``. Throw a typed error. Unfinished features throw rather than trap.
- **No silent fallbacks for bad data**. Report invalid input; don't quietly replace it. The exception is a tolerance FreeSO had and real files rely on: keep it and say so in the doc comment.
- **File-derived numbers are hostile**. Check every size, offset, and count against the bytes that remain before slicing or allocating, and watch for overflow.
- **Bound what data can drive:** decompression output, nested containers, call depth, graph walks, and BHAV execution.
- **Failures change nothing**. A reader that throws returns nothing partial.
- **Contain failures**. One bad file or entry doesn't stop a scan or a content load, and an error in one entity's thread stays in that entity.
- **Prove it**. Every crash or bad-input fix comes with a regression test that failed before the fix.
- **Generated code is a temporary exception**. Force unwraps and asserts are byproducts of code generator, not licenses. Fix each case by refactoring the output.

### Forward compatibility

FreeSO was built against TSO New & Improved, likely the Anniversary Update (1.1082.2.0). Simburbia was first built against the beta (1.3.2.121), then the 2002 retail copy (1.145.1.0) and finally the Mystic Tree update (1.1097.1.0). And it will still meet newer data than any of them: FreeSO's content, mods, and its own later saves.

- **Port the versions real files use**. FreeSO's version branches are a guide, not a checklist. Port the rest when a file or mod needs them.
- **Unknown isn't corrupt**. Data newer than a reader knows is skipped or kept raw and reported where the format allows. Data that is actually broken is still an error.
- **Keep what you can when rewriting a file**. If a rewrite drops something it couldn't read, say so.
- **Older Simburbia reads newer saves (strict)**. Version Simburbia's own formats. Add new data as parts an older build can skip. A change it can't skip takes a new major version, which older builds refuse with a clear message.

### Library rules

These apply to the Simburbia libraries. Tools (``tsofiles-check``, the oracles) may print, and are freer.

- **Engine-free**. No rendering, audio playback, UI, logging, or printing in library targets. Decode to plain values and report through errors and results.
- **Deterministic (strict)**. SimAntics must give the same results on every machine for lockstep play: wrap 16-bit arithmetic (``&+``, ``&-``, ``&*``), never iterate a ``Dictionary`` or ``Set`` in VM logic, process entities in object ID order, take randomness only from the VM's seed, never read the clock, and review any floating point that feeds simulation state.
- **Values, not singletons**. Where FreeSO used ``Content.Get()``, pass the dependency in.
- **Say where it comes from** when it helps: name the FreeSO type a Swift type follows, and record deliberate differences in the scorecard's "Known differences from FreeSO".
- **Independent packages**. Each package builds and tests on its own, and dependencies point one way (TSOFiles, then TSOContent, then SimAntics, then SimsScript). Libraries don't declare ``platforms:``.
- **Dependencies as needed**. Take one when it earns its place, and say why.
- **No EA data in the repository (strict)**. Tests build synthetic files in code or use ``MockInstall``. Results files hold names, sizes, chunk IDs, and GUIDs only.
- **Test what matters**, with Swift Testing (``import Testing``), never XCTest: crash fixes, and quirks real content relies on.
- **Say breaking changes out loud**. Renaming public API, or adding a case to a public enum, breaks callers in the other packages: update them and call it out.
- **Measure before optimizing,** with a release build against a real install.
- **The [Swift guidelines](./.agents/skills/swift-guidelines/SKILL.md)** (and the [C guidelines](./.agents/skills/c-guidelines/SKILL.md) for ``TSOFilesC``) are a guide. Match the surrounding code when they disagree.

### The client

- **TSO's interface**. These windows and controls are the base for Simburbia's take on TSO's ``.uis`` screens.
- **Seeing it**. ``simburbia --screenshot <file.png>`` draws a few frames in a hidden window and saves the last, for checking a change without anyone at the screen; ``--loading-screenshot <file.png>`` and ``--login-screenshot <file.png>`` save the loading screen or the login window instead. Without ``--lot`` the client opens on the login window; ``--lot`` goes straight to a lot. The windows and controls come from [Hudini](https://github.com/tonytins/Hudini), the owner's interface library; its ``hudini-demo`` shows them on their own.
- **Building on Linux** needs the X11 and GL headers (``libx11-dev`` and friends, as in CI). 
- **Use the ``raylib-swift`` skill** in ``.agents/skills/raylib-swift/`` for any work that imports Raylib: it covers the API's Swift shapes, the lifecycle, the frame, textures, render textures, input, the examples to read, and how to check a visual change on a private display. These rules win where the two disagree.
- **The libraries never import raylib**. Rendering reads simulation state and never writes it. If something can't be tested without a window, it belongs in the client.
- **raylib's examples are the reference**. Read the one closest to what you're writing. A frame is ``BeginDrawing``, the drawing, ``EndDrawing``; textures load after ``InitWindow`` and unload before ``CloseWindow``, never inside the frame loop.

### Documenting the FreeSO snapshot

- **Work from the code** in this repo where you can, cite where it lives, and say how sure you are.
- **Never change the snapshot (strict)**: ``FreeSO/TSOClient/``, ``FreeSO/Charvatia/``, ``FreeSO/FSOInstaller/``, and ``FreeSO/Other/``.
- **Respect the IP**. Document formats and how the code reads them, but never paste or reconstruct game data.
- ``FSOMonoGame`` and ``FSOMina.NET`` were removed from ``FreeSO/Other/libs/``; the oracle doesn't need them. Folder names often differ from assembly names; [docs/fso/README.md](./docs/fso/README.md) maps them.

Markdown: plain short sentences, relative links, lowercase kebab-case file names. Link new pages from [docs/fso/README.md](./docs/fso/README.md).

## Before you finish

- Reviews, by a person or an agent, follow [REVIEW.md](./REVIEW.md); agents also follow [AGENTS.md](./AGENTS.md).
- Every package you touched, and every package that depends on it, builds and passes its tests. Leave the rest to CI. If you touched a reader and an install is set, run the scan.
- Look over your diff for force unwraps by eye; the search can't tell ``!`` from ``!=``.
- When a step finishes, update the [scorecard](./docs/scorecard.md) and the [roadmap](./docs/roadmap.md).
- Update this file if the layout changes. Leave ``README.md`` alone unless asked.

Keep every package building and its tests green at every step, since sessions can end abruptly.

## Personal Configuration

Keep personal preferences and machine-specific guidance in git-ignored
`*.local` files or directories, rather than in shared project instructions.
Check for relevant local guidance before environment-specific work. You can
create or update these files for details such as:

- Coding preferences
- Local build and development environment
- Personal shortcuts or workflows
