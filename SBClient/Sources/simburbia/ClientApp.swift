import Hudini
import LotScene
import Raylib
import SimAntics

/// The window and its frame loop: input, then time, then drawing.
final class ClientApp {
    private let session: LotSession
    private var scene = LotScene()
    private let view = LotView()
    private let topBar: TopBar
    private let inspector: Inspector
    private let help: HelpWindow
    private let momi: MomiWindow
    private let library = SpriteLibrary()
    private let textures: SpriteTextures
    /// The floors' textures; `nil` when the install's floors couldn't be read.
    private var floors: FloorPass?
    /// The walls' sprites; `nil` without readable walls or the depth shader, and walls are boxes.
    private var walls: WallPass?
    private var wallSprites: [WallSprite] = []
    /// In cutaway mode, the last three indoor rooms the pointer was over, oldest first, and the
    /// tile it was last over the lot at (`UILotControl.CutRooms`, `MouseCutRect`).
    private var cutRooms: [UInt16] = []
    private var pointerTile: SIMD2<Float>?
    /// Whether the pointer drives the cutaway; not in a hidden window, which has none.
    private let followsPointer: Bool
    /// Sprite depth; `nil` if the shader didn't compile, and sprites draw back to front only.
    private var depth: SpriteDepth?
    // Kept between frames, so drawing doesn't allocate.
    private var sprites: [ObjectSprite] = []
    private var drawOrder: [Int] = []
    private var objectsWithSprites: Set<Int16> = []
    private var hovered: Int16?
    private var lastMinute: Int32
    /// With --verbose, the run's log.
    private let log: RunLog?

    /// Sets up the lot's view in the open window (``ClientWindow``), at a zoom step and centered on
    /// a tile when they're given, with the interface its documents describe. `hidden` is a window
    /// that only takes a screenshot.
    init(session: LotSession, interface: Interface, hidden: Bool, zoomStep: Int? = nil, focus: SIMD2<Float>? = nil,
         rotation: Int = 0, walls wallMode: WallMode = .cutaway, log: RunLog? = nil) {
        self.session = session
        self.log = log
        followsPointer = !hidden
        textures = SpriteTextures(library: library)
        lastMinute = session.vm.clock.minutes
        SetWindowTitle("Simburbia - \(session.lotName)")
        topBar = TopBar(script: interface.topBar)
        inspector = Inspector(script: interface.inspector)
        help = HelpWindow(script: interface.help)
        momi = MomiWindow(script: interface.momi)
        depth = SpriteDepth()
        floors = session.floors.map(FloorPass.init)
        walls = depth == nil ? nil : session.walls.map(WallPass.init)

        rebuildScene()
        view.center(on: scene.center)
        view.fit(width: scene.lotWidth, height: scene.lotHeight, screenHeight: Int(GetScreenHeight()))
        if let zoomStep { view.setZoomStep(zoomStep) }
        if let focus { view.center(on: SIMD3(focus.x + 0.5, 0, focus.y + 0.5)) }
        view.rotate(by: rotation)
        view.wallMode = wallMode
        rebuildSprites()
    }

    /// Makes what the first frames would make, the textures of what's in view among them, by
    /// drawing a frame where it isn't seen, so the lot doesn't stutter as it appears. The loading
    /// screen calls it before giving way.
    func warmUp() {
        let target = LoadRenderTexture(GetScreenWidth(), GetScreenHeight())
        guard IsRenderTextureValid(target) else { return }
        BeginTextureMode(target)
        drawWorld(camera: view.camera(screenHeight: Int(GetScreenHeight())))
        EndTextureMode()
        UnloadRenderTexture(target)
    }

    /// Runs until the window is closed.
    func run() {
        while !WindowShouldClose() {
            handleInput()
            advance()
            draw()
        }
        textures.unloadAll()
        floors?.unloadAll()
        walls?.unloadAll()
        depth?.unload()
        CloseWindow()
    }

