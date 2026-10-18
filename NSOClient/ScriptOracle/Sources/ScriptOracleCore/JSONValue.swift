import Foundation

/// A minimal JSON value type for parity with NSOOracle.
public enum JSONValue {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue], [String])
    
    public static func parse(_ s: String) throws -> JSONValue {
        let data = Data(s.utf8)
        let decoder = JSONDecoder()
        struct AnyDecodable: Decodable {}
        // Use JSONSerialization for simplicity
        if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return .object(try obj.mapValues { try convert($0) }, Array(obj.keys))
        } else if let arr = try JSONSerialization.jsonObject(with: data) as? [Any] {
            return .array(try arr.map { try convert($0) })
        } else {
            throw NSError(domain: "JSON", code: 0)
        }
    }
    
    static func convert(_ v: Any) throws -> JSONValue {
        switch v {
        case is NSNull: return .null
        case let b as Bool: return .bool(b)
        case let n as NSNumber: return .number(n.doubleValue)
        case let s as String: return .string(s)
        case let a as [Any]: return .array(try a.map { try convert($0) })
        case let o as [String: Any]: return .object(try o.mapValues { try convert($0) }, Array(o.keys))
        default: throw NSError(domain: "JSON", code: 0)
        }
    }
}
