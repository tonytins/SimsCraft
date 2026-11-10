import Hudini
import LotScene
import Raylib

/// The bar along the top of the screen: the lot, how fast time runs, the time; then the floor,
/// any errors, the object count, and the button that opens the help.
///
/// Laid out by `Interface/topbar.xml`, after the owner's prototype interface
/// (`docs/design/prototype-interface.figcraft`), which doubles as Simburbia's fallback and debug
/// interface. The document places everything; the bar fills in the text and draws its regions:
/// the background, the speed arrows, and the help button.
final class TopBar {
    private let script: UIScript
    private let view: UIScriptView

    init(script: UIScript) {
        self.script = script
        view = UIScriptView(script: script, theme: .simburbia)
    }

    /// The bar's height, from its document.
    var height: Float { script.window.size.height }

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

    func contains(_ point: Vector2) -> Bool {
        point.y >= 0 && point.y < height
    }

    /// Fills the document's text from the state, and stretches it to the screen.
    func update(_ state: TopBar.State) {
        view.setWindowSize(Vector2(x: Float(GetScreenWidth()), y: height))
        view.setText(state.lotName, named: "lotName")
        view.setText(state.isPaused ? "\(state.clock)  Paused" : state.clock, named: "clock")
        view.setText(LotSession.floorName(state.level), named: "floor")
        view.setText("\(state.errors) \(state.errors == 1 ? "Error" : "Errors")", named: "errors")
        view.setHidden(state.errors == 0, named: "errors")
        view.setText("\(state.objects) Objects", named: "objects")
    }

    /// The bar's response to this frame's click, if the click was on something it has.
    func click(at point: Vector2) -> Action? {
        if view.pressButton(at: point, origin: .zero) == .pressed(control: "errors") { return .messages }
        if let help = view.bounds(named: "help", at: .zero), CheckCollisionPointRec(point, help) { return .help }
        for index in LotSession.speeds.indices {
            if let arrow = view.bounds(named: "speed\(index)", at: .zero), CheckCollisionPointRec(point, arrow) {
                return .speed(index)
            }
        }
        return nil
    }

    func draw(_ state: TopBar.State) {
        let speedOn = script.styles["speedOn"]?.fillColor ?? .blue
        let speedOff = script.styles["speedOff"]?.fillColor ?? .lightGray
        let help = script.styles["help"]
        view.draw(at: .zero) { name, bounds in
            switch name {
            case "bar":
                DrawRectangleRec(bounds, self.script.styles["bar"]?.backgroundColor ?? .darkGray)
            case "help":
                // A circle with a question mark, as the prototype has it.
                let center = Vector2(x: bounds.x + bounds.width / 2, y: bounds.y + bounds.height / 2)
                DrawCircleV(center, min(bounds.width, bounds.height) / 2, help?.fillColor ?? .green)
                let size = help?.fontSize ?? 16
                DrawText("?", Int(center.x) - MeasureText("?", size) / 2, Int(center.y) - size / 2, size, help?.textColor ?? .black)
            default:
                // A right-pointing triangle per speed, lit up to the one time runs at; none while paused.
                guard name.hasPrefix("speed"), let index = Int(name.dropFirst("speed".count)) else { return }
                let color = !state.isPaused && index <= state.speedIndex ? speedOn : speedOff
                DrawTriangle(Vector2(x: bounds.x, y: bounds.y), Vector2(x: bounds.x, y: bounds.y + bounds.height),
                             Vector2(x: bounds.x + bounds.width, y: bounds.y + bounds.height / 2), color)
            }
        }
    }
}

/// The window that lists the client's keys and what they do (`Interface/help.xml`), opened from
/// the top bar.
final class HelpWindow {
    let window: DocumentWindow

    init(script: UIScript) {
        let size = script.window.size
        window = DocumentWindow(title: "Help", script: script) {
            // Centered top to bottom, title bar and all.
            Vector2(x: Float(GetScreenWidth()) / 2 + 40, y: (Float(GetScreenHeight()) - size.height - Float(WindowFrame.titleHeight)) / 2)
        }
    }
}

/// MOMI: the window of system messages (`Interface/momi.xml`), opened from the top bar's error
/// count. A log of the messages, newest at the bottom, and below it the input, disabled: there's
/// no one to write to until online play.
final class MomiWindow {
    let window: DocumentWindow
    private var shownCount = -1

    init(script: UIScript) {
        let size = script.window.size
        window = DocumentWindow(title: "MOMI", script: script) {
            Vector2(x: Float(GetScreenWidth()) / 2 - size.width - 40, y: (Float(GetScreenHeight()) - size.height - Float(WindowFrame.titleHeight)) / 2)
        }
    }

    /// Shows the messages; the list wraps and scrolls them, so it's refilled only when one arrives.
    func show(_ messages: [String]) {
        guard messages.count != shownCount else { return }
        window.view.list(named: "log")?.items = messages
        window.view.setHidden(!messages.isEmpty, named: "empty")
        shownCount = messages.count
    }
}
