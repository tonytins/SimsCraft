import Foundation
import SimAntics
import TSOContent

/// What the client was asked to show, from its command line and the environment.
public struct ClientOptions: Sendable, Equatable {
    /// The TSO install to read.
    public var gameDirectory: URL
    /// The blueprint XML of the lot to load.
    public var lot: URL
    /// FreeSO's content folder, for its patches and standalone objects; `nil` for none.
    public var freeSOContent: URL?
    /// Simburbia's mods folder, with a player's objects and patches; `nil` for none.
    public var modsDirectory: URL?

    /// Chooses the install and the lot. Without `game`, the install is the first of `installs`
    /// (``InstallKind`` order: `TSO_GAME_DIR`, `TSO_CLASSIC_DIR`, `TSO_BETA_DIR`), then
    /// Simburbia's MockInstall, so the client runs anywhere. Without `lot`, the lot is the
    /// owner's house on a real install and the mock lot on MockInstall.
    ///
    /// - Parameters:
    ///   - installs: the installs the configuration names, as ``InstallKind/installs(named:)``
    ///     lists them.
    ///   - simburbiaFolder: the Simburbia folder, which holds MockInstall, Lots, and (next to it)
    ///     FreeSO's content.
    ///   - freeSOContent: FreeSO's content folder, as ``FreeSOContentLocator`` finds it, or `nil`
    ///     for the copy in SimsCraft's FreeSO snapshot. MockInstall gets none either way:
    ///     FreeSO's patches target real installs.
    ///   - modsDirectory: Simburbia's mods folder (``UserFolderLocator/modsDirectory()``), or `nil`.
    public init(game: String? = nil, lot: String? = nil, installs: [NamedInstall], simburbiaFolder: URL,
                freeSOContent: URL? = nil, modsDirectory: URL? = nil) {
        let mockInstall = simburbiaFolder.appendingPathComponent("MockInstall/TSOClient", isDirectory: true)
        let chosen = game.map { URL(fileURLWithPath: $0, isDirectory: true) } ?? installs.first?.directory
        let usesMock = chosen == nil
        gameDirectory = chosen ?? mockInstall
        self.lot = lot.map { URL(fileURLWithPath: $0) }
            ?? simburbiaFolder.appendingPathComponent(usesMock ? "MockInstall/Lots/mock-lot.xml" : "Lots/tonys-house.xml")
        // FreeSO's patches target real installs; MockInstall is made up and has none.
        self.freeSOContent = usesMock ? nil
            : freeSOContent ?? simburbiaFolder.appendingPathComponent("../TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
        self.modsDirectory = modsDirectory
    }
}

extension ClientOptions {
    /// The lot's blueprint in TSO's dialect, with each object named from its `OBJD` (see
    /// `docs/sb/blueprints.md`): how a lot saved in FreeSO's dialect becomes one people can read.
    /// The lot is read, not run.
    public func blueprintInTSOsDialect() throws(ClientError) -> Data {
        let content: GameContent
        do {
            content = try GameContent(.init(gameDirectory: gameDirectory, freeSOContentDirectory: freeSOContent,
                                            modsDirectory: modsDirectory))
        } catch {
            throw .content("\(gameDirectory.path): \(error)")
        }
        do {
            return try Blueprint(xml: try Data(contentsOf: lot)).namingObjects(from: content).xml()
        } catch {
            throw .lot("\(lot.path): \(error)")
        }
    }
}

extension ClientOptions {
    /// Where the client finds Simburbia's own files, MockInstall and Lots: beside the executable,
    /// as the Linux and Windows packages lay them out (`Simburbia/packaging`), or in the app's
    /// `Resources`, as macOS's does; else the source folder, for a build run from the repository.
    public static func simburbiaFolder(executableFolder: URL?, sourceFolder: URL) -> URL {
        guard let executableFolder else { return sourceFolder }
        let candidates = [executableFolder, executableFolder.deletingLastPathComponent().appendingPathComponent("Resources")]
        return candidates.first { folder in
            ["Lots", "MockInstall"].allSatisfy { name in
                var isFolder: ObjCBool = false
                return FileManager.default.fileExists(atPath: folder.appendingPathComponent(name).path, isDirectory: &isFolder)
                    && isFolder.boolValue
            }
        } ?? sourceFolder
    }
}

/// Why the client couldn't start.
public enum ClientError: Error, Equatable, CustomStringConvertible {
    /// The install couldn't be read.
    case content(String)
    /// The lot couldn't be read or loaded.
    case lot(String)

    public var description: String {
        switch self {
        case .content(let message): "couldn't read the install: \(message)"
        case .lot(let message): "couldn't load the lot: \(message)"
        }
    }
}

/// A lot running in the VM, advanced in real time at TSO's 30 ticks a second.
public final class LotSession {
    /// TSO's tick rate: 150 ticks a game minute, a game minute every five seconds.
    public static let ticksPerSecond = 30.0
    /// The speeds the player can pick, as multiples of real time.
    public static let speeds = [1, 3, 10]
    /// The most ticks one frame runs, so a slow frame can't snowball into slower ones.
    public static let mostTicksPerFrame = 30

