import Foundation
import TSOFiles

/// The install's floors: the build catalog's entries, and each floor's sprites.
///
/// Ports FreeSO's `WorldFloorProvider`. Floors 1 up are the global ones, in
/// `objectdata/globals/floors.iff`; 256 up are the IFFs of `housedata/floors/floors.far`, then
/// `floors2`, `floors3`, and `floors4`, numbered in archive and manifest order. 65534 (water) and
/// 65535 (pool) are catalog entries only; their tiles come from ``globalSprite(id:)``. Everything
/// is read when the provider is made, and a sprite is parsed when it's asked for.
///
/// Where it differs from FreeSO (DIFF-29, DIFF-30 in the scorecard):
/// - The global floors' names, prices, and descriptions come from `build.iff`'s floor strings
///   (`STR#` 0x82). FreeSO reads the wallpaper strings (0x83) instead, and so names every global
///   floor after a wallpaper. It counts the floors from that table too, one fewer than a third of
///   its strings; a third of the floor strings gives the same 29 floors on every install.
/// - An archive the install doesn't have holds no floors: the base game and the beta have only
///   `floors.far`, where FreeSO would stop. An IFF in an archive that can't be read takes its ID
///   and is reported in ``failures``.
public struct FloorProvider: Sendable {
    /// The archives that hold floors 256 up, in the order they're numbered.
    public static let archivePaths = ["housedata/floors/floors.far", "housedata/floors2/floors2.far",
                                      "housedata/floors3/floors3.far", "housedata/floors4/floors4.far"]
    /// The catalog ID of pool tiles.
    public static let poolID: UInt16 = 65535
    /// The catalog ID of water tiles.
    public static let waterID: UInt16 = 65534

    /// A floor's sprites at each zoom (FreeSO's `Floor`), and the file their palettes are in.
    public struct Floor: Sendable {
        public let id: UInt16
        public let far: SPR2?
        public let medium: SPR2?
        public let near: SPR2?
        public let file: IFFFile
    }

    /// The catalog entries, in ID order: the global floors, pool and water, then the archives'.
    public let entries: [BuildCatalogEntry]
    /// What couldn't be read.
    public let failures: [BuildContentFailure]
    /// Floor archives the install doesn't have.
    public let missingArchives: [String]
    /// `objectdata/globals/floors.iff`, which also holds the pool and water tiles.
    public let globals: IFFFile
    /// How many global floors there are, from ID 1.
    public let globalCount: UInt16

    private let filesByName: [String: IFFFile]
    private let entriesByID: [UInt16: BuildCatalogEntry]

    static let globalsPath = "objectdata/globals/floors.iff"
    static let buildPath = "objectdata/globals/build.iff"

