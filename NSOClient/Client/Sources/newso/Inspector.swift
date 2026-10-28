import Interface
import LotScene
import Raylib
import SimAntics

/// The window that shows the selected object: what it is, where, and what it's running.
final class Inspector {
    private static let size = Vector2(x: 380, y: 260)
    private static let lineHeight = 18
    private let frame = WindowFrame("Object")

    /// The object being inspected, by its ID in the VM; `nil` hides the window.
    var selected: Int16?

    private var bounds: Rectangle {
        frame.place(Self.size, Vector2(x: Float(GetScreenWidth()) - Self.size.x - 20, y: 50))
    }

    func close() {
        selected = nil
    }

    /// Whether a point is over the open window.
    func contains(_ point: Vector2) -> Bool {
        selected != nil && CheckCollisionPointRec(point, bounds)
    }

    /// Lets the window be dragged and closed. Returns whether it used this frame's click.
    func update() -> Bool {
        guard selected != nil else { return false }
        let bounds = self.bounds
        if frame.followPointer(bounds) { return true }
        if frame.update(bounds) == .close {
            close()
            return true
        }
        return false
    }

    func draw(_ entity: Entity) {
        let inspection = Inspection(entity)
        let bounds = self.bounds
        frame.title = inspection.title
        frame.draw(bounds)
        let content = WindowFrame.content(bounds)
        var y = Int(content.y) + 10
        for line in inspection.lines {
            DrawText(line, Int(content.x) + 12, y, 14, Theme.text)
            y += Self.lineHeight
        }
    }
}
