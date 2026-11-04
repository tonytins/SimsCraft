import Hudini
import LotScene
import Raylib

/// The login window of the owner's mockup (`docs/design/login-screen.png`), over the loading
/// screen's art, as TSO's and FreeSO's login dialog sits over theirs: a movable window without a
/// close button, with a Start tab to pick a lot and play it, and a Join tab to join someone else's
/// game, shown disabled until Simburbia has networking.
final class LoginWindow {
    private static let titles = ["Start Game", "Join Game"]

    private let frame: WindowFrame
    private let start: UIScriptView
    private let join: UIScriptView
    private let size: Vector2
    private let lots: [LotChoice]
    private var tab = 0

    init(start startScript: UIScript, join joinScript: UIScript, lots: [LotChoice]) {
        self.lots = lots
        frame = WindowFrame(title: Self.titles[0], theme: .simburbia)
        frame.showsCloseButton = false
        frame.toolbarItems = ["Start", "Join"]
        frame.selectedToolbarIndex = 0
        start = UIScriptView(script: startScript, theme: .simburbia)
        join = UIScriptView(script: joinScript, theme: .simburbia)
        size = Vector2(x: startScript.window.size.width, y: startScript.window.size.height + Float(WindowFrame.titleHeight))
        // Deleting and making lots wait for their own step; joining waits for networking.
        for name in ["delete", "new", "play"] { start.setDisabled(true, named: name) }
        for name in ["address", "port", "name", "password", "delete", "new"] { join.setDisabled(true, named: name) }
        let list = start.list(named: "lots")
        list?.items = lots.map { $0.isPlayers ? "\($0.name) (yours)" : $0.name }
        if lots.isEmpty {
            list?.items = ["No lots found."]
        } else {
            list?.selectedIndex = 0
            start.setDisabled(false, named: "play")
        }
    }

    /// Where the window is: centred on the screen until it's dragged.
    var bounds: Rectangle {
        frame.place(size: size, at: Vector2(x: (Float(GetScreenWidth()) - size.x) / 2,
                                            y: (Float(GetScreenHeight()) - size.y) / 2))
    }

    private var contentOrigin: Vector2 {
        let content = WindowFrame.content(in: bounds)
        return Vector2(x: content.x, y: content.y)
    }

    private var view: UIScriptView { tab == 0 ? start : join }

    /// The lot picked in the list, if any.
    private var picked: LotChoice? {
        guard let index = start.list(named: "lots")?.selectedIndex, lots.indices.contains(index) else { return nil }
        return lots[index]
    }

    /// Handles a frame's input. Returns the lot to play once Play is pressed (or Enter, with a lot
    /// picked).
    func update() -> LotChoice? {
        let bounds = self.bounds
        if frame.followPointer(in: bounds) { return nil }
        if case .toolbarItemSelected(let index) = frame.update(in: bounds), Self.titles.indices.contains(index) {
            tab = index
            frame.selectedToolbarIndex = index
            frame.title = Self.titles[index]
            view.clearFocus()
            return nil
        }
        let events = view.update(at: contentOrigin)
        guard tab == 0, let picked else { return nil }
        let play = events.contains(.pressed(control: "play")) || IsKeyPressed(.enter)
        return play ? picked : nil
    }

    func draw() {
        let bounds = self.bounds
        frame.draw(in: bounds)
        let origin = contentOrigin
        if tab == 1, let area = join.bounds(named: "servers", at: origin) {
            DrawRectangleRec(area, Color(r: 0x22, g: 0x22, b: 0x22, a: 255))
        }
        view.draw(at: origin)
        view.drawTooltip(at: origin)
    }
}
