# Tools

## tsofiles-check

`tsofiles-check` (the TSOFilesCheck package) is the first test of the file readers against a real
install. It opens every FAR1, FAR3, DBPF, and IFF file, reads every archive entry, and parses every
supported chunk, then reports counts and failures.

```sh
swift run --package-path Simburbia/TSOFilesCheck -c release tsofiles-check
```

### Which installs it checks

- **With a folder argument,** it checks that folder.
- **Without one,** it checks every install named by `TSO_GAME_DIR` (1.1097.1.0 since 2026-10-28;
  the base game before that), `TSO_CLASSIC_DIR` (the base game), and `TSO_BETA_DIR` (the 2002
  beta), in that order, as TSOContent's `InstallKind` lists them, read through `TSOConfig`.
  `--install game`, `classic`, or `beta` picks one, and can be repeated. Two variables naming the
  same folder check it once. Each install's header shows the version its `version` file records.
- **The differences file** is written only when exactly two installs are checked, such as
  `--install classic --install beta`.

Each folder must contain an `objectdata` folder, in any letter case. One that doesn't is reported
and skipped, and the other install is still checked.

### What it prints

For each install, a header and a summary:

```text
== TSO_GAME_DIR: /home/user/Applications/tso/TSOClient
FAR1: 13 files
FAR3: 47 files
DBPF: 7 files
IFF: 29 files
entries read: 84912 (IFFs inside archives: 1578)
chunks parsed: 50798 (BCON 784, BHAV 15906, ...)
other files: 1590
failures: 0
unreferenced chunks that don't parse (the game never loads them): 5
```

Failures name the file, the archive entry, and the chunk (`objiff.far: chairs.iff: TTAB #128`).
`--max-failures N` limits how many are listed (all are counted), and `--headers-only` opens archives
without reading entries. `--far1-variant a` reads The Sims 1's FAR layout.

Exit codes: 0 when everything reads, 1 when anything fails, 2 when a folder isn't an install or
can't be listed.

### The differences report, once

The first time it checks two or more installs, it compares each with the next newer one (the
beta, then the classic copy, then the game) and writes
[`docs/results/install-differences.md`](../results/install-differences.md) (or the path in `--differences`), one
section per step. After that it only says the file exists. Delete the file to compare again.

The report lists files only in one install, then, for each file that differs:

- **IFFs and archives of IFFs** (such as `objiff.far`): one row per IFF, with the chunks only in
  each install and those that changed, grouped by type, and the GUIDs of changed objects.
- **Other archives** (avatars, audio): counts of entries added, removed, and changed.

It holds names, sizes, chunk IDs, and GUIDs, never game data, so it can be committed. It's the
reference for backwards compatibility: when something behaves differently on the beta, check
there what the files change before calling it a bug in Simburbia.

## sb-oracle

`sb-oracle` (the SBOracle package) runs the experiments `fso-oracle` runs on FreeSO, on
Simburbia instead, and records the results in `fso-oracle`'s formats, so the two records can be
compared line for line. The comparison asks whether they agree, without assuming it: a
disagreement is a finding to explain, and a case one side couldn't measure is inconclusive.



| Command | Records |
| --- | --- |
| `list-objects` | What loads for every registered object: label, resource, semi-global, routine and tuning counts, entry points |
| `run-objects` | Each GUID on standard input run alone on an empty lot, with a state digest after creation and as it ticks |
| `run-lot` | One lot (`--blueprint`) loaded with its objects and run, with a state digest after loading and as it ticks; `--leave-out GUID` leaves out an object `fso-oracle` left out, and `--dump` adds every entity's digested fields |
| `run-primitive` | `fso-oracle`'s JSON requests on standard input, each on a freshly loaded lot (`--blueprint`, `--leave-out`), answered in its format: the lot as loaded, the exit code, registers, and every effect; `unsupported` where a primitive isn't ported |
| `room-maps` | Each blueprint path on standard input: its room maps and rooms |
| `study` | The randomized study (below): sampled objects on lots, a game day on both VMs, for a time budget |
| `compare` | Whether both sides' records agree, experiment by experiment, and with `--review FILE`, that install's section of the report written; `--strict` exits with an error on any disagreement |

