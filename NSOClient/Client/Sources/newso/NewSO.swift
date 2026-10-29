import ArgumentParser
import Foundation
import LotScene

/// The `newso` command: NewSO's client, as far as it goes.
@main
struct NewSO: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "newso",
        abstract: "Load a lot from a TSO install, run it, and show it.",
        discussion: """
        Without --game, the install is $TSO_GAME_DIR, then $TSO_BETA_DIR, then NSOClient's \
        MockInstall. Until the game's sprites decode, objects are drawn as boxes.
        """
    )

    @Option(help: "The TSO install to read.")
    var game: String?

    @Option(help: "The blueprint XML of the lot (default: the owner's house, or the mock lot on MockInstall).")
    var lot: String?

    @Option(help: "Run the lot hidden, save one frame here, and quit, for checking a change without a screen.")
    var screenshot: String?

    @Option(help: "Ticks to run before the screenshot, 30 a second (default: 300).")
    var ticks: Int?

    @Option(help: "The zoom to start at, 1 (closest, TSO's near) to 5 (default: the one that fits the lot).")
    var zoom: Int?

    @Option(help: "The tile to center on, as x,y (default: the lot's middle).")
    var focus: String?

    @Option(help: "Quarter turns of the view to start with, 0 to 3.")
    var rotation = 0

    func validate() throws {
        if let zoom, !(1...5).contains(zoom) { throw ValidationError("--zoom takes 1 to 5") }
        guard (0...3).contains(rotation) else { throw ValidationError("--rotation takes 0 to 3") }
        if let focus, focusTile(focus) == nil { throw ValidationError("--focus takes a tile as x,y, such as 32,30") }
        guard let ticks else { return }
        guard screenshot != nil else { throw ValidationError("--ticks only goes with --screenshot") }
        guard ticks >= 0 else { throw ValidationError("--ticks can't be negative") }
    }

    func run() throws {
        let options = ClientOptions(game: game, lot: lot, environment: ProcessInfo.processInfo.environment,
                                    nsoclient: Self.nsoclient)
        // A ClientError says what to fix; ArgumentParser prints it and exits with a failure.
        let session = try LotSession(options)
        for missing in session.leftOut {
            let guid = String(missing.object.guid, radix: 16)
            FileHandle.standardError.write(Data("newso: left out object 0x\(guid): \(missing.reason)\n".utf8))
        }

        let app = ClientApp(session: session, hidden: screenshot != nil, zoomStep: zoom.map { $0 - 1 }, focus: focus.flatMap(focusTile),
                            rotation: rotation)
        if let screenshot {
            guard app.saveScreenshot(to: screenshot, after: ticks ?? 300) else {
                throw Failure(description: "couldn't save the screenshot to \(screenshot)")
            }
        } else {
            app.run()
        }
    }

    private func focusTile(_ text: String) -> SIMD2<Float>? {
        let parts = text.split(separator: ",").compactMap { Float($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 2, parts.allSatisfy(\.isFinite) else { return nil }
        return SIMD2(parts[0], parts[1])
    }

    /// The NSOClient folder, which holds MockInstall and Lots.
    static let nsoclient = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
}

/// A failure to report, which exits with a nonzero status.
struct Failure: Error, CustomStringConvertible {
    var description: String
}
