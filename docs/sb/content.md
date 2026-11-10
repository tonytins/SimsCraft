# TSOContent: loading a game install

TSOContent turns a folder of game files into objects and globals the VM can run. It replaces the
parts of FreeSO's `Content` singleton that SimAntics needs: finding the install, indexing its
files, applying patches, and loading objects by GUID.

## Finding the install

`GameLocator` checks, in order, a configured folder, the `TSO_GAME_DIR` environment variable, and
the usual folders for the OS (on Linux, `$XDG_DATA_HOME/The Sims Online/TSOClient`, then
`game/TSOClient` next to the working directory). A folder counts as an install if it has an
`objectdata` folder in any letter case.

```swift
import TSOContent

let install = try GameLocator().locate()
```

A configured folder or `TSO_GAME_DIR` that isn't an install throws `ContentError.notAnInstall`
rather than falling through to a default, so a typo never loads a different install silently.
Unlike FreeSO, it doesn't read the Windows registry.

## Listing the installs

Tools, tests, and the client may check more than one copy of the game. `InstallKind` lists them
in one place: `game` (`TSO_GAME_DIR`), `classic` (`TSO_CLASSIC_DIR`), and `beta` (`TSO_BETA_DIR`),
in that order. `InstallKind.installs(in:)` returns the ones an environment names, leaving out unset
or empty values and keeping a folder named twice once. `GameVersion.read(install:)` reads the
version an install's `version` file records, in either known layout (`1.1097.1.0`, or the beta's
`major:1` lines), and throws on any other. FreeSO reads neither.

The `TSOConfig` product reads the same installs through
[swift-configuration](https://github.com/apple/swift-configuration), under the keys `tso.game.dir`
and so on, which its environment provider reads as `TSO_GAME_DIR`. It's a separate product so the
libraries don't take on swift-configuration, whose API needs macOS 15.

```swift
import Configuration
import TSOConfig

let installs = InstallKind.installs(in: ConfigReader(provider: EnvironmentVariablesProvider()))
```

## Content folders and mods

Beside the game, content comes from two more folders:

- **FreeSO's content folder**, `FreeSOContentLocator`: a configured folder, then the
  `FSO_CONTENT_DIR` environment variable, then `Content` beside the running executable (where
  FreeSO keeps it), then a fallback the caller gives (the tools and the client use the copy in the
  FreeSO snapshot). It holds FreeSO's shipped patches in `Patch`, a player's FreeSO patches in
  `Patch/User`, and custom objects in `Objects`, so content made for FreeSO works unchanged. A
  folder named on purpose that has neither `Patch` nor `Objects` is an error, not skipped.
- **Simburbia's user folder**, `UserFolderLocator`: a configured folder, then `SB_USER_DIR`, then
  the OS's usual place (`$XDG_DATA_HOME/Simburbia` or `~/.local/share/Simburbia` on Linux,
  `~/Library/Application Support/Simburbia` on macOS, `%APPDATA%\Simburbia` on Windows). Its `Mods`
  folder holds a player's custom objects in `Mods/Objects` and patches in `Mods/Patch`. It needn't
  exist.

`GameContent.Configuration(gameDirectory:freeSOContentDirectory:modsDirectory:)` loads them in
order. The mods' patches count as user patches, so they replace the shipped ones for the same
file, as FreeSO's `Patch/User` does. Custom objects load after FreeSO's, and one whose GUID is
already registered is left out and listed in `objects.duplicates`, so a mod can't silently replace
one of the game's objects. A custom object that can't be read is skipped and listed in
`objects.standaloneFailures`, and the rest still load, where FreeSO would fail to start. The
`TSOConfig` product reads both folders from settings too: `sb.user.dir` and `fso.content.dir`.

The loop for making an object works end to end: SimsScript compiles it to a standalone IFF
(`CompiledObject.objectFile`), it goes in `Mods/Objects`, and Simburbia loads it, with
`simsscript list` showing its routines.

## Loading content

`GameContent` holds one install's content. It indexes every file, loads the PIFF patches, and
registers every object up front. Object files, globals, and tuning load on first use and are kept.

```swift
let content = try GameContent(.init(gameDirectory: install,
                                    freeSOContentDirectory: repository.appendingPathComponent("FreeSO/TSOClient/tso.content/Content")))
```

The `freeSOContentDirectory` form uses FreeSO's layout: patches from `Content/Patch` and standalone
objects from `Content/Objects`. Use `Configuration(gameDirectory:patchDirectory:standaloneObjectDirectory:loadsSprites:)`
to set them separately, or leave both `nil` to load the game's files alone. Sprites stay unloaded
unless `loadsSprites` is set; a headless VM doesn't need them.

Nothing is global. Two `GameContent` values for two installs (say, the production copy and the
beta) can be loaded side by side.

### Files in any letter case

Installs mix letter case (`UIGraphics` beside `uigraphics`). FreeSO joins paths as written, which
works on Windows and fails on case-sensitive file systems. `GameFileIndex` looks every path up in
any case:

```swift
let url = content.files.url(for: "ObjectData/Objects/objiff.far")   // finds objectdata/objects/objiff.far
print(content.files.caseCollisions)                                 // paths that differ only in case
```

## Objects

`ObjectProvider` registers the objects listed in `packingslips/objecttable.xml` (all in
`objiff.far`) and every `OBJD` in FreeSO's standalone IFFs. Looking one up loads its IFF with
patches, tuning, sprites if enabled, and its semi-global. Every object in that IFF shares the one
loaded resource.

