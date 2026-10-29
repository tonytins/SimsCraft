---
name: raylib-swift
description: How SimsCraft's client uses raylib-swift (raylib 6.0 from Swift) for its window, its frame loop, the camera, textures, render textures, text, and input, how the NSOInterface package and its cs2swift translation from CityLimits fit in, and how to check a visual change without the owner's desktop. Use this whenever you write, review, or debug code that imports Raylib, touches NSOClient/NSOInterface, the client, or interface-demo, adds or draws an asset, syncs CityLimits' interface, or verifies something on screen, even if the request never says "raylib".
---

# raylib-swift in SimsCraft

SimsCraft's client draws with [raylib-swift](https://github.com/tonytins/raylib-swift),
the owner's own binding, which builds raylib `6.0` from source and adds a Swift layer
over its C API. This skill is how that library is used here. `AGENTS.md` holds the
project's rules and wins wherever the two disagree. It grew out of CityLimits'
`raylib-cs` skill, since much of the client comes from CityLimits.

## 1. Check the API before you use it

raylib's API changes between releases (`IsTextureReady` became `IsTextureValid`, and
`IsRenderTextureValid` and `IsFontValid` follow it), and the web docs and raylib's
`master` track the latest, not the pinned version.

- **The vendored header is the authority.** After a build, raylib-swift's checkout is
  under the package's `.build/checkouts/raylib-swift/`. Its `RAYLIB_VERSION` names the
  version, and `Sources/CRaylib/raylib/raylib.h` declares every function. Search it for
  `RLAPI .* <Name>(` before calling something you haven't seen in this codebase.
- **What Swift sees differs from the header in three generated places**, all in that
  checkout:
  - `Sources/CRaylib/include/CRaylib.apinotes` renames every enum case (`KEY_LEFT_SHIFT`
    is `KeyboardKey.leftShift`, `FLAG_WINDOW_RESIZABLE` is `ConfigFlags.windowResizable`).
    The C names don't exist in Swift.
  - `Sources/Raylib/Generated/Overloads.swift` holds the overloads that take `Int` (and
    the typed enums) where raylib takes a C `int`.
  - `Sources/Raylib/Generated/Colors.swift` holds the colors (`Color.rayWhite`).
- **raylib's C examples at the matching tag are the reference.** Clone raylib into your
  scratch directory at tag `6.0` and read the example closest to what you're writing
  (section 9 has the index). Read it; don't build it or copy it into the tree. The
  examples are zlib-licensed. Learn the shape, then write SimsCraft's own Swift.

  ```sh
  git clone --depth 1 --branch 6.0 https://github.com/raysan5/raylib.git <scratch>/raylib
  ```

- **Swift shapes.**
  - raylib's structs are C structs: build them with every field labelled
    (`Rectangle(x: 0, y: 0, width: 10, height: 10)`, `Color(r: 1, g: 2, b: 3, a: 255)`),
    or `Rectangle()` for all zeros.
  - Functions are global and keep raylib's names (`DrawText`, `IsKeyDown`); there's no
    `Raylib.` prefix as in Raylib-cs.
  - **Integers.** Pass `Int`: the overloads clamp it to `Int32`. A function whose only
    `int` is its result (`GetScreenWidth`, `GetCharPressed`, `GetFPS`) still returns
    `Int32`, so write `Int(GetScreenWidth())`. Mixing an `Int` and an `Int32` in one call
    picks no overload and fails to compile. Convert one side.
  - **Enums and flags.** `IsKeyPressed(.escape)`, `IsMouseButtonDown(.left)`,
    `SetConfigFlags([.windowResizable, .vsyncHint])`. Enum cases are imported open, so a
    `switch` over one needs `@unknown default`.
  - **Vectors** have operators (`a + b * 2`, `v / 2`, `+=`) and `.zero`, `.one`; `Vector2`,
    `Vector3`, `Rectangle`, and `Color` are `Equatable`. raymath is there too
    (`Vector2Length`, `Clamp`).
  - **Strings** pass straight to `const char *` parameters. A `const char *` result is
    `UnsafePointer<CChar>!`; read it with `String(cString:)` at once, since raylib reuses
    the buffer.
  - **Pointers.** A `T *` parameter takes `&value` (`ImageDrawPixel(&image, x, y, .red)`).

## 2. Where raylib is allowed

| Place | raylib? |
|---|---|
| `NSOClient/NSOInterface`, and the client packages that come after it | yes |
| `TSOFiles`, `TSOFilesC`, `TSOContent`, `SimAntics`, `SimsScript` | never: no dependency, no import, no call |
| The tools and oracles (`tsofiles-check`, `nso-oracle`, `sso-oracle`), and a future headless lot server | never. A raylib call there opens a window, or loads native code a server may not have |

