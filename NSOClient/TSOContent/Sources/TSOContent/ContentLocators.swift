import Foundation

/// Finds NewSO's user folder: where a player's own content lives, apart from the game's files.
///
/// NewSO's own: FreeSO keeps a player's things beside its executable, in `Content/`
/// (`FSOEnvironment.UserDir`). NewSO uses the OS's per-user application data folder instead,
/// checking in order:
///
/// 1. a configured folder;
/// 2. the `NSO_USER_DIR` environment variable;
/// 3. the usual folder for this OS: `$XDG_DATA_HOME/NewSO` (or `~/.local/share/NewSO`) on
///    Linux, `~/Library/Application Support/NewSO` on macOS, `%APPDATA%\NewSO` on Windows.
///
/// The folder needn't exist: a player with no mods has none. Its `Mods` folder holds custom
/// objects (`Mods/Objects`) and patches (`Mods/Patch`); see ``GameContent/Configuration``.
public struct UserFolderLocator: Sendable {
    public static let environmentVariable = "NSO_USER_DIR"
    /// The folder's name in the OS's application data folder.
    public static let folderName = "NewSO"

    /// A folder chosen by the user, checked first.
    public var configuredDirectory: URL?
    public var environment: [String: String]
    public var homeDirectory: URL

    public init(configuredDirectory: URL? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment,
                homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.configuredDirectory = configuredDirectory
        self.environment = environment
        self.homeDirectory = homeDirectory
    }

    /// The usual user folder for this OS.
    public var defaultDirectory: URL {
        #if os(Windows)
        let appData = environment["APPDATA"].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) }
            ?? homeDirectory.appendingPathComponent("AppData/Roaming", isDirectory: true)
        return appData.appendingPathComponent(Self.folderName, isDirectory: true)
        #elseif os(macOS)
        return homeDirectory.appendingPathComponent("Library/Application Support/\(Self.folderName)", isDirectory: true)
        #else
        let dataHome = environment["XDG_DATA_HOME"].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) }
            ?? homeDirectory.appendingPathComponent(".local/share", isDirectory: true)
        return dataHome.appendingPathComponent(Self.folderName, isDirectory: true)
        #endif
    }

    /// The user folder.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a configured folder or
    ///   `NSO_USER_DIR` names something that exists but isn't a folder.
    public func locate() throws(ContentError) -> URL {
        let given = configuredDirectory
            ?? environment[Self.environmentVariable].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) }
        guard let given else { return defaultDirectory }
        var isFolder: ObjCBool = false
        if FileManager.default.fileExists(atPath: given.path, isDirectory: &isFolder), !isFolder.boolValue {
            throw .invalidFile(path: given.path, reason: "not a folder, so it can't be NewSO's user folder")
        }
        return given
    }

    /// The mods folder inside the user folder.
    public func modsDirectory() throws(ContentError) -> URL {
        try locate().appendingPathComponent("Mods", isDirectory: true)
    }
}

/// Finds FreeSO's own content folder, whose `Patch` and `Objects` NewSO reads too: FreeSO's
/// shipped patches, a player's patches in `Patch/User`, and custom objects in `Objects`.
///
/// Checks, in order:
///
/// 1. a configured folder;
/// 2. the `FSO_CONTENT_DIR` environment variable;
/// 3. `Content` beside the running executable, where FreeSO keeps it;
/// 4. a fallback the caller gives, such as the copy in SimsCraft's FreeSO snapshot.
///
/// A configured folder or `FSO_CONTENT_DIR` that isn't a content folder (it has neither
/// `Patch` nor `Objects`) is an error rather than skipped, so a typo doesn't silently lose a
/// player's content.
public struct FreeSOContentLocator: Sendable {
    public static let environmentVariable = "FSO_CONTENT_DIR"

    public var configuredDirectory: URL?
    public var environment: [String: String]
    /// The folder holding the running executable.
    public var executableDirectory: URL?
    /// Where to look last, or `nil` for nowhere.
    public var fallback: URL?

    public init(configuredDirectory: URL? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment,
                executableDirectory: URL? = Bundle.main.executableURL?.deletingLastPathComponent(),
                fallback: URL? = nil) {
        self.configuredDirectory = configuredDirectory
        self.environment = environment
        self.executableDirectory = executableDirectory
        self.fallback = fallback
    }

    /// FreeSO's content folder, or `nil` if there's none to use.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a configured folder or
    ///   `FSO_CONTENT_DIR` isn't a content folder.
    public func locate() throws(ContentError) -> URL? {
        let given = configuredDirectory
            ?? environment[Self.environmentVariable].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) }
        if let given {
            guard Self.isContentFolder(given) else {
                throw .invalidFile(path: given.path, reason: "not a FreeSO content folder: it has neither Patch nor Objects")
            }
            return given
        }
        let candidates = [executableDirectory?.appendingPathComponent("Content", isDirectory: true), fallback].compactMap { $0 }
        return candidates.first(where: Self.isContentFolder)
    }

    /// Whether a folder holds FreeSO's content: a `Patch` or an `Objects` folder.
    public static func isContentFolder(_ directory: URL) -> Bool {
        ["Patch", "Objects"].contains { name in
            var isFolder: ObjCBool = false
            return FileManager.default.fileExists(atPath: directory.appendingPathComponent(name).path, isDirectory: &isFolder)
                && isFolder.boolValue
        }
    }
}
