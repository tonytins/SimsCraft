import Interface
import LotScene
import Raylib
import SimAntics

/// The window and its frame loop: input, then time, then drawing.
final class ClientApp {
    private let session: LotSession
    private var scene = LotScene()
    private let view = LotView()
    private let inspector = Inspector()
    private var hovered: Int16?
    private var lastMinute: Int32

    /// Opens the window, which is hidden when the client only takes a screenshot.
    init(session: LotSession, hidden: Bool) {
        self.session = session
        lastMinute = session.vm.clock.minutes
        SetTraceLogLevel(.warning)
        SetConfigFlags(hidden ? [.windowHidden] : [.windowResizable, .vsyncHint, .msaa4xHint])
        InitWindow(1280, 720, "NewSO - \(session.lotName)")
        SetTargetFPS(60)
        // Escape closes the inspector instead of the client.
        SetExitKey(.null)

        rebuildScene()
        view.center(on: scene.center)
        view.fit(width: scene.lotWidth, height: scene.lotHeight)
    }

    /// Runs until the window is closed.
    func run() {
        while !WindowShouldClose() {
            handleInput()
            advance()
            draw()
        }
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
        CloseWindow()
        return saved
    }

    private func rebuildScene() {
        scene.rebuildArchitecture(of: session.vm)
        scene.rebuildObjects(of: session.vm)
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
        if IsKeyPressed(.escape) { inspector.close() }

        let mouse = GetMousePosition()
        let overInspector = inspector.contains(mouse)
        if !overInspector { view.zoom(by: GetMouseWheelMove()) }
        if IsMouseButtonDown(.right) { view.pan(by: GetMouseDelta(), screenHeight: Int(GetScreenHeight())) }
        hovered = overInspector ? nil : view.object(at: mouse, in: scene)
        // The inspector takes the click when it wants it; otherwise a click picks what's under the pointer.
        if !inspector.update(), IsMouseButtonPressed(.left), !overInspector {
            inspector.selected = hovered
        }
        if let id = inspector.selected, session.vm.entity(id: id) == nil { inspector.close() }
    }

    private func advance() {
        session.advance(seconds: Double(GetFrameTime()))
        // Rooms regenerate on the tick after a change; once a game minute is often enough to catch it.
        if session.vm.clock.minutes != lastMinute {
            lastMinute = session.vm.clock.minutes
            scene.rebuildArchitecture(of: session.vm)
        }
        scene.rebuildObjects(of: session.vm)
    }

    private func draw() {
        BeginDrawing()
        ClearBackground(Color(r: 34, g: 44, b: 58, a: 255))
        view.draw(scene, selected: inspector.selected, hovered: hovered)
        drawStatusBar()
        drawHelp()
        if let id = inspector.selected, let entity = session.vm.entity(id: id) {
            inspector.draw(entity)
        } else if let id = hovered, let entity = session.vm.entity(id: id) {
            let mouse = GetMousePosition()
            DrawText(Inspection(entity).title, Int(mouse.x) + 14, Int(mouse.y) + 10, 16, Theme.text)
        }
        EndDrawing()
    }

    private func drawStatusBar() {
        var status = "\(session.lotName)   \(session.clockText)   "
        status += session.isPaused ? "paused" : "x\(session.speed)"
        status += "   floor \(view.level)   \(scene.objects.count) objects"
        if !session.vm.reportedErrors.isEmpty { status += "   \(session.vm.reportedErrors.count) errors" }
        DrawRectangle(0, 0, Int(GetScreenWidth()), 28, Theme.panel)
        DrawText(status, 10, 7, 16, Theme.text)
    }

    private func drawHelp() {
        let help = "Space pause   1-3 speed   Q/E rotate   wheel zoom   right-drag pan   PgUp/PgDn floor   W walls   click an object"
        DrawText(help, 10, Int(GetScreenHeight()) - 22, 14, Theme.textDim)
    }
}
