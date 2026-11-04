# The client: simburbia

`simburbia` is Simburbia's client, in [`Simburbia/SBClient`](../../Simburbia/SBClient/). It loads a lot from an
install, runs it on SimAntics at TSO's 30 ticks a second, and shows it in a window. It doesn't play
the game yet: there are no Sims, no building, and no online play. It shows how far the libraries
have come, and it's the tool for watching a lot run.

```sh
swift run --package-path Simburbia/SBClient simburbia
```

On Linux the build needs the X11 and GL headers; [`AGENTS.md`](../../AGENTS.md) says where they come
from on the owner's machine.

## What it opens

Without `--game`, the install is `TSO_GAME_DIR`, then `TSO_CLASSIC_DIR`, then `TSO_BETA_DIR`
(TSOContent's `InstallKind` lists them), then [MockInstall](../../Simburbia/MockInstall/README.md),
so it runs anywhere. Without `--lot`, the lot is the owner's house
([`Simburbia/Lots`](../../Simburbia/Lots/)) on a real install and the mock lot on MockInstall. Objects
the install doesn't have, or can't load, are left out and reported, as `fso-oracle` leaves them out.

It also loads FreeSO's content folder and Simburbia's mods (`FSO_CONTENT_DIR` and `SB_USER_DIR`; see
[content.md](content.md#content-folders-and-mods)). A custom object or patch that can't be read,
or a custom object whose GUID is taken, becomes a system message in MOMI and counts as an error in
the top bar.

## Loading

The window opens on a loading screen at once, as TSO's does, while the install and the lot load
on another thread; the session is handed to the window once, when it's ready. The screen is the
install's own loading art, TSO's `setup` graphic (New & Improved's, or the 2002 copies'), scaled
to the window's height and centred on TSO's dark blue (`#09182F`), as FreeSO's `UISetupBackground`
draws it; without one, as on MockInstall, it's Simburbia's logo. Under it, a caption
and lines that slide in from the right one after another, as FreeSO's `LoadingScreen` slides them:
each takes a second and comes in only when loading has reached its share, so the screen shows
for at least four seconds. The text is TSO's own when there's an install (the caption is table
154's entry 5, the lines table 155's entries 6 to 9, read with Hudini's `CSTCatalog` from
`gamedata`), else Simburbia's (`Interface/uitext/_1_loading.cst`).

Loading reports its progress: the install's content, its floors and walls, the lot and its first
tick, then the textures of what's in view, which the client makes by drawing a frame off screen
so the lot doesn't stutter as it appears. Half a second after the last line settles, the lot
appears. `--loading-screenshot FILE` saves a frame of the screen as its second line slides in.

## The window

The lot is drawn through raylib's 3D camera at TSO's view: looking down 30° from the horizon, at a
45° angle, with TSO's three zooms (near, medium, far) and two farther ones. Roadmap decision 7
explains why a 3D camera rather than FreeSO's 2D batches.

- **Objects** draw with their sprites, placed as FreeSO's `DGRPRenderer` places them. Each pixel
  has its depth from the sprite's depth frame, made global as FreeSO's `2DWorldBatch` shader does
  (Hyde Park's E2). So objects cover each other, and the walls, pixel by pixel: a television's
  screen shows in front of its own body, and a cut-down wall hides the base of what stands
  behind it. A GPU that can't compile the depth shader gets the sprites back to front instead.
- **Hidden objects** aren't drawn or picked: portals, the mailbox's second part, and other
  controllers hide themselves through object data 34, as FreeSO reads it, and TSO's job lots
  also mark theirs `hidden="1"` in the blueprint. That's the lot format's, not SimAntics': the
  client applies it, and the VM never sees it.
- **Floors** are textured tiles, as update-46's `_3DFloorGeometry` draws them. Each floor's sprite
  is a texture that repeats across the lot: a tile's diamond takes its part of it, and the
  sprite's corners, filled from half a frame away when it's decoded (FreeSO's `FloorCopy`),
  carry the neighboring tiles' halves. Pools and water take one of 16 shapes from the tiles
  beside them and stay upright on screen as the view turns. Floors are opaque, and texels
  under half alpha aren't drawn. Pool corners aren't drawn, as update-46's 3D floors don't.
- **Walls** are sprites, as update-46's `WallComponent` draws them: each side and diagonal takes
  its pattern, masked by its style (a full wall, a cut-down one, a fence), turned with the view,
  and placed from its tile's top corner on screen. Each pixel's depth comes from FreeSO's
  generated gradients, so walls and objects hide each other where they should. Full-height
  walls are capped where they stop, and junction pieces cover where they meet. Doors and windows
  cut their openings with wall styles made from their own sprites, as FreeSO's
  `VMGameObject.PositionChange` makes them. Diagonal tiles draw their two floor halves.
- **Wall modes** are TSO's, for the floor in view; floors below keep their walls up. Cutaway, the
  default, cuts walls down in front of the last three indoor rooms the pointer was over and
  around the pointer, slanting them where the cut ends (FreeSO's `GenerateRoomCut` and
  `ApplyCutRectangle`); down cuts every wall down, leaving a door's wall out; up leaves them
  standing. W steps through them, and `--walls cutaway|down|up` picks one to start with. A
  screenshot has no pointer, so its cutaway follows the middle of the screen, which `--focus` sets.
- **The ground** is a flat shape for now; grass waits. Floors and the ground are drawn a little
  back and down, as FreeSO draws its floors, so the feet of objects standing on them show. If
  the install's floors or walls can't be read, they're drawn as plain tiles and boxes, and MOMI
  says why.
- **An object without a sprite** for the view is drawn as a box.

| Input | Does |
| --- | --- |
| Space | Pause and resume |
| 1 to 3, or the speed arrows | Normal, fast, and fastest speed (1, 3, and 10 times) |
| Q and E | Rotate the view a quarter turn |
| Mouse wheel | Zoom |
| Right-drag | Pan |
| Page Up and Page Down | Change the floor in view |
| W | The next wall mode: cutaway, down, up |
| Click an object | Inspect it |
| Escape | Close the open window |

The interface follows the owner's prototype mockup ([`Simburbia/mockups`](../../Simburbia/mockups/README.md)),
which also serves as Simburbia's fallback and debug interface:

- **The top bar** shows the lot, the speed, the game time, the floor in view, the object count, a
  red error count when there are errors, and a help button.
- **Help** lists the keys.
- **MOMI**, opened from the error count, shows Simburbia's system messages: for now, each error a
  thread reported, in words. MOMI was TSO's in-universe name for its game masters. Its input stays
  disabled until there's online play.
- **The inspector** shows a clicked object: what it is, where it is, and what it's running.

The windows and controls come from [Hudini](https://github.com/tonytins/Hudini), the owner's
interface library for raylib-swift, which grew out of the NSOInterface package this repository
used to have. Its `hudini-demo` shows them on their own. Simburbia's colors are
`InterfaceTheme.simburbia`, for now Hudini's standard palette.

The top bar and the Help, MOMI, and inspector windows are described in Hudini's UIScript XML, in
[`Simburbia/Interface/`](../../Simburbia/Interface/): `topbar.xml`, `help.xml`, `momi.xml`, and
`inspector.xml`. Each says where its controls go, what fixed text they hold, and their colors;
the client fills in what changes (the lot, the time, the messages, the object) and draws what
UIScript has no control for (the speed arrows and the round help button, in regions the document
places). Each window's document is its content, under the title bar Hudini's `WindowFrame` draws.
The client reads them when its window opens: one that's missing, doesn't read, or lacks a control
the client uses (`InterfaceDocuments.required`) stops it with a message naming it. Moving a
control, or rewording the help, is an edit to a document, with no rebuild. The format is close to
TSO's own `.uis` screens, which Hudini also reads.

## Without a window

Three options run the lot without anyone at the screen, and a fourth rewrites its blueprint.

- **`--screenshot FILE`** opens a hidden window, runs `--ticks` ticks (300 by default), saves one
  frame, and quits. `--zoom` (1 to 5), `--focus x,y`, and `--rotation` (0 to 3) frame the shot.
- **`--headless`** opens no window at all and needs no display, after CityLimits' headless run. The
  lot runs `--ticks` ticks back to back, as fast as the machine allows: a game day (216,000 ticks)
  by default, a game week at most. It logs to standard error and exits.
- **`--verbose`** logs the same as a headless run while the window is open.
- **`--rewrite-blueprint FILE`** writes the lot's blueprint in TSO's own dialect, with every object
  named, and quits without running it: how a lot saved by FreeSO becomes one people can read
  ([blueprints.md](blueprints.md)). It can name its own lot (`--lot`) to rewrite it in place.

A run's log, through swift-log, has Simburbia's version, the lot and the install's version, each system message as it
arrives, a line each game hour, and a summary. Every line is stamped with the tick and the game
time, never the clock, so two runs of the same lot log alike:

```text
info: tick 1, 0:00: lot tonys-house, install .../TSOClient (1.1097.1.0)
info: tick 9000, 1:00: 319 entities, 6 errors so far
info: tick 216001, 0:00: ran 216000 ticks, 1 day of game time; 319 entities, 8 errors
```

Options that need a window are refused with `--headless`, and `--ticks` is refused outside
`--headless` and `--screenshot`.

## Time

TSO counts 150 ticks a game minute, as FreeSO sets it in TSO mode. At 30 ticks a second, a game
minute lasts 5 real seconds, a game hour 5 minutes, and a game day 2 hours at normal speed. A
headless run of the owner's house covers a game day in about 9 seconds.

## Versions

`simburbia --version` prints Simburbia's version, which the owner's GitVersion plugin works out
as the client builds: the base in [`Simburbia/GitVersion.txt`](../../Simburbia/GitVersion.txt)
(`0.1.100`), plus each commit since that touches `Simburbia/`, after the .NET SDK's
`major.minor.1xx` feature bands. The branch and commit follow it (`0.1.103+main.1a2b3c4d5e6f`), and `.dirty`
when the working tree has staged changes. A build needs the whole history: a shallow clone fails
on purpose, since its count would be wrong.

## Packages

`Simburbia/packaging/` builds the client into packages players download, so it runs without
`swift run`: an AppImage and a `.tar.gz` on Linux, and, once they've been tried on those systems,
a zip on Windows and an app on macOS ([its README](../../Simburbia/packaging/README.md)). A
packaged client finds its lots and the mock install beside itself (in `Contents/Resources` in the
Mac app), and a build run from the repository finds them in `Simburbia/`.

## How it's built

The client is two targets:

- **`LotScene`**, without raylib, works out what to show: the lot's geometry, which sprites go
  where, the inspector's lines, the system messages, the run's log lines, and the session that
  ticks the VM. Its tests run without a window.
- **`simburbia`**, the executable, draws with [raylib-swift](https://github.com/tonytins/raylib-swift),
  takes input, and logs. Only it imports raylib or swift-log.

The rendering reads the VM's state and never changes it, so what's drawn can't affect the simulation.
