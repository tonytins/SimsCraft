import ArgumentParser
import Foundation
import ScriptOracleCore
import SimAntics
import TSOContent

private let repositoryContent = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("TSOClient/tso.content/Content").standardizedFileURL

struct InstallOptions: ParsableArguments {
    @Option(help: "The TSO install. Defaults to $TSO_GAME_DIR.")
    var game: String?

    @Option(help: "FreeSO's Content folder, for patches and standalone objects (default: the one in this repository).")
    var content: String?

    func load() throws -> GameContent {
        guard let path = game ?? ProcessInfo.processInfo.environment["TSO_GAME_DIR"], !path.isEmpty else {
            throw ValidationError("No --game given and TSO_GAME_DIR is not set.")
        }
        return try GameContent(.init(gameDirectory: URL(fileURLWithPath: path, isDirectory: true),
                                     freeSOContentDirectory: contentDirectory))
    }

    var contentDirectory: URL {
        content.map { URL(fileURLWithPath: $0, isDirectory: true) } ?? repositoryContent
    }
}

struct LotOptions: ParsableArguments {
    @Option(help: "The lot (default: Blueprints/empty_lot_fso.xml in the content folder).")
    var blueprint: String?

    @Option(name: .customLong("leave-out"),
            help: "An object GUID (hex) to leave out of the lot, such as one fso-oracle left out. Repeatable.")
    var leaveOut: [String] = []

    func lot(in install: InstallOptions) throws -> Blueprint {
        let file = blueprint.map { URL(fileURLWithPath: $0) }
            ?? install.contentDirectory.appendingPathComponent("Blueprints/empty_lot_fso.xml")
        var lot = try Blueprint(xml: try Data(contentsOf: file))
        let guids = try Set(leaveOut.map { text throws -> UInt32 in
            let digits = text.lowercased().hasPrefix("0x") ? String(text.dropFirst(2)) : text
            guard let guid = UInt32(digits, radix: 16) else { throw ValidationError("--leave-out \(text) isn't a hex GUID") }
            return guid
        })
        lot.objects.removeAll { guids.contains($0.guid) }
        return lot
    }
    
    func leaveOutGuids() throws -> [UInt32] {
        return try leaveOut.map { text throws -> UInt32 in
            let digits = text.lowercased().hasPrefix("0x") ? String(text.dropFirst(2)) : text
            guard let guid = UInt32(digits, radix: 16) else { throw ValidationError("--leave-out \(text) isn't a hex GUID") }
            return guid
        }
    }
}

extension ScriptOracle {
    struct ListObjects: ParsableCommand {
        static let configuration = CommandConfiguration(commandName: "list-objects",
                                                        abstract: "Print what NSOClient loads for every registered object.")
        @OptionGroup var install: InstallOptions

        func run() throws {
            let content = try install.load()
            let runner = ScenarioRunner(content: content)
            let ctx = ScenarioContext(content: content)
            let lines = try runner.run("list_objects", context: ctx)
            for line in lines { print(line) }
        }
    }

    struct RunObjects: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "run-objects",
            abstract: "For each GUID on standard input, run the object alone on an empty lot and print digests.")
        @OptionGroup var install: InstallOptions
        @Option(help: "The lot (default: Blueprints/empty_lot_fso.xml in the content folder); its objects are left out.") var blueprint: String?
        @Option(help: "Ticks to run.") var ticks = 1800
        @Option(help: "Also print a digest every this many ticks (0 for only the end).") var every = 0

        func run() throws {
            let content = try install.load()
            let lotFile = blueprint.map { URL(fileURLWithPath: $0) }
                ?? install.contentDirectory.appendingPathComponent("Blueprints/empty_lot_fso.xml")
            let lot = try Blueprint(xml: try Data(contentsOf: lotFile))
            let runner = ScenarioRunner(content: content)
            let ctx = ScenarioContext(content: content, blueprint: lot, ticks: ticks, every: every)
            while let line = readLine() {
                let text = line.trimmingCharacters(in: .whitespaces)
                guard !text.isEmpty else { continue }
                guard let guid = UInt32(text, radix: 16) else {
                    print("\(text) error not a GUID")
                    continue
                }
                let prefix = String(format: "%08x", guid)
                let lines = try runner.run("run_objects", context: ctx)
                for answer in lines { print("\(prefix) \(answer)") }
            }
        }
    }

    struct RunLot: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "run-lot", abstract: "Load a lot with its objects, run it, and print digests.")
        @OptionGroup var install: InstallOptions
        @OptionGroup var lotOptions: LotOptions
        @Option(help: "Ticks to run.") var ticks = 1800
        @Option(help: "Also print a digest every this many ticks (0 for only the end).") var every = 0
        @Flag(help: "After each digest, print the digested fields of every entity, one line each.") var dump = false

        func run() throws {
            let content = try install.load()
            let lot = try lotOptions.lot(in: install)
            let runner = ScenarioRunner(content: content)
            let ctx = ScenarioContext(content: content, blueprint: lot, ticks: ticks, every: every, dump: dump, leaveOut: try lotOptions.leaveOutGuids())
            for line in try runner.run("run_lot", context: ctx) { print(line) }
        }
    }

    struct RunPrimitive: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "run-primitive", abstract: "Run a primitive on a fresh lot, as requested on stdin; answer on stdout in fso-oracle format.")
        @OptionGroup var install: InstallOptions
        @OptionGroup var lotOptions: LotOptions

        func run() throws {
            let content = try install.load()
            let lot = try lotOptions.lot(in: install)
            let runner = ScenarioRunner(content: content)
            let ctx = ScenarioContext(content: content, blueprint: lot, leaveOut: try lotOptions.leaveOutGuids())
            while let line = readLine() {
                if let result = try runner.runPrimitive(line, context: ctx) { print(result) }
            }
        }
    }

    struct RoomMaps: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "room-maps", abstract: "Print a blueprint's room maps and rooms, one JSON line each per stdin path.")
        @OptionGroup var install: InstallOptions

        func run() throws {
            let content = try install.load()
            let runner = ScenarioRunner(content: content)
            let ctx = ScenarioContext(content: content)
            while let line = readLine() {
                let file = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !file.isEmpty else { continue }
                let maps = try runner.runRoomMaps(file, context: ctx)
                if let data = try? JSONEncoder().encode(AnyEncodable(maps)) {
                    print(String(decoding: data, as: UTF8.self))
                }
            }
        }
    }

    struct Compare: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "compare", abstract: "Compare fso-oracle and sso-oracle records and report disagreements.")
        @Option(help: "Write docs/results/nso-review.md for this install section.") var review: String?
        @Flag(name: .long, help: "Exit with non-zero if there are any disagreements.") var strict = false

        func run() throws {
            let result = Comparison().compare()
            print(result)
            if strict && (result.contains("DISAGREE") || result.contains("INCONCLUSIVE")) {
                throw ExitCode.failure
            }
        }
    }
}

struct AnyEncodable: Encodable {
    let value: Any
    init(_ value: Any) { self.value = value }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = value as? String { try container.encode(v) }
        else if let v = value as? Int { try container.encode(v) }
        else if let v = value as? Double { try container.encode(v) }
        else if let v = value as? Bool { try container.encode(v) }
        else if let v = value as? [Any] { try container.encode(v.map { AnyEncodable($0) }) }
        else if let v = value as? [String: Any] { try container.encode(v.mapValues { AnyEncodable($0) }) }
        else { try container.encodeNil() }
    }
}
