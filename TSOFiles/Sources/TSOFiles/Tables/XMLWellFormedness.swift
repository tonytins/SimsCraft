import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Checks XML well-formedness before `XMLDocument` reads it.
///
/// On Linux, FoundationXML's `XMLDocument(data:)` and `nodes(forXPath:)` can crash with a null
/// pointer dereference on malformed input instead of throwing, so every reader here checks with
/// `XMLParser`, which fails safely, first.
public enum XMLWellFormedness {
    /// Why the XML isn't well-formed, or `nil` if it is. External entities aren't resolved.
    public static func problem(in data: Data) -> String? {
        let parser = XMLParser(data: data)
        parser.shouldResolveExternalEntities = false
        if parser.parse() { return nil }
        return parser.parserError.map { "\($0.localizedDescription) at line \(parser.lineNumber)" } ?? "not well-formed"
    }
}
