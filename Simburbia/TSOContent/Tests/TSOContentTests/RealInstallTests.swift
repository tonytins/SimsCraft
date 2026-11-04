import Foundation
import Testing
import TSOFiles
@testable import TSOContent

/// The TSO install named by `TSO_GAME_DIR`, or `nil` when it isn't set.
let gameDirectory: URL? = InstallKind.installs(in: ProcessInfo.processInfo.environment)
    .first { $0.kind == .game }?.directory

/// FreeSO's own content folder in the snapshot (update-46): shipped patches and standalone objects.
let freeSOContentDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("../../../../TSOClient/tso.content/Content").standardizedFileURL

/// Checks against a real TSO install. Skipped unless `TSO_GAME_DIR` is set; no game data is in the repository.
@Suite(.enabled(if: gameDirectory != nil, "TSO_GAME_DIR is not set"))
struct RealInstallTests {
    let content: GameContent

    init() throws {
        content = try GameContent(.init(gameDirectory: try #require(gameDirectory),
                                        freeSOContentDirectory: freeSOContentDirectory))
    }

    @Test func locatesTheInstallFromTheEnvironment() throws {
        #expect(try GameLocator().locate().standardizedFileURL == gameDirectory?.standardizedFileURL)
    }

    @Test func indexesTheInstallWithoutCaseCollisions() {
        #expect(content.files.relativePaths.count > 1_000)
        #expect(content.files.caseCollisions.isEmpty, "\(content.files.caseCollisions.prefix(5))")
    }

    @Test func loadsTheGlobal() throws {
        let global = try content.global()
        #expect(try global.chunks(BHAV.self).count > 100)
        #expect(global.tuning != nil)
    }

    /// Every registered object loads with its semi-global. Objects whose IFF the install
    /// lacks are allowed (the 2002 beta lists `skillcheater` without shipping it); any
    /// other failure isn't.
    @Test func loadsEveryRegisteredObject() throws {
        var loaded = 0, absent: [UInt32] = [], missingFiles: [String] = [], failures: [String] = []
        var semiGlobals = Set<String>()
        var tuningFailures = Set<String>(), skippedPatches = Set<String>()
        for reference in content.objects.references {
            do {
                guard let object = try content.objects.object(guid: reference.guid) else {
                    absent.append(reference.guid)
                    continue
                }
                loaded += 1
                if let name = object.resource.semiGlobal?.name { semiGlobals.insert(name) }
                if let failure = object.resource.tuningFailure { tuningFailures.insert(failure) }
                skippedPatches.formUnion(object.resource.patches.skipped.map(\.name))
            } catch .missingFile(let path) {
                missingFiles.append(path)
            } catch {
                failures.append("\(String(reference.guid, radix: 16)) \(reference.fileName): \(error)")
            }
        }
        print("""
            TSOContent real install: \(content.objects.references.count) registered, \(loaded) loaded, \
            \(absent.count) absent from their files, \(missingFiles.count) with missing files \(missingFiles), \
            \(failures.count) failed; \
            \(semiGlobals.count) semi-globals; \(tuningFailures.count) tuning failures; \
            \(skippedPatches.count) patches skipped; \(content.objects.duplicates.count) duplicate GUIDs
            """)
        #expect(loaded > 2_000)
        #expect(failures.isEmpty, "\(failures.count) failures, first: \(failures.prefix(5))")
        #expect(tuningFailures.isEmpty, "\(tuningFailures.prefix(5))")
    }

    /// Every wall and floor in the catalog reads, with its sprites at every zoom, and so does
    /// every wall style.
    @Test func readsEveryWallAndFloor() throws {
        let floors = try FloorProvider(files: content.files)
        let walls = try WallProvider(files: content.files)
        var floorsWithoutSprites: [UInt16] = [], patternsWithoutSprites: [UInt16] = []
        for entry in floors.entries where entry.id < FloorProvider.waterID {
            let floor = try #require(try floors.floor(id: entry.id))
            if floor.far == nil || floor.medium == nil || floor.near == nil { floorsWithoutSprites.append(entry.id) }
        }
        for entry in walls.entries {
            let pattern = try #require(try walls.pattern(id: entry.id))
            if pattern.far == nil || pattern.medium == nil || pattern.near == nil { patternsWithoutSprites.append(entry.id) }
        }
        let styles = try (1...255).compactMap { try walls.style(id: UInt16($0)) }
        let withMasks = styles.filter { $0.wallsUp.near != nil }.map(\.id)
        print("""
            TSOContent real install: \(floors.entries.count) floors (\(floors.globalCount) global), \
            \(walls.entries.count) wall patterns, styles with masks \(withMasks), \
            missing archives \(floors.missingArchives + walls.missingArchives); \
            without every sprite: floors \(floorsWithoutSprites), patterns \(patternsWithoutSprites)
            """)
        #expect(floors.failures.isEmpty, "\(floors.failures.prefix(5))")
        #expect(walls.failures.isEmpty, "\(walls.failures.prefix(5))")
        #expect(floors.globalCount == 29)
        #expect(try walls.junctions().near != nil)
    }
}
