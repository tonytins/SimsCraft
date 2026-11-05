import Foundation
import Testing
import TSOFiles
@testable import TSOContent

/// `Simburbia/MockInstall`: a made-up install committed for tests, so these always run.
let mockInstall = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("../../../MockInstall/TSOClient").standardizedFileURL

/// The mock install read the way a real one is (see its README for what's in it).
@Suite struct MockInstallTests {
    let content: GameContent

    init() throws {
        content = try GameContent(.init(gameDirectory: mockInstall))
    }

    @Test func registersTheSevenMockObjects() {
        #expect(content.objects.references.map(\.guid) == [0x4D4F_4301, 0x4D4F_4302, 0x4D4F_4303, 0x4D4F_4304, 0x4D4F_4305, 0x4D4F_4306, 0x4D4F_4307])
        #expect(content.objects.references.map(\.fileName) == ["mockchair", "mocktable", "mocktable", "mocktable", "mocklamp", "mockregister", "mocksim"])
        #expect(content.objects.duplicates.isEmpty)
    }

    @Test func loadsEachObjectWithTheMockSemiGlobal() throws {
        for reference in content.objects.references {
            let object = try #require(try content.objects.object(guid: reference.guid))
            #expect(object.resource.semiGlobal?.name == "mockglobals")
            #expect(try object.resource.semiGlobal?.chunk(BHAV.self, id: 8192) != nil)
            #expect(try object.resource.chunk(BHAV.self, id: 4096) != nil && object.resource.chunk(BHAV.self, id: 4097) != nil)
        }
    }

    @Test func describesTheTableAsAMasterWithTwoParts() throws {
        let table = try #require(try content.objects.object(guid: 0x4D4F_4302))
        let left = try #require(try content.objects.object(guid: 0x4D4F_4303))
        let right = try #require(try content.objects.object(guid: 0x4D4F_4304))
        #expect([table, left, right].allSatisfy { $0.definition.masterID == 1 })
        #expect([table.definition.subIndex, left.definition.subIndex, right.definition.subIndex] == [-1, 0, 0x0100])
        let chair = try #require(try content.objects.object(guid: 0x4D4F_4301))
        #expect(chair.definition.masterID == 0)
    }

    @Test func loadsTheGlobal() throws {
        #expect(try content.global().chunk(BHAV.self, id: 256) != nil)
    }

    /// The mock's own made-up motive tuning has every key the defaults have, so none come from them.
    @Test func readsTheMadeUpMotiveTuning() throws {
        let global = try content.globalTuning()
        #expect(global.tuning.entry(named: "simmotives")?.number(forKey: "WakeHours") == 16)
        #expect(global.tuning.entry(named: "lotmotives")?.values.count == 77)
        #expect(global.defaultedKeys.isEmpty)
    }

    /// An unpatched disc's `tuning.dat` has other entries but no motive tuning: every motive key
    /// comes from Simburbia's defaults, and the install's own entries stay.
    @Test func takesWhatTheInstallLacksFromTheDefaults() throws {
        let install = try FakeInstall()
        try install.write("<ObjectInfoTable></ObjectInfoTable>", to: "packingslips/objecttable.xml")
        try install.write(makeFAR1([]), to: "objectdata/objects/objiff.far")
        try install.write(tuningDat([("SimMotives", [("WakeHours", "12")]), ("Roommates", [("Max", "8")])]), to: "tuning.dat")
        let global = try GameContent(.init(gameDirectory: install.root)).globalTuning()
        #expect(global.tuning.entry(named: "SimMotives")?.number(forKey: "WakeHours") == 12)
        #expect(global.tuning.entry(named: "Roommates")?.value(forKey: "Max") == "8")
        #expect(global.defaultedKeys.count == 88 && !global.defaultedKeys.contains("SimMotives/WakeHours"))
        #expect(global.defaultedKeys.first == "SimMotives/HungerDecrementRatio")
    }

    @Test func aMissingOrBrokenTuningFileIsAnError() throws {
        let install = try FakeInstall()
        try install.write("<ObjectInfoTable></ObjectInfoTable>", to: "packingslips/objecttable.xml")
        try install.write(makeFAR1([]), to: "objectdata/objects/objiff.far")
        let content = try GameContent(.init(gameDirectory: install.root))
        #expect(throws: ContentError.missingFile("tuning.dat")) { try content.globalTuning() }
        let url = try install.write(Data([2, 0, 0, 0]), to: "tuning.dat")
        // The file index is taken when the content loads, so a fresh one sees the new file.
        let reloaded = try GameContent(.init(gameDirectory: install.root))
        #expect(throws: ContentError.invalidFile(path: url.path, reason: String(describing: TuningError.notATuningFile))) {
            try reloaded.globalTuning()
        }
    }

    @Test func readsTheMadeUpWallsAndFloors() throws {
        let floors = try FloorProvider(files: content.files)
        #expect(floors.entries.map(\.id) == [1, 2, 256, 257, 65534, 65535])
        #expect(floors.entries.map(\.name) == ["Mock Grass", "Mock Planks", "Mock Tile", "Mock Carpet", "Mock Water", "Mock Pool"])
        #expect(floors.failures.isEmpty && floors.missingArchives.count == 3)
        for id: UInt16 in [1, 2, 256, 257] {
            let floor = try #require(try floors.floor(id: id))
            let palette = try floor.file.chunk(PALT.self, id: 1)
            for sprite in [floor.far, floor.medium, floor.near] {
                let image = try #require(sprite).decode(frameAt: 0, palette: palette)
                #expect(image.width > 0 && image.rgba != nil)
            }
        }
        #expect(try floors.globalSprite(id: 0x420)?.frames.count == 1)
        #expect(try floors.globalSprite(id: 0x80F)?.frames.count == 3)

        let walls = try WallProvider(files: content.files)
        #expect(walls.entries.map(\.id) == [1, 2, 3, 256, 257])
        #expect(walls.styleEntries.map(\.name) == ["Mock Wall", "Mock Picket Fence", "Mock Iron Fence", "Mock Privacy Fence", "Mock Banister"])
        #expect(walls.failures.isEmpty && walls.missingArchives.count == 3)
        for id: UInt16 in [1, 2, 3, 252, 253, 256, 257] {
            let pattern = try #require(try walls.pattern(id: id))
            #expect([pattern.far, pattern.medium, pattern.near].allSatisfy { $0?.frames.count == 4 })
        }
        let wall = try #require(try walls.style(id: 1))
        #expect(wall.wallsDown.near?.id == 1027)
        #expect(try walls.style(id: 2)?.wallsDown.near?.id == 1028) // no cut-down masks: the full ones
        #expect(try walls.junctions().near?.frames.count == 46)
    }
}
