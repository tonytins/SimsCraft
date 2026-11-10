import ArgumentParser
import Configuration
import Foundation
import Hudini
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

    @Option(help: "Run hidden, save a frame of the login window here once the install has loaded, and quit.")
    var loginScreenshot: String?

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
        if [screenshot, loadingScreenshot, loginScreenshot].compactMap({ $0 }).count > 1 {
            throw ValidationError("--screenshot, --loading-screenshot, and --login-screenshot each take the one frame; pick one")
        }
        if loginScreenshot != nil, lot != nil {
            throw ValidationError("--login-screenshot shows the login window, which --lot skips")
        }
        if headless {
            let windowOnly = [("--screenshot", screenshot != nil), ("--loading-screenshot", loadingScreenshot != nil),
                              ("--login-screenshot", loginScreenshot != nil),
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
        let snapshot = Self.simburbiaFolder.appendingPathComponent("FreeSO/TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
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
        let (art, artWarning) = LoadingScreen.setupArt(gameDirectory: options.gameDirectory)
        for warning in warnings + textWarnings + (artWarning.map { [$0] } ?? []) {
            FileHandle.standardError.write(Data("simburbia: \(warning)\n".utf8))
        }
        let hidden = screenshot != nil || loadingScreenshot != nil || loginScreenshot != nil
        ClientWindow.open(hidden: hidden)
        let loading = LoadingScreen(text: text, art: art, logo: Self.simburbiaFolder.appendingPathComponent("Interface/logo.png"))
        // Run the lot asked for, or for a screenshot of the lot or of loading, the default one;
        // otherwise load the install, then let the player pick a lot in the login window.
        let goesStraightToLot = options.lotWasChosen || screenshot != nil || loadingScreenshot != nil
        var lot = options.lot
        var install: LoadedInstall?
        if !goesStraightToLot {
            let installLoad = BackgroundLoad { progress throws(ClientError) in try LoadedInstall(options, progress: progress) }
            guard let loaded = try showLoading(loading, installLoad, threadShare: 1) else { return }
            install = loaded
            let userFolder = try? UserFolderLocator(config: ConfigReader(provider: EnvironmentVariablesProvider())).locate()
            let lots = LotChoices.lots(simburbiaFolder: Self.simburbiaFolder, includesMockLots: options.usesMockInstall, userFolder: userFolder)
            let login = LoginWindow(start: interface.loginStart, join: interface.loginJoin, lots: lots)
            guard let chosen = try showLogin(loading, login) else { return }
            lot = chosen.url
            loading.restart()
        }
        let lotLoad: BackgroundLoad<LotSession>
        if let install {
            let chosenLot = lot
            lotLoad = BackgroundLoad { _ throws(ClientError) in try LotSession(install: install, lot: chosenLot) }
        } else {
            lotLoad = BackgroundLoad { progress throws(ClientError) in try LotSession(options, progress: progress) }
        }
        var app: ClientApp?
        let loadedSession = try showLoading(loading, lotLoad, threadShare: 0.75) { session in
            if !logs {
                for missing in session.leftOut {
                    let guid = String(missing.object.guid, radix: 16)
                    FileHandle.standardError.write(Data("simburbia: left out object 0x\(guid): \(missing.reason)\n".utf8))
                }
            }
            let log = logs ? RunLog(session: session, install: Self.describe(options.gameDirectory)) : nil
            let made = ClientApp(session: session, interface: interface, hidden: hidden, zoomStep: zoom.map { $0 - 1 },
                                 focus: focus.flatMap(focusTile), rotation: rotation, walls: walls, log: log)
            made.warmUp()
            app = made
        }
        loading.unload()
        guard loadedSession != nil, let app else { return }
        if let screenshot {
            guard app.saveScreenshot(to: screenshot, after: ticks ?? 300) else {
                throw Failure(description: "couldn't save the screenshot to \(screenshot)")
            }
        } else {
            app.run()
        }
    }

    /// Shows the loading screen while `load` runs, until it has finished and the lines have each
    /// had their turn, then a little longer (``loadingBuffer``), and returns what it made. `ready`
    /// runs once on the frame loop when it arrives, for work that needs the window, such as
    /// making textures; until then `load` counts for `threadShare` of the progress.
    ///
    /// Returns `nil` if the window was closed or a loading screenshot was taken, having closed the
    /// window; a failure to load closes it and throws.
    private func showLoading<Value>(_ loading: LoadingScreen, _ load: BackgroundLoad<Value>, threadShare: Double,
                                    ready: (Value) -> Void = { _ in }) throws -> Value? {
        var value: Value?
        var settledAt: Double?
        while true {
            if WindowShouldClose() {
                loading.unload()
                CloseWindow()
                return nil
            }
            if value == nil, let result = load.take() {
                switch result {
                case .success(let made):
                    ready(made)
                    value = made
                case .failure(let error):
                    loading.unload()
                    CloseWindow()
                    throw error
                }
            }
            let progress = value == nil ? min(load.progress, threadShare) : 1
            // A loading screenshot steps evenly, so its frame is the same each time; a lot's
            // screenshot doesn't wait for the slides.
            let seconds = loadingScreenshot != nil ? 1.0 / 60 : screenshot != nil ? SlidingLines.slideSeconds : Double(GetFrameTime())
            loading.advance(seconds: seconds, progress: progress)
            loading.draw()
            if let loadingScreenshot {
                let lines = loading.lines
                guard (lines.current >= 1 && lines.slid >= 0.5) || lines.isFinished(progress: progress) else { continue }
                try Self.capture(to: loadingScreenshot)
                loading.unload()
                CloseWindow()
                // A loading thread may still be running; the process ends with it.
                return nil
            }
            guard loading.lines.isFinished(progress: progress), let made = value else { continue }
            let settled = settledAt ?? GetTime()
            settledAt = settled
            if screenshot != nil || GetTime() - settled >= Self.loadingBuffer { return made }
        }
    }

    /// Shows the login window over the loading screen's art, with Simburbia's version at the
    /// bottom right (as TSO's login screen shows its own at the bottom left, and FreeSO's after it),
    /// until a lot is picked to play. Returns `nil` if the window was closed or a login screenshot
    /// was taken, having closed the window.
    private func showLogin(_ loading: LoadingScreen, _ login: LoginWindow) throws -> LotChoice? {
        let version = "Version \(GitVersion.version)"
        while true {
            if WindowShouldClose() {
                loading.unload()
                CloseWindow()
                return nil
            }
            let chosen = login.update()
            loading.draw(showsLines: false) {
                login.draw()
                let size: Int32 = 16
                let width = MeasureText(version, size)
                DrawText(version, GetScreenWidth() - width - 20, GetScreenHeight() - size - 16, size, InterfaceTheme.simburbia.text)
            }
            if let loginScreenshot {
                try Self.capture(to: loginScreenshot)
                loading.unload()
                CloseWindow()
                return nil
            }
            if let chosen { return chosen }
        }
    }

    /// Saves what was last drawn.
    private static func capture(to path: String) throws {
        let image = LoadImageFromScreen()
        let saved = ExportImage(image, path)
        UnloadImage(image)
        guard saved else { throw Failure(description: "couldn't save the screenshot to \(path)") }
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
