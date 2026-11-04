import Foundation
import SimsScript

/// An experiment written in SimsScript: an object, how long to run it, and the attributes it
/// should leave.
///
/// A scenario file (`.ss`) is a SimsScript object with a header of comments. Plain comment
/// lines describe it; lines starting `// @` are directives:
///
/// ```text
/// // Counting: a function called from a loop.
/// // @ticks 2
/// // @expect count = 212
/// integer count;
/// ...
/// ```
///
/// - `@ticks N`: ticks to run after the object's initialize (0 to 30,000; default 1).
/// - `@expect NAME = VALUE`: an object variable's value at the end (a 16-bit integer).
///
/// The header ends at the first line that is neither blank nor a comment. An unknown directive
/// is an error, so a typo doesn't quietly drop a check.
public struct Scenario: Sendable, Equatable {
    /// One object variable's expected value.
    public struct Expectation: Sendable, Equatable {
        public var attribute: String
        public var value: Int16

        public init(attribute: String, value: Int16) {
            self.attribute = attribute
            self.value = value
        }
    }

    /// The file name without its extension.
    public var name: String
    /// The header's plain comment lines, joined.
    public var summary: String
    public var ticks: Int
    public var expectations: [Expectation]
    /// The whole file, which SimsScript compiles (the header is comments to it).
    public var source: String

    /// The most ticks a scenario may run: over 16 game minutes, far more than one needs.
    public static let mostTicks = 30_000

    /// Reads a scenario's header.
    ///
    /// - Throws: ``ScenarioError/directive(scenario:line:message:)`` for a directive it can't read.
    public init(name: String, text: String) throws(ScenarioError) {
        self.name = name
        source = text
        ticks = 1
        expectations = []
        var summary: [String] = []
        var seenTicks = false
        for (index, rawLine) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            guard line.hasPrefix("//") else { break }
            let comment = line.dropFirst(2).trimmingCharacters(in: .whitespaces)
            guard comment.hasPrefix("@") else {
                if !comment.isEmpty { summary.append(comment) }
                continue
            }
            func fail(_ message: String) -> ScenarioError {
                .directive(scenario: name, line: index + 1, message: message)
            }
            let words = comment.dropFirst().split(separator: " ", maxSplits: 1).map(String.init)
            let argument = words.count > 1 ? words[1].trimmingCharacters(in: .whitespaces) : ""
            switch words.first ?? "" {
            case "ticks":
                guard !seenTicks else { throw fail("@ticks appears twice") }
                guard let count = Int(argument), (0...Self.mostTicks).contains(count) else {
                    throw fail("@ticks takes a number from 0 to \(Self.mostTicks)")
                }
                ticks = count
                seenTicks = true
            case "expect":
                let parts = argument.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                guard parts.count == 2, !parts[0].isEmpty, parts[0].allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }),
                      let value = Int16(parts[1]) else {
                    throw fail("@expect takes NAME = VALUE, with a 16-bit integer value")
                }
                guard !expectations.contains(where: { $0.attribute == parts[0] }) else {
                    throw fail("@expect \(parts[0]) appears twice")
                }
                expectations.append(Expectation(attribute: parts[0], value: value))
            default:
                throw fail("unknown directive \"@\(words.first ?? "")\"; the directives are @ticks and @expect")
            }
        }
        self.summary = summary.joined(separator: " ")
    }

    /// Compiles the scenario's object.
    ///
    /// - Throws: ``ScenarioError/script(scenario:_:)`` if SimsScript rejects it, or
    ///   ``ScenarioError/unknownAttribute(scenario:attribute:)`` if an expectation names a
    ///   variable the object doesn't declare.
    public func compiled() throws(ScenarioError) -> CompiledObject {
        let object: CompiledObject
        do {
            object = try ScriptCompiler.compile(source)
        } catch {
            throw .script(scenario: name, error)
        }
        for expectation in expectations where !object.attributes.contains(expectation.attribute) {
            throw .unknownAttribute(scenario: name, attribute: expectation.attribute)
        }
        return object
    }
}

/// Why a scenario couldn't be read or compiled.
public enum ScenarioError: Error, Equatable, Sendable, CustomStringConvertible {
    /// A header directive is malformed.
    case directive(scenario: String, line: Int, message: String)
    /// SimsScript rejected the object.
    case script(scenario: String, ScriptError)
    /// An `@expect` names a variable the object doesn't declare.
    case unknownAttribute(scenario: String, attribute: String)
    /// A scenario file or folder couldn't be read.
    case unreadable(path: String, reason: String)
    /// A file or folder couldn't be written.
    case unwritable(path: String, reason: String)
    /// A scenario's object couldn't be written as an IFF.
    case objectFile(scenario: String, String)
    /// The install's content couldn't be loaded.
    case content(String)
    /// The GUID a scenario was given already belongs to one of the install's objects.
    case guidTaken(scenario: String, guid: UInt32)

    public var description: String {
        switch self {
        case .directive(let scenario, let line, let message): "\(scenario).ss:\(line): \(message)"
        case .script(let scenario, let error): "\(scenario).ss:\(error)"
        case .unknownAttribute(let scenario, let attribute):
            "\(scenario).ss: @expect names \(attribute), which the object doesn't declare"
        case .unreadable(let path, let reason): "\(path): \(reason)"
        case .unwritable(let path, let reason): "\(path): \(reason)"
        case .objectFile(let scenario, let reason): "\(scenario).ss: can't write its object: \(reason)"
        case .content(let reason): "can't load the content: \(reason)"
        case .guidTaken(let scenario, let guid):
            "\(scenario).ss: its GUID \(String(format: "%08x", guid)) belongs to one of the install's objects"
        }
    }
}

/// The scenarios in a folder, or the ones that ship with sso-oracle.
public enum ScenarioLibrary {
    /// The largest scenario file read.
    static let largestFile = 1 << 20

    /// The scenarios bundled with sso-oracle.
    public static func bundled() throws(ScenarioError) -> [Scenario] {
        guard let folder = Bundle.module.url(forResource: "Scenarios", withExtension: nil) else {
            throw .unreadable(path: "Scenarios", reason: "not in sso-oracle's resources")
        }
        return try load(folder: folder)
    }

    /// Every `.ss` file in a folder, by name.
    public static func load(folder: URL) throws(ScenarioError) -> [Scenario] {
        let names: [String]
        do {
            names = try FileManager.default.contentsOfDirectory(atPath: folder.path)
        } catch {
            throw .unreadable(path: folder.path, reason: error.localizedDescription)
        }
        var scenarios: [Scenario] = []
        for file in names.filter({ $0.lowercased().hasSuffix(".ss") }).sorted() {
            let url = folder.appendingPathComponent(file)
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                throw .unreadable(path: url.path, reason: error.localizedDescription)
            }
            guard data.count <= largestFile else { throw .unreadable(path: url.path, reason: "larger than 1 MB") }
            guard let text = String(data: data, encoding: .utf8) else { throw .unreadable(path: url.path, reason: "not UTF-8") }
            scenarios.append(try Scenario(name: String(file.dropLast(3)), text: text))
        }
        return scenarios
    }
}
