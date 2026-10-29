import NSOInterface
import LotScene
import Raylib
import SimAntics

/// The window and its frame loop: input, then time, then drawing.
final class ClientApp {
    private let session: LotSession
    private var scene = LotScene()
    private let view = LotView()
    private let inspector = Inspector()
    private let help = HelpWindow()
    private let momi = MomiWindow()
    private let library = SpriteLibrary()
    private let textures: SpriteTextures
    // Kept between frames, so drawing doesn't allocate.
    private var sprites: [ObjectSprite] = []
    private var drawOrder: [Int] = []
    private var objectsWithSprites: Set<Int16> = []
    private var hovered: Int16?
    private var lastMinute: Int32
    /// With --verbose, the run's log.
    private let log: RunLog?

    /// Opens the window, which is hidden when the client only takes a screenshot, at a zoom
    /// step and centered on a tile when they're given.
    init(session: LotSession, hidden: Bool, zoomStep: Int? = nil, focus: SIMD2<Float>? = nil, rotation: Int = 0, log: RunLog? = nil) {
        self.session = session
        self.log = log
        textures = SpriteTextures(library: library)
        lastMinute = session.vm.clock.minutes
        SetTraceLogLevel(.warning)
        SetConfigFlags(hidden ? [.windowHidden] : [.windowResizable, .vsyncHint, .msaa4xHint])
        InitWindow(1280, 720, "NewSO - \(session.lotName)")
        SetTargetFPS(60)
        // Escape closes the inspector instead of the client.
        SetExitKey(.null)

        rebuildScene()
        view.center(on: scene.center)
        view.fit(width: scene.lotWidth, height: scene.lotHeight, screenHeight: Int(GetScreenHeight()))
        if let zoomStep { view.setZoomStep(zoomStep) }
        if let focus { view.center(on: SIMD3(focus.x + 0.5, 0, focus.y + 0.5)) }
        view.rotate(by: rotation)
        rebuildSprites()
    }

    /// Runs until the window is closed.
    func run() {
        while !WindowShouldClose() {
            handleInput()
            advance()
            draw()
        }
        textures.unloadAll()
        CloseWindow()
    }

    /// Runs the lot `ticks` ticks, draws a few frames, saves the last, and closes the window.
    func saveScreenshot(to path: String, after ticks: Int) -> Bool {
        for _ in 0..<ticks { session.vm.tick() }
        rebuildScene()
        // The first frames of a new window can be blank; the third is settled.
        for _ in 0..<3 { draw() }
        let image = LoadImageFromScreen()
        let saved = ExportImage(image, path)
        UnloadImage(image)
        textures.unloadAll()
        CloseWindow()
        return saved
    }

    private func rebuildScene() {
        scene.rebuildArchitecture(of: session.vm)
        scene.rebuildObjects(of: session.vm)
        rebuildSprites()
    }

    private func rebuildSprites() {
        LotScene.objectSprites(of: session.vm, zoom: view.spriteZoom, worldRotation: view.worldRotation,
                               library: library, into: &sprites)
        objectsWithSprites.removeAll(keepingCapacity: true)
        for sprite in sprites { objectsWithSprites.insert(sprite.objectID) }
    }

    // MARK: Frame

    private func handleInput() {
        if IsKeyPressed(.space) { session.isPaused.toggle() }
        for (key, index) in [(KeyboardKey.one, 0), (.two, 1), (.three, 2)] where IsKeyPressed(key) {
            session.setSpeed(index: index)
        }
        if IsKeyPressed(.q) { view.rotate(by: -1) }
        if IsKeyPressed(.e) { view.rotate(by: 1) }
        if IsKeyPressed(.w) { view.wallsCut.toggle() }
        if IsKeyPressed(.pageUp) { view.level = min(view.level + 1, Architecture.stories) }
        if IsKeyPressed(.pageDown) { view.level = max(view.level - 1, 1) }
        if IsKeyPressed(.escape) {
            if help.isOpen { help.isOpen = false } else if momi.isOpen { momi.isOpen = false } else { inspector.close() }
        }

        let mouse = GetMousePosition()
        let overInterface = TopBar.contains(mouse) || inspector.contains(mouse) || help.contains(mouse) || momi.contains(mouse)
        if !overInterface { view.zoom(by: GetMouseWheelMove()) }
        if IsMouseButtonDown(.right) { view.pan(by: GetMouseDelta()) }
        hovered = overInterface ? nil : view.object(at: mouse, in: scene, camera: view.camera(screenHeight: Int(GetScreenHeight())))
        // The windows take the click when they want it, then the bar; otherwise a click picks
        // what's under the pointer.
        let usedByWindow = help.update() || momi.update() || inspector.update()
        if !usedByWindow, IsMouseButtonPressed(.left) {
            switch TopBar.click(at: mouse, topBarState) {
            case .speed(let index):
                session.setSpeed(index: index)
                session.isPaused = false
            case .help:
                help.isOpen.toggle()
            case .messages:
                momi.isOpen.toggle()
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
        scene.rebuildObjects(of: session.vm)
        rebuildSprites()
    }

    private func draw() {
        let camera = view.camera(screenHeight: Int(GetScreenHeight()))
        BeginDrawing()
        ClearBackground(Color(r: 34, g: 44, b: 58, a: 255))
        view.draw(scene, camera: camera, objectsWithSprites: objectsWithSprites, selected: inspector.selected, hovered: hovered)
        view.drawSprites(sprites, camera: camera, textures: textures, order: &drawOrder, selected: inspector.selected, hovered: hovered)
        TopBar.draw(topBarState)
        if let id = inspector.selected, let entity = session.vm.entity(id: id) {
            inspector.draw(entity)
        } else if let id = hovered, let entity = session.vm.entity(id: id) {
            let mouse = GetMousePosition()
            DrawText(Inspection(entity).title, Int(mouse.x) + 14, Int(mouse.y) + 10, 16, Theme.text)
        }
        momi.draw(SystemMessages.messages(of: session.vm))
        help.draw()
        EndDrawing()
    }

    private var topBarState: TopBar.State {
        TopBar.State(lotName: session.lotName, speedIndex: session.speedIndex, isPaused: session.isPaused,
                     clock: session.clockText, level: view.level, errors: session.vm.reportedErrors.count,
                     objects: scene.objects.count)
    }
}
