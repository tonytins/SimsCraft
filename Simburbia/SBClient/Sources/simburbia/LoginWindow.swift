import Hudini
import LotScene
import Raylib

/// The login window of the owner's mockup (`docs/design/login-screen.png`), over the loading
/// screen's art, as TSO's and FreeSO's login dialog sits over theirs: a movable window without a
/// close button, with a Start tab to pick a lot and play it, and a Join tab to join someone else's
/// game, shown disabled until Simburbia has networking.
///
/// Hudini's window frame always has a close button, and its lists can't be picked from, so the
/// window ignores the button and draws its own list of lots in the Start tab's `lots` region.
final class LoginWindow {
    private static let titles = ["Start Game", "Join Game"]
    private static let rowHeight: Float = 20
    private static let padding: Float = 6

    private let frame: WindowFrame
    private let start: UIScriptView
    private let join: UIScriptView
    private let size: Vector2
    private let lots: [LotChoice]
    private var tab = 0
    private var picked: Int?
    private var firstRow = 0

    init(start startScript: UIScript, join joinScript: UIScript, lots: [LotChoice]) {
        self.lots = lots
        frame = WindowFrame(title: Self.titles[0], theme: .simburbia)
        frame.toolbarItems = ["Start", "Join"]
        frame.selectedToolbarIndex = 0
        start = UIScriptView(script: startScript, theme: .simburbia)
        join = UIScriptView(script: joinScript, theme: .simburbia)
        size = Vector2(x: startScript.window.size.width, y: startScript.window.size.height + Float(WindowFrame.titleHeight))
        // Deleting and making lots wait for their own step; joining waits for networking.
        for name in ["delete", "new", "play"] { start.setDisabled(true, named: name) }
        for name in ["address", "port", "name", "password", "delete", "new"] { join.setDisabled(true, named: name) }
        if !lots.isEmpty { pick(0) }
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

    /// Handles a frame's input. Returns the lot to play once Play is pressed (or Enter, with a lot
    /// picked).
    func update() -> LotChoice? {
        let bounds = self.bounds
        if frame.followPointer(in: bounds) { return nil }
        switch frame.update(in: bounds) {
        case .toolbarItemSelected(let index) where Self.titles.indices.contains(index):
            tab = index
            frame.selectedToolbarIndex = index
            frame.title = Self.titles[index]
            view.clearFocus()
            return nil
        case .close:
            // The mockup's window has none; Hudini draws one regardless, which does nothing here.
            return nil
        default:
            break
        }
        let events = view.update(at: contentOrigin)
        guard tab == 0 else { return nil }
        updateList()
        let play = events.contains(.pressed(control: "play")) || (IsKeyPressed(.enter) && picked != nil)
        guard play, let picked, lots.indices.contains(picked) else { return nil }
        return lots[picked]
    }

    private func pick(_ index: Int) {
        picked = index
        start.setDisabled(false, named: "play")
    }

    /// Picks the row clicked, and scrolls with the wheel.
    private func updateList() {
        guard let area = start.bounds(named: "lots", at: contentOrigin) else { return }
        let mouse = GetMousePosition()
        guard CheckCollisionPointRec(mouse, area) else { return }
        let visible = max(1, Int((area.height - Self.padding * 2) / Self.rowHeight))
        let wheel = GetMouseWheelMove()
        if wheel != 0 {
            firstRow = min(max(firstRow - Int(wheel.rounded()), 0), max(0, lots.count - visible))
        }
        if IsMouseButtonPressed(.left) {
            let row = firstRow + Int((mouse.y - area.y - Self.padding) / Self.rowHeight)
            if lots.indices.contains(row) { pick(row) }
        }
    }

    func draw() {
        let bounds = self.bounds
        frame.draw(in: bounds)
        let origin = contentOrigin
        if tab == 0 {
            drawList(at: origin)
        } else if let area = join.bounds(named: "servers", at: origin) {
            DrawRectangleRec(area, Color(r: 0x22, g: 0x22, b: 0x22, a: 255))
        }
        view.draw(at: origin)
        view.drawTooltip(at: origin)
    }

    /// The lots, one a row, the picked one highlighted, the player's own marked.
    private func drawList(at origin: Vector2) {
        guard let area = start.bounds(named: "lots", at: origin) else { return }
        let theme = InterfaceTheme.simburbia
        DrawRectangleRec(area, Color(r: 0x22, g: 0x22, b: 0x22, a: 255))
        BeginScissorMode(Int32(area.x), Int32(area.y), Int32(area.width), Int32(area.height))
        defer { EndScissorMode() }
        guard !lots.isEmpty else {
            DrawText("No lots found.", Int32(area.x + Self.padding), Int32(area.y + Self.padding), 14, theme.secondaryText)
            return
        }
        let visible = Int((area.height - Self.padding * 2) / Self.rowHeight) + 1
        for row in firstRow..<min(lots.count, firstRow + visible) {
            let y = area.y + Self.padding + Float(row - firstRow) * Self.rowHeight
            if row == picked {
                DrawRectangleRec(Rectangle(x: area.x + 2, y: y - 2, width: area.width - 4, height: Self.rowHeight), theme.selectedItem)
            }
            let name = lots[row].isPlayers ? "\(lots[row].name) (yours)" : lots[row].name
            DrawText(name, Int32(area.x + Self.padding), Int32(y + 1), 14, theme.text)
        }
    }

    /// Releases nothing yet; kept for symmetry with the other screens.
    func clearFocus() {
        start.clearFocus()
        join.clearFocus()
    }
}
