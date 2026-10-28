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

    /// Chooses the install and the lot. Without `game`, the install is `TSO_GAME_DIR`, then
    /// `TSO_BETA_DIR`, then NSOClient's MockInstall, so the client runs anywhere. Without
    /// `lot`, the lot is the owner's house on a real install and the mock lot on MockInstall.
    ///
    /// - Parameter nsoclient: the NSOClient folder, which holds MockInstall, Lots, and (next to
    ///   it) FreeSO's content.
    public init(game: String? = nil, lot: String? = nil, environment: [String: String], nsoclient: URL) {
        let mockInstall = nsoclient.appendingPathComponent("MockInstall/TSOClient", isDirectory: true)
        let installPath = game ?? environment["TSO_GAME_DIR"].flatMap { $0.isEmpty ? nil : $0 }
            ?? environment["TSO_BETA_DIR"].flatMap { $0.isEmpty ? nil : $0 }
        let usesMock = installPath == nil
        gameDirectory = installPath.map { URL(fileURLWithPath: $0, isDirectory: true) } ?? mockInstall
        self.lot = lot.map { URL(fileURLWithPath: $0) }
            ?? nsoclient.appendingPathComponent(usesMock ? "MockInstall/Lots/mock-lot.xml" : "Lots/tonys-house.xml")
        // FreeSO's patches target real installs; MockInstall is made up and has none.
        freeSOContent = usesMock ? nil
            : nsoclient.appendingPathComponent("../TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
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
    /// Whether time is stopped.
    public var isPaused = false
    /// The index into ``speeds``.
    public private(set) var speedIndex = 0
    private var owedTicks = 0.0

    /// Loads the install and the lot, and runs one tick so the lot's rooms exist.
    public init(_ options: ClientOptions) throws(ClientError) {
        let content: GameContent
        do {
            let configuration = options.freeSOContent.map {
                GameContent.Configuration(gameDirectory: options.gameDirectory, freeSOContentDirectory: $0)
            } ?? GameContent.Configuration(gameDirectory: options.gameDirectory)
            content = try GameContent(configuration)
        } catch {
            throw .content("\(options.gameDirectory.path): \(error)")
        }
        let xml: Data
        do {
            xml = try Data(contentsOf: options.lot)
        } catch {
            throw .lot("\(options.lot.path) can't be read: \(error.localizedDescription)")
        }
        do {
            let blueprint = try Blueprint(xml: xml)
            vm = try VM(content: content, seed: 1)
            leftOut = try vm.load(blueprint)
        } catch {
            throw .lot("\(options.lot.path): \(error)")
        }
        lotName = options.lot.deletingPathExtension().lastPathComponent
        vm.tick()
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

    /// The game time as `h:mm`.
    public var clockText: String {
        let clock = vm.clock
        return "\(clock.hours):" + (clock.minutes < 10 ? "0" : "") + "\(clock.minutes)"
    }
}
