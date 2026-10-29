import ArgumentParser
import Configuration
import Foundation
import ScriptOracleCore
import SimAntics
import TSOConfig
import TSOContent

/// `sso-oracle`: experiments written in SimsScript, run on NSOClient's VM and FreeSO's.
@main
struct ScriptOracle: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sso-oracle",
        abstract: "Run experiments written in SimsScript.",
        discussion: """
            A scenario is a SimsScript object (.ss) with a header that says how long to run it and \
            which attributes it should leave. See NSOClient/ScriptOracle/README.md.
            """,
        subcommands: [Check.self, Build.self, Run.self, Compare.self])
}

/// Where the scenarios come from: a folder, or the ones that ship with sso-oracle.
struct ScenarioOptions: ParsableArguments {
    @Option(help: "A folder of .ss scenarios (default: the ones that ship with sso-oracle).")
    var scenarios: String?

    func load() throws -> [Scenario] {
        guard let scenarios else { return try ScenarioLibrary.bundled() }
        return try ScenarioLibrary.load(folder: URL(fileURLWithPath: scenarios, isDirectory: true))
    }
}

extension ScriptOracle {
    struct Check: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Compile every scenario and check its header, without running anything.")
        @OptionGroup var options: ScenarioOptions

        func run() throws {
            var failed = 0
            for scenario in try options.load() {
                do {
                    let object = try scenario.compiled()
                    print("\(scenario.name) ok: \(object.routines.count) routines, \(scenario.ticks) ticks, "
                          + "\(scenario.expectations.count) expectations")
                } catch {
                    print("\(scenario.name) error: \(error)")
                    failed += 1
                }
            }
            if failed > 0 { throw ExitCode.failure }
        }
    }
}

/// The NSOClient folder, which holds MockInstall, next to FreeSO's content in the snapshot.
private let nsoclient = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

extension ScriptOracle {
    struct Build: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Compile every scenario into a folder of standalone objects, for another VM to run.",
            discussion: """
                Writes NAME.iff for each scenario, a folder FreeSO's content can load as Content/Objects, \
                and scenarios.tsv: each object's GUID, its scenario's name, and its ticks.
                """)
        @OptionGroup var options: ScenarioOptions
        @Argument(help: "The folder to write.") var folder: String

        func run() throws {
            let runner = ScenarioRunner(scenarios: try options.load())
            try runner.writeObjects(to: URL(fileURLWithPath: folder, isDirectory: true))
            print("wrote \(runner.scenarios.count) scenarios to \(folder)")
        }
    }

    /// Where NSOClient's VM runs the scenarios.
    struct RunOptions: ParsableArguments {
        @Option(help: "The TSO install to load (default: $TSO_GAME_DIR, else NSOClient's MockInstall).")
        var game: String?

        @Option(help: "The lot to run on; its objects are taken out (default: FreeSO's empty_lot_fso.xml).")
        var blueprint: String?

        /// Runs the scenarios on NSOClient's VM.
        func results(of scenarios: [Scenario]) throws -> [ScenarioResult] {
            let installs = InstallKind.installs(in: ConfigReader(provider: EnvironmentVariablesProvider()))
            let game = game.map { URL(fileURLWithPath: $0, isDirectory: true) }
                ?? installs.first { $0.kind == .game }?.directory
                ?? nsoclient.appendingPathComponent("MockInstall/TSOClient", isDirectory: true)
            let lotFile = blueprint.map { URL(fileURLWithPath: $0) }
                ?? nsoclient.appendingPathComponent("../TSOClient/tso.content/Content/Blueprints/empty_lot_fso.xml")
                    .standardizedFileURL
            let lot = try Blueprint(xml: try Data(contentsOf: lotFile))
            let objects = FileManager.default.temporaryDirectory
                .appendingPathComponent("sso-oracle-\(UUID().uuidString)", isDirectory: true)
            defer { try? FileManager.default.removeItem(at: objects) }
            return try ScenarioRunner(scenarios: scenarios).run(gameDirectory: game, lot: lot, objectFolder: objects)
        }
    }

    struct Run: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Run every scenario on NSOClient's VM and check its expectations.",
            discussion: """
                Prints one record line per scenario (its object variables, then any errors), then \
                whether it met its expectations. Exits with 1 if any scenario missed one or hit an error.
                """)
        @OptionGroup var options: ScenarioOptions
        @OptionGroup var runOptions: RunOptions

        @Flag(help: "Print only the record lines, for comparing with another VM's.")
        var recordsOnly = false

        func run() throws {
            let results = try runOptions.results(of: try options.load())
            var failed = 0
            for result in results {
                print(result.recordLine)
                if !result.passed { failed += 1 }
                guard !recordsOnly else { continue }
                for miss in result.misses {
                    print("  missed: \(miss.attribute) is \(miss.actual), expected \(miss.expected)")
                }
                if result.passed { print("  ok") }
            }
            if !recordsOnly { print("\(results.count - failed) of \(results.count) scenarios passed") }
            if failed > 0 { throw ExitCode.failure }
        }
    }
}

extension ScriptOracle {
    struct Compare: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Run every scenario on NSOClient's VM and compare it with FreeSO's records.",
            discussion: """
                RECORDS is what fso-oracle run-scenarios printed for the objects sso-oracle build wrote \
                from the same scenarios. Prints, per scenario, whether the two VMs agree, differ, or \
                couldn't both measure it (inconclusive, which is never counted as agreement).
                """)
        @OptionGroup var options: ScenarioOptions
        @OptionGroup var runOptions: RunOptions
        @Argument(help: "fso-oracle run-scenarios' output.") var records: String
        @Flag(help: "Exit with 1 if any scenario differs or is inconclusive.") var strict = false

        func run() throws {
            let freeSO = try String(contentsOf: URL(fileURLWithPath: records), encoding: .utf8)
            let outcomes = ScenarioComparison.compare(try runOptions.results(of: try options.load()),
                                                      freeSORecords: freeSO.components(separatedBy: "\n"))
            var differ = 0, inconclusive = 0
            for (name, outcome) in outcomes {
                switch outcome {
                case .agree:
                    print("\(name) agrees")
                case .differ(let nso, let fso):
                    differ += 1
                    print("\(name) differs\n  NSOClient: \(nso)\n  FreeSO:    \(fso)")
                case .inconclusive(let reason):
                    inconclusive += 1
                    print("\(name) inconclusive: \(reason)")
                }
            }
            print("\(outcomes.count - differ - inconclusive) agree, \(differ) differ, \(inconclusive) inconclusive")
            if strict && differ + inconclusive > 0 { throw ExitCode.failure }
        }
    }
}
