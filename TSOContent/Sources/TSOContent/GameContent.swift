import Foundation
import TSOFiles

/// The content of one TSO install: its files, patches, globals, and objects.
///
/// Replaces FreeSO's `Content` singleton for the parts SimAntics needs. Create one
/// per install; nothing is global, so tests and tools can load several side by side.
public final class GameContent: Sendable {
    /// Where to find the game and FreeSO's additions.
    public struct Configuration: Sendable {
        /// The install folder; see ``GameLocator``.
        public var gameDirectory: URL
        /// A folder of PIFF and OTF patches (FreeSO's `Content/Patch`), or `nil` for none.
        public var patchDirectory: URL?
        /// A folder of standalone object IFFs (FreeSO's `Content/Objects`), or `nil` for none.
        public var standaloneObjectDirectory: URL?
        /// Simburbia's mods folder, with a player's custom objects in `Objects` and patches in
        /// `Patch`, or `nil` for none; see ``UserFolderLocator``. Its patches count as user
        /// patches, so they replace the shipped ones for the same file; its objects load after
        /// FreeSO's, and can't replace an object that's already registered.
        public var modsDirectory: URL?
        /// Whether to load object sprites. Servers don't need them.
        public var loadsSprites: Bool

        public init(gameDirectory: URL, patchDirectory: URL? = nil, standaloneObjectDirectory: URL? = nil,
                    modsDirectory: URL? = nil, loadsSprites: Bool = false) {
            self.gameDirectory = gameDirectory
            self.patchDirectory = patchDirectory
            self.standaloneObjectDirectory = standaloneObjectDirectory
            self.modsDirectory = modsDirectory
            self.loadsSprites = loadsSprites
        }

        /// FreeSO's layout: `Patch` and `Objects` inside its `Content` folder, and optionally
        /// Simburbia's mods. Either folder may be missing (a player's FreeSO folder may hold only
        /// custom objects), and then holds nothing.
        public init(gameDirectory: URL, freeSOContentDirectory: URL?, modsDirectory: URL? = nil,
                    loadsSprites: Bool = false) {
            func existing(_ name: String) -> URL? {
                guard let folder = freeSOContentDirectory?.appendingPathComponent(name, isDirectory: true),
                      FileManager.default.fileExists(atPath: folder.path) else { return nil }
                return folder
            }
            self.init(gameDirectory: gameDirectory, patchDirectory: existing("Patch"),
                      standaloneObjectDirectory: existing("Objects"), modsDirectory: modsDirectory,
                      loadsSprites: loadsSprites)
        }

        /// The mods folder's patches, `Mods/Patch`.
        public var modPatchDirectory: URL? { modsDirectory?.appendingPathComponent("Patch", isDirectory: true) }
        /// The mods folder's objects, `Mods/Objects`.
        public var modObjectDirectory: URL? { modsDirectory?.appendingPathComponent("Objects", isDirectory: true) }
    }

    public let files: GameFileIndex
    public let patches: PatchRegistry
    public let globals: GlobalProvider
    public let objects: ObjectProvider

    /// Indexes the install, loads the patches, and registers every object.
    ///
    /// Objects, globals, and their files load later, on first use.
    public init(_ configuration: Configuration) throws(ContentError) {
        files = try GameFileIndex(root: configuration.gameDirectory)
        var patches = PatchRegistry()
        for (directory, asUserPatches) in [(configuration.patchDirectory, false), (configuration.modPatchDirectory, true)] {
            guard let directory else { continue }
            // FreeSO's patch folder is expected; a player with no mods has no Mods/Patch.
            guard asUserPatches == false || FileManager.default.fileExists(atPath: directory.path) else { continue }
            do {
                try patches.register(directory: directory, asUserPatches: asUserPatches)
            } catch {
                throw .invalidFile(path: directory.path, reason: String(describing: error))
            }
        }
        self.patches = patches
        globals = GlobalProvider(files: files, patches: patches)
        objects = try ObjectProvider(files: files, patches: patches, globals: globals,
                                     standaloneDirectories: [configuration.standaloneObjectDirectory,
                                                             configuration.modObjectDirectory].compactMap { $0 },
                                     loadsSprites: configuration.loadsSprites)
    }

    /// The global every object can call (`objectdata/globals/global.iff`).
    public func global() throws(ContentError) -> GlobalResource {
        try globals.resource(named: "global")
    }

    /// The buy-mode catalog (`packingslips/catalog.xml`), with its negative-category entries left out.
    ///
    /// - Throws: ``ContentError/missingFile(_:)`` if the install has no catalog,
    ///   ``ContentError/invalidCatalog(_:)`` if it's malformed, or
    ///   ``ContentError/invalidFile(path:reason:)`` if it can't be read.
    public func catalog() throws(ContentError) -> ObjectCatalog {
        let path = "packingslips/catalog.xml"
        guard let url = files.url(for: path) else { throw .missingFile(path) }
        do {
            return try ObjectCatalog(bytes: Data(contentsOf: url))
        } catch let error as ContentError {
            throw error
        } catch {
            throw .invalidFile(path: url.path, reason: String(describing: error))
        }
    }

    /// Global tuning as a lot reads it (`Content.GlobalTuning`): Simburbia's defaults
    /// (``defaultTuningXML``) with the install's `tuning.dat` laid over them key by key, and the
    /// keys the install didn't have.
    public struct GlobalTuning: Sendable, Equatable {
        public var tuning: TuningFile
        /// The keys taken from Simburbia's defaults, as `Entry/Key`, in the defaults' order.
        public var defaultedKeys: [String]
    }

    /// The global tuning, read from disk on every call: a VM reads it once, when its first Sim
    /// needs it.
    ///
    /// 1.1097.1.0's `tuning.dat` has everything the defaults do, so nothing comes from them. The
    /// unpatched 2002 and beta discs have no `SimMotives` or `LotMotives` (patches delivered
    /// them), so those come from the defaults.
    ///
    /// - Throws: ``ContentError/missingFile(_:)`` if the install has no `tuning.dat`, as FreeSO
    ///   fails without one; ``ContentError/invalidFile(path:reason:)`` if it can't be read, or if
    ///   the defaults can't (which a test rules out).
    public func globalTuning() throws(ContentError) -> GlobalTuning {
        let path = "tuning.dat"
        guard let url = files.url(for: path) else { throw .missingFile(path) }
        let install: TuningFile
        do {
            install = try TuningFile(contentsOf: url)
        } catch {
            throw .invalidFile(path: url.path, reason: String(describing: error))
        }
        let defaults = try Self.defaultTuning()
        var defaulted: [String] = []
        for entry in defaults.entries {
            let installed = install.entry(named: entry.name)
            for (key, _) in entry.values where installed?.value(forKey: key) == nil {
                defaulted.append("\(entry.name)/\(key)")
            }
        }
        return GlobalTuning(tuning: defaults.merging(install), defaultedKeys: defaulted)
    }

    /// Simburbia's defaults on their own.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if they don't read as tuning XML.
    public static func defaultTuning() throws(ContentError) -> TuningFile {
        do {
            return try TuningXML(bytes: Data(defaultTuningXML.utf8)).tuning
        } catch {
            throw .invalidFile(path: "Simburbia's default tuning", reason: String(describing: error))
        }
    }
}