    /// Runs the lot `ticks` ticks, draws a few frames, saves the last, and closes the window.
    func saveScreenshot(to path: String, after ticks: Int) -> Bool {
        for _ in 0..<ticks { session.vm.tick() }
        // A screenshot has no pointer: the cutaway follows the middle of the screen, which --focus picks.
        followPointer(Vector2(x: Float(GetScreenWidth()) / 2, y: Float(GetScreenHeight()) / 2), overInterface: false, always: true)
        rebuildScene()
        // The first frames of a new window can be blank; the third is settled.
        for _ in 0..<3 { draw() }
        let image = LoadImageFromScreen()
        let saved = ExportImage(image, path)
        UnloadImage(image)
        textures.unloadAll()
        floors?.unloadAll()
        walls?.unloadAll()
        depth?.unload()
        CloseWindow()
        return saved
    }

    private func rebuildScene() {
        scene.rebuildArchitecture(of: session.vm)
        scene.rebuildObjects(of: session.vm, hiddenByBlueprint: session.hiddenByBlueprint)
        rebuildSprites()
    }

    private func rebuildSprites() {
        LotScene.objectSprites(of: session.vm, zoom: view.spriteZoom, worldRotation: view.worldRotation,
                               library: library, hiddenByBlueprint: session.hiddenByBlueprint, into: &sprites)
        objectsWithSprites.removeAll(keepingCapacity: true)
        for sprite in sprites { objectsWithSprites.insert(sprite.objectID) }
        if walls != nil {
            let (architecture, objectStyles) = LotScene.drawnArchitecture(of: session.vm)
            wallSprites = LotScene.wallSprites(of: architecture, level: view.level, zoom: view.spriteZoom,
                                               worldRotation: view.worldRotation, wallsDown: wallsDown(of: architecture),
                                               objectStyles: objectStyles)
        }
    }

    /// Which tiles of the floor in view have their walls down in TSO's wall mode: none with walls
    /// up, all with walls down, and in cutaway, the rooms the pointer last visited and the tiles
    /// around it (`UILotControl.UpdateCutaway`).
    private func wallsDown(of architecture: Architecture) -> [Bool]? {
        let tiles = architecture.width * architecture.height
        switch view.wallMode {
        case .up:
            return nil
        case .down:
            return Array(repeating: true, count: tiles)
        case .cutaway:
            var cut = LotScene.roomCut(of: architecture, level: view.level, worldRotation: view.worldRotation, rooms: Set(cutRooms))
            if let pointerTile {
                let rect = LotScene.pointerCut(at: pointerTile, worldRotation: view.worldRotation)
                LotScene.applyCut(&cut, of: architecture, level: view.level, x: rect.x, y: rect.y, width: rect.width, height: rect.height)
            }
            return cut
        }
    }

    /// Follows the pointer for the cutaway: the tile it's over, and the indoor room there, kept
    /// with the two before it. Stays put while the view is being dragged, as in FreeSO.
    private func followPointer(_ mouse: Vector2, overInterface: Bool, always: Bool = false) {
        guard always || (followsPointer && !overInterface && !IsMouseButtonDown(.right)) else { return }
        let camera = view.camera(screenHeight: Int(GetScreenHeight()))
        guard let tile = view.tile(at: mouse, camera: camera, level: view.level) else { return }
        pointerTile = tile
        let architecture = session.vm.architecture
        let x = Int(tile.x.rounded(.down)), y = Int(tile.y.rounded(.down))
        guard x >= 0, y >= 0, x < architecture.width, y < architecture.height,
              architecture.roomMaps.indices.contains(view.level - 1) else { return }
        let map = architecture.roomMaps[view.level - 1].map
        guard map.indices.contains(y * architecture.width + x) else { return }
        let room = UInt16(truncatingIfNeeded: map[y * architecture.width + x])
        let outside = architecture.rooms.indices.contains(Int(room)) ? architecture.rooms[Int(room)].isOutside : true
        if !outside, !cutRooms.contains(room) { cutRooms.append(room) }
        if cutRooms.count > 3 { cutRooms.removeFirst(cutRooms.count - 3) }
    }

    // MARK: Frame