If you can't decide something without raylib, it belongs in the client. If something
can be decided without it, it belongs in a library, behind a test. Which wall a Sim can
see is the VM's to work out; how that wall is drawn is the client's.

## 3. The lifecycle

The order matters, because textures need the OpenGL context that `InitWindow` creates.
`NSOClient/NSOInterface/Sources/interface-demo/main.swift` is the model:

1. `SetConfigFlags(...)`, before the window.
2. `InitWindow(width, height, title)`.
3. `SetTargetFPS(60)`.
4. Load every texture, font, and render texture **once**, here, after `InitWindow`.
   Never load inside the frame loop.
5. The frame loop, while `!WindowShouldClose()` and nothing has asked to quit.
6. Unload what step 4 loaded (`UnloadTexture`, `UnloadRenderTexture`, `UnloadFont`),
   then `CloseWindow()` last.

Give anything that owns GPU memory an owner that unloads it explicitly before
`CloseWindow`. Don't leave it to a `deinit`: nothing orders a deinit before the window
closes, and unloading after `CloseWindow` is undefined.

## 4. The shape of a frame

Every frame is bracketed, or the window stays black because the buffer is never
presented:

```text
BeginDrawing
  ClearBackground
  BeginMode3D(lotCamera)   world space: the lot, Sims and sprites sharing the depth buffer
  EndMode3D
  the interface, in screen space: windows, panels, notices
EndDrawing
```

- **World first, then the interface.** Anything between `BeginMode3D` and `EndMode3D`
  moves with the camera (section 5 has why the lot uses a 3D camera). Windows and controls
  are drawn after `EndMode3D`, in screen pixels. A flat 2D view, such as a map screen, uses
  `BeginMode2D` and `NSOInterface.Camera` the same way.
- **Updates before the draw.** Read input and advance the simulation, then draw. Drawing
  only reads state. Rendering never writes the simulation's state.
- **Don't allocate in the frame loop.** raylib's structs are values, so they're free. A new
  array, a `String` built by interpolation, a closure, or a dictionary per object per
  frame is not. Keep buffers in properties and reuse them, and build text once when it
  changes, as `WindowFrame` caches its shortened title.
- **No blocking.** No `sleep`, and no waiting on a file or a task in the loop. Load in the
  background and hand results over, or load before the loop.

## 5. Textures, sprites, and render textures

TSO draws lots from sprites (`SPR2`) and 3D meshes, not a tile sheet; how FreeSO does it
is in `docs/fso/rendering.md`.

### How a lot is drawn (roadmap decision 7)

- **One 3D pass, one depth buffer.** The lot is drawn through a `Camera3D` set up for the
  isometric view, not `Camera2D`. Sims are skinned models and objects, walls, and floors are
  sprites on quads, all in the same `BeginMode3D`, so depth sorts them: a Sim on a couch is
  hidden behind its front edge. The interface still goes on top, after `EndMode3D`.
- **Sprite depth is made global.** An SPR2's depth bytes are local to that sprite. Turn them
  into world depth the way FreeSO's `vsZSprite` does (`tso.content/ContentSrc/Effects/2DWorldBatch.fx`):
  from the draw group's `ObjectOffset` (`tso.files/formats/iff/chunks/DGRP.cs`), in a shader
  that writes the fragment's depth. Without it, a quad gets one depth, and neighboring
  sprites seam. `newso` does this in `SpriteDepth`: sprites stay flat on the screen, drawn
  after `EndMode3D` with the depth test on, and each pixel's depth runs from its tile's far
  corner toward the viewer (`LotScene.depthLine`), projected with the 3D pass's own matrices.
- **Floors sit just behind the sprites on them.** TSO's depth art puts the feet of some
  objects a little behind the floor they stand on. FreeSO draws its 3D floors and terrain a
  little back and down for this (`TerrainComponent.Draw`), and `newso` does the same
  (`SpriteZoom.floorBias`). Without it, table feet and chair legs are cut off. Walls get no
  bias, so a cut-down wall in front of an object correctly hides its base.
- **Pre-composite per state and direction.** Build an object's textures for every graphic
  state and direction when it's loaded, so a state change never stalls a frame. Which
  states an object cycles through comes from its BHAVs, which the VM runs.
- **Sims are built at run time.** TSOFiles decodes Vitaboy to plain values; the client turns
  them into raylib meshes with bone weights (TSO's meshes blend vertices between bones, so
  each vertex needs weights, not one rigid bone) and drives the bones from the decoded
  animation. Nothing is converted ahead of time: NewSO reads the player's own install. A Sim
  is several models (body, head, hands) posed by one skeleton; some have no head or hands.
- **raylib model pitfalls.** A failed `LoadModel` returns an empty model instead of failing,
  so check `meshCount` before use. A model's texture goes on the material its mesh uses,
  `materials[meshMaterial[0]]`, which isn't always `materials[0]`.

