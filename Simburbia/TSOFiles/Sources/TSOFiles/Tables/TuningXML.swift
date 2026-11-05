import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Simburbia's own global tuning, as XML: the same named entries of keys and values as
/// `tuning.dat` (``TuningFile``), in a file people can read and edit. Simburbia's defaults use it,
/// and ``TuningFile/merging(_:)`` lays an install's `tuning.dat` over them.
///
/// ```xml
/// <Tuning version="1">
///   <Entry name="SimMotives">
///     <Value key="WakeHours">16</Value>
///   </Entry>
/// </Tuning>
/// ```
///
/// A value is the text inside its `Value` element, trimmed of surrounding whitespace.
///
/// Forward compatibility: `version` is the format's major version, a whole number. A newer
/// version is refused, since its meaning may have changed. Within a version, an element this
/// reader doesn't know (in `Tuning`, an `Entry`, or a `Value`) is skipped with everything inside
/// it, and listed in ``ignored``; unknown attributes and comments are ignored. Newer data can add
/// either and older builds still read the rest.
public struct TuningXML: Sendable, Equatable {
    /// The format version this reader understands.
    public static let version = 1

    /// The entries, in document order.
    public let tuning: TuningFile
    /// Each element that was skipped, as a path such as `Tuning/Entry[SimMotives]/Range`.
    public let ignored: [String]

    /// Reads a tuning document. Nothing is returned when it fails.
    public init(bytes: Data) throws(TuningXMLError) {
        let reader = Reader()
        let parser = XMLParser(data: bytes)
        parser.delegate = reader
        let parsed = parser.parse()
        if let error = reader.error { throw error }
        guard parsed else {
            throw .malformedXML(parser.parserError.map { String(describing: $0) } ?? "unknown parser error")
        }
        guard reader.sawRoot else { throw .notATuningDocument(root: "") }
        tuning = TuningFile(entries: reader.entries)
        ignored = reader.ignored
    }

    /// Reads a tuning document from disk.
    public init(contentsOf url: URL) throws {
        try self.init(bytes: Data(contentsOf: url))
    }

    /// Walks the document, keeping the first error and stopping there.
    private final class Reader: NSObject, XMLParserDelegate {
        var entries: [TuningFile.Entry] = []
        var ignored: [String] = []
        var error: TuningXMLError?
        var sawRoot = false

        /// The known elements open now: the root, an entry, a value.
        private var path: [String] = []
        /// How deep inside an element being skipped; 0 when none is.
        private var skipping = 0
        private var entry: TuningFile.Entry?
        private var entryNames = Set<String>()
        private var keys = Set<String>()
        private var key: String?
        private var text = ""

        private func fail(_ failure: TuningXMLError, _ parser: XMLParser) {
            if error == nil { error = failure }
            parser.abortParsing()
        }

        func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName: String?,
                    attributes: [String: String] = [:]) {
            if skipping > 0 {
                skipping += 1
                return
            }
            switch (path.count, name) {
            case (0, "Tuning"):
                guard let version = attributes["version"] else {
                    return fail(.missingAttribute(element: "Tuning", attribute: "version"), parser)
                }
                guard let number = Int(version), number >= 1 else { return fail(.invalidVersion(version), parser) }
                guard number <= TuningXML.version else { return fail(.unsupportedVersion(number), parser) }
                sawRoot = true
            case (0, _):
                return fail(.notATuningDocument(root: name), parser)
            case (1, "Entry"):
                guard let entryName = attributes["name"], !entryName.isEmpty else {
                    return fail(.missingAttribute(element: "Entry", attribute: "name"), parser)
                }
                // Entries are matched without case, as `tuning.dat`'s are.
                guard entryNames.insert(entryName.lowercased()).inserted else {
                    return fail(.repeatedEntry(entryName), parser)
                }
                entry = TuningFile.Entry(name: entryName, values: [])
                keys = []
            case (2, "Value"):
                guard let valueKey = attributes["key"], !valueKey.isEmpty else {
                    return fail(.missingAttribute(element: "Value", attribute: "key"), parser)
                }
                guard keys.insert(valueKey).inserted else {
                    return fail(.repeatedKey(entry: entry?.name ?? "", key: valueKey), parser)
                }
                key = valueKey
                text = ""
            default:
                ignored.append((path + [label(name, attributes)]).joined(separator: "/"))
                skipping = 1
                return
            }
            path.append(label(name, attributes))
        }

        func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
            if skipping > 0 {
                skipping -= 1
                return
            }
            switch path.count {
            case 3:
                if let key { entry?.values.append((key: key, value: text.trimmingCharacters(in: .whitespacesAndNewlines))) }
                key = nil
            case 2:
                if let entry { entries.append(entry) }
                entry = nil
            default:
                break
            }
            path.removeLast()
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if skipping == 0 && key != nil { text += string }
        }

        func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            if error == nil { error = .malformedXML(String(describing: parseError)) }
        }

        /// An element's name in a path, with its name or key when it has one.
        private func label(_ name: String, _ attributes: [String: String]) -> String {
            if let identifier = attributes["name"] ?? attributes["key"] { return "\(name)[\(identifier)]" }
            return name
        }
    }
}

/// An error from reading Simburbia's tuning XML.
public enum TuningXMLError: Error, Equatable, Sendable {
    case malformedXML(String)
    /// The root element isn't `Tuning` (empty if there's no root).
    case notATuningDocument(root: String)
    case missingAttribute(element: String, attribute: String)
    /// The version isn't a whole number from 1.
    case invalidVersion(String)
    /// A version newer than ``TuningXML/version``, which this build can't safely read.
    case unsupportedVersion(Int)
    case repeatedEntry(String)
    case repeatedKey(entry: String, key: String)
}

extension TuningFile {
    /// Tuning from entries already read, such as ``TuningXML``'s or a merge's.
    public init(entries: [Entry]) {
        self.entries = entries
    }

    /// This tuning with another's values over it, key by key: an entry in both (matched without
    /// case) keeps this one's keys in order, each replaced where the other has it, then the
    /// other's new keys; entries only the other has come after, in its order.
    public func merging(_ other: TuningFile) -> TuningFile {
        var merged = entries
        for top in other.entries {
            guard let index = merged.firstIndex(where: { $0.name.lowercased() == top.name.lowercased() }) else {
                merged.append(top)
                continue
            }
            for (key, value) in top.values {
                if let position = merged[index].values.firstIndex(where: { $0.key == key }) {
                    merged[index].values[position].value = value
                } else {
                    merged[index].values.append((key: key, value: value))
                }
            }
        }
        return TuningFile(entries: merged)
    }
}