    private func handleInput() {
        if IsKeyPressed(.space) { session.isPaused.toggle() }
        for (key, index) in [(KeyboardKey.one, 0), (.two, 1), (.three, 2)] where IsKeyPressed(key) {
            session.setSpeed(index: index)
        }
        if IsKeyPressed(.q) { view.rotate(by: -1) }
        if IsKeyPressed(.e) { view.rotate(by: 1) }
        if IsKeyPressed(.w) { view.wallMode = view.wallMode.next }
        if IsKeyPressed(.pageUp) { view.level = min(view.level + 1, Architecture.stories) }
        if IsKeyPressed(.pageDown) { view.level = max(view.level - 1, 1) }
        if IsKeyPressed(.escape) {
            if help.window.isOpen { help.window.isOpen = false } else if momi.window.isOpen { momi.window.isOpen = false } else { inspector.close() }
        }

        topBar.update(topBarState)
        let mouse = GetMousePosition()
        let overInterface = topBar.contains(mouse) || inspector.contains(mouse) || help.window.contains(mouse) || momi.window.contains(mouse)
        if !overInterface { view.zoom(by: GetMouseWheelMove()) }
        followPointer(mouse, overInterface: overInterface)
        if IsMouseButtonDown(.right) { view.pan(by: GetMouseDelta()) }
        hovered = overInterface ? nil : view.object(at: mouse, in: scene, camera: view.camera(screenHeight: Int(GetScreenHeight())))
        // The windows take the click when they want it, then the bar; otherwise a click picks
        // what's under the pointer.
        let usedByWindow = help.window.update() || momi.window.update() || inspector.update()
        if !usedByWindow, IsMouseButtonPressed(.left) {
            switch topBar.click(at: mouse) {
            case .speed(let index):
                session.setSpeed(index: index)
                session.isPaused = false
            case .help:
                help.window.isOpen.toggle()
            case .messages:
                momi.window.isOpen.toggle()
            case nil:
                if !overInterface { inspector.selected = hovered }
            }
        }
        if let id = inspector.selected, session.vm.entity(id: id) == nil { inspector.close() }
    }

    private func advance() {
        session.advance(seconds: Double(GetFrameTime()))
        log?.update()
        // Rooms regenerate on the tick after a change; once a game minute is often enough to catch it.
        if session.vm.clock.minutes != lastMinute {
            lastMinute = session.vm.clock.minutes
            scene.rebuildArchitecture(of: session.vm)
        }
        scene.rebuildObjects(of: session.vm, hiddenByBlueprint: session.hiddenByBlueprint)
        rebuildSprites()
    }

    private func draw() {
        let camera = view.camera(screenHeight: Int(GetScreenHeight()))
        BeginDrawing()
        drawWorld(camera: camera)
        let state = topBarState
        topBar.update(state)
        topBar.draw(state)
        if let id = inspector.selected, let entity = session.vm.entity(id: id) {
            inspector.draw(entity)
        } else if let id = hovered, let entity = session.vm.entity(id: id) {
            let mouse = GetMousePosition()
            DrawText(Inspection(entity).title, Int(mouse.x) + 14, Int(mouse.y) + 10, 16, InterfaceTheme.simburbia.text)
        }
        momi.show(session.systemMessages)
        momi.window.draw()
        help.window.draw()
        EndDrawing()
    }

    /// The lot: floors, walls, and objects, without the interface.
    private func drawWorld(camera: Camera3D) {
        ClearBackground(Color(r: 34, g: 44, b: 58, a: 255))
        view.draw(scene, camera: camera, floors: floors, wallsAsSprites: walls != nil, objectsWithSprites: objectsWithSprites, selected: inspector.selected, hovered: hovered)
        if let walls, let depth { walls.draw(wallSprites, camera: camera, depth: depth, scale: view.spriteScale, level: view.level) }
        view.drawSprites(sprites, camera: camera, textures: textures, depth: depth, order: &drawOrder, selected: inspector.selected, hovered: hovered)
    }

    private var topBarState: TopBar.State {
        TopBar.State(lotName: session.lotName, speedIndex: session.speedIndex, isPaused: session.isPaused,
                     clock: session.clockText, level: view.level, errors: session.contentProblems.count + session.vm.reportedErrors.count,
                     objects: scene.objects.count)
    }
}