```swift
if let door = try content.objects.object(guid: 0x0000_01CA) {   // a door, in objiff.far's doors.iff
    print(door.definition.label, door.resource.name)            // the OBJD label, the IFF's name
    let main = try door.resource.chunk(BHAV.self, id: door.definition.bhavMainID)
    print(main?.instructions.count ?? 0)
    print(door.resource.patches.applied, door.resource.patches.skipped)
}
for reference in content.objects.references.prefix(5) {
    print(String(reference.guid, radix: 16), reference.fileName, reference.source)
}
```

A `GameObject` pairs the definition (`OBJD`) with its `ObjectResource`:

| Field | Holds |
| --- | --- |
| `mainFile` | The object's IFF, patched |
| `sprites` | The sprite IFF from `objspf*.far`, if sprites are loaded |
| `tuning` | The object's OTF, from the patches or beside the IFF, if there is one |
| `semiGlobal` | The semi-global the object's `GLOB` names, for shared code and tuning |
| `treesByName` | Routines by name, for Run Tree by Name: the object's, then its semi-global's |
| `patches` | Which PIFF patches applied and which were skipped |
| `tuningFailure` | Why the OTF failed to load, if it exists but did (FreeSO ignores this silently) |

`chunk(_:id:)` and `chunks(_:)` read from the main file (and the sprite file for sprite chunks), so
code asks for chunks without caring which file holds them.

Where FreeSO fails, this keeps loading and reports instead:

- A GUID listed twice keeps its first registration; the rest are in `objects.duplicates`.
- An entry whose IFF isn't in `objiff.far` throws `ContentError.missingFile` for that object only.
- The beta's object table has no display names, which FreeSO can't read; `Reference.name` is then `nil`.

When patches change an archived IFF, its objects are registered again from the patched file,
as in FreeSO, since a patch can add or remove definitions.

## Globals

`objectdata/globals` holds `global.iff`, which every object can call, and the semi-globals that
groups of objects share. `GlobalProvider` loads each by name (in any case) with its patches and
tuning:

```swift
let global = try content.global()                        // global.iff
let doorGlobals = try content.globals.resource(named: "DoorGlobals")   // doorglobals.iff, with doorglobals.otf
print(try doorGlobals.chunks(BHAV.self).count, doorGlobals.tuning != nil)
```

Both `GlobalResource` and `ObjectResource` conform to `IFFResource`, which is what SimAntics reads
code and tuning through: `chunk(_:id:)`, `chunks(_:)`, `tuningTable(id:)`, and `semiGlobal`.

## Walls and floors

`FloorProvider` and `WallProvider` port FreeSO's `WorldFloorProvider` and `WorldWallProvider`. They
aren't part of `GameContent`, since servers don't draw: the client makes them from the install's
file index. Each reads its catalog when it's made and parses a sprite when it's asked for.

```swift
let floors = try FloorProvider(files: content.files)
let walls = try WallProvider(files: content.files)
let carpet = try floors.floor(id: 256)          // far, medium, and near SPR2s, and the file with their palettes
let brick = try walls.pattern(id: 2)            // a wall pattern: SPR# with a frame per side
let fence = try walls.style(id: 2)              // a wall style's masks, with walls up and cut down
```

| IDs | Floors | Walls |
| --- | --- | --- |
| Global | 1 up, from `floors.iff`, named by `build.iff`'s floor strings | patterns 0 to 255 and styles 1 to 255, from `walls.iff` |
| Archives | 256 up, from `housedata/floors` to `floors4` | patterns 256 up, from `housedata/walls` to `walls4` |
| Others | 65534 (water) and 65535 (pool), catalog entries only; their tiles come from `globalSprite(id:)` | junction pieces, from `junctions()` |

Archive IDs follow FreeSO's order: each archive in turn, its IFFs in manifest order. An IFF that
doesn't read keeps its ID, so the ones after it keep theirs, and is listed in `failures`. An
archive the install doesn't have holds none, and is listed in `missingArchives`: the base game
and the beta have only the first of each. An unknown wall pattern from 256 up is drawn as the
first archive pattern, a tolerance FreeSO had.

On 1.1097.1.0 there are 234 floors (29 global) and 304 wall patterns with catalog entries; on the
base game and the beta, 169 and 221. `sb-oracle architecture` and `fso-oracle architecture` agree
on every ID on all three and on `MockInstall`.

## Interface graphics

`UIGraphicsProvider` ports FreeSO's: every FAR3 archive under `uigraphics`, by asset ID, the file
ID shifted up 32 bits and then the type ID, as FreeSO's `UIFileIDs` write them (TSO's loading and
login background, `setup`, is `0x3A300000001`). It also finds the handful of graphics FreeSO reads
from loose files, and the one ID it redirects.

```swift
let graphics = UIGraphicsProvider(files: content.files)
let setup = try graphics.image(id: AssetID(packed: 0x3A3_0000_0001))   // RGBA, 800 by 600
```

`image(id:)` decodes as FreeSO's `ImageLoader` does: a BMP, with its near-magenta pixels made
transparent, or a Targa with the 2.0 footer. Anything else, such as 1.1097.1.0's one PNG, is an
error. An ID two archives both hold keeps the first and is listed in `duplicates`; an archive
that can't be read is listed in `failures` (no install has either).

## Errors

Every failure is a `ContentError`:

| Case | When |
| --- | --- |
| `gameNotFound(searched:)` | No default folder is an install; lists the folders tried |
| `notAnInstall(path:)` | A configured folder or `TSO_GAME_DIR` has no `objectdata` |
| `missingFile(_:)` | A file the content needs doesn't exist |
| `invalidFile(path:reason:)` | A file exists but doesn't read or parse |
| `invalidObjectTable(_:)` | `objecttable.xml` is malformed |

A failed load isn't cached, so a later call tries again.