    /// The running lot.
    public let vm: VM
    /// The lot's file name, for display.
    public let lotName: String
    /// Objects the lot names that the install doesn't have, left out of it.
    public let leftOut: [VM.LeftOut]
    /// The objects the blueprint marks `hidden="1"`, by object ID, each with its GUID so an ID a
    /// later object reuses isn't hidden too. TSO's job lots mark their portals this way; it's the
    /// lot format's, not SimAntics', so the client applies it, and the VM never sees it.
    public let hiddenByBlueprint: [Int16: UInt32]
    /// Problems loading the content, such as a broken mod; see ``SystemMessages/contentProblems(of:)``.
    public let contentProblems: [String]
    /// The install's floors, for drawing them; `nil` if they couldn't be read, and the client
    /// draws floors as plain tiles instead, with why in ``contentProblems``.
    public let floors: FloorImages?
    /// The install's walls, for drawing them; `nil` if they couldn't be read, and the client draws
    /// walls as boxes instead, with why in ``contentProblems``.
    public let walls: WallImages?
    /// Whether time is stopped.
    public var isPaused = false
    /// The index into ``speeds``.
    public private(set) var speedIndex = 0
    private var owedTicks = 0.0

    /// Loads the install and the lot, and runs one tick so the lot's rooms exist.
    ///
    /// - Parameter progress: Told how far loading has got, as a fraction: a quarter when the
    ///   install's content is ready, a half when its floors and walls are, and three quarters when
    ///   the lot has loaded and run its first tick. The rest is left to the client, which has
    ///   textures to make. It's called on the thread loading runs on.
    public init(_ options: ClientOptions, progress: (Double) -> Void = { _ in }) throws(ClientError) {
        let content: GameContent
        do {
            // The client draws objects, so it loads their sprite files too.
            content = try GameContent(.init(gameDirectory: options.gameDirectory, freeSOContentDirectory: options.freeSOContent,
                                            modsDirectory: options.modsDirectory, loadsSprites: true))
        } catch {
            throw .content("\(options.gameDirectory.path): \(error)")
        }
        progress(0.25)
        var problems = SystemMessages.contentProblems(of: content)
        do {
            let provider = try FloorProvider(files: content.files)
            problems += provider.failures.map { "Floor \($0.path) can't be read: \($0.reason)" }
            floors = FloorImages(floors: provider)
        } catch {
            problems.append("The floors can't be read, so they're drawn plain: \(error)")
            floors = nil
        }
        do {
            let provider = try WallProvider(files: content.files)
            problems += provider.failures.map { "Wall \($0.path) can't be read: \($0.reason)" }
            walls = WallImages(walls: provider, floors: floors, objects: content.objects)
        } catch {
            problems.append("The walls can't be read, so they're drawn plain: \(error)")
            walls = nil
        }
        contentProblems = problems
        progress(0.5)
        let xml: Data
        do {
            xml = try Data(contentsOf: options.lot)
        } catch {
            throw .lot("\(options.lot.path) can't be read: \(error.localizedDescription)")
        }
        do {
            let blueprint = try Blueprint(xml: xml)
            vm = try VM(content: content, seed: 1)
            let loaded = try vm.loadLot(blueprint)
            leftOut = loaded.leftOut
            var hidden: [Int16: UInt32] = [:]
            for (object, ids) in zip(blueprint.objects, loaded.objectIDs) where object.isHidden {
                for id in ids { hidden[id] = vm.entity(id: id)?.object.guid }
            }
            hiddenByBlueprint = hidden
        } catch {
            throw .lot("\(options.lot.path): \(error)")
        }
        lotName = options.lot.deletingPathExtension().lastPathComponent
        vm.tick()
        progress(0.75)
    }

    /// The current speed as a multiple of real time.
    public var speed: Int { Self.speeds[speedIndex] }

    /// Picks a speed by its index in ``speeds``, ignoring one that isn't there.
    public func setSpeed(index: Int) {
        guard Self.speeds.indices.contains(index) else { return }
        speedIndex = index
    }

    /// Runs the ticks owed for `seconds` of real time, and returns how many ran.
    @discardableResult
    public func advance(seconds: Double) -> Int {
        guard !isPaused, seconds.isFinite, seconds > 0 else { return 0 }
        owedTicks += seconds * Self.ticksPerSecond * Double(speed)
        let count = min(Int(owedTicks), Self.mostTicksPerFrame)
        // A frame that hit the cap drops its backlog, so the next frame doesn't pay for it.
        owedTicks = count == Self.mostTicksPerFrame ? 0 : owedTicks - Double(count)
        for _ in 0..<count { vm.tick() }
        return count
    }

    /// A story's name as the top bar shows it: 1 is "1st Floor", 2 "2nd Floor", and so on.
    public static func floorName(_ level: Int) -> String {
        let suffix = switch (level % 100, level % 10) {
        case (11...13, _): "th"
        case (_, 1): "st"
        case (_, 2): "nd"
        case (_, 3): "rd"
        default: "th"
        }
        return "\(level)\(suffix) Floor"
    }

    /// Every system message so far: the content's problems, floors and walls that couldn't be decoded, then
    /// each error the VM reported.
    public var systemMessages: [String] {
        contentProblems + (floors?.failures ?? []) + (walls?.failures ?? []) + SystemMessages.messages(of: vm)
    }

    /// The game time as `h:mm`.
    public var clockText: String {
        let clock = vm.clock
        return "\(clock.hours):" + (clock.minutes < 10 ? "0" : "") + "\(clock.minutes)"
    }
}
