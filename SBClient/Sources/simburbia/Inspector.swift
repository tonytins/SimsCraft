import Hudini
import LotScene
import Raylib
import SimAntics

/// The window that shows the selected object (`Interface/inspector.xml`): what it is, where,
/// and what it's running.
final class Inspector {
    let window: DocumentWindow
    private var shownLines: [String] = []

    init(script: UIScript) {
        let size = script.window.size
        window = DocumentWindow(title: "Object", script: script) {
            Vector2(x: Float(GetScreenWidth()) - size.width - 20, y: 50)
        }
    }

    /// The object being inspected, by its ID in the VM; `nil` hides the window.
    var selected: Int16? {
        didSet { window.isOpen = selected != nil }
    }

    func close() {
        selected = nil
    }

    func contains(_ point: Vector2) -> Bool {
        window.contains(point)
    }

    /// Lets the window be dragged and closed. Returns whether it used this frame's click.
    func update() -> Bool {
        let used = window.update()
        if !window.isOpen { selected = nil }
        return used
    }

    func draw(_ entity: Entity) {
        let inspection = Inspection(entity)
        window.frame.title = inspection.title
        // The list wraps the lines, so it's refilled only when they change.
        if inspection.lines != shownLines {
            window.view.list(named: "lines")?.items = inspection.lines
            shownLines = inspection.lines
        }
        window.draw()
    }
}
