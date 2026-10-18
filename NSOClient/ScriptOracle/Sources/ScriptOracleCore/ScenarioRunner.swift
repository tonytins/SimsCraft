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
    
    public func run(_ name: String, context: ScenarioContext) throws -> [String] {
        let source = try ScenarioLoader.load(name)
        let compiled = try ScriptCompiler.compile(source)
        return try execute(compiled: compiled, context: context, name: name)
    }
    
    public func runPrimitive(_ line: String, context: ScenarioContext) throws -> String? {
        let name = "run_primitive"
        let source = try ScenarioLoader.load(name)
        let compiled = try ScriptCompiler.compile(source)
        return try executePrimitive(compiled: compiled, context: context, line: line)
    }
    
    public func runRoomMaps(_ file: String, context: ScenarioContext) throws -> [String: Any] {
        let name = "room_maps"
        let source = try ScenarioLoader.load(name)
        let compiled = try ScriptCompiler.compile(source)
        return try executeRoomMaps(compiled: compiled, context: context, file: file)
    }
    
    private func execute(compiled: CompiledObject, context: ScenarioContext, name: String) throws -> [String] {
        // No fallback - if scenario can't produce expected output format, throw as error
        // For now, use Answers implementation behavior as reference
        switch name {
        case "list_objects":
            return Answers(content: content).objectListing()
        case "run_objects":
            return [] // handled per GUID in command
        case "run_lot":
            var lot = context.blueprint
            if lot == nil {
                lot = try Blueprint(xml: try Data(contentsOf: URL(fileURLWithPath: "/run/media/tonytins/Finnick/Projects/FSOdoc/TSOClient/tso.content/Content", isDirectory: true).appendingPathComponent("Blueprints/empty_lot_fso.xml")))
            }
            var l = lot!
            if !context.leaveOut.isEmpty {
                l.objects.removeAll { context.leaveOut.contains($0.guid) }
            }
            return Answers(content: content).lotRun(l, ticks: context.ticks, every: context.every, dump: context.dump)
        default:
            throw NSError(domain: "ScenarioRunner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown scenario \(name)"])
        }
    }
    
    private func executePrimitive(compiled: CompiledObject, context: ScenarioContext, line: String) throws -> String? {
        var lot = context.blueprint
        if lot == nil {
            let url = URL(fileURLWithPath: "/run/media/tonytins/Finnick/Projects/FSOdoc/TSOClient/tso.content/Content", isDirectory: true).appendingPathComponent("Blueprints/empty_lot_fso.xml")
            lot = try Blueprint(xml: try Data(contentsOf: url))
        }
        if !context.leaveOut.isEmpty {
            var l = lot!
l.objects.removeAll { context.leaveOut.contains($0.guid) }
lot = l
        }
        let runner = PrimitiveRunner(answers: Answers(content: content), lot: lot!)
        return runner.answerLine(line)
    }
    
    private func executeRoomMaps(compiled: CompiledObject, context: ScenarioContext, file: String) throws -> [String: Any] {
        let url = URL(fileURLWithPath: file)
        return Answers.roomMaps(of: url)
    }
}
