import Configuration
import Foundation
import TSOContent

// swift-configuration's API needs macOS 15 and its peers; the libraries don't declare
// platforms, so this says it here instead.
@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
extension InstallKind {
    /// The setting that names this install, such as `tso.game.dir`.
    ///
    /// swift-configuration's environment provider reads it as ``environmentVariable``
    /// (`TSO_GAME_DIR`), and a file provider as `dir` in a `[tso.game]` table or its like.
    public var configKey: ConfigKey { ["tso", rawValue, "dir"] }

    /// The installs a configuration names, in ``allCases`` order, as
    /// ``installs(named:)`` lists them.
    public static func installs(in config: ConfigReader) -> [NamedInstall] {
        installs { config.string(forKey: $0.configKey) }
    }
}

// The content folders' settings: `nso.user.dir` (NSO_USER_DIR in the environment) and
// `fso.content.dir` (FSO_CONTENT_DIR).
@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
extension UserFolderLocator {
    /// The setting that names the user folder, read from the environment as ``environmentVariable``.
    public static let configKey: ConfigKey = ["nso", "user", "dir"]

    /// A locator that takes the folder from a configuration, else the OS's usual folder.
    public init(config: ConfigReader) {
        self.init(configuredDirectory: config.string(forKey: Self.configKey).flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) },
                  environment: [:])
    }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
extension FreeSOContentLocator {
    /// The setting that names FreeSO's content folder, read from the environment as ``environmentVariable``.
    public static let configKey: ConfigKey = ["fso", "content", "dir"]

    /// A locator that takes the folder from a configuration, else beside the executable, else `fallback`.
    public init(config: ConfigReader, fallback: URL?) {
        self.init(configuredDirectory: config.string(forKey: Self.configKey).flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) },
                  environment: [:], fallback: fallback)
    }
}