Where Simburbia can't take a measurement yet, `run-objects` adds an `unsupported` line naming what
isn't ported; comparisons count those as inconclusive, ranked, so they show what to port next.
`run-lot` stops at the first tick that reaches something not ported, with `unsupported at tick
N by 0xGUID:`, naming the object that reached it, and what.

### The randomized study

`sb-oracle study` asks how objects behave over game time, without running every object of an
install. Until its time budget runs out (`--minutes`, five in a review), it builds lots: about
thirty objects both sides load (`--fso-objects`, from `fso-oracle list-objects`), picked by a seed
with those its ledger hasn't seen first, on a grid of a floor plan, each facing a direction the
seed picks. The floor plans (`--floor-plan`, repeatable) are lots emptied of their own objects,
and the seed picks one per lot: FreeSO's `empty_lot_fso.xml` by default, and in a review on a
real install, TSO's own job lots too, so objects meet real walls, counters, and doors. A plan
FreeSO can't read (TSO's `nightclub00_01.xml`) is dropped for the rest of the run. Each lot runs
a game day, with a digest every game hour:

1. On Simburbia first, since it's quick. An object that reaches something Simburbia doesn't
   support yet is recorded as such and set aside, and the lot runs again without it. If the
   object isn't one the lot names, it's mapped to the multi-tile object it belongs to, or found
   by halving the lot on Simburbia alone.
2. Then on FreeSO, through `fso-oracle run-lot`, and the digests are compared.
3. A lot that disagrees is halved, keeping every object's tile and facing, to the fewest objects
   that still disagree.

Every lot is kept as a blueprint in `--out/lots`, so it can be run again, and the records go to
`--out/study.tsv`, which `compare --study` reads. The ledger (`--ledger`; in a review,
`docs/results/sb-study-<install>.tsv`) keeps each object's latest result, so each run samples what
the last ones didn't. The seed defaults to the time, and is printed.

```sh
sb-oracle study --game "$TSO_GAME_DIR" --fso-objects /tmp/oracle/fso/objects.tsv --out /tmp/study --minutes 5
```

The study replaced running every object alone (`run-objects`, still here for one-off
questions), which took hours on a real install.


`Simburbia/scripts/oracle-review.sh [--review | --mock]` runs both oracles on every install it's
given (`TSO_GAME_DIR` as "production", `TSO_CLASSIC_DIR` as "classic", `TSO_BETA_DIR` as "beta") and compares them; `--mock` uses
`Simburbia/MockInstall` instead, as CI does, and stops on any disagreement (`compare --strict`) so a
person looks at it before the change goes in.
FreeSO's side comes from `oracle-fixtures.sh`. With `--review` it writes
[docs/results/sb-review.md](../results/sb-review.md); do that only after a phase of the roadmap,
since it reruns every object and primitive case. The same comparisons run as SBOracle's tests
against FreeSO's records, sharing the same code, so the checks and the report can't contradict
each other.

## sso-oracle

`sso-oracle` (`Simburbia/ScriptOracle`) runs experiments written in SimsScript. A scenario is a
small object with a header saying how long to run it and which object variables it should leave
(`@ticks`, `@expect`); see [its README](../../Simburbia/ScriptOracle/README.md).

- `check` compiles each scenario.
- `run` runs each on Simburbia's VM, as `run-objects` runs an object, and checks its expectations.
- `build DIR` writes each compiled object, and `scenarios.tsv`, for `fso-oracle run-scenarios`.
- `compare RECORDS` runs them on Simburbia's VM and sets the result beside FreeSO's records.

```sh
Simburbia/scripts/scenario-oracle.sh --mock     # build, run on FreeSO, compare; fails on any difference
```

Because both VMs run the same compiled bytes, a scenario pins down one behavior in a form anyone
can read. The first two cover SimAntics' 16-bit arithmetic, which FreeSO's VM confirms.

## simsscript

`simsscript list OBJECT` (`Simburbia/SimsScript`) prints an object's routines as SimsScript's
`Listing` writes them: one line per instruction, with routines, parameters, locals, attributes,
and constants named from the object's files, its semi-global, and the global file, and ported
primitives' operands in words. See [SimsScript's README](../../Simburbia/SimsScript/README.md).
Primitives Simburbia doesn't run yet still read in words: their operands are decoded, and
`fso-oracle operands` checks every field against FreeSO's own decoding.
