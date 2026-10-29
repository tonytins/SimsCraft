import Interface
import LotScene
import Raylib

/// The bar along the top of the screen: the lot, how fast time runs, the time; then the floor,
/// any errors, the object count, and the button that opens the help.
///
/// Laid out after the owner's prototype interface (`NSOClient/mockups/prototype-interface.svg`),
/// which doubles as NewSO's fallback and debug interface. The prototype's money slot waits for
/// money to exist.
struct TopBar {
    static let height = 28
    private static let fontSize = 16
    private static let background = Color(r: 59, g: 59, b: 59, a: 255)        // #3B3B3B
    private static let currentSpeed = Color(r: 62, g: 110, b: 190, a: 255)    // #3E6EBE
    private static let otherSpeed = Color(r: 217, g: 217, b: 217, a: 255)     // #D9D9D9
    private static let helpButton = Color(r: 74, g: 138, b: 66, a: 255)       // #4A8A42
    private static let arrowSize: Float = 14
    private static let arrowStep: Float = 16

    /// What the bar shows this frame.
    struct State {
        var lotName: String
        var speedIndex: Int
        var isPaused: Bool
        var clock: String
        var level: Int
        var errors: Int
        var objects: Int
    }

    /// What a click on the bar asked for.
    enum Action {
        case speed(Int)
        case help
    }

    /// The left edge of the speed arrows, after the lot name.
    private static func arrowsLeft(_ state: State) -> Float {
        Float(16 + MeasureText(state.lotName, fontSize) + 24)
    }

    /// The square a speed arrow sits in.
    private static func arrow(_ index: Int, _ state: State) -> Rectangle {
        Rectangle(x: arrowsLeft(state) + Float(index) * arrowStep, y: (Float(height) - arrowSize) / 2,
                  width: arrowSize, height: arrowSize)
    }

    /// The help button's circle.
    private static var helpCenter: Vector2 {
        Vector2(x: Float(GetScreenWidth()) - 18, y: Float(height) / 2)
    }

    static func contains(_ point: Vector2) -> Bool {
        point.y >= 0 && point.y < Float(height)
    }

    /// The bar's response to this frame's click, if the click was on something it has.
    static func click(at point: Vector2, _ state: State) -> Action? {
        if CheckCollisionPointCircle(point, helpCenter, 10) { return .help }
        for index in LotSession.speeds.indices where CheckCollisionPointRec(point, arrow(index, state)) {
            return .speed(index)
        }
        return nil
    }

    static func draw(_ state: State) {
        let width = Int(GetScreenWidth())
        DrawRectangle(0, 0, width, height, background)
        let textY = (height - fontSize) / 2
        DrawText(state.lotName, 16, textY, fontSize, .white)

        // A right-pointing triangle per speed; the one time runs at is blue, none while paused.
        for index in LotSession.speeds.indices {
            let box = arrow(index, state)
            let color = !state.isPaused && index == state.speedIndex ? currentSpeed : otherSpeed
            DrawTriangle(Vector2(x: box.x, y: box.y), Vector2(x: box.x, y: box.y + box.height),
                         Vector2(x: box.x + box.width, y: box.y + box.height / 2), color)
        }
        let clockX = Int(arrowsLeft(state) + Float(LotSession.speeds.count) * arrowStep) + 24
        DrawText(state.isPaused ? "\(state.clock)  Paused" : state.clock, clockX, textY, fontSize, .white)

        // Right to left: the help button, the object count, any errors, the floor.
        let center = helpCenter
        DrawCircleV(center, 10, helpButton)
        DrawText("?", Int(center.x) - MeasureText("?", fontSize) / 2, textY, fontSize, .black)
        var right = Int(center.x) - 10 - 24
        func item(_ text: String, _ color: Color) {
            right -= MeasureText(text, fontSize)
            DrawText(text, right, textY, fontSize, color)
            right -= 24
        }
        item("\(state.objects) Objects", .white)
        if state.errors > 0 { item("\(state.errors) \(state.errors == 1 ? "Error" : "Errors")", Theme.error) }
        item(LotSession.floorName(state.level), .white)
    }
}

/// The window that lists the client's keys and what they do, opened from the top bar.
final class HelpWindow {
    private static let fontSize = 16
    private static let lineHeight = 22
    private static let keys: [(key: String, effect: String)] = [
        ("Space", "Pause"), ("1-3", "Speed"), ("Q/E", "Rotate"), ("Mouse Wheel", "Zoom"), ("Right-drag", "Pan"),
        ("PgUp/PgDn", "Floor"), ("W", "Walls"), ("Click on Object", "Inspect"),
    ]
    private static let size = Vector2(x: 300, y: Float(36 + keys.count * lineHeight + 12))
    private let frame = WindowFrame("Help")

    var isOpen = false

    private var bounds: Rectangle {
        frame.place(Self.size, Vector2(x: (Float(GetScreenWidth()) - Self.size.x) / 2,
                                       y: (Float(GetScreenHeight()) - Self.size.y) / 2))
    }

    func contains(_ point: Vector2) -> Bool {
        isOpen && CheckCollisionPointRec(point, bounds)
    }

    /// Lets the window be dragged and closed. Returns whether it used this frame's click.
    func update() -> Bool {
        guard isOpen else { return false }
        let bounds = self.bounds
        if frame.followPointer(bounds) { return true }
        if frame.update(bounds) == .close {
            isOpen = false
            return true
        }
        return false
    }

    func draw() {
        guard isOpen else { return }
        let bounds = self.bounds
        frame.draw(bounds)
        let content = WindowFrame.content(bounds)
        var y = Int(content.y) + 12
        for (key, effect) in Self.keys {
            DrawText(key, Int(content.x) + 12, y, Self.fontSize, Theme.text)
            let right = Int(content.x + content.width) - 12
            DrawText(effect, right - MeasureText(effect, Self.fontSize), y, Self.fontSize, Theme.accent)
            y += Self.lineHeight
        }
    }
}
