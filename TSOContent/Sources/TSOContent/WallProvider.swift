import Foundation
import TSOFiles

/// The install's walls: wall patterns (the wallpaper a wall shows), wall styles (the shape that
/// masks it: a full wall, a cut-down one, a fence), and the junction pieces drawn where walls meet.
///
/// Ports FreeSO's `WorldWallProvider`. Patterns 0 to 255 and styles 1 to 255 are global, in
/// `objectdata/globals/walls.iff`; patterns 256 up are the IFFs of `housedata/walls/walls.far`,
/// then `walls2`, `walls3`, and `walls4`, numbered in archive and manifest order. Everything is
/// read when the provider is made, and a sprite is parsed when it's asked for. Styles objects add
/// while a lot runs (FreeSO's `AddDynamicWallStyle`, 256 up) aren't here yet.
///
/// Where it differs from FreeSO (DIFF-29, DIFF-30 in the scorecard):
/// - Only the five styles the catalog sells (wall, picket, iron, and privacy fences, and
///   banisters) have catalog strings. FreeSO's `TryGetValue` leaves every other style at index
///   0, so each takes the plain wall's name and price.
/// - An archive the install doesn't have holds no walls: the base game and the beta have only
///   `walls.far`, where FreeSO would stop. An IFF in an archive that can't be read takes its ID
///   and is reported in ``failures``.
public struct WallProvider: Sendable {
    /// The archives that hold patterns 256 up, in the order they're numbered.
    public static let archivePaths = ["housedata/walls/walls.far", "housedata/walls2/walls2.far",
                                      "housedata/walls3/walls3.far", "housedata/walls4/walls4.far"]
    /// The styles the catalog sells, in the order of their strings (FreeSO's `WallStyleIDs`).
    public static let catalogStyleIDs: [UInt16] = [0x1, 0x2, 0xD, 0xC, 0xE]

    /// A pattern's sprites at each zoom (FreeSO's `Wall`), and the file their palettes are in.
    /// Each sprite has a frame per side the wall can be drawn on.
    public struct Pattern: Sendable {
        public let id: UInt16
        public let far: SPR?
        public let medium: SPR?
        public let near: SPR?
        public let file: IFFFile
    }

    /// A style's masks at each zoom, with walls up and cut down (FreeSO's `WallStyle`). A style
    /// without its own cut-down masks uses the full ones for both, as in FreeSO.
    public struct Style: Sendable {
        public let id: UInt16
        public let wallsUp: (far: SPR?, medium: SPR?, near: SPR?)
        public let wallsDown: (far: SPR?, medium: SPR?, near: SPR?)
        /// The catalog strings, for the styles the catalog sells.
        public let entry: BuildCatalogEntry?
    }

    /// The patterns' catalog entries, in ID order: the global ones with strings, then the archives'.
    public let entries: [BuildCatalogEntry]
    /// The styles' catalog entries, in catalog order.
    public let styleEntries: [BuildCatalogEntry]
    /// What couldn't be read.
    public let failures: [BuildContentFailure]
    /// Wall archives the install doesn't have.
    public let missingArchives: [String]
    /// `objectdata/globals/walls.iff`.
    public let globals: IFFFile

    private let filesByName: [String: IFFFile]
    private let entriesByID: [UInt16: BuildCatalogEntry]
    /// The first archive pattern, which FreeSO falls back to for an unknown ID.
    private let firstArchiveEntry: BuildCatalogEntry?

    static let globalsPath = "objectdata/globals/walls.iff"

