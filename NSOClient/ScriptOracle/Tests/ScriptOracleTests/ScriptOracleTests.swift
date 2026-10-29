import Foundation
import ScriptOracleCore
import SimsScript
import Testing

@Suite struct ScenarioTests {
    @Test func readsTheHeader() throws {
        let scenario = try Scenario(name: "sample", text: """

            // Sample: two lines
            //   of description.
            // @ticks 30
            // @expect a = -5
            // @expect b_2 = 32767
            integer a;
            // @ticks 99 is past the header, so it's only a comment
            """)
        #expect(scenario.summary == "Sample: two lines of description.")
        #expect(scenario.ticks == 30)
        #expect(scenario.expectations == [.init(attribute: "a", value: -5), .init(attribute: "b_2", value: 32767)])
    }

    @Test func defaultsToOneTickAndNoExpectations() throws {
        let scenario = try Scenario(name: "bare", text: "integer a;\ndefault { initialize() { a = 1; } }")
        #expect(scenario.ticks == 1 && scenario.expectations.isEmpty && scenario.summary.isEmpty)
    }

    @Test(arguments: [
        ("// @tick 3", 1, "unknown directive"),
        ("// @ticks", 1, "@ticks takes"),
        ("// @ticks -1", 1, "@ticks takes"),
        ("// @ticks 30001", 1, "@ticks takes"),
        ("// @ticks 1\n// @ticks 2", 2, "appears twice"),
        ("// @expect a", 1, "@expect takes"),
        ("// @expect a = 40000", 1, "@expect takes"),
        ("// @expect a b = 1", 1, "@expect takes"),
        ("\n// @expect a = 1\n// @expect a = 2", 3, "appears twice"),
    ])
    func reportsABadDirectiveWithItsLine(header: String, line: Int, message: String) {
        #expect {
            try Scenario(name: "bad", text: header + "\ninteger a;")
        } throws: { error in
            guard case ScenarioError.directive("bad", line, let text) = error else { return false }
            return text.contains(message)
        }
    }

    @Test func compilesAndChecksTheExpectedNames() throws {
        let good = try Scenario(name: "good", text: "// @expect a = 1\ninteger a;\ndefault { initialize() { a = 1; } }")
        #expect(try good.compiled().attributes == ["a"])
        let misnamed = try Scenario(name: "misnamed", text: "// @expect b = 1\ninteger a;\ndefault { initialize() { a = 1; } }")
        #expect(throws: ScenarioError.unknownAttribute(scenario: "misnamed", attribute: "b")) { try misnamed.compiled() }
        let broken = try Scenario(name: "broken", text: "integer a;\ndefault { initialize() { a = ; } }")
        #expect {
            try broken.compiled()
        } throws: { error in
            guard case ScenarioError.script("broken", let script) = error else { return false }
            return script.line == 2
        }
    }

    @Test func everyBundledScenarioCompiles() throws {
        let scenarios = try ScenarioLibrary.bundled()
        #expect(scenarios.map(\.name) == ["arithmetic", "counting"])
        for scenario in scenarios {
            #expect(throws: Never.self) { try scenario.compiled() }
        }
    }

    @Test func reportsAFolderItCantRead() {
        #expect(throws: ScenarioError.self) { try ScenarioLibrary.load(folder: URL(fileURLWithPath: "/no/such/folder")) }
    }
}
