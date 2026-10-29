import Configuration
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
