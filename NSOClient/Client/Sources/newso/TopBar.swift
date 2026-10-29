import NSOInterface
import LotScene
import Raylib

/// The bar along the top of the screen: the lot, how fast time runs, the time; then the floor,
/// any errors, the object count, and the button that opens the help.
///
/// Laid out after the owner's prototype interface (`NSOClient/mockups/prototype-interface`),
/// which doubles as NewSO's fallback and debug interface. The prototype's money slot waits for
/// money to exist.
struct TopBar {
    static let height = 28
    private static let fontSize = 16
    private static let gap = 24
    private static let background = Color(r: 59, g: 59, b: 59, a: 255)        // #3B3B3B
    private static let speedOn = Color(r: 62, g: 110, b: 190, a: 255)         // #3E6EBE
    private static let speedOff = Color(r: 217, g: 217, b: 217, a: 255)       // #D9D9D9
    private static let errorText = Color(r: 255, g: 0, b: 0, a: 255)          // #FF0000
    private static let helpButton = Color(r: 74, g: 138, b: 66, a: 255)       // #4A8A42
    private static let arrowSize: Float = 14
    private static let arrowStep: Float = 16
    private static var textY: Int { (height - fontSize) / 2 }

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
    enum Action: Equatable {
        case speed(Int)
        case help
        case messages
    }

    /// The left edge of the speed arrows, after the lot name.
    private static func arrowsLeft(_ state: State) -> Float {
        Float(16 + MeasureText(state.lotName, fontSize) + gap)
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

    /// The right-hand texts, right to left from the help button: the object count, the errors
    /// (only when there are any), and the floor, each with where it's drawn.
    private static func rightItems(_ state: State) -> [(text: String, color: Color, bounds: Rectangle, action: Action?)] {
        var items: [(text: String, color: Color, bounds: Rectangle, action: Action?)] = []
        var right = Int(helpCenter.x) - 10 - gap
        func add(_ text: String, _ color: Color, _ action: Action?) {
            let width = MeasureText(text, fontSize)
            right -= width
            items.append((text, color, Rectangle(x: Float(right), y: 0, width: Float(width), height: Float(height)), action))
            right -= gap
        }
        add("\(state.objects) Objects", .white, nil)
        if state.errors > 0 { add("\(state.errors) \(state.errors == 1 ? "Error" : "Errors")", errorText, .messages) }
        add(LotSession.floorName(state.level), .white, nil)
        return items
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
        return rightItems(state).first { $0.action != nil && CheckCollisionPointRec(point, $0.bounds) }?.action
    }

    static func draw(_ state: State) {
        DrawRectangle(0, 0, Int(GetScreenWidth()), height, background)
        DrawText(state.lotName, 16, textY, fontSize, .white)

        // A right-pointing triangle per speed, blue up to the one time runs at; none while paused.
        for index in LotSession.speeds.indices {
            let box = arrow(index, state)
            let color = !state.isPaused && index <= state.speedIndex ? speedOn : speedOff
            DrawTriangle(Vector2(x: box.x, y: box.y), Vector2(x: box.x, y: box.y + box.height),
                         Vector2(x: box.x + box.width, y: box.y + box.height / 2), color)
        }
        let clockX = Int(arrowsLeft(state) + Float(LotSession.speeds.count) * arrowStep) + gap
        DrawText(state.isPaused ? "\(state.clock)  Paused" : state.clock, clockX, textY, fontSize, .white)

        let center = helpCenter
        DrawCircleV(center, 10, helpButton)
        DrawText("?", Int(center.x) - MeasureText("?", fontSize) / 2, textY, fontSize, .black)
        for item in rightItems(state) {
            DrawText(item.text, Int(item.bounds.x), textY, fontSize, item.color)
        }
    }
}

/// The window that lists the client's keys and what they do, opened from the top bar.
final class HelpWindow {
    private static let fontSize = 16
    private static let lineHeight = 22
    private static let effectColor = Color(r: 255, g: 248, b: 0, a: 255)       // #FFF800
    private static let keys: [(key: String, effect: String)] = [
        ("Space", "Pause"), ("1-3", "Speed"), ("Q/E", "Rotate"), ("Mouse Wheel", "Zoom"), ("Right-drag", "Pan"),
        ("PgUp/PgDn", "Floor"), ("W", "Walls"), ("Click on Object", "Inspect"),
    ]
    private static let size = Vector2(x: 300, y: Float(36 + keys.count * lineHeight + 12))
    private let frame = WindowFrame("Help")

