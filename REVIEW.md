# Review Guide

Use this when reviewing a change to SimsCraft, by a person or an agent. Read
[CLAUDE.md](CLAUDE.md) for the project's rules and [AGENTS.md](AGENTS.md) for agents' own. One
person maintains SimsCraft, so a review is often the only other pair of eyes a change gets.

## Before reviewing

- Read the change's description, its diff against where it started, and the code and tests it
  affects, including callers in Simburbia's other packages.
- Work out what the change is meant to do and check it does that. For a bug fix, check it fixes
  the cause, everywhere the cause reaches.
- Check what ran: the packages' builds and tests, the install scan, the oracle comparisons, and
  CI. Run focused checks where you can, and say which you couldn't run.

## What failure looks like in SimsCraft

| Area | Look for |
| --- | --- |
| Reading files | A truncated, corrupt, or hostile file (an archive, a chunk, a blueprint, a mod) traps instead of throwing; a size or offset from a file is used before it's checked; a reader that throws leaves something half done; unknown data is dropped without a report, or bad data is quietly replaced. |
| The simulation | Results that could differ between machines: a `Dictionary` or `Set` iterated in VM logic, the clock read, randomness not from the VM's seed, 16-bit arithmetic that doesn't wrap, floating point feeding state. One entity's error escaping into others. |
| Fidelity to FreeSO | A change to behavior real content relies on, without a known difference recorded in the scorecard. Differing from FreeSO is fine on its own: FreeSO is a witness, not the answer key. |
| Formats Simburbia writes | A blueprint, save, or other file that an older Simburbia can no longer read, a new section an older build can't skip, or a version that isn't raised for a change that can't be skipped; parts a rewrite should have carried through dropped. |
| The client | raylib called outside the window's lifetime or off the main thread; rendering that writes simulation state; a library that imports raylib; an interface document missing a control the client uses; a package that doesn't carry its files. |
| The oracles | An experiment that isn't repeatable; an inconclusive case counted as agreement; a disagreement hidden rather than triaged; a change to FreeSO's snapshot. |
| Docs and records | The scorecard, roadmap, or `docs/` saying something the code no longer does; a result claimed that wasn't measured. |
| Data and licences | The game's data committed; a dependency added without a reason, or one whose licence doesn't fit. |

## Not worth a finding

- Style alone. Formatting and naming are the guidelines' concern, and a change matching the code
  around it is fine.
- Speculative refactors, and missing tests with no concrete risk behind them.
- Process details CLAUDE.md doesn't mark strict, such as a doc comment that doesn't name its FreeSO type.
- FreeSO's snapshot itself (`TSOClient/` and the folders beside it), which is never edited; any
  change to it is a finding.
- Build output (`.build/`, `dist/`, `bin/`, `obj/`), unless a change tracks it.
- Bad input in a test that's meant to be rejected: check it's rejected as intended.

## Writing findings

Start with how many findings there are, such as `2 findings` or `0 findings`. Then say what was
reviewed, which checks ran and what they showed, and what remains uncertain. A clean review isn't
proof the change is right.

Give each finding a short title, the file and line, what triggers it, what goes wrong, and what
that leads to. Gather repeats of one cause into one finding, with the other places it shows. Keep
open questions apart from verified findings, and order findings by impact:

- **Blocking:** the build breaks, a package's tests fail, game data or the snapshot is changed, or
  normal use fails badly and unavoidably.
- **High:** a reader traps on bad input, the simulation stops being deterministic, a format
  stops being readable by older builds, or an existing behavior or common flow breaks.
- **Medium:** a limited but real defect in behavior or reliability.
- **Low:** a small edge case, or an improvement that shouldn't block the change.

## Reviewing again

- Check earlier findings are fixed or answered, and don't repeat ones that are. Look at what's
  new and what it touches.
- After three rounds of review and fixes on one change, sum up what's still open and ask whether
  the approach should change, rather than going round again.
- When the same feedback keeps coming back, suggest a rule in `CLAUDE.md` or a check that
  catches it.

Adapted from AmtrakStatus' review guide and NVFlare's
([NVIDIA/NVFlare](https://github.com/NVIDIA/NVFlare)).
