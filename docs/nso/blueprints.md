# Blueprints

**Design, settled 2026-10-29.** Reading is built (`Blueprint` in SimAntics); writing and NewSO's sections aren't yet.

A blueprint is a lot as an XML file: its walls, floors, objects, and more. It's how TSO shipped
its job lots, how FreeSO saves and shares lots, and how NewSO will save, share, debug, and test
them. This page describes the two dialects in use and proposes how NewSO reads, writes, and
extends them.

## Two dialects

**TSO's dialect** is Maxis' own. 1.1097.1.0 ships 23 blueprints in `housedata/blueprints/` (the
nightclub, restaurant, and robot factory job lots, 2004) and the format's definition beside them,
`blueprint.dtd`. The 2002 copy and the beta have none. It's written for people to read:

- a `<revision>` with author, date, and change number, from Maxis' version control;
- comments naming each section ("0-parent objects", "Level 0 Floors");
- each object's `name` ("Portal - NPC"), and `hidden="1"` on the objects not meant to be seen;
- sections FreeSO dropped: a flag layer per level, puddles (`<water>`), and the lot's sounds.

**FreeSO's dialect** is whatever FreeSO's `XmlHouseData` (`tso.world/model/XmlHouse.cs`) writes:
only what it reads. Objects are GUIDs and coordinates, with no names, no `hidden`, no flags, no
puddles, no revision, and no comments, plus XML Schema namespaces on the root. The owner's house
(`NSOClient/Lots/tonys-house.xml`) is in it, which is why it's hard to read: knowing what's on the
lot means looking up 211 GUIDs.

TSO's files also say where Maxis meant to take the format. `housedata/default_house.xml`, which
lists the objects every new lot starts with, ends:

> At some point, it would be great to have sections for walls, floors, and so on
> We would also like to be able to store general object data, attributes, temps, and other relevant fields

## The decision

NewSO reads, writes, and extends TSO's dialect, as Maxis intended. FreeSO's dialect is read-only:
NewSO loads FreeSO's lots, and saves them in TSO's dialect. (Owner, 2026-10-29.)

## TSO's dialect

From `blueprint.dtd`, checked against the 22 job lots that parse:

| Element | Holds | Notes |
| --- | --- | --- |
| `house` | `version` | "1.0" in every file |
| `revision` | `author`, `date`, `change` | Perforce keywords, such as `$Author: sperrine $` |
| `size` | The lot's width in tiles | 64 in every file |
| `category` | The lot category | 0, 9, 101, 102, 103 |
| `world/flags/layer` | `level`; 4,096 comma-separated numbers, one per tile | One per level. Meaning unknown: neither FreeSO nor NewSO reads them. Common values 6, 7, 38, 39, and 1 look like bit fields (**Unverified**) |
| `world/floors/floor` | `level`, `x`, `y`, `value` | Levels 0 and 1 |
| `world/walls/wall` | `level`, `x`, `y`, `segments`, `placement`, `tls`, `trs`, `tlp`, `trp`, `blp`, `brp` | As FreeSO reads them |
| `world/pools/pool` | `x`, `y`, `value` | |
| `world/water/puddle` | `x`, `y`, `value` | 2,554 across the lots; FreeSO doesn't read them |
| `sounds/sound` | `id`, `on` (0 or 1) | 858 across the lots |
| `objects/object` | `guid`, `name`, `group`, `x`, `y`, `level`, `dir`, `hidden` | Without `x` and `y`, the object is out of the world (controllers) |

Where the files and the DTD disagree, the files win:

- **Object levels** are 1 and 2 in the files; the DTD says 0 or 1. Floors and walls use 0 and 1.
- **One file is broken.** `nightclub00_01.xml` has a stray `<` before its level 1 flag layer, so
  it isn't well-formed XML. FreeSO's reader would fail on it too.
- **The encoding** is ISO-8859-1, with CRLF line ends and a `DOCTYPE` naming `blueprint.dtd`.

## Reading

One reader for both dialects, since FreeSO's is TSO's with parts missing.

- **Everything the dialect has is read,** including names, `hidden`, flags, puddles, sounds, and
  the revision, even before the simulation uses them. A save then keeps them.
- **Unknown parts are kept.** An element or attribute the reader doesn't know (a later NewSO's
  section, or a mod tool's) is carried through to the next save unchanged, and reported.
- **What SimAntics has no part in, the client applies.** TSO forked from The Sims before its
  blueprints grew `hidden` and the rest, so SimAntics knows nothing of them: `hidden="1"` hides an
  object in the client (`LotSession.hiddenByBlueprint`) and never touches the VM, whose results
  stay FreeSO's.
- **Broken files are errors,** with one tolerance: a `<` followed by whitespace, which is never
  valid XML, is dropped, so `nightclub00_01.xml` loads. TSO's launcher ran its patcher first, so
  players likely never had the broken copy, but it's what the install holds, and the reader says
  so in its doc comment. Any other file that isn't well-formed throws, and a scan or load
  reports it and goes on.
- **The `DOCTYPE` is ignored,** never fetched: the file names a DTD by path, and reading must
  never reach outside the file.

## Writing

NewSO writes TSO's dialect, as Maxis did: the revision (NewSO's version and the date), a comment
per section, each object's name, and `hidden` where it's set. Elements come in the DTD's order.
Writing a blueprint read from TSO and reading it back gives the same lot, and keeps what NewSO
doesn't understand.

## Extending

Maxis' two wishes become optional sections. A blueprint without them is a lot as it starts; one
with them is a lot as it was saved.

- **Object state.** Each object can carry its object data, attributes, and temps, and whatever
  else a save needs (its thread, slots, relationships, as the simulation grows).
- **The lot's state.** The global values, the clock, and the random seed.

### Versions

NewSO's sections are marked with one element, `<newso version="1" />`, after the `revision`.
Maxis' `version="1.0"` keeps meaning Maxis' layout. The rule is CityLimits' 2.0 one, from the
start rather than added later:

- **Sections are named, not counted.** New state comes as a new element, never a new attribute on
  an existing one, so it can be kept or left out whole. XML names its own elements, so there's no
  features list.
- **The version is a major number only,** and moves only for a change an older NewSO can't safely
  skip, such as a new kind of tile. A blueprint with a newer major is refused with a message,
  such as "this is NewSO blueprint 2; this version reads up to 1".
- **A section that's missing starts fresh,** so a blueprint without any (TSO's own, or FreeSO's)
  is a lot as it begins.
- **A section that's unknown is kept,** unread, and written back exactly as it came, and the load
  reports it. CityLimits drops one instead; NewSO keeps it, as AGENTS.md's "keep what you don't
  understand" asks, and XML makes that cheap.
- **No upgrade steps until one is needed.** The first breaking change brings the first. FreeSO skips elements it doesn't know, so it can still open a NewSO blueprint as a fresh
lot (**Unverified**; one oracle test would check it).

## Scenarios

A blueprint with state is a scenario: a lot set up a particular way. Add expected results, as
SimsScript's `@expect` does for objects, and it's a test case, after SimCity's scenarios as
CityLimits uses them. The job lots, the owner's house, the made-up lots `make_blueprints.py`
writes, and hand-made ones all become the same kind of file, and the oracles run them all.

## Settled (owner, 2026-10-29)

1. **Versions:** NewSO's own marker, with CityLimits' 2.0 rule from the start (see Versions).
2. **The broken nightclub:** tolerated.
3. **Flags and puddles:** kept and written back, and worked out only when something needs them.
4. **Object levels:** written as the files have them, 1 and 2 for objects and 0 and 1 for floors
   and walls, not as the DTD says.
