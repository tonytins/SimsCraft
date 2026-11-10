import Raylib

/// The client's one window, opened before anything loads so the loading screen shows at once.
enum ClientWindow {
    /// Opens it: hidden when the client only takes a screenshot.
    static func open(hidden: Bool) {
        SetTraceLogLevel(.warning)
        SetConfigFlags(hidden ? [.windowHidden] : [.windowResizable, .vsyncHint, .msaa4xHint])
        InitWindow(1280, 720, "Simburbia")
        SetTargetFPS(60)
        // Escape closes the lot's windows instead of the client.
        SetExitKey(.null)
    }
}
