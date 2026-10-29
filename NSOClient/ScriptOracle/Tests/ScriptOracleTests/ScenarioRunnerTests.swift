import Foundation
import ScriptOracleCore
import SimAntics
import Testing

/// NSOClient's folder, holding MockInstall, next to FreeSO's content in the snapshot.
private let nsoclient = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
private let mockInstall = nsoclient.appendingPathComponent("MockInstall/TSOClient", isDirectory: true)

private func emptyLot() throws -> Blueprint {
    try Blueprint(xml: try Data(contentsOf: nsoclient
        .appendingPathComponent("../TSOClient/tso.content/Content/Blueprints/empty_lot_fso.xml").standardizedFileURL))
}

private func temporaryFolder() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent("sso-tests-\(UUID().uuidString)", isDirectory: true)
}

private func run(_ scenarios: [Scenario]) throws -> [ScenarioResult] {
    let folder = temporaryFolder()
    defer { try? FileManager.default.removeItem(at: folder) }
    return try ScenarioRunner(scenarios: scenarios).run(gameDirectory: mockInstall, lot: try emptyLot(), objectFolder: folder)
}

@Suite struct ScenarioRunnerTests {
    @Test func everyBundledScenarioMeetsItsExpectations() throws {
        for result in try run(try ScenarioLibrary.bundled()) {
            #expect(result.passed, "\(result.recordLine) \(result.misses)")
        }
    }

    @Test func runsInitializeThenTheTicks() throws {
        let source = "integer ticks;\ndefault { initialize() { ticks = 100; } main() { ticks += 1; } }"
        let results = try run([try Scenario(name: "none", text: "// @ticks 0\n" + source),
                               try Scenario(name: "three", text: "// @ticks 3\n" + source)])
        #expect(results.map(\.recordLine) == ["none 5c000001 attributes ticks=100", "three 5c000002 attributes ticks=103"])
    }

    @Test func reportsAMissedExpectation() throws {
        let scenario = try Scenario(name: "wrong", text: "// @ticks 0\n// @expect a = 2\ninteger a;\ndefault { initialize() { a = 1; } }")
        let result = try #require(try run([scenario]).first)
        #expect(!result.passed)
        #expect(result.misses == [.init(attribute: "a", expected: 2, actual: 1)])
    }

    @Test func writesEachObjectAndTheTable() throws {
        let folder = temporaryFolder()
        defer { try? FileManager.default.removeItem(at: folder) }
        let runner = ScenarioRunner(scenarios: try ScenarioLibrary.bundled())
        try runner.writeObjects(to: folder)
        let table = try String(contentsOf: folder.appendingPathComponent("scenarios.tsv"), encoding: .utf8)
        #expect(table == "5c000001\tarithmetic\t0\twrapped,divided,remainder,negative,masked\n5c000002\tcounting\t2\tcount\n")
        #expect(FileManager.default.fileExists(atPath: folder.appendingPathComponent("counting.iff").path))
    }

    @Test func stopsOnAScenarioThatDoesntCompile() {
        let folder = temporaryFolder()
        defer { try? FileManager.default.removeItem(at: folder) }
        #expect(throws: ScenarioError.self) {
            try ScenarioRunner(scenarios: [try Scenario(name: "broken", text: "integer a; default { initialize() { a = ; } }")])
                .writeObjects(to: folder)
        }
    }
}

@Suite struct ScenarioComparisonTests {
    let results = [
        ScenarioResult(name: "a", guid: 0x5C00_0001, attributes: [("x", 1)], errors: [], misses: []),
        ScenarioResult(name: "b", guid: 0x5C00_0002, attributes: [("y", 2)], errors: [], misses: []),
        ScenarioResult(name: "c", guid: 0x5C00_0003, attributes: [("z", 3)], errors: ["tick 1: boom"], misses: []),
        ScenarioResult(name: "d", guid: 0x5C00_0004, attributes: [], errors: [], misses: []),
        ScenarioResult(name: "e", guid: 0x5C00_0005, attributes: [("w", 5)], errors: [], misses: []),
    ]

    @Test func setsEachResultBesideFreeSOsRecord() {
        let records = ["a 5c000001 attributes x=1", "b 5c000002 attributes y=3", "c 5c000003 attributes z=3",
                       "d 5c000004 missing", "other 5c000009 attributes q=1", ""]
        let outcomes = ScenarioComparison.compare(results, freeSORecords: records)
        #expect(outcomes.map(\.name) == ["a", "b", "c", "d", "e"])
        #expect(outcomes[0].outcome == .agree)
        #expect(outcomes[1].outcome == .differ(nso: "attributes y=2", fso: "attributes y=3"))
        #expect(outcomes[2].outcome == .inconclusive("NSOClient hit errors: tick 1: boom"))
        #expect(outcomes[3].outcome == .inconclusive("FreeSO: missing"))
        #expect(outcomes[4].outcome == .inconclusive("FreeSO has no record"))
    }
}
