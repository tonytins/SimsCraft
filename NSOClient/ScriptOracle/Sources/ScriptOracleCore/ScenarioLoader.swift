import Foundation
import SimsScript

public struct ScenarioLoader {
    public static func load(_ name: String) throws -> String {
        let candidates = [
            URL(fileURLWithPath: name),
            URL(fileURLWithPath: "\(name).s"),
            URL(fileURLWithPath: "Scenarios/\(name).s"),
            URL(fileURLWithPath: "Scenarios/\(name).ss"),
            URL(fileURLWithPath: "NSOClient/ScriptOracle/Scenarios/\(name).s"),
            URL(fileURLWithPath: "NSOClient/ScriptOracle/Scenarios/\(name).ss"),
        ]
        for url in candidates {
            if FileManager.default.fileExists(atPath: url.path) {
                return try String(contentsOf: url, encoding: .utf8)
            }
        }
        throw NSError(domain: "ScenarioLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Scenario \(name) not found"])
    }
    
    public static func list() -> [String] {
        let dir = URL(fileURLWithPath: "NSOClient/ScriptOracle/Scenarios")
        if let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            return urls.filter { $0.pathExtension == "s" || $0.pathExtension == "ss" }.map { $0.deletingPathExtension().lastPathComponent }
        }
        return []
    }
}
