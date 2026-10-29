import ArgumentParser
import Configuration
import Foundation
import LotScene
import SimAntics
import TSOConfig
import TSOContent

/// The `newso` command: NewSO's client, as far as it goes.
@main
struct NewSO: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "newso",
        abstract: "Load a lot from a TSO install, run it, and show it.",
        discussion: """
        Without --game, the install is $TSO_GAME_DIR, then $TSO_CLASSIC_DIR, then $TSO_BETA_DIR, \
        then NSOClient's MockInstall. Objects without sprites for the view are drawn as boxes.

        With --headless, no window opens: the lot runs --ticks ticks as fast as the machine allows \
        and logs what happens to standard error, then exits. --verbose logs the same while the \
        window is open.
        """
    )

    @Option(help: "The TSO install to read.")
    var game: String?

    @Option(help: "The blueprint XML of the lot (default: the owner's house, or the mock lot on MockInstall).")
    var lot: String?

    @Option(help: "Run the lot hidden, save one frame here, and quit, for checking a change without a screen.")
    var screenshot: String?

    @Flag(help: "Run with no window: tick the lot --ticks times as fast as possible, log what happens, and exit.")
    var headless = false

    @Flag(help: "Log the run to standard error: system messages as they arrive and a line each game hour. --headless implies it.")
    var verbose = false

    @Option(help: """
        With --headless: how many ticks the run takes, 0 to \(Self.mostTicks), a game week (default \(Self.defaultHeadlessTicks), \
        a game day). With --screenshot: ticks to run before it (default 300). 30 ticks are a second at normal speed.
        """)
    var ticks: Int?

    @Option(help: "The zoom to start at, 1 (closest, TSO's near) to 5 (default: the one that fits the lot).")
    var zoom: Int?

    @Option(help: "The tile to center on, as x,y (default: the lot's middle).")
    var focus: String?

    @Option(help: "Quarter turns of the view to start with, 0 to 3.")
    var rotation = 0

    /// A game day at TSO's 150 ticks a game minute, the default length of a headless run.
    static let defaultHeadlessTicks = 216_000
    /// A game week: the longest run, so a mistyped count can't run for hours.
    static let mostTicks = 7 * defaultHeadlessTicks

    func validate() throws {
        if let zoom, !(1...5).contains(zoom) { throw ValidationError("--zoom takes 1 to 5") }
        guard (0...3).contains(rotation) else { throw ValidationError("--rotation takes 0 to 3") }
        if let focus, focusTile(focus) == nil { throw ValidationError("--focus takes a tile as x,y, such as 32,30") }
        // A headless run must never open a window, so the options that need one are refused.
        if headless {
            let windowOnly = [("--screenshot", screenshot != nil), ("--zoom", zoom != nil), ("--focus", focus != nil),
                              ("--rotation", rotation != 0)].filter(\.1).map(\.0)
            if let first = windowOnly.first { throw ValidationError("\(first) needs a window, so it can't run with --headless") }
        }
        guard let ticks else { return }
        guard headless || screenshot != nil else {
            throw ValidationError("--ticks only applies with --headless or --screenshot; the window runs until it is closed")
        }
        guard (0...Self.mostTicks).contains(ticks) else { throw ValidationError("--ticks takes 0 to \(Self.mostTicks), a game week") }
    }

    func run() throws {
        let config = ConfigReader(provider: EnvironmentVariablesProvider())
        let installs = InstallKind.installs(in: config)
        let snapshot = Self.nsoclient.appendingPathComponent("../TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
        let options = ClientOptions(game: game, lot: lot, installs: installs, nsoclient: Self.nsoclient,
                                    freeSOContent: try FreeSOContentLocator(config: config, fallback: snapshot).locate(),
                                    modsDirectory: try UserFolderLocator(config: config).modsDirectory())
        // A ClientError says what to fix; ArgumentParser prints it and exits with a failure.
        let session = try LotSession(options)
        let logs = headless || verbose
        if logs {
            RunLog.bootstrap()
        } else {
            for missing in session.leftOut {
                let guid = String(missing.object.guid, radix: 16)
                FileHandle.standardError.write(Data("newso: left out object 0x\(guid): \(missing.reason)\n".utf8))
            }
        }
        if headless {
            HeadlessRun.run(session, ticks: ticks ?? Self.defaultHeadlessTicks, install: Self.describe(options.gameDirectory))
            return
        }

        let log = logs ? RunLog(session: session, install: Self.describe(options.gameDirectory)) : nil
        let app = ClientApp(session: session, hidden: screenshot != nil, zoomStep: zoom.map { $0 - 1 }, focus: focus.flatMap(focusTile),
                            rotation: rotation, log: log)
        if let screenshot {
            guard app.saveScreenshot(to: screenshot, after: ticks ?? 300) else {
                throw Failure(description: "couldn't save the screenshot to \(screenshot)")
            }
        } else {
            app.run()
        }
    }

    /// An install as the log names it: its folder and the version its `version` file records.
    static func describe(_ directory: URL) -> String {
        let version = (try? GameVersion.read(install: directory)).flatMap { $0 }.map { " (\($0))" } ?? ""
        return directory.path + version
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