    /// Reads the catalog of an install.
    ///
    /// - Throws: ``ContentError/missingFile(_:)`` if `walls.iff` or `build.iff` is missing, or
    ///   ``ContentError/invalidFile(path:reason:)`` if one of them, its style or wallpaper
    ///   strings, or an archive doesn't read. FreeSO stops on each.
    public init(files: GameFileIndex) throws(ContentError) {
        globals = try buildGlobal(Self.globalsPath, in: files)
        let build = try buildGlobal(FloorProvider.buildPath, in: files)
        let styleStrings = try buildStrings(id: 0x81, in: build, path: FloorProvider.buildPath)
        let patternStrings = try buildStrings(id: 0x83, in: build, path: FloorProvider.buildPath)

        var failures: [BuildContentFailure] = []
        func entry(_ id: UInt16, _ strings: StringTable, at index: Int) -> BuildCatalogEntry {
            BuildCatalogEntry(id: id, fileName: "global", name: strings.string(at: index * 3 + 1),
                              price: BuildArchives.price(strings.string(at: index * 3), path: FloorProvider.buildPath, failures: &failures),
                              description: strings.string(at: index * 3 + 2))
        }
        styleEntries = Self.catalogStyleIDs.enumerated().map { entry($0.element, styleStrings, at: $0.offset) }

        // Patterns 1 up have strings, three each, up to 255.
        var entries: [BuildCatalogEntry] = []
        for id in stride(from: UInt16(1), through: UInt16(min(patternStrings.count / 3, 255)), by: 1) {
            entries.append(entry(id, patternStrings, at: Int(id) - 1))
        }
        let archives = try BuildArchives(paths: Self.archivePaths, firstID: 256, in: files)
        firstArchiveEntry = archives.entries.first
        entries += archives.entries
        self.entries = entries
        self.failures = failures + archives.failures
        missingArchives = archives.missingArchives
        filesByName = archives.filesByName
        entriesByID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// The catalog entry of a pattern, if it has one.
    public func entry(id: UInt16) -> BuildCatalogEntry? {
        entriesByID[id]
    }

    /// A pattern's sprites, as FreeSO's `Get` finds them. Patterns 0 to 255 always exist, with
    /// their sprites from `walls.iff` (far `id + 1536`, medium `id + 1792`, near `id + 2048`),
    /// any of which may be missing. An archive pattern's come from its IFF (`SPR#` 1, 1793, and
    /// 2049). An unknown ID from 256 up falls back to the first archive pattern, a tolerance
    /// FreeSO had that lots made with other content rely on; `nil` if there's no archive pattern
    /// or its IFF didn't read.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a sprite chunk doesn't parse.
    public func pattern(id: UInt16) throws(ContentError) -> Pattern? {
        if id < 256 {
            return Pattern(id: id, far: try buildSprite(SPR.self, id: id + 1536, in: globals, path: Self.globalsPath),
                           medium: try buildSprite(SPR.self, id: id + 1792, in: globals, path: Self.globalsPath),
                           near: try buildSprite(SPR.self, id: id + 2048, in: globals, path: Self.globalsPath),
                           file: globals)
        }
        guard let entry = entriesByID[id] ?? firstArchiveEntry, let file = filesByName[entry.fileName] else { return nil }
        let path = "housedata/\(entry.fileName)"
        return Pattern(id: id, far: try buildSprite(SPR.self, id: 1, in: file, path: path),
                       medium: try buildSprite(SPR.self, id: 1793, in: file, path: path),
                       near: try buildSprite(SPR.self, id: 2049, in: file, path: path),
                       file: file)
    }

    /// A style's masks, from `walls.iff`: style `n` keeps its full masks at `2n` (far), `2n + 512`
    /// (medium), and `2n + 1024` (near), and its cut-down ones one after each. When the far
    /// cut-down mask is missing, the full masks serve for both, as in FreeSO. `nil` outside 1 to 255.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a mask chunk doesn't parse.
    public func style(id: UInt16) throws(ContentError) -> Style? {
        guard id >= 1, id <= 255 else { return nil }
        let base = id * 2
        func mask(_ chunkID: UInt16) throws(ContentError) -> SPR? {
            try buildSprite(SPR.self, id: chunkID, in: globals, path: Self.globalsPath)
        }
        let up = (far: try mask(base), medium: try mask(base + 512), near: try mask(base + 1024))
        var down = (far: try mask(base + 1), medium: try mask(base + 513), near: try mask(base + 1025))
        if down.far == nil { down = up }
        return Style(id: id, wallsUp: up, wallsDown: down, entry: styleEntries.first { $0.id == id })
    }

    /// The junction pieces drawn where walls meet, at each zoom (`SPR#` 4096 to 4098), one frame
    /// per way walls can meet (FreeSO's `Junctions`).
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a chunk doesn't parse.
    public func junctions() throws(ContentError) -> Pattern {
        Pattern(id: 256, far: try buildSprite(SPR.self, id: 4096, in: globals, path: Self.globalsPath),
                medium: try buildSprite(SPR.self, id: 4097, in: globals, path: Self.globalsPath),
                near: try buildSprite(SPR.self, id: 4098, in: globals, path: Self.globalsPath),
                file: globals)
    }
}
