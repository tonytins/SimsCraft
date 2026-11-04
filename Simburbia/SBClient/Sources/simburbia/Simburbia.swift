import ArgumentParser
import Configuration
import Foundation
import LotScene
import Raylib
import SimAntics
import TSOConfig
import TSOContent

/// The `simburbia` command: Simburbia's client, as far as it goes.
@main
struct Simburbia: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simburbia",
        abstract: "Load a lot from a TSO install, run it, and show it.",
        discussion: """
        Without --game, the install is $TSO_GAME_DIR, then $TSO_CLASSIC_DIR, then $TSO_BETA_DIR, \
        then Simburbia's MockInstall. Objects without sprites for the view are drawn as boxes.

        With --headless, no window opens: the lot runs --ticks ticks as fast as the machine allows \
        and logs what happens to standard error, then exits. --verbose logs the same while the \
        window is open.
        """,
        version: "Simburbia \(GitVersion.version)"
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

    @Option(help: "Write the lot's blueprint in TSO's dialect, with each object named, to this file, and quit; the lot isn't run.")
    var rewriteBlueprint: String?

    @Option(help: "The zoom to start at, 1 (closest, TSO's near) to 5 (default: the one that fits the lot).")
    var zoom: Int?

    @Option(help: "The tile to center on, as x,y (default: the lot's middle).")
    var focus: String?

    @Option(help: "Quarter turns of the view to start with, 0 to 3.")
    var rotation = 0

    @Option(help: "TSO's wall mode for the floor in view to start with: cutaway (the default), down, or up.")
    var walls: WallMode = .cutaway

    @Option(help: "Run hidden, save a frame of the loading screen here as its second line slides in, and quit.")
    var loadingScreenshot: String?

    /// How long the loading screen stays once everything has loaded and its last line has
    /// settled, in seconds: time for the engine to settle before the lot appears.
    static let loadingBuffer = 0.5

    /// A game day at TSO's 150 ticks a game minute, the default length of a headless run.
    static let defaultHeadlessTicks = 216_000
    /// A game week: the longest run, so a mistyped count can't run for hours.
    static let mostTicks = 7 * defaultHeadlessTicks

    func validate() throws {
        if let zoom, !(1...5).contains(zoom) { throw ValidationError("--zoom takes 1 to 5") }
        guard (0...3).contains(rotation) else { throw ValidationError("--rotation takes 0 to 3") }
        if let focus, focusTile(focus) == nil { throw ValidationError("--focus takes a tile as x,y, such as 32,30") }
        if rewriteBlueprint != nil {
            let others = [("--headless", headless), ("--screenshot", screenshot != nil), ("--ticks", ticks != nil)].filter(\.1).map(\.0)
            if let first = others.first { throw ValidationError("--rewrite-blueprint doesn't run the lot, so it can't take \(first)") }
        }
        // A headless run must never open a window, so the options that need one are refused.
        if screenshot != nil, loadingScreenshot != nil {
            throw ValidationError("--screenshot and --loading-screenshot each take the one frame; pick one")
        }
        if headless {
            let windowOnly = [("--screenshot", screenshot != nil), ("--loading-screenshot", loadingScreenshot != nil),
                              ("--zoom", zoom != nil), ("--focus", focus != nil), ("--rotation", rotation != 0)].filter(\.1).map(\.0)
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
        let snapshot = Self.simburbiaFolder.appendingPathComponent("../TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
        let options = ClientOptions(game: game, lot: lot, installs: installs, simburbiaFolder: Self.simburbiaFolder,
                                    freeSOContent: try FreeSOContentLocator(config: config, fallback: snapshot).locate(),
                                    modsDirectory: try UserFolderLocator(config: config).modsDirectory())
        if let rewriteBlueprint {
            let file = URL(fileURLWithPath: rewriteBlueprint)
            do {
                try options.blueprintInTSOsDialect().write(to: file, options: .atomic)
            } catch let error as ClientError {
                throw error
            } catch {
                throw Failure(description: "couldn't write \(file.path): \(error.localizedDescription)")
            }
            return
        }
        let logs = headless || verbose
        if logs { RunLog.bootstrap() }
        if headless {
            // A ClientError says what to fix; ArgumentParser prints it and exits with a failure.
            let session = try LotSession(options)
            HeadlessRun.run(session, ticks: ticks ?? Self.defaultHeadlessTicks, install: Self.describe(options.gameDirectory))
            return
        }

        // The interface's documents and the loading screen's text, read before the window opens,
        // so a missing or broken one says so instead of leaving the window blank.
        let (interface, warnings) = try Interface.load(from: Self.simburbiaFolder)
        let (text, textWarnings) = LoadingText.load(gameDirectory: options.gameDirectory, simburbiaFolder: Self.simburbiaFolder)
        for warning in warnings + textWarnings {
            FileHandle.standardError.write(Data("simburbia: \(warning)\n".utf8))
        }
        let hidden = screenshot != nil || loadingScreenshot != nil
        ClientWindow.open(hidden: hidden)
        let loading = LoadingScreen(text: text, logo: Self.simburbiaFolder.appendingPathComponent("Interface/logo.png"))
        let loader = SessionLoader(options)
        var loaded: ClientApp?
        var settledAt: Double?
        while true {
            if WindowShouldClose() {
                loading.unload()
                CloseWindow()
                return
            }
            if loaded == nil, let result = loader.take() {
                let session: LotSession
                switch result {
                case .success(let made):
                    session = made
                case .failure(let error):
                    loading.unload()
                    CloseWindow()
                    throw error
                }
                if !logs {
                    for missing in session.leftOut {
                        let guid = String(missing.object.guid, radix: 16)
                        FileHandle.standardError.write(Data("simburbia: left out object 0x\(guid): \(missing.reason)\n".utf8))
                    }
                }
                let log = logs ? RunLog(session: session, install: Self.describe(options.gameDirectory)) : nil
                let app = ClientApp(session: session, interface: interface, hidden: hidden, zoomStep: zoom.map { $0 - 1 },
                                    focus: focus.flatMap(focusTile), rotation: rotation, walls: walls, log: log)
                app.warmUp()
                loaded = app
            }
            // The textures are the last quarter; the loading thread reports the rest.
            let progress = loaded == nil ? min(loader.progress, 0.75) : 1
            // A loading screenshot steps evenly, so its frame is the same each time; a lot's
            // screenshot doesn't wait for the slides.
            let seconds = loadingScreenshot != nil ? 1.0 / 60 : screenshot != nil ? SlidingLines.slideSeconds : Double(GetFrameTime())
            loading.advance(seconds: seconds, progress: progress)
            loading.draw()
            if let loadingScreenshot {
                let lines = loading.lines
                guard (lines.current >= 1 && lines.slid >= 0.5) || lines.isFinished(progress: progress) else { continue }
                let image = LoadImageFromScreen()
                let saved = ExportImage(image, loadingScreenshot)
                UnloadImage(image)
                loading.unload()
                CloseWindow()
                guard saved else { throw Failure(description: "couldn't save the screenshot to \(loadingScreenshot)") }
                // The loading thread may still be running; the process ends with it.
                return
            }
            guard loading.lines.isFinished(progress: progress) else { continue }
            let settled = settledAt ?? GetTime()
            settledAt = settled
            if screenshot != nil || GetTime() - settled >= Self.loadingBuffer { break }
        }
        loading.unload()
        guard let app = loaded else { return }
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

    /// The folder that holds MockInstall and Lots: beside the executable in a package, else the
    /// Simburbia folder this was built from.
    static let simburbiaFolder = ClientOptions.simburbiaFolder(
        executableFolder: Bundle.main.executableURL?.deletingLastPathComponent(),
        sourceFolder: URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent())
}

/// A failure to report, which exits with a nonzero status.
struct Failure: Error, CustomStringConvertible {
    var description: String
}

/// TSO's wall modes for the floor in view: walls cut down around what the player's looking at,
/// cut down everywhere, or standing.
enum WallMode: String, ExpressibleByArgument, CaseIterable {
    case cutaway, down, up

    /// The next mode, as W steps through them.
    var next: WallMode {
        switch self {
        case .cutaway: .down
        case .down: .up
        case .up: .cutaway
        }
    }
}
