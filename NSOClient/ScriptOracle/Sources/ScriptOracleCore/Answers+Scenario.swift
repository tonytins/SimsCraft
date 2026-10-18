import Foundation
import SimAntics
import SimsScript
import TSOContent
import TSOFiles

extension Answers {
    /// Run a scenario compiled from SimsScript
    public func runScenario(_ name: String, ticks: Int = 10) throws -> [String] {
        let source = try ScenarioLoader.load(name)
        let compiled = try ScriptCompiler.compile(source)
        // For now, just verify it compiles
        return ["scenario \(name): compiled \(compiled.routines.count) routines"]
    }
}
