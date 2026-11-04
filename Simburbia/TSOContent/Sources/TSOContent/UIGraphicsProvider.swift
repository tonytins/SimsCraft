import Foundation
import TSOFiles

/// The interface's graphics, by asset ID: every entry of the FAR3 archives under `uigraphics`.
///
/// Ports FreeSO's `UIGraphicsProvider` and the `FAR3Provider` it builds on. An ID is the entry's
/// file ID shifted up 32 bits, then its type ID, as FreeSO's `UIFileIDs` write them (`setup` is
/// `0x3A300000001`). A few graphics aren't in any archive, and FreeSO names their loose files;
/// one ID the rack's panel asks for is redirected to the file that holds it. Those are kept.
///
/// Where it differs from FreeSO: an ID that two archives both hold is FreeSO's `Dictionary.Add`
/// failing, which stops its content from loading; here the first archive in path order keeps it,
/// and the rest are listed in ``duplicates``. An archive that doesn't read is listed in
/// ``failures`` and the others still load (DIFF-31 in the scorecard).
public struct UIGraphicsProvider: Sendable {
    /// Graphics FreeSO reads from loose files instead of archives, by ID.
    static let looseFiles: [UInt64: String] = [
        0x0000_0CB8_0000_0002: "uigraphics/friendshipweb/friendshipwebalpha.tga",
        0x0000_CBFB_0000_0001: "uigraphics/hints/hint_mechanicskill.bmp",
        0x1AF0_856D_DBAC: "uigraphics/chat/balloonpointersadbottom.bmp",
        0x1B00_856D_DBAC: "uigraphics/chat/balloonpointersadside.bmp",
        0x1B10_856D_DBAC: "uigraphics/chat/balloontilessad.bmp",
        0x0197_2454_856D_DBAC: "uigraphics/friendshipweb/f_web_inbtn.bmp",
        0x03D3_AEF0_856D_DBAC: "uigraphics/friendshipweb/f_web_outbtn.bmp",
    ]
    /// IDs FreeSO redirects to another (the rack's panel asks for one the archives hold under another).
    static let redirects: [UInt64: UInt64] = [0x0000_0288_0000_0001: 0x0000_0946_0000_0001]

    private let archives: [FAR3Archive]
    private let paths: [String]
    private let entriesByID: [UInt64: (archive: Int, entry: FAR3Archive.Entry)]
    private let files: GameFileIndex

    /// IDs found in more than one archive, each kept from the first.
    public let duplicates: [AssetID]
    /// Archives that couldn't be read, each with why.
    public let failures: [BuildContentFailure]

    /// Opens every archive whose path holds `uigraphics/` and then `.dat`, in path order (FreeSO's
    /// unanchored `uigraphics/.*\.dat`, here in any letter case).
    public init(files: GameFileIndex) {
        self.files = files
        var archives: [FAR3Archive] = [], paths: [String] = []
        var entriesByID: [UInt64: (archive: Int, entry: FAR3Archive.Entry)] = [:]
        var duplicates: [AssetID] = [], failures: [BuildContentFailure] = []
        for path in files.paths(where: Self.isArchive) {
            guard let url = files.url(for: path) else { continue }
            do {
                let archive = try FAR3Archive(contentsOf: url)
                for entry in archive.entries {
                    if entriesByID[entry.assetID.packed] != nil {
                        duplicates.append(entry.assetID)
                    } else {
                        entriesByID[entry.assetID.packed] = (archives.count, entry)
                    }
                }
                archives.append(archive)
                paths.append(path)
            } catch {
                failures.append(BuildContentFailure(path: path, reason: String(describing: error)))
            }
        }
        self.archives = archives
        self.paths = paths
        self.entriesByID = entriesByID
        self.duplicates = duplicates
        self.failures = failures
    }

    static func isArchive(_ lowerCasePath: String) -> Bool {
        guard let start = lowerCasePath.range(of: "uigraphics/") else { return false }
        return lowerCasePath[start.upperBound...].contains(".dat")
    }

    /// Every ID the archives hold, in order.
    public var ids: [AssetID] {
        entriesByID.keys.sorted().map { AssetID(packed: $0) }
    }

    /// A graphic's bytes, as stored (a BMP, a Targa, or another image file), or `nil` if there's
    /// no graphic with that ID.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if its archive entry or loose file
    ///   can't be read.
    public func data(id: AssetID) throws(ContentError) -> Data? {
        let packed = Self.redirects[id.packed] ?? id.packed
        if let path = Self.looseFiles[packed] {
            guard let url = files.url(for: path) else { return nil }
            do {
                return try Data(contentsOf: url)
            } catch {
                throw .invalidFile(path: path, reason: error.localizedDescription)
            }
        }
        guard let (index, entry) = entriesByID[packed] else { return nil }
        do {
            return try archives[index].data(for: entry)
        } catch {
            throw .invalidFile(path: "\(paths[index])/\(AssetID(packed: packed))", reason: String(describing: error))
        }
    }

    /// A graphic decoded as FreeSO's `ImageLoader` decodes it: a bitmap (`BM`) as a BMP, with its
    /// near-magenta pixels (red and blue 248 or more, green 4 or less) made transparent black as
    /// `ManualTextureMaskSingleThreaded` makes them; a file with a Targa footer as a Targa, as is.
    /// `nil` if there's no graphic with that ID.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if it can't be read or decoded, or is
    ///   a format Simburbia doesn't read yet (1.1097.1.0 holds one PNG, which FreeSO hands to
    ///   MonoGame).
    public func image(id: AssetID) throws(ContentError) -> RasterImage? {
        guard let data = try data(id: id) else { return nil }
        do {
            if data.starts(with: [0x42, 0x4D]) {
                var image = try BMPImage.decode(data)
                Self.maskMagenta(&image)
                return image
            }
            if TargaImage.hasFooter(data) { return try TargaImage.decode(data) }
            throw ImageError.unsupported("a format other than BMP or Targa")
        } catch {
            throw .invalidFile(path: "uigraphics \(id)", reason: String(describing: error))
        }
    }

    /// FreeSO's mask: TSO's interface art marks its transparent parts in magenta, near enough.
    static func maskMagenta(_ image: inout RasterImage) {
        for at in stride(from: 0, to: image.rgba.count, by: 4)
        where image.rgba[at] >= 248 && image.rgba[at + 2] >= 248 && image.rgba[at + 1] <= 4 {
            image.rgba[at] = 0
            image.rgba[at + 1] = 0
            image.rgba[at + 2] = 0
            image.rgba[at + 3] = 0
        }
    }
}
