# SimAntics oracle

`fso-oracle` runs FreeSO's SimAntics VM (FreeSO beta/update-46, August 2017) headless on modern
.NET, and records how it behaves: one side of the experiments that test whether Simburbia behaves
like FreeSO (roadmap decision 2, the West Darrington milestone). It compiles FreeSO's SimAntics, Files, Content, LotView, HIT, and
Vitaboy sources unchanged: `SnapshotSources.props` links them read-only from
`TSOClient/`, and nothing under `TSOClient/` is ever edited.

Its Swift counterpart, `sb-oracle` (`Simburbia/SBOracle`), runs the same experiments on
Simburbia and records the results in the same formats. Neither side is the answer key: comparing
the two records asks whether they agree, and a disagreement is a finding to explain, which may
turn out to be Simburbia's bug, FreeSO's quirk, or a deliberate difference.
`Simburbia/scripts/oracle-review.sh` runs both and, with `--review`, writes the report,
`docs/results/sb-review.md`.

The experiments must be repeatable: the same install, inputs, and seed give the same records.
Where FreeSO's own code isn't, the oracle makes the smallest change that makes it so, and says
which below (lot loading, and money transactions' timing). One change is of runtime rather than
of FreeSO: TSO's own blueprints (1.1097.1.0's job lots, and FreeSO's `empty_lot.xml`) name
`blueprint.dtd` in a DOCTYPE, which FreeSO's `XmlHouseData.Parse` read on .NET Framework 4.5 but
.NET since Core refuses outright, so the oracle drops the DOCTYPE, unread, before FreeSO's reader
sees the lot.

## Running it

```sh
dotnet run --project Simburbia/FSO.Oracle -c Release -- run-lot --ticks 1800 --every 300
```

It reads the game from `TSO_GAME_DIR` (or `--game`), loads a lot from blueprint XML
(FreeSO's `empty_lot_fso.xml` by default), ticks it, and prints one line per digest:

```text
tick 0 seed 0f50d0c5eed00001 entities 12 digest daa28213a5e94dc0fc7678d346b6f691998fae08a839aadfe49d795303d78700
```

Standard output carries only results. FreeSO's own messages (such as
`Failed to get Object ID`) are sent to standard error.

Options: `--game`, `--content` (FreeSO's `Content` folder), `--blueprint`,
`--seed`, and for `run-lot`, `--ticks`, `--every`, and `--dump` (after each digest,
the digested fields of every entity, one line each, for finding where two runs part).
Run without arguments for help.

Runs are repeatable: the same install, blueprint, seed, and tick count give the
same digests. That takes one change to how FreeSO loads a lot. The lot server sends a
`VMBlueprintRestoreCmd`, whose `VMWorldActivator.LoadFromXML` replaces the VM's context,
and a new `VMContext` seeds itself from an unseeded `System.Random`; every random draw
while the lot's objects are created, and on the tick the load runs in, would differ from
run to run. `LotLoader.cs` is a copy of the command and the activator, in the same order,
that seeds the new context as soon as it's made. After that tick, the seed is set again,
so the first digest starts from `--seed`.

Money needs one more change. The VM runs with FreeSO's standalone global link
(`VMTSOGlobalLinkStub`), which settles a Transfer Funds transaction at once but sends its
answer from a new `System.Threading.Thread`, so the tick the answer arrives on depends on
thread timing. `SynchronousGlobalLink.cs` is the same stub with that one call made on the
calling thread, so the answer always arrives on the next tick, as the background thread almost
always did.

## Sprites: `sprites`

FreeSO's content loads object sprites only when there's a graphics device, so `sprites` opens
them itself: each `objspf*.far` under the install, as TSO's FAR 1b, and each IFF in it in name
order. It decodes every `SPR2` and `SPR#` frame and reads every `DGRP` with FreeSO's own
readers, and prints one tab-separated line for each, keyed by entry, chunk type, chunk ID, and
frame (`-` for a `DGRP`):

| Chunk | Then |
| --- | --- |
| `SPR2` | width, height, x, y, palette, flags, and FNV-1a 64 hashes of the RGBA and the depth bytes (`-` when the frame has none) |
| `SPR#` | width, height, palette, and the RGBA hash |
| `DGRP` | the image count and the hash of a listing of its images (`SpriteDump.DrawGroupListing`) |

A frame or file that throws prints `error` and the exception's type, and a chunk that throws
while being read prints the same with `-` for its frame; chunks are read one at a time, so one
that throws doesn't hide the rest. `sb-oracle sprites` prints the same from Simburbia, and
`compare` reads both as `sprites.tsv`. Differences Simburbia makes on purpose are listed in
SBOracle's `KnownDifference` and counted as such, not as disagreements.

## Walls and floors: `architecture`

`architecture` asks FreeSO's wall and floor providers (`Content.WorldWalls`, `Content.WorldFloors`)
for every ID the lot view can ask for, and prints which sprite chunk each zoom gets, as a chunk ID
and frame count (`1537:4`), or `-` for none. One tab-separated line each:

| Line | For | Then |
| --- | --- | --- |
| `floor ID` | each floor catalog entry | its file (`global` for the global ones), the far, medium, and near sprites, then their pixels |
| `floor-sprite ID` | each pool (0x400 to 0x43F) and water (0x800 to 0x80F) sprite there is | the sprite, then its pixels |
| `wall ID` | patterns 0 to 255, then each archive pattern | its file, the far, medium, and near sprites, then their pixels |
| `style ID` | styles 1 to 255 | the full masks at each zoom, then the cut-down ones, then their pixels |
| `junctions -` | the junction pieces | the far, medium, and near sprites, then their pixels |

An ID that throws prints `error` and the exception's type. Catalog names and prices aren't
printed, since Simburbia reads some from other strings on purpose (the scorecard's DIFF-29).
The pixels are each frame of the line's sprites as FreeSO decodes it to draw (a floor's with
its sprite's `FloorCopy` and `ZAsAlpha` set as the providers set them): the size, then the
FNV-1a 64 hash of its RGBA (`128x64:0123abcd...`), comma-separated. `sb-oracle
architecture` prints the same from TSOContent's providers, and `compare` reads both as
`architecture.tsv`.

## Sims on a lot: `run-lot --sims`

`run-lot --sims N` (and `run-primitive --sims N`, before each request's fresh lot, so requests can
name the Sims as the caller or stack object) brings N made-up Sims onto the lot after it loads, the
way a player joins one:
FreeSO's `VMNetSimJoinCmd`, as the lot server runs it when an avatar arrives (`SimJoin.cs`). They
join inside a tick, and then the VM is seeded again, so the first digest starts from the seed.

Each Sim is the person template (`VMAvatar.TEMPLATE_PERSON`, or the object `--sim-template`
names, such as MockInstall's Mock Sim, `4D4F4307`), with an identity made up here and no player's
or city's data: Sim `n` is "Oracle Sim n", persist ID `0x0AC1E000 + n`, a visitor (so FreeSO's
roommate bookkeeping doesn't run), male, skin tone 0, in FreeSO's default suits, with every motive
and persisted skill at 0, and no relationships, jobs, or budget. Setting the template is the one
change: a static FreeSO left open, not a file under `TSOClient`.

The join places a Sim by the lot's mailbox (`VMFindLocationFor`), or without one at tile 3,3. If
that tile is taken, FreeSO tries nowhere else, and the Sim stays out of the world, as on
`mock-lot.xml`, whose chair stands at 3,3.

The review scripts join Sims to the lots `lot_sims` (in `Simburbia/scripts/oracle-lots.sh`)
names, recorded in `lots.run`'s second and third columns: MockInstall's `mock-lot-sim.xml` gets its
Mock Sim. `sb-oracle` takes the same options and joins the same way (SimAntics' `VM.joinSim`).
TSO's own placing of players on 3,3 after a job is a memory of the game, **Unverified**: FreeSO uses
3,3 only for this fallback, and every job lot in 1.1097.1.0 has a mailbox.

**Repeatable:** checked 2026-11-04. FreeSO's Sim setup takes randomness only from the seeded
context (the only other unseeded `Random`s are in EOD plugins an idle Sim doesn't reach), and two
runs give the same digests at every point: the owner's house with one Sim over 1,800 ticks on
1.1097.1.0, and `mock-lot.xml` with two over 900. To check again:

```sh
for run in 1 2; do fso-oracle run-lot --blueprint Simburbia/Lots/tonys-house.xml --sims 1 --every 300 >/tmp/sims-$run.txt; done
diff /tmp/sims-1.txt /tmp/sims-2.txt && echo repeatable
```

## The state digest (version 1)

SHA-256 over little-endian values, in this order:

1. the VM's random seed (64 bits);
2. the entity count (32 bits);
3. for each entity, in object ID order:
   object ID (16), object GUID (32), tile x (16), tile y (16), level (8),
   direction (8), the object data count (32) and values (16 each), the thread's
   stack depth (32), then each frame's routine ID (16) and instruction pointer (16);
4. and after a Sim's stack only (a `VMAvatar`), since version 1:
   - the person data count (32, FreeSO's 101) and values (16 each);
   - the motive count (32, 16) and values (16 each);
   - the animation count (32) and each animation, then whether there's a carry animation (8)
     and it if so: the name's UTF-8 length (32) and bytes, the current frame and the speed as
     32-bit float bits, whether it plays backwards, loops, and has ended (8 each), and how many
     events it has run (8);
   - the action queue's length (32) and each action: its routine ID (16), the callee's object ID
     (16, 0 for none), interaction number (32), priority (16), mode (8), ID (16), and whether it's
     cancelled (8).

Version 1 changes nothing for other entities, so a lot without Sims has the same digest in both
versions. Frames and speeds are compared as float bits, so animation has to match FreeSO's
floating point exactly. `--dump` adds a Sim's fields to its line: `person=... motives=...
animations=name@frame,... carry=name@frame (or -) queue=routine:callee:priority,...`.

The Swift port (SimAntics' `StateDigest`) must compute the same digest from the same state. Until
it runs animations and the queue (phases C and D), its Sims write none of either. Bump the version
when fields are added again.

## Single primitives: `run-primitive` (protocol version 1)

```sh
dotnet run --project Simburbia/FSO.Oracle -c Release -- run-primitive < requests.jsonl
```

Loads the same lot as `run-lot` (`--blueprint`, FreeSO's empty lot by default), then reads
JSON requests from standard input, one per line, and writes one JSON response per line. Blank lines and lines starting
with `#` are skipped. Each request runs on a freshly loaded lot, so requests never
see each other's effects. [Examples/expression.jsonl](Examples/expression.jsonl)
has annotated examples.

The oracle calls the primitive's FreeSO handler directly, the way
`VMThread.ExecuteInstruction` does. The handler runs on a one-instruction routine
whose frame is pushed onto the caller's thread, with the caller as the callee and
code owner. The oracle reports the exit code but doesn't act on it: no branching
and no scheduling.

Request fields (only `opcode` is required; unknown fields are rejected):

| Field | Meaning | Default |
| --- | --- | --- |
| `id` | any JSON value, echoed back | none |
| `opcode` | primitive opcode, 0 to 255 | |
| `operand` | operand bytes as in the BHAV, hex, up to 8 bytes; padded with zeros | all zeros |
| `caller` | object ID of the caller | the lowest object ID on the lot |
| `stackObject` | stack object ID | 0 (none) |
| `seed` | the VM's random seed, hex | `--seed` |
| `temps`, `tempXL` | up to 20 temps and 2 extended temps; the rest are 0 | all 0 |
| `locals`, `args` | the frame's locals and arguments | none, and four 0 arguments |
| `globals` | `{"index": value}` to set before running | |
| `currentTick` | the scheduler's current tick | the loaded lot's |
| `idleStart`, `interrupt` | the caller thread's idle start tick (`ScheduleIdleStart`) and interrupt flag | the loaded lot's |
| `clock` | `{"hours": h, "minutes": m, "minuteFractions": f}` (0 to 149 fractions a minute) to set the game clock | the loaded lot's clock |
| `objects` | `{"objectID": {"data": {"index": value}, "attributes": {"index": value}, "list": [values], "direction": d}}` to set before running; `list` replaces the whole list, and `direction` (0 north to 7, clockwise) sets the facing without snapping it to the rotation step. A Sim also takes `"person": {"index": value}` and `"motives": {"index": value}`, set through its accessors (`SetPersonData`, `SetMotiveData`, so their special cases and limits apply), and `"motiveChanges": {"motive": [perHour, max, ticked]}`, set exactly; giving any of them for an object that isn't a Sim is a request error | |
| `propertyCategory` | the lot's category (`VMTSOLotState.PropertyCategory`), 0 to 255 | the loaded lot's |

Response fields:

| Field | Meaning |
| --- | --- |
| `protocol`, `id` | the protocol version (1) and the request's `id` |
| `primitive` | the primitive's name in FreeSO |
| `exit` | the exit code name, such as `GOTO_TRUE` or `CONTINUE_NEXT_TICK` |
| `exception` | instead of `exit`, if the handler threw: `Type: message` (FreeSO resets the thread when this happens) |
| `noPrimitive` | `true` if FreeSO has no primitive for the opcode; it then counts as `GOTO_TRUE` |
| `temps`, `tempXL`, `locals`, `args`, `stackObject`, `seed` | the values after running |
| `thread` | what the primitive changed on the caller's thread: `idleStart`, `interrupt`, and `scheduledTick` (the tick it's scheduled to run next, `ScheduleIdleEnd`) |
| `lot` | every object on the lot before running, in object ID order: `[objectID, guid, category, registered, x, y, level, direction, objectData, attributes, footprint, slots]`, where `registered` says whether the object is listed under its category (FreeSO lists an object once its category is set), `direction` is FreeSO's compass flag, `objectData` all 80 values, `footprint` the object's rectangle `[x1, y1, x2, y2]` or `null`, and `slots` the ID in each container slot (0 for empty), so a test can rebuild the lot |
| `groups` | the objects that share a group, or came from a multi-tile master, each `[multiTile, masterGUID, objectIDs]` in the group's own order; `masterGUID` is `null` without a master |
| `lotSize` | the lot's width and height in tiles |
| `sims` | every Sim before running, in object ID order: `[objectID, personData, motives, motiveChanges]`, with all 101 person data and 16 motives as the accessors read them, and each motive change as `[perHour, max, ticked]` (its fraction isn't compared) |
| `callerGUID`, `stackObjectGUID` | the GUIDs (8 hex digits) of the caller and the requested stack object, so a test can build the same objects |
| `frames` | stack frames from the request's frame up; more than 1 means the primitive pushed one |
| `globals` | `{"index": value}` for each global the primitive changed |
| `objects` | for each object the primitive changed: changed `data` and `attributes` entries, the whole `list` if it changed, and the new `position` (`[x, y, level]`) and `direction`; for a Sim, also changed `person` and `motives` entries and each changed motive change, as `"motiveChanges": {"motive": [perHour, max, ticked]}` |
| `created`, `removed` | object IDs added to or taken off the lot |
| `requestError` | instead of all of the above, if the request couldn't be run, such as malformed JSON or an object not on the lot |

`objects` and `globals` hold only the primitive's effects: the requested state is
applied first, and the difference is taken from there.

[check_protocol.py](check_protocol.py) runs the examples and checks the responses. It's
a regression check for the oracle itself; run it after changing the oracle:

```sh
python3 -I Simburbia/FSO.Oracle/check_protocol.py
```

Responses depend on the install, so generated records must not be committed.

Not covered yet: avatars (the default lot has none, so person data, motives, and
relationships can't be tested), and state outside the fields above, such as
contained objects and object lists.

## Single objects: `run-objects`

```sh
cut -f1 objects.tsv | dotnet run --project Simburbia/FSO.Oracle -c Release -- run-objects --ticks 30 --every 10
```

Reads object GUIDs (hexadecimal) from standard input, one per line. For each, it loads the
lot with every object taken out, creates the object out of the world as
`VMContext.CreateObjectInstance` does (running its init), and prints
`guid tick N seed S entities E digest D` (digest version 0) after creation (tick 0), every
`--every` ticks, and at the end. It prints `guid missing` if FreeSO can't create the object and
`guid error Type` if creating or ticking throws; the full exception goes to standard error.

`sb-oracle run-objects` runs each object the same way, and SBOracle's tests compare every line.
Objects that reach behavior Simburbia doesn't have yet are counted by what stopped them, which
ranks what to port next.

## SimsScript scenarios: `run-scenarios`

```sh
swift run --package-path Simburbia/ScriptOracle sso-oracle build /tmp/scenarios
dotnet run --project Simburbia/FSO.Oracle -c Release -- run-scenarios --scenarios /tmp/scenarios
```

Runs the objects `sso-oracle build` compiled from SimsScript scenarios. It links FreeSO's content
folder into a temporary one whose `Objects` folder also holds the scenario objects, which FreeSO
loads as standalone objects. Each is then run as `run-objects` runs an object: an empty lot,
the object created out of the world (running its init), and the ticks `scenarios.tsv` gives it.
It prints `name guid attributes a=1 b=2`, the attributes named as the scenario names them, which
is the form `sso-oracle run --records-only` prints; `name guid missing` if FreeSO can't create
it; or `name guid error Type` if creating or ticking throws. FreeSO suppresses an exception inside
an object's thread and resets the object, so such an error doesn't show in the record.

`Simburbia/scripts/scenario-oracle.sh` builds, runs, and compares (`sso-oracle compare`).

## Operands: `operands`

```sh
dotnet run --project Simburbia/FSO.Oracle -c Release -- operands > operands.tsv
```

Reads every instruction of a primitive Simburbia decodes but doesn't run yet (the opcodes in
`OperandDump.cs`, which must match SimAntics' `PrimitiveTable.unportedOperands`; an SBOracle test
checks) in the install's `objiff.far` and `objectdata/globals`, with the operand class FreeSO
registers for it in TSO mode. Each line is the entry, BHAV ID, instruction index, opcode, and the
operand's public numeric, enum, and boolean fields and properties as `Name=value`, in name order.
`sb-oracle operands` prints the same from Simburbia's decoders, and the comparison checks every
field Simburbia decodes; FreeSO's derived properties (flags read as booleans) aren't compared.

## Rooms: `room-maps`

```sh
cat blueprints.txt | dotnet run --project Simburbia/FSO.Oracle -c Release -- room-maps > rooms.jsonl
```

Reads blueprint XML paths from standard input, one per line. For each, it loads the lot as
`run-lot` does and prints one JSON line:

| Field | Value |
| --- | --- |
| `file` | the blueprint's file name |
| `size` | the lot's width and height in tiles |
| `maps` | each level's room map (`VMRoomMap.Map`), ground floor first: one number per tile, across then down |
| `rooms` | every room after FreeSO's unused room 0, each `[id, lightBaseRoom, floor, isOutside, area, isPool, adjacentRooms, [x, y, width, height], supportRooms]`; `floor` is 0 for the ground floor, and `adjacentRooms` is in FreeSO's iteration order |

If loading throws, the line is `{"file":…,"error":Type}` and the full exception goes to standard
error. One of TSO's own does: `nightclub00_01.xml` has a stray `<` FreeSO's reader stops at, which
Simburbia tolerates, so the comparison counts it as answered where FreeSO failed. TSO's job lots
are read from the install (`housedata/blueprints`), never copied here. FreeSO's blueprints have floors but no walls, so `Simburbia/SimAntics/OracleCases/make_blueprints.py`
writes synthetic ones (no game data) with walls, fences, diagonals, pools, and upper floors. The
SBOracle's tests read each blueprint with the Swift `Blueprint` and compare every field.


Each line also has `scores`: each room's score (`GetRoomScore`) by room ID from 0, with the lot's
objects in it. `sb-oracle room-maps` writes the same when given an install, and `compare` checks
scores only where both sides have them. Room score is low priority: it moves with object decay.
## Content: `list-objects`

```sh
dotnet run --project Simburbia/FSO.Oracle -c Release -- list-objects > objects.tsv
```

Loads every object registered at startup through FreeSO's content system and prints one
tab-separated line per GUID, sorted by GUID:

| Result | Fields after the GUID (8 hex digits) |
| --- | --- |
| loaded | the `OBJD` label, the resource name (a standalone object's path relative to the content folder, such as `Objects/3TileClock.iff`, so records from different checkouts compare), the semi-global (lower-case file name without extension, or `-`), the number of routines by name, the number of BHAVs, the number of tuning tables, and the entry point table a FreeSO entity builds (`condition:action` pairs, comma-separated, or `none`) |
| no `OBJD` with the GUID | `missing` |
| loading threw | `error` and the exception type; the full exception goes to standard error |

SBOracle's tests compare each line with what Simburbia's content system loads.

## FreeSO's records, for the comparisons

`Simburbia/scripts/oracle-fixtures.sh` builds the oracle and runs every experiment on FreeSO,
writing its records into one folder (by default `$TMPDIR/fso-oracle-fixtures`): `objects.tsv` from
`list-objects`, `lots.digests` from `run-lot` on each lot
with objects (and `lots.leftout`, the objects it left out), for each ported primitive its cases
from `Simburbia/SimAntics/OracleCases/make_cases.py` with their `run-primitive` responses, and
`rooms.jsonl` from `room-maps` on the synthetic blueprints in `blueprints/` and the repository's
lots. `--mock` uses `Simburbia/MockInstall` and its lots instead of `TSO_GAME_DIR`; the cases are
then written for the mock lot, leaving out any that set up an object it doesn't have. SBOracle's
tests run the same experiments on Simburbia and check that the two still agree:

```sh
Simburbia/scripts/oracle-fixtures.sh /tmp/oracle
TSO_ORACLE_DIR=/tmp/oracle swift test --package-path Simburbia/SBOracle
```

`Simburbia/scripts/oracle-review.sh` uses the same script for FreeSO's side of the review. The
records depend on the install, so don't commit them. To look into one primitive case, run its
request line through both oracles' `run-primitive` and compare the two responses.

## How it stands in for FreeSO's build

Four kinds of help, each kept as small as possible:

| Part | Why |
| --- | --- |
| `Stubs/MinaIoBuffer.cs` | A working `IoBuffer` with the members the sources call. FreeSO's Mina.NET fork isn't checked out. |
| `Stubs/MonoGameFork.cs` | C# 14 extension members for what stock MonoGame 3.8 lacks: XNA 4.0's `Color.TransparentBlack` and the fork's `RenderTarget2D.InheritDepthStencil`. |
| `Stubs/GlobalUsings.cs` | Resolves `Color` to XNA's, which FreeSO's build saw without ambiguity. |
| `Stubs/Ninject.cs`, `Stubs/MP3Player.cs` | Names the VM never uses at run time. |

Two files are left out (`Base64JsonConverter.cs`, `MP3Player.cs`) because they need
libraries the oracle doesn't reference. Stock MonoGame DesktopGL supplies the XNA
types; no window or graphics device is ever created.

## Older installs: the game overlay

FreeSO was built against TSO's New & Improved files. An older install, such as the
beta, lacks some files and has a different shape for others, and FreeSO's
content system stops on both. `GameOverlay` builds a temporary folder of links to
the install, adds placeholders or adapted copies only where needed, and reports
each one on standard error:

- empty sound groups for `relationships`, `tsov3`, and `turkey` (the VM runs
  without audio);
- empty wall and floor expansion archives (`walls2` to `walls4`, `floors2` to
  `floors4`);
- `packingslips/objecttable.xml` and `catalog.xml` copies with display names
  filled in from file names, since the beta's tables have none;
- for an install with only what Simburbia reads, such as `Simburbia/MockInstall`: empty
  tuning, audio archives with one track, sound groups, a data definition, and an empty
  `cities` folder (and, where the install has none, wall and floor globals with build-mode
  string tables and the first wall and floor archives; MockInstall has its own since 2026-11-04);
- blueprint objects the install doesn't have, or that FreeSO can't load (such as one whose FreeSO patch doesn't fit the install, or a Sim whose avatar FreeSO can't build because the install has no skeletons, as on MockInstall), are left out of the lot and reported.

The install is never written to. FreeSO's user data (such as the sandbox
ban list) goes to a scratch folder inside the overlay, which is deleted on exit.

## Keeping it current

If the list of FreeSO projects or their files changes, regenerate the source list:

```sh
python3 -I Simburbia/FSO.Oracle/generate_sources.py
```

AGENTS.md allows `dotnet` for this project only.
