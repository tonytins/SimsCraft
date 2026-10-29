# The client: newso

`newso` is NewSO's client, in [`NSOClient/Client`](../../NSOClient/Client/). It loads a lot from an
install, runs it on SimAntics at TSO's 30 ticks a second, and shows it in a window. It doesn't play
the game yet: there are no Sims, no building, and no online play. It shows how far the libraries
have come, and it's the tool for watching a lot run.

```sh
swift run --package-path NSOClient/Client newso
```

On Linux the build needs the X11 and GL headers; [`AGENTS.md`](../../AGENTS.md) says where they come
from on the owner's machine.

## What it opens

Without `--game`, the install is `TSO_GAME_DIR`, then `TSO_CLASSIC_DIR`, then `TSO_BETA_DIR`
(TSOContent's `InstallKind` lists them), then [MockInstall](../../NSOClient/MockInstall/README.md),
so it runs anywhere. Without `--lot`, the lot is the owner's house
([`NSOClient/Lots`](../../NSOClient/Lots/)) on a real install and the mock lot on MockInstall. Objects
the install doesn't have, or can't load, are left out and reported, as `fso-oracle` leaves them out.

It also loads FreeSO's content folder and NewSO's mods (`FSO_CONTENT_DIR` and `NSO_USER_DIR`; see
[content.md](content.md#content-folders-and-mods)). A custom object or patch that can't be read,
or a custom object whose GUID is taken, becomes a system message in MOMI and counts as an error in
the top bar.

## The window

The lot is drawn through raylib's 3D camera at TSO's view: looking down 30° from the horizon, at a
45° angle, with TSO's three zooms (near, medium, far) and two farther ones. Roadmap decision 7
explains why a 3D camera rather than FreeSO's 2D batches.

- **Objects** draw with their sprites, placed as FreeSO's `DGRPRenderer` places them. Each pixel
  has its depth from the sprite's depth frame, made global as FreeSO's `2DWorldBatch` shader does
  (Hyde Park's E2). So objects cover each other, and the walls, pixel by pixel: a television's
  screen shows in front of its own body, and a cut-down wall hides the base of what stands
  behind it. A GPU that can't compile the depth shader gets the sprites back to front instead.
- **Walls, floors, and the ground** are flat shapes for now, colored by kind. The walls of the floor
  in view are cut down so the rooms show, as TSO does. Floors and the ground are drawn a little
  back and down, as FreeSO draws its floors, so the feet of objects standing on them show.
- **An object without a sprite** for the view is drawn as a box.

| Input | Does |
| --- | --- |
| Space | Pause and resume |
| 1 to 3, or the speed arrows | Normal, fast, and fastest speed (1, 3, and 10 times) |
| Q and E | Rotate the view a quarter turn |
| Mouse wheel | Zoom |
| Right-drag | Pan |
| Page Up and Page Down | Change the floor in view |
| W | Show walls whole, or cut down |
| Click an object | Inspect it |
| Escape | Close the open window |

The interface follows the owner's prototype mockup ([`NSOClient/mockups`](../../NSOClient/mockups/README.md)),
which also serves as NewSO's fallback and debug interface:

- **The top bar** shows the lot, the speed, the game time, the floor in view, the object count, a
  red error count when there are errors, and a help button.
- **Help** lists the keys.
- **MOMI**, opened from the error count, shows NewSO's system messages: for now, each error a
  thread reported, in words. MOMI was TSO's in-universe name for its game masters. Its input stays
  disabled until there's online play.
- **The inspector** shows a clicked object: what it is, where it is, and what it's running.

The windows and controls come from the owner's CityLimits through cs2swift, in
[`NSOClient/NSOInterface`](../../NSOClient/NSOInterface/); `interface-demo` there shows them on their own.

## Without a window

Three options run the lot without anyone at the screen.

- **`--screenshot FILE`** opens a hidden window, runs `--ticks` ticks (300 by default), saves one
  frame, and quits. `--zoom` (1 to 5), `--focus x,y`, and `--rotation` (0 to 3) frame the shot.
- **`--headless`** opens no window at all and needs no display, after CityLimits' headless run. The
  lot runs `--ticks` ticks back to back, as fast as the machine allows: a game day (216,000 ticks)
  by default, a game week at most. It logs to standard error and exits.
- **`--verbose`** logs the same as a headless run while the window is open.

A run's log, through swift-log, has the lot and the install's version, each system message as it
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

## How it's built

The client is two targets:

- **`LotScene`**, without raylib, works out what to show: the lot's geometry, which sprites go
  where, the inspector's lines, the system messages, the run's log lines, and the session that
  ticks the VM. Its tests run without a window.
- **`newso`**, the executable, draws with [raylib-swift](https://github.com/tonytins/raylib-swift),
  takes input, and logs. Only it imports raylib or swift-log.

The rendering reads the VM's state and never changes it, so what's drawn can't affect the simulation.
