# NSOClient

NSOClient is the Swift code of NewSO. At its core are libraries that reimplement the parts of
FreeSO that don't depend on a game engine: the file formats, the content system, and the SimAntics
virtual machine that runs object behavior. They aim to get the same results as FreeSO, as its code
stood at beta/update-46, in August 2017 (in [`TSOClient/`](../../TSOClient/)), without copying that
code. Around them are NewSO's own client, `newso`, which shows a lot running, and the tools that
check the libraries against FreeSO. It all keeps working on older copies of the game, a 2002 copy
and a 2002 beta, whose files differ from the ones FreeSO expects.

This folder describes how the code behaves today. For what's finished and the evidence for it, see
the [scorecard](../scorecard.md); for what comes next, the [roadmap](../roadmap.md). Unfamiliar
terms are explained in the [docs index](../README.md#terms).

These pages cover the libraries, the client, and the tools. `fso-oracle`, which runs FreeSO's code
through the experiments NSOClient is measured against, has [its own README](../../NSOClient/FSO.Oracle/README.md),
and so does [SimsScript](../../NSOClient/SimsScript/README.md), the scripting language in progress.

## The packages

Each package is an independent Swift package under [`NSOClient/`](../../NSOClient/). Dependencies
point one way:

```text
TSOFiles ──▶ TSOContent ──▶ SimAntics ──▶ SimsScript ──▶ ScriptOracle (sso-oracle)
                                │
                                ├──▶ NSOOracle (nso-oracle)
                                └──▶ Client (newso) ◀── NSOInterface ◀── raylib-swift

TSOFiles and TSOContent ──▶ TSOFilesCheck (tsofiles-check)
```

TSOContent's `TSOConfig` product reads the installs through swift-configuration, for the tools and
the client; the libraries themselves take no configuration library.

| Package | What it does | Page |
| --- | --- | --- |
| TSOFiles | Reads the game's containers (FAR1, FAR3, DBPF, IFF), IFF chunks, tables, and PIFF patches | [files.md](files.md) |
| TSOContent | Finds an install and loads objects, globals, and patches from it | [content.md](content.md) |
| SimAntics | Runs object behavior: the VM, entities, threads, primitives, and variables | [simantics.md](simantics.md) |
| SimAntics (lot model) | Positions, the tile index, walls, floors, rooms, and blueprints | [lot.md](lot.md) |
| SimsScript | Routines as readable listings and text assembly, and a small compiler; `simsscript list` | [tools.md](tools.md#simsscript) |
| NSOInterface | The client's windows and controls on raylib-swift, from CityLimits through cs2swift | [client.md](client.md) |
| Client | `newso`: shows a lot running, or runs it headless and logs it | [client.md](client.md) |
| TSOFilesCheck | `tsofiles-check`, which opens everything in each install and compares two | [tools.md](tools.md) |
| NSOOracle | `nso-oracle`, which runs `fso-oracle`'s experiments on NSOClient and reports whether the two agree | [tools.md](tools.md#nso-oracle) |
| ScriptOracle | `sso-oracle`, which runs SimsScript scenarios on both VMs | [tools.md](tools.md#sso-oracle) |

## How the code behaves

A few rules hold everywhere. Knowing them makes each package easier to follow.

- **Same results as FreeSO, not the same code.** Doc comments name FreeSO's type each Swift type
  corresponds to (for example, `Entity` ports `VMEntity`). Where results deliberately differ,
  the comment says so, and the scorecard lists the difference under "Known differences from FreeSO".
- **The libraries have no engine.** Only the client draws, takes input, or logs, and its drawing
  reads the simulation without changing it. The libraries decode to plain values and report through
  errors, so they test and run anywhere, the client's headless runs included.
- **Errors are values.** Readers throw typed errors (`FAR1Error`, `IFFChunkError`,
  `ContentError`, `SimAnticsError`) instead of crashing. Where FreeSO would read past the end of an
  array, NSOClient throws. Nothing in the libraries uses `try!`, `as!`, or `fatalError`.
- **Values, not singletons.** Archives and chunks are immutable `Sendable` values, often over
  memory-mapped bytes. FreeSO reaches content through a global `Content.Get()`; here a
  `GameContent` is created and passed in, so tests and tools can load several installs side by side.
- **Degrade gracefully on older installs.** Where the 2002 copy's or the beta's files differ from the
  New & Improved files FreeSO expects, NSOClient skips what doesn't fit, reports it, and keeps going. For example,
  a PIFF patch that doesn't fit an object is skipped, not fatal. [`install-differences.md`](../results/install-differences.md)
  records how the production and beta installs differ.
- **Deterministic simulation.** SimAntics uses wrapping 16-bit arithmetic, never iterates a
  `Dictionary` or `Set` where order matters, and keeps entities in object ID order. Two VMs given
  the same lot and seed stay in step, which lockstep multiplayer needs.

## Trying it

Every package builds and tests on its own:

```sh
swift test --package-path NSOClient/SimAntics
```

You need Swift 6, the X11 and GL headers on Linux for the client, and, for the comparisons with
FreeSO, the .NET 10 SDK. You don't need the game:
without it, the tests use [`NSOClient/MockInstall`](../../NSOClient/MockInstall/README.md), a tiny
made-up install, and the tests that need the real game are skipped. To run those too, set these
environment variables:

| Variable | Points at |
| --- | --- |
| `TSO_GAME_DIR` | The main install's `TSOClient` folder: the copy closest to FreeSO's files (1.1097.1.0 on the owner's machine) |
| `TSO_CLASSIC_DIR` | An older production copy's `TSOClient` folder, such as the 2002 one (1.145.1.0) |
| `TSO_BETA_DIR` | The 2002 beta's `TSOClient` folder |
| `NSO_USER_DIR` | NewSO's user folder, whose `Mods` folder holds a player's custom objects and patches (default: the OS's usual NewSO folder) |
| `FSO_CONTENT_DIR` | FreeSO's `Content` folder, for its patches and custom objects (default: beside the executable, else the FreeSO snapshot's) |
| `TSO_ORACLE_DIR` | A folder of FreeSO's records of the experiments, written by `NSOClient/scripts/oracle-fixtures.sh` (or `oracle-review.sh`), for the tests that compare NSOClient with FreeSO |

```sh
NSOClient/scripts/oracle-review.sh --mock /tmp/review     # both oracles on the mock install, as CI runs them
```

The snippets on these pages use the public API. Where a snippet needs an install, it assumes
`TSO_GAME_DIR` points at one.

## Compatibility

NSOClient matches FreeSO as of beta/update-46 (August 2017), the snapshot in
[`TSOClient/`](../../TSOClient/); [FreeSO's releases](../fso/releases.md) list what came before and
after it. Nothing newer is a target. In particular, FreeSO is rebuilding its server and client for
the self-hosting FreeSO Archive, and says modifications to the current software may need to be
refactored to work with them ([freeso.org/download](https://freeso.org/download/)). NewSO doesn't
follow that rework, so expect the Archive's server and client to be incompatible with NewSO, and
with content made for FreeSO before its server shut down in December 2024.