### Rules for any texture

These hold for the lot renderer and for anything else:

- **One owner for sprite knowledge.** Which image and which source rectangle an object
  draws with comes from the content system's decoded data, through one lookup, not from
  numbers scattered through draw code.
- **One draw per sprite:** `DrawTexturePro(texture, source, destination, .zero, 0, .white)`,
  with the destination at whole pixels. `textures_srcrec_dstrec.c` shows the rectangles.
- **Only what the camera sees.** Clip loops to the visible area.
- **Pixel art stays sharp.** `SetTextureFilter(texture, .point)` on anything drawn from
  pixel art. Bilinear filtering blurs it and bleeds neighbors at the edges.
- **A missing asset isn't a crash.** Check `IsTextureValid`, report it, and draw a
  fallback. The original install is user data, and it may be the 2002 beta.
- **Decoded pixels come from the libraries.** TSOFiles decodes to plain RGBA; the client
  turns that into a texture (`LoadTextureFromImage` from an `Image` over those bytes).
  Decoding never moves into the client.

### Render textures

Drawing something once into a `RenderTexture2D` and reusing it is how CityLimits caches
its map, and the same applies to a lot's static parts:

- `LoadRenderTexture(w, h)` after `InitWindow`; check `IsRenderTextureValid`;
  `UnloadRenderTexture` before `CloseWindow`.
- Draw into it between `BeginTextureMode(target)` and `EndTextureMode()`, before the
  frame's `BeginMode2D`, never inside it, or the camera transform applies to it too.
- **It's upside down.** OpenGL's render targets are flipped, so draw one with a negative
  source height: `Rectangle(x: 0, y: 0, width: Float(target.texture.width), height: -Float(target.texture.height))`.
- Set `.point` on `target.texture` as well, or the cache blurs when the camera zooms.
- Redraw a cached part only when what's in it changes, and in step with the state.
- Keep a fallback that draws directly through the same draw function, and prove a cache
  change by screenshotting both ways and comparing the pixels (section 10).

## 6. The camera

