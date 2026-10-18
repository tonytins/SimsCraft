import Foundation
import SimAntics
import SimsScript
import TSOContent
import TSOFiles

/// Runs SimsScript scenarios against the VM.
public struct ScenarioRunner {
    let content: GameContent
    
    public init(content: GameContent) {
        self.content = content
    }
    
    /// Compile and run a SimsScript scenario.
    public func run(_ source: String) throws -> CompiledObject {
        return try ScriptCompiler.compile(source)
    }
}
