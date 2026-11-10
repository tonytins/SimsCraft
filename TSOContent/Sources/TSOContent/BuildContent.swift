import Foundation
import TSOFiles

/// A wall or floor the build catalog lists: its ID, where it's stored, and its catalog strings.
///
/// Ports FreeSO's `WallReference` and `FloorReference`. A string the file doesn't have is `nil`,
/// and so is a price that isn't a number; ``BuildContentFailure`` says which.
public struct BuildCatalogEntry: Sendable, Equatable {
    /// The ID blueprints and the architecture use for it.
    public var id: UInt16
    /// The IFF's name in its archive, or `global` for one in `walls.iff` or `floors.iff`.
    public var fileName: String
    public var name: String?
    public var price: Int?
    public var description: String?

    public init(id: UInt16, fileName: String, name: String?, price: Int?, description: String?) {
        self.id = id
        self.fileName = fileName
        self.name = name
        self.price = price
        self.description = description
    }
}

/// Part of the wall or floor content that couldn't be read. FreeSO stops loading content on any
/// of these; Simburbia reports it and loads the rest.
public struct BuildContentFailure: Sendable, Equatable {
    /// The archive and entry, such as `housedata/walls/walls.far/brick.wll`, or the global file.
    public var path: String
    public var reason: String
}

/// The `housedata` archives of walls or floors, read the way FreeSO's providers number them.
struct BuildArchives: Sendable {
    /// The catalog entries, in ID order.
    var entries: [BuildCatalogEntry] = []
    /// Each IFF by its entry name. When two archives have the same name the later one wins, as in
    /// FreeSO's `FAR1Provider`, which the providers read sprites through.
    var filesByName: [String: IFFFile] = [:]
    var failures: [BuildContentFailure] = []
    /// Archives the install doesn't have (the base game and the beta have only the first).
    var missingArchives: [String] = []

    /// The first ID FreeSO's floor pattern conversion keeps for its own tiles (air, water, pools).
    static let reservedIDs: UInt16 = 65503

    /// Reads each archive in turn, numbering its entries from `firstID` in archive order, then
    /// manifest order, as FreeSO's `Init` does.
    ///
    /// An entry takes its ID even when it can't be read, so the entries after it keep FreeSO's
    /// numbers. Each IFF's catalog strings are `STR#` 0: name, price, description.
    ///
    /// - Throws: ``ContentError/invalidFile(path:reason:)`` if an archive exists but isn't a FAR1.
    init(paths: [String], firstID: UInt16, in files: GameFileIndex) throws(ContentError) {
        var nextID = firstID
        for path in paths {
            guard let url = files.url(for: path) else {
                missingArchives.append(path)
                continue
            }
            let archive: FAR1Archive
            do {
                archive = try FAR1Archive(contentsOf: url, variant: .b)
            } catch {
                throw .invalidFile(path: path, reason: String(describing: error))
            }
            for entry in archive.entries {
                let entryPath = "\(path)/\(entry.fileName)"
                guard nextID < Self.reservedIDs else {
                    failures.append(BuildContentFailure(path: entryPath, reason: "past the last ID before the reserved tiles"))
                    continue
                }
                let id = nextID
                nextID += 1
                let file: IFFFile
                do {
                    file = try IFFFile(bytes: archive.data(for: entry))
                } catch {
                    failures.append(BuildContentFailure(path: entryPath, reason: String(describing: error)))
                    continue
                }
                filesByName[entry.fileName] = file
                let strings: StringTable?
                do {
                    strings = try file.chunk(STR.self, id: 0)?.table
                } catch {
                    failures.append(BuildContentFailure(path: entryPath, reason: String(describing: error)))
                    strings = nil
                }
                if strings == nil {
                    failures.append(BuildContentFailure(path: entryPath, reason: "no catalog strings (STR# 0)"))
                }
                let price = Self.price(strings?.string(at: 1), path: entryPath, failures: &failures)
                entries.append(BuildCatalogEntry(id: id, fileName: entry.fileName, name: strings?.string(at: 0),
                                                 price: price, description: strings?.string(at: 2)))
            }
        }
    }

    /// A catalog price, read as .NET's `int.Parse` reads one: surrounding spaces and a sign are
    /// allowed. Anything else is reported, where FreeSO would stop.
    static func price(_ text: String?, path: String, failures: inout [BuildContentFailure]) -> Int? {
        guard let text else { return nil }
        guard let value = Int32(text.trimmingCharacters(in: .whitespaces)) else {
            failures.append(BuildContentFailure(path: path, reason: "the price \(text.debugDescription) isn't a number"))
            return nil
        }
        return Int(value)
    }
}

/// Reads a global IFF the build providers need.
func buildGlobal(_ path: String, in files: GameFileIndex) throws(ContentError) -> IFFFile {
    guard let url = files.url(for: path) else { throw .missingFile(path) }
    do {
        return try IFFFile(contentsOf: url)
    } catch {
        throw .invalidFile(path: path, reason: String(describing: error))
    }
}

/// A sprite chunk from a build file, or `nil` if the file has none with that ID.
func buildSprite<Sprite: IFFChunk>(_ type: Sprite.Type, id: UInt16, in file: IFFFile, path: String) throws(ContentError) -> Sprite? {
    do {
        return try file.chunk(type, id: id)
    } catch {
        throw .invalidFile(path: "\(path): \(Sprite.typeCode) #\(id)", reason: String(describing: error))
    }
}

/// A string table from a build file.
///
/// - Throws: ``ContentError/invalidFile(path:reason:)`` if it's missing or doesn't parse:
///   FreeSO stops loading content on either.
func buildStrings(id: UInt16, in file: IFFFile, path: String) throws(ContentError) -> StringTable {
    let table: StringTable?
    do {
        table = try file.chunk(STR.self, id: id)?.table
    } catch {
        throw .invalidFile(path: "\(path): STR# #\(id)", reason: String(describing: error))
    }
    guard let table else { throw .invalidFile(path: path, reason: "no STR# #\(id)") }
    return table
}
