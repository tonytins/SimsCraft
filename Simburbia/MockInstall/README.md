# Mock install

**Nothing in this folder is from The Sims Online.** It's a tiny, made-up install, for testing
only. Every object, routine, wall, floor, and name in `TSOClient/` was written for SimsCraft's
tests, and none of it comes from, or stands for, EA's game data. It can't be played.
`GameData/` holds the mock Sim to come, Kenney's CC0 character (see [its README](GameData/README.md)).

It exists so tests and CI can run without a copy of TSO: point `TSO_GAME_DIR` at `TSOClient/` here,
and anything that reads an install (`tsofiles-check`, TSOContent, the SimAntics VM) reads this one
the same way.

```sh
TSO_GAME_DIR=Simburbia/MockInstall/TSOClient swift run --package-path Simburbia/TSOFilesCheck tsofiles-check
```

## What's in it

It follows the layout of a real install, with only what the content system needs:

| File | Holds |
| --- | --- |
| `packingslips/objecttable.xml` | The four objects below, by GUID |
| `packingslips/catalog.xml` | Their catalog entries (made-up prices; the parts aren't for sale) |
| `objectdata/objects/objiff.far` | `mockchair.iff`, `mocktable.iff`, `mocklamp.iff`, `mockregister.iff`, and `mocksim.iff` |
| `objectdata/objects/objspf.far` | `mockchair.spf`: made-up sprites for the `sprites` comparison (a palette, `SPR2` versions 1000 and 1001 using every run command, `SPR#` in both byte orders, and `DGRP` versions 20000, 20001, and 20004). DGRP 0 is the chairs' own (base graphic 0 plus graphic 0), with near images for north and east, so the client draws them. Two cover edge cases: `SPR#` #201 is big-endian version 1001, which FreeSO misreads (DIFF-26), and `SPR2` #102 has alpha 40, past the 5 bits the field holds, which FreeSO and Simburbia both wrap to 73 |
| `objectdata/globals/global.iff` | One global routine (256) that returns true, and the Sim's walk (`STR#` 150) and swim (`STR#` 158) animation names, made up |
| `tuning.dat` | The global tuning a Sim's motives read, made up: `lotmotives` (a weight of 1 for every lot category and motive) and `simmotives` (small decay rates, 16 waking hours) |
| `avatardata/skeletons/skeletons.dat` | A FAR3 holding `adult.skel`, a made-up skeleton of one bone (`ROOT`), laid out as 1.1097.1.0's is |
| `objectdata/globals/mockglobals.iff` | The objects' semi-global: one routine (8192) that returns true |
| `objectdata/globals/build.iff` | The build catalog's strings: five wall styles (`STR#` 0x81), two floors (0x82), three wallpapers (0x83), and pool and water (0x85). There's one more wallpaper than floors, as in the real tables, since FreeSO counts the global floors from the wallpaper strings (DIFF-29) |
| `objectdata/globals/walls.iff` | Wall styles 1 (wall), 2, 12, 13, and 14 (fences, banister), and 7 and 8 (the cutaway styles), with cut-down masks for 1, 7, and 8; patterns 1 to 3 (plaster, brick, blue paint), 248 to 251 (the fences' own), and 252 and 253 (the cutaway overlays); and the 46 junction pieces. Each sprite has the four sides FreeSO draws, at its sizes for each zoom |
| `objectdata/globals/floors.iff` | Floors 1 (straw, standing in for grass) and 2 (planks), 16 pool tiles at each zoom with their corners, and 16 water tiles with a depth layer FreeSO turns into alpha: 255 inside the diamond and 0 outside, written for every pixel, since a transparent run's depth of 255 would turn opaque black |
| `housedata/walls/walls.far` | Two archive wall patterns, 256 (`mockstone.wll`) and 257 (`mockpanel.wll`) |
| `housedata/floors/floors.far` | Two archive floors, 256 (`mocktile.flr`) and 257 (`mockcarpet.flr`). Like the base game, the mock has no `walls2` to `walls4` or `floors2` to `floors4` (DIFF-30) |

| GUID | Object | Notes |
| --- | --- | --- |
| `0x4D4F4301` | Mock Chair | A one-tile object |
| `0x4D4F4302` | Mock Table | A multi-tile master (master ID 1) |
| `0x4D4F4303` | Mock Table (left) | Its part at offset (0, 0) |
| `0x4D4F4304` | Mock Table (right) | Its part one tile along x |
| `0x4D4F4305` | Mock Lamp | A one-tile object whose main runs a routine by name |
| `0x4D4F4306` | Mock Register | A one-tile object whose main moves money |
| `0x4D4F4307` | Mock Sim | A one-tile person (object type `person`) whose main counts runs in attribute 0. Its body strings (`STR#` 200, `BodyStringID`) make it an adult named Mock Sim |

The GUIDs spell `MOC` followed by a number, so they can't be mistaken for a real object's.

Every object shares two routines. Init (`BHAV` 4097) lets it stand on floor or bare ground at
floor height (object data 42 and 4). Main (`BHAV` 4096) counts its runs in attribute 0. Each
object uses the `mockglobals` semi-global.

The lamp's main is its own instead. It makes the lamp the stack object, then uses Run Tree By
Name with string table 300 (`STR#` 300: "mock tree", "no such tree") to run "mock tree" (`BHAV`
4098, which adds 1 to attribute 1) on its own stack and on the stack object's, to look up the name
it doesn't have, and to push "mock tree" as a subroutine.

The register's main is its own too. It makes itself the stack object, then uses Transfer Funds
to be paid 100 by the game, pay 30 back, and fail to pay 1,000, each waiting a tick for its
answer, and puts its cash in TempXL 0, which it copies to attribute 2. Objects on a blueprint lot
all have persist ID 0, which FreeSO resolves to the lowest-numbered object, so on the mock lot
the money moves in and out of object 1, and alone on a lot it's the register's own.

The Sim has what FreeSO needs to create one, all made up: its body strings (type, outfits left
empty for FreeSO's default, name, gender, age, and skin tone), an adult skeleton in a FAR3 archive,
the motive tuning in `tuning.dat`, and the global walk and swim animation tables. FreeSO creates
and runs it; Simburbia doesn't run Sims yet, so it reports the Sim's setup as unsupported, and the
oracles count it as not measured until Queen Margaret's fourth pass.

`Lots/mock-lot.xml` is a made-up lot for it: a closed 3 by 3 room with floor, a chair out of
the world, a chair in the room, two tables outside (one facing south, with a group ID), the lamp in the
room, the register in the room, and one GUID the install doesn't have, which both oracles leave out.
`Lots/mock-lot-sim.xml` is the same lot for a Sim, which joins it as a player joins a lot (both
oracles' `run-lot --sims 1 --sim-template 4D4F4307`) rather than being in the blueprint. The lot has
no mailbox, so the Sim arrives on tile 3,3, the join's fallback; the chair that stands there on
`mock-lot.xml` stands on 4,4 here instead. Keep 3,3 free on this lot. On `mock-lot.xml` the chair
still takes 3,3, so a Sim joining there stays out of the world, as FreeSO's join leaves it. The lots
are kept apart so the Sim, which Simburbia can't set up yet, doesn't stop the primitive cases and
the lot run on `mock-lot.xml` from being measured; Simburbia's side of the Sim's lot counts as not
measured until Queen Margaret's fourth pass sets Sims up (phase B).

`fso-oracle` reads it too: its game overlay adds placeholders for what FreeSO loads and
Simburbia doesn't (audio, tuning, the missing wall and floor archives, and so on). CI runs both oracles on
it and reports whether they agree:

```sh
Simburbia/scripts/oracle-review.sh --mock /tmp/oracle
TSO_GAME_DIR="$PWD/Simburbia/MockInstall/TSOClient" TSO_ORACLE_DIR=/tmp/oracle/mock/fso swift test --package-path Simburbia/SBOracle
```

## Changing it

The files are kept as they are, not generated. Add to them as tests need: another object, a
chunk type, a quirk to cover. Update the tables above when you do, and keep everything made up.

`generators/` keeps the scripts that made some of the files, to show how they were built:
`mock_sim.py` gave the Sim its body strings, animation names, skeleton, and tuning, and
`mock_build.py` wrote the walls and floors. Each ran once
on the committed files and refuses to run again on files it has already patched, except
`mock_build.py`, which writes only the files that are missing, so deleting one remakes it. The script that
made `objspf.far` wasn't kept.
