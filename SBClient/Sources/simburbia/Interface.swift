import Foundation
import Hudini
import LotScene
import Raylib

/// The client's interface documents, read once at start (``InterfaceDocuments``).
struct Interface {
    let topBar: UIScript
    let help: UIScript
    let momi: UIScript
    let inspector: UIScript
    let loginStart: UIScript
    let loginJoin: UIScript

    /// Reads every document from a Simburbia folder, and checks each has the controls the client
    /// uses. Attributes a document has that Hudini ignored, such as a misspelled one, are
    /// returned as warnings.
    ///
    /// - Throws: ``Failure`` naming the document that's missing, doesn't read, or lacks a control.
    static func load(from simburbiaFolder: URL) throws -> (Interface, warnings: [String]) {
        var scripts: [String: UIScript] = [:]
        var warnings: [String] = []
        for (document, controls) in InterfaceDocuments.required {
            let url = InterfaceDocuments.url(of: document, in: simburbiaFolder)
            let script: UIScript
            do {
                script = try UIScript(contentsOf: url)
            } catch {
                throw Failure(description: "couldn't read the interface document \(url.path): \(error.localizedDescription)")
            }
            let missing = controls.filter { script.control(named: $0) == nil }
            guard missing.isEmpty else {
                throw Failure(description: "the interface document \(url.path) has no control named \(missing.joined(separator: ", "))")
            }
            warnings += script.ignoredAttributes.map { "\(document).xml line \($0.line): \($0.element) ignores '\($0.attribute)'" }
            scripts[document] = script
        }
        guard let topBar = scripts["topbar"], let help = scripts["help"], let momi = scripts["momi"],
              let inspector = scripts["inspector"], let loginStart = scripts["login-start"],
              let loginJoin = scripts["login-join"] else {
            throw Failure(description: "the interface documents are incomplete")
        }
        return (Interface(topBar: topBar, help: help, momi: momi, inspector: inspector,
                          loginStart: loginStart, loginJoin: loginJoin), warnings)
    }
}

/// A window whose content is a UIScript document: Hudini's window frame around the document's
/// view, placed where the window starts until it's dragged.
final class DocumentWindow {
    let frame: WindowFrame
    let view: UIScriptView
    private let size: Vector2
    private let start: () -> Vector2

    var isOpen = false

    /// - Parameter start: where the window's top left starts, worked out when it's first placed.
    init(title: String, script: UIScript, start: @escaping () -> Vector2) {
        frame = WindowFrame(title: title, theme: .simburbia)
        view = UIScriptView(script: script, theme: .simburbia)
        // The document is the content; the frame adds its title bar above.
        size = Vector2(x: script.window.size.width, y: script.window.size.height + Float(WindowFrame.titleHeight))
        self.start = start
    }

    var bounds: Rectangle {
        frame.place(size: size, at: start())
    }

    private var contentOrigin: Vector2 {
        let content = WindowFrame.content(in: bounds)
        return Vector2(x: content.x, y: content.y)
    }

    func contains(_ point: Vector2) -> Bool {
        isOpen && CheckCollisionPointRec(point, bounds)
    }

    /// Lets the window be dragged and closed, and its controls used. Returns whether it used
    /// this frame's click.
    func update() -> Bool {
        guard isOpen else { return false }
        let bounds = self.bounds
        if frame.followPointer(in: bounds) { return true }
        if frame.update(in: bounds) == .close {
            isOpen = false
            view.clearFocus()
            return true
        }
        _ = view.update(at: contentOrigin)
        return IsMouseButtonPressed(.left) && CheckCollisionPointRec(GetMousePosition(), bounds)
    }

    func draw() {
        guard isOpen else { return }
        frame.draw(in: bounds)
        view.draw(at: contentOrigin)
        view.drawTooltip(at: contentOrigin)
    }
}
