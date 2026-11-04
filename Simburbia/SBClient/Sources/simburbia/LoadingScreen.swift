import Foundation
import Hudini
import LotScene
import Raylib

/// What the loading screen says: a caption and the lines that slide in under it.
///
/// With an install, its own: TSO's caption (table 154, entry 5) and its four loading lines
/// (table 155, entries 6 to 9), read from `gamedata`'s text as FreeSO's `LoadingScreen` reads them.
/// Without one, or if any are missing, Simburbia's (`Interface/uitext/_1_loading.cst`).
struct LoadingText {
    var caption: String
    var lines: [String]

    /// Simburbia's own, if even its table can't be read.
    static let builtIn = LoadingText(caption: "Simburbia is getting ready", lines: ["Loading"])

    /// The install's text, else Simburbia's, and anything worth telling about why.
    static func load(gameDirectory: URL, simburbiaFolder: URL) -> (text: LoadingText, warnings: [String]) {
        if let catalog = try? CSTCatalog(gameData: gameDirectory.appendingPathComponent("gamedata", isDirectory: true)),
           let caption = catalog.text(table: 154, key: "5") {
            let lines = (6...9).compactMap { catalog.text(table: 155, key: "\($0)") }
            if lines.count == 4 { return (LoadingText(caption: caption, lines: lines), []) }
        }
        let folder = simburbiaFolder.appendingPathComponent("Interface/uitext", isDirectory: true)
        do {
            let catalog = try CSTCatalog(directory: folder)
            let warnings = (catalog.table(1)?.problems ?? []).map { "Interface/uitext/_1_loading.cst line \($0.line): \($0.message)" }
            let lines = (1...4).compactMap { catalog.text(table: 1, key: "\($0)") }
            guard let caption = catalog.text(table: 1, key: "Caption"), !lines.isEmpty else {
                return (builtIn, warnings + ["Interface/uitext/_1_loading.cst has no caption or lines"])
            }
            return (LoadingText(caption: caption, lines: lines), warnings)
        } catch {
            return (builtIn, ["the loading text can't be read: \(error.localizedDescription)"])
        }
    }
}

/// Builds a lot's session on another thread, so the window keeps drawing while it loads.
///
/// The session isn't shared: it's built on the loading thread, then handed to the frame loop
/// once, under the lock, and only the frame loop uses it after that. Progress crosses the same way.
final class SessionLoader: @unchecked Sendable {
    private let lock = NSLock()
    private var _progress = 0.0
    private var _result: Result<LotSession, ClientError>?

    /// Starts loading.
    init(_ options: ClientOptions) {
        let thread = Thread { [self] in
            let result: Result<LotSession, ClientError>
            do throws(ClientError) {
                result = .success(try LotSession(options) { fraction in self.set(progress: fraction) })
            } catch {
                result = .failure(error)
            }
            lock.lock()
            _result = result
            lock.unlock()
        }
        // The content system is deep in places (nested archives, patches); give it room.
        thread.stackSize = 8 << 20
        thread.start()
    }

    private func set(progress: Double) {
        lock.lock()
        _progress = progress
        lock.unlock()
    }

    /// How far loading has got, 0 to 1.
    var progress: Double {
        lock.lock()
        defer { lock.unlock() }
        return _progress
    }

    /// The session or why it failed, once loading has finished; taken once.
    func take() -> Result<LotSession, ClientError>? {
        lock.lock()
        defer { lock.unlock() }
        let result = _result
        _result = nil
        return result
    }
}

/// The screen shown while the client loads, as TSO's: its art, its caption, and the lines sliding
/// in under it (FreeSO's `LoadingScreen` and `UISetupBackground`). Until TSO's art is read, it's
/// Simburbia's logo on TSO's dark blue.
final class LoadingScreen {
    /// `UISetupBackground`'s fill.
    static let background = Color(r: 0x09, g: 0x18, b: 0x2F, a: 255)

    private let text: LoadingText
    private var logo: Texture2D?
    private(set) var lines: SlidingLines

    init(text: LoadingText, logo path: URL) {
        self.text = text
        lines = SlidingLines(lines: text.lines)
        let texture = LoadTexture(path.path)
        if IsTextureValid(texture) {
            SetTextureFilter(texture, .bilinear)
            logo = texture
        }
    }

    /// Moves the lines on.
    func advance(seconds: Double, progress: Double) {
        lines.advance(seconds: seconds, progress: progress)
    }

    /// Draws a frame. FreeSO lays the screen out at 800 by 600, the caption at 508 and the lines
    /// at 550; here the same places are scaled to the window's height.
    func draw() {
        let width = Float(GetScreenWidth()), height = Float(GetScreenHeight())
        let scale = height / 600
        BeginDrawing()
        ClearBackground(Self.background)
        if let logo {
            let side = min(height * 0.6, width * 0.6)
            let destination = Rectangle(x: (width - side) / 2, y: height * 0.12, width: side, height: side)
            DrawTexturePro(logo, Rectangle(x: 0, y: 0, width: Float(logo.width), height: Float(logo.height)),
                           destination, .zero, 0, .white)
        }
        let size = Int32(max(12, (20 * scale).rounded()))
        centered(text.caption, y: 508 * scale + 18 * scale, size: size, offset: 0, width: width)
        let (outgoing, incoming) = lines.offsets
        if let line = lines.outgoing { centered(line, y: 550 * scale + 18 * scale, size: size, offset: Float(outgoing) * width, width: width) }
        if let line = lines.incoming { centered(line, y: 550 * scale + 18 * scale, size: size, offset: Float(incoming) * width, width: width) }
        EndDrawing()
    }

    private func centered(_ line: String, y: Float, size: Int32, offset: Float, width: Float) {
        let measured = Float(MeasureText(line, size))
        DrawText(line, Int32((width - measured) / 2 + offset), Int32(y), size, InterfaceTheme.simburbia.text)
    }

    /// Releases the logo; call before the window closes.
    func unload() {
        if let logo { UnloadTexture(logo) }
        logo = nil
    }
}