    var isOpen = false

    private var bounds: Rectangle {
        frame.place(Self.size, Vector2(x: Float(GetScreenWidth()) / 2 + 40, y: (Float(GetScreenHeight()) - Self.size.y) / 2))
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
            DrawText(effect, right - MeasureText(effect, Self.fontSize), y, Self.fontSize, Self.effectColor)
            y += Self.lineHeight
        }
    }
}

/// MOMI: the window of system messages, opened from the top bar's error count. A log of the
/// messages, newest at the bottom, and below it the input, disabled: there's no one to write to
/// until online play.
final class MomiWindow {
    private static let fontSize = 14
    private static let lineHeight = 18
    private static let size = Vector2(x: 420, y: 260)
    private static let logBackground = Color(r: 34, g: 34, b: 34, a: 255)     // #222222
    private static let inputBackground = Color(r: 20, g: 20, b: 20, a: 255)   // #141414
    private let frame = WindowFrame("MOMI")
    private var wrapped: [String] = []
    private var wrappedCount = -1
    /// How many lines the log is scrolled up from its newest.
    private var scroll = 0

    var isOpen = false

    private var bounds: Rectangle {
        frame.place(Self.size, Vector2(x: Float(GetScreenWidth()) / 2 - Self.size.x - 40,
                                       y: (Float(GetScreenHeight()) - Self.size.y) / 2))
    }

    private var log: Rectangle {
        let content = WindowFrame.content(bounds)
        return Rectangle(x: content.x + 10, y: content.y + 10, width: content.width - 20, height: content.height - 66)
    }

    private var input: Rectangle {
        let content = WindowFrame.content(bounds)
        return Rectangle(x: content.x + 10, y: content.y + content.height - 46, width: content.width - 20, height: 36)
    }

    func contains(_ point: Vector2) -> Bool {
        isOpen && CheckCollisionPointRec(point, bounds)
    }

    /// Lets the window be dragged, closed, and its log scrolled. Returns whether it used this
    /// frame's click.
    func update() -> Bool {
        guard isOpen else { return false }
        let bounds = self.bounds
        if CheckCollisionPointRec(GetMousePosition(), log) {
            scroll = max(0, scroll + Int(GetMouseWheelMove().rounded()))
        }
        if frame.followPointer(bounds) { return true }
        if frame.update(bounds) == .close {
            isOpen = false
            return true
        }
        return false
    }

    func draw(_ messages: [String]) {
        guard isOpen else { return }
        let bounds = self.bounds
        frame.draw(bounds)
        let log = self.log
        // Wrapping measures text, so it's redone only when a message arrives.
        if messages.count != wrappedCount {
            wrapped = messages.flatMap { TextWrap.lines($0, Self.fontSize, Int(log.width) - 16) }
            wrappedCount = messages.count
        }
        DrawRectangleRec(log, Self.logBackground)
        let visible = max(1, (Int(log.height) - 12) / Self.lineHeight)
        scroll = min(scroll, max(0, wrapped.count - visible))
        let end = wrapped.count - scroll
        let shown = wrapped[max(0, end - visible)..<max(0, end)]
        var y = Int(log.y) + 6
        if wrapped.isEmpty {
            DrawText("No messages.", Int(log.x) + 8, y, Self.fontSize, Theme.textDim)
        }
        for line in shown {
            DrawText(line, Int(log.x) + 8, y, Self.fontSize, Theme.text)
            y += Self.lineHeight
        }
        let input = self.input
        DrawRectangleRec(input, Self.inputBackground)
        DrawText("Replies arrive with online play.", Int(input.x) + 8, Int(input.y) + 11, Self.fontSize, Theme.textDim)
    }
}