`NSOInterface.Camera` (from CityLimits' `Camera.cs`) wraps `Camera2D`: `toRaylib()` for
`BeginMode2D`, `screenToWorld` for the mouse, `zoomAt` to zoom toward the pointer, and
`clampTo` to keep the view on the world. `core_2d_camera_mouse_zoom.c` is the reference
for zooming toward the pointer.

**Always write `NSOInterface.Camera`** where Raylib is imported too: raylib has its own
`Camera` (an alias of `Camera3D`), and Swift picks raylib's.

A position from the mouse crosses a boundary: check it against the lot before using it
as a tile or an object.

## 7. Text and the interface

- `NSOClient/NSOInterface` is the base for NewSO's take on TSO's `.uis` screens. Its
  `Sources/NSOInterface/CityLimits/` is cs2swift's translation of CityLimits' controls:
  regenerated by `NSOClient/scripts/sync-interface.sh`, never edited. Change the C# in
  CityLimits instead, or put NewSO's own Swift in `Sources/NSOInterface/NewSO/`.
- Colors and sizes live in `Sources/NSOInterface/NewSO/Theme.swift`, not in draw code.
- The interface uses raylib's default font through `DrawText` and `MeasureText`. Lay text
  out from `MeasureText`, never from guessed widths: a fixed-width column once ran
  CityLimits' prices into their labels. Measuring needs the font a window loads; without
  a window, `MeasureText` returns 0, so tests stay with what doesn't measure.
- The default font draws printable ASCII only. `TextField` and `TextArea` take only that.
- A panel that takes clicks keeps them off the world under it.
- `ConfirmPanel` keeps no open state: update and draw it only while it's asking.
- A custom font is an asset: load it once after `InitWindow`, check `IsFontValid`.

## 8. Input

- raylib polls input **once per frame**. `IsMouseButtonPressed` is true only on the frame
  the button went down, `IsMouseButtonDown` while it's held, `IsMouseButtonReleased` on
  the frame it came up. A drag starts on `Pressed`, follows on `Down`, and is applied the
  first frame the button is no longer down. Don't apply work on every `Down` frame.
- `IsKeyPressed` for toggles, `IsKeyDown` for held movement such as panning.
- Escape: raylib's default exit key makes `WindowShouldClose()` true. A client that uses
  Escape to cancel calls `SetExitKey(.null)` and handles it itself.
- `GetCharPressed` queues typed characters; read it until it returns 0, as `TextField` does.

## 9. The examples, by subject

At raylib's tag `6.0`, under `examples/`:

| You are writing | Read |
|---|---|
| The window, the loop, shutdown | `core/core_basic_window.c`, `core/core_window_flags.c`, `core/core_window_should_close.c` |
| The 2D camera, pan and zoom | `core/core_2d_camera.c`, `core/core_2d_camera_mouse_zoom.c` |
| Drawing into a cached texture | `core/core_render_texture.c`, `core/core_smooth_pixelperfect.c`, `textures/textures_framebuffer_rendering.c` |
| Scaling to the window | `core/core_window_letterbox.c` |
| Sprites from a sheet | `textures/textures_srcrec_dstrec.c`, `textures/textures_sprite_animation.c`, `textures/textures_tiled_drawing.c` |
| Images from decoded pixels | `textures/textures_image_loading.c`, `textures/textures_to_image.c` |
| Mouse and keyboard | `core/core_input_mouse.c`, `core/core_input_mouse_wheel.c`, `core/core_input_keys.c` |
| Clipping a panel | `core/core_scissor_test.c` |
| Text, fonts, measuring | `text/text_font_loading.c`, `text/text_rectangle_bounds.c`, `text/text_font_filters.c` |
| Overlays, blending | `textures/textures_blend_modes.c`, `textures/textures_fog_of_war.c` |
| Sound (later) | `audio/audio_sound_loading.c`, `audio/audio_music_stream.c` |
| Routing raylib's log | `core/core_custom_logging.c` |

raylib-swift's own `Examples/BasicWindow` shows the C example in Swift.

## 10. Checking a visual change

A change to what the player sees is checked by running it and looking at it. Whether it
*plays* well is the owner's call, not yours.

- **Never drive the owner's desktop.** Don't send input to their real display. Don't open
  a window on it unless they asked.
- **A still frame:** `interface-demo --screenshot <scratch>/shot.png` draws a few frames
  in a hidden window and saves the last. Give the client the same flag as it grows. Save
  with `LoadImageFromScreen` and `ExportImage`: `TakeScreenshot` only writes into the
  working directory.
- **Interaction:** run under a private virtual display, which the owner's host has
  (`xvfb-run`, `xdotool`, ImageMagick):

  ```sh
  xvfb-run -a -s "-screen 0 1280x720x24" ./drive.sh <scratch>
  ```

  Inside the script: start the built binary in the background, `sleep 3`, find the
  window with `xdotool search --name <title>`, drive it, then
  `import -window root <scratch>/shot.png` and `kill` it.
- **Hold every press across frames.** raylib compares input between frames, so a press and
  a release within one frame are never seen: `xdotool keydown Return; sleep 0.08; xdotool keyup Return`,
  and for the mouse `mousedown 1`, move in small steps with `sleep 0.03`, then `mouseup 1`.
- **Look closely.** Crop and enlarge what changed
  (`magick shot.png -crop WxH+X+Y -filter point -resize 300% zoom.png`), then read the image.
- **Report what you saw, and what you didn't.** "The window, its title, and the button row
  drew; the toolbar tab switched on click; not play-tested" is a report. "Builds" isn't a
  visual check.

## 11. Pitfalls

- **A black window:** a frame never reached `EndDrawing`.
- **A blank texture:** loaded before `InitWindow` or after `CloseWindow`, or the file is
  missing. Check `IsTextureValid`.
- **An upside-down cache:** a render texture drawn without the negative source height.
- **A blurry or seamed image:** no `.point` filter, or drawn at fractional positions.
- **The interface moving with the world:** drawn inside `BeginMode2D` or `BeginMode3D`.
- **Seams between neighboring sprites:** their depth wasn't made global (section 5).
- **A model that draws nothing or untextured:** `LoadModel` returned an empty stub, or the
  texture went on `materials[0]` instead of `materials[meshMaterial[0]]`.
- **A stutter:** allocation or loading in the frame loop, or drawing what the camera can't see.
- **"has no member" on a camera:** Swift picked raylib's `Camera`. Write `NSOInterface.Camera`.
- **No overload of a draw call matches:** an `Int` and an `Int32` in one call. Convert one.
- **Enum cases with C names (`KEY_SPACE`) not found, or old case names:** the apinotes
  renamed them. If the names look stale after raylib-swift updates, `swift package clean`
  in the package that imports it: clang's module cache doesn't track `.apinotes`.
- **"precompiled file ... was compiled with module cache path ...":** the package's
  `.build` came from another path (the repo moved or was renamed). Delete that one
  package's `.build`, not every package's at once: rebuilding all of them together ran
  the owner's machine out of memory.
- **Missing `X11/Xlib.h` on Linux:** the X11 headers aren't installed. On the owner's
  Atomic host they come from Homebrew; see `AGENTS.md`, "The client".
- **raylib's own log lines:** raylib prints `INFO:` lines when the window opens.
  `SetTraceLogLevel(.warning)` quiets them.
