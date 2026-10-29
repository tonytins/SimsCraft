import Foundation

/// The copies of The Sims Online a machine can name, each through its own setting.
///
/// NewSO's own: FreeSO finds a single install (see ``GameLocator``). Tools, tests, and the
/// client check several, in ``allCases`` order, so this is the one list of them.
public enum InstallKind: String, CaseIterable, Sendable {
    /// The main install, `TSO_GAME_DIR`: the copy closest to the files FreeSO was built
    /// against (TSO after its New & Improved update).
    case game
    /// An older production copy, `TSO_CLASSIC_DIR`, such as one from 2002.
    case classic
    /// A beta, `TSO_BETA_DIR`, such as the 2002 one.
    case beta

    /// The environment variable that names this install, such as `TSO_GAME_DIR`.
    public var environmentVariable: String { "TSO_\(rawValue.uppercased())_DIR" }

    /// The installs a lookup names, in ``allCases`` order.
    ///
    /// A kind the lookup has no value for, or an empty value, is left out. A folder named by
    /// two kinds is kept once, under the first.
    public static func installs(named lookup: (InstallKind) -> String?) -> [NamedInstall] {
        var installs: [NamedInstall] = []
        for kind in allCases {
            guard let path = lookup(kind), !path.isEmpty else { continue }
            let directory = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
            guard !installs.contains(where: { $0.directory == directory }) else { continue }
            installs.append(NamedInstall(kind: kind, directory: directory))
        }
        return installs
    }

    /// The installs an environment names through ``environmentVariable``, in ``allCases`` order.
    public static func installs(in environment: [String: String]) -> [NamedInstall] {
        installs { environment[$0.environmentVariable] }
    }
}

/// An install named by a setting such as `TSO_GAME_DIR`.
public struct NamedInstall: Sendable, Equatable {
    /// Which setting named it.
    public var kind: InstallKind
    /// The install folder (the one holding `objectdata`), standardized.
    public var directory: URL

    public init(kind: InstallKind, directory: URL) {
        self.kind = kind
        self.directory = directory
    }
}

/// The game version an install's `version` file records, such as 1.1097.1.0.
///
/// NewSO's own: FreeSO doesn't read this file (its `version.txt` is FreeSO's). Two layouts
/// are known. Production installs hold one dotted line, `1.1097.1.0`. The 2002 beta holds
/// `key:value` lines, `major:1`, `minor:3`, `patch:2`, and `build:121`. Any other layout,
/// including an unknown key, is reported as an error rather than guessed at.
public struct GameVersion: Sendable, Hashable, Comparable, CustomStringConvertible {
    public var major: Int
    public var minor: Int
    public var patch: Int
    public var build: Int

    /// The largest `version` file read. Real ones are a few dozen bytes.
    static let largestFile = 1024

    public init(major: Int, minor: Int, patch: Int, build: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.build = build
    }

    /// Parses the text of a `version` file.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` with the path `version` if the
    ///   text has neither known layout.
    public init(parsing text: String) throws(ContentError) {
        let lines = text.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if lines.count == 1, !lines[0].contains(":") {
            let parts = lines[0].split(separator: ".", omittingEmptySubsequences: false)
            guard parts.count == 4 else { throw Self.invalid("expected four dotted numbers, found \"\(lines[0])\"") }
            let numbers = try parts.map { part throws(ContentError) in try Self.number(String(part)) }
            self.init(major: numbers[0], minor: numbers[1], patch: numbers[2], build: numbers[3])
            return
        }
        var fields: [String: Int] = [:]
        for line in lines {
            let pair = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let key = pair[0].trimmingCharacters(in: .whitespaces).lowercased()
            guard pair.count == 2, ["major", "minor", "patch", "build"].contains(key) else {
                throw Self.invalid("unknown line \"\(line)\"")
            }
            guard fields[key] == nil else { throw Self.invalid("\(key) appears twice") }
            fields[key] = try Self.number(pair[1].trimmingCharacters(in: .whitespaces))
        }
        guard let major = fields["major"], let minor = fields["minor"], let patch = fields["patch"],
              let build = fields["build"] else {
            throw Self.invalid("expected major, minor, patch, and build")
        }
        self.init(major: major, minor: minor, patch: patch, build: build)
    }

    /// The version an install records, or `nil` if it has no `version` file (in any letter
    /// case), as MockInstall doesn't.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if the file can't be read, is
    ///   larger than any real one, or has neither known layout.
    public static func read(install directory: URL) throws(ContentError) -> GameVersion? {
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: directory.path),
              let name = names.first(where: { $0.lowercased() == "version" }) else { return nil }
        let file = directory.appendingPathComponent(name)
        let data: Data
        do {
            data = try Data(contentsOf: file)
        } catch {
            throw .invalidFile(path: file.path, reason: "unreadable: \(error.localizedDescription)")
        }
        guard data.count <= largestFile else {
            throw .invalidFile(path: file.path, reason: "\(data.count) bytes, larger than any version file")
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw .invalidFile(path: file.path, reason: "not text")
        }
        do {
            return try GameVersion(parsing: text)
        } catch .invalidFile(_, let reason) {
            throw .invalidFile(path: file.path, reason: reason)
        } catch {
            throw error
        }
    }

    public var description: String { "\(major).\(minor).\(patch).\(build)" }

    public static func < (lhs: GameVersion, rhs: GameVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch, lhs.build) < (rhs.major, rhs.minor, rhs.patch, rhs.build)
    }

    private static func number(_ text: String) throws(ContentError) -> Int {
        guard (1...9).contains(text.count), text.allSatisfy(\.isASCII), let value = Int(text), value >= 0 else {
            throw invalid("\"\(text)\" isn't a version number")
        }
        return value
    }

    private static func invalid(_ reason: String) -> ContentError {
        .invalidFile(path: "version", reason: reason)
    }
}