    /// Reads the catalog of an install.
    ///
    /// - Throws: ``ContentError/missingFile(_:)`` if `floors.iff` or `build.iff` is missing, or
    ///   ``ContentError/invalidFile(path:reason:)`` if one of them, its floor or pool strings, or
    ///   an archive doesn't read. FreeSO stops on each.
    public init(files: GameFileIndex) throws(ContentError) {
        globals = try buildGlobal(Self.globalsPath, in: files)
        let build = try buildGlobal(Self.buildPath, in: files)
        let floorStrings = try buildStrings(id: 0x82, in: build, path: Self.buildPath)
        let poolStrings = try buildStrings(id: 0x85, in: build, path: Self.buildPath)

        var entries: [BuildCatalogEntry] = []
        var failures: [BuildContentFailure] = []
        // Global floors stop below 256, where the archives' start.
        let count = UInt16(min(floorStrings.count / 3, 255))
        if floorStrings.count / 3 > 255 {
            failures.append(BuildContentFailure(path: Self.buildPath, reason: "more than 255 global floors; the rest are left out"))
        }
        for id in stride(from: UInt16(1), through: count, by: 1) {
            let base = Int(id - 1) * 3
            entries.append(BuildCatalogEntry(
                id: id, fileName: "global", name: floorStrings.string(at: base + 1),
                price: BuildArchives.price(floorStrings.string(at: base), path: Self.buildPath, failures: &failures),
                description: floorStrings.string(at: base + 2)))
        }
        globalCount = count
        for (id, base) in [(Self.poolID, 0), (Self.waterID, 3)] {
            entries.append(BuildCatalogEntry(
                id: id, fileName: "global", name: poolStrings.string(at: base + 1),
                price: BuildArchives.price(poolStrings.string(at: base), path: Self.buildPath, failures: &failures),
                description: poolStrings.string(at: base + 2)))
        }

        let archives = try BuildArchives(paths: Self.archivePaths, firstID: 256, in: files)
        entries += archives.entries
        entries.sort { $0.id < $1.id }
        self.entries = entries
        self.failures = failures + archives.failures
        missingArchives = archives.missingArchives
        filesByName = archives.filesByName
        entriesByID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// The catalog entry with an ID, if there is one.
    public func entry(id: UInt16) -> BuildCatalogEntry? {
        entriesByID[id]
    }

    /// A floor's sprites, as FreeSO's `Get` finds them: a global floor's from `floors.iff` (far
    /// `id`, medium `id + 256`, near `id + 512`), an archive floor's from its IFF (`SPR2` 1, 257,
    /// and 513). `nil` for an ID with no floor, pool and water included, or an IFF that didn't
    /// read. A sprite the file lacks is `nil`, where FreeSO would stop.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if a sprite chunk doesn't parse.
    public func floor(id: UInt16) throws(ContentError) -> Floor? {
        if id >= 1, id <= globalCount {
            return Floor(id: id, far: try buildSprite(SPR2.self, id: id, in: globals, path: Self.globalsPath),
                         medium: try buildSprite(SPR2.self, id: id + 256, in: globals, path: Self.globalsPath),
                         near: try buildSprite(SPR2.self, id: id + 512, in: globals, path: Self.globalsPath),
                         file: globals)
        }
        guard let entry = entriesByID[id], let file = filesByName[entry.fileName] else { return nil }
        let path = "housedata/\(entry.fileName)"
        return Floor(id: id, far: try buildSprite(SPR2.self, id: 1, in: file, path: path),
                     medium: try buildSprite(SPR2.self, id: 257, in: file, path: path),
                     near: try buildSprite(SPR2.self, id: 513, in: file, path: path),
                     file: file)
    }

    /// A sprite from `floors.iff` by chunk ID (FreeSO's `GetGlobalSPR`): the pool tiles (0x400 up)
    /// and water tiles (0x800 up), or `nil` if there's none.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if the chunk doesn't parse.
    public func globalSprite(id: UInt16) throws(ContentError) -> SPR2? {
        try buildSprite(SPR2.self, id: id, in: globals, path: Self.globalsPath)
    }

    /// Whether FreeSO's `GetGlobalSPR` turns a global sprite's depth into alpha: the water tiles
    /// 0x801 to 0x80F. Its test is `id > 0x800`, so 0x800, water with no pool tile beside it,
    /// keeps its depth; kept, as that's how FreeSO draws it.
    public static func globalSpriteTakesDepthAsAlpha(_ id: UInt16) -> Bool {
        id > 0x800 && id < 0x810
    }

    /// A floor sprite's frame as the texture FreeSO draws: decoded with its palette from `file`
    /// (none is transparent black, as in FreeSO), floor-copied so it repeats across tiles
    /// (`SPR2.decode(frameAt:palette:floorCopy:depthAsAlpha:)`), and for water, with depth as alpha.
    ///
    /// - Throws: ``SpriteError/unreadableChunk(_:)`` if the palette doesn't parse, or the
    ///   decode's errors.
    public static func texture(of sprite: SPR2, frameAt index: Int, in file: IFFFile,
                               depthAsAlpha: Bool = false) throws(SpriteError) -> SpriteImage {
        guard sprite.frames.indices.contains(index) else { throw .noSuchFrame(index) }
        let paletteID = sprite.frames[index].paletteID
        let palette: PALT?
        do {
            palette = try file.chunk(PALT.self, id: paletteID)
        } catch {
            throw .unreadableChunk("PALT #\(paletteID): \(error)")
        }
        return try sprite.decode(frameAt: index, palette: palette, floorCopy: true, depthAsAlpha: depthAsAlpha)
    }
}
