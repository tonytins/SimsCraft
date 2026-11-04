import Foundation
import Testing
import TSOFiles
@testable import TSOContent

/// A string table in format -1: a count, then C strings.
func strChunk(id: UInt16, _ strings: [String]) -> ChunkFixture {
    var writer = ByteWriter()
    writer.int16(-1)
    writer.uint16(UInt16(strings.count))
    for string in strings { writer.ascii(string + "\0") }
    return ChunkFixture(type: "STR#", id: id, contents: writer.bytes)
}

/// A `SPR#` (version 1000) with no frames.
func sprChunk(id: UInt16) -> ChunkFixture {
    var writer = ByteWriter()
    writer.uint16(1000)
    writer.uint16(0)
    writer.uint32(0) // frames
    writer.uint32(0) // palette
    return ChunkFixture(type: "SPR#", id: id, contents: writer.bytes)
}

/// A `SPR2` (version 1000) with no frames.
func spr2Chunk(id: UInt16) -> ChunkFixture {
    var writer = ByteWriter()
    writer.uint32(1000)
    writer.uint32(0) // frames
    writer.uint32(0) // palette
    return ChunkFixture(type: "SPR2", id: id, contents: writer.bytes)
}

/// A wall or floor IFF from an archive: its catalog strings and the sprites at each zoom.
func buildIFF(name: String, price: String, sprites: [ChunkFixture]) -> Data {
    makeIFF([strChunk(id: 0, [name, price, "about \(name)"])] + sprites)
}

/// An install with the build globals and two of the four archives of each kind.
func buildInstall(floorArchives: [String: [(name: String, contents: Data)]] = [:],
                  wallArchives: [String: [(name: String, contents: Data)]] = [:]) throws -> FakeInstall {
    let install = try FakeInstall()
    try install.write(makeIFF([
        strChunk(id: 0x81, ["10", "Wall", "", "20", "Picket", "", "30", "Iron", "", "40", "Privacy", "", "50", "Banister", ""]),
        strChunk(id: 0x82, ["1", "Grass floor", "", "2", "Wood floor", ""]),
        strChunk(id: 0x83, ["3", "Paint", "", "4", "Brick", "", "5", "Stone", ""]),
        strChunk(id: 0x85, ["6", "Pool", "", "7", "Water", ""]),
    ]), to: "objectdata/globals/build.iff")
    try install.write(makeIFF([spr2Chunk(id: 1), spr2Chunk(id: 257), spr2Chunk(id: 513), spr2Chunk(id: 0x800)]),
                      to: "objectdata/globals/floors.iff")
    try install.write(makeIFF([
        sprChunk(id: 2), sprChunk(id: 514), sprChunk(id: 1026), // style 1 up, no cut-down masks
        sprChunk(id: 4), sprChunk(id: 5), sprChunk(id: 516), sprChunk(id: 517), sprChunk(id: 1028), sprChunk(id: 1029), // style 2
        sprChunk(id: 1537), sprChunk(id: 2049), // pattern 1: far and near, no medium
        sprChunk(id: 4096), sprChunk(id: 4097), sprChunk(id: 4098),
    ]), to: "objectdata/globals/walls.iff")
    let floorSprites = [spr2Chunk(id: 1), spr2Chunk(id: 257), spr2Chunk(id: 513)]
    let wallSprites = [sprChunk(id: 1), sprChunk(id: 1793), sprChunk(id: 2049)]
    let floors = floorArchives.isEmpty ? [
        "housedata/floors/floors.far": [("tile.flr", buildIFF(name: "Tile", price: "11", sprites: floorSprites)),
                                        ("broken.flr", Data("not an IFF".utf8)),
                                        ("carpet.flr", buildIFF(name: "Carpet", price: " 12 ", sprites: floorSprites))],
        "housedata/floors3/floors3.far": [("marble.flr", buildIFF(name: "Marble", price: "lots", sprites: floorSprites)),
                                          ("tile.flr", buildIFF(name: "Tile again", price: "13", sprites: []))],
    ] : floorArchives
    let walls = wallArchives.isEmpty ? [
        "housedata/walls/walls.far": [("panel.wll", buildIFF(name: "Panel", price: "21", sprites: wallSprites)),
                                      ("plaster.wll", buildIFF(name: "Plaster", price: "22", sprites: wallSprites))],
    ] : wallArchives
    for (path, entries) in floors.merging(walls, uniquingKeysWith: { first, _ in first }) {
        try install.write(makeFAR1(entries), to: path)
    }
    return install
}

@Suite struct FloorProviderTests {
    @Test func numbersGlobalFloorsFromTheFloorStringsAndArchiveFloorsFrom256() throws {
        let install = try buildInstall()
        let floors = try FloorProvider(files: GameFileIndex(root: install.root))
        #expect(floors.globalCount == 2)
        #expect(floors.entries.map(\.id) == [1, 2, 256, 258, 259, 260, 65534, 65535])
        // DIFF-29: named from the floor strings, where FreeSO reads the wallpaper ones.
        #expect(floors.entry(id: 1)?.name == "Grass floor" && floors.entry(id: 1)?.price == 1)
        #expect(floors.entry(id: 65535)?.name == "Pool" && floors.entry(id: 65534)?.name == "Water")
        #expect(floors.entry(id: 256)?.fileName == "tile.flr" && floors.entry(id: 256)?.price == 11)
        #expect(floors.entry(id: 258)?.name == "Carpet" && floors.entry(id: 258)?.price == 12)
    }

    @Test func anEntryThatDoesntReadKeepsItsIDAndIsReported() throws {
        let install = try buildInstall()
        let floors = try FloorProvider(files: GameFileIndex(root: install.root))
        // broken.flr took 257, so the entries after it keep FreeSO's numbers.
        #expect(floors.entry(id: 257) == nil)
        #expect(floors.entry(id: 259)?.name == "Marble")
        #expect(floors.failures.map(\.path) == ["housedata/floors/floors.far/broken.flr", "housedata/floors3/floors3.far/marble.flr"])
        #expect(floors.entry(id: 259)?.price == nil)
    }

    @Test func missingArchivesHoldNoFloors() throws {
        let install = try buildInstall()
        let floors = try FloorProvider(files: GameFileIndex(root: install.root))
        #expect(floors.missingArchives == ["housedata/floors2/floors2.far", "housedata/floors4/floors4.far"])
    }

    @Test func findsEachFloorsSpritesAndALaterArchiveWinsByName() throws {
        let install = try buildInstall()
        let floors = try FloorProvider(files: GameFileIndex(root: install.root))
        let global = try #require(try floors.floor(id: 1))
        #expect(global.far?.id == 1 && global.medium?.id == 257 && global.near?.id == 513)
        let missingSprites = try #require(try floors.floor(id: 2))
        #expect(missingSprites.far == nil && missingSprites.near == nil)
        // tile.flr is in floors3.far too, without sprites; FreeSO's FAR1Provider reads that one.
        let tile = try #require(try floors.floor(id: 256))
        #expect(tile.far == nil)
        #expect(try floors.floor(id: 258)?.near?.id == 513)
        #expect(try floors.floor(id: 257) == nil)
        #expect(try floors.floor(id: FloorProvider.poolID) == nil)
        #expect(try floors.floor(id: 300) == nil)
        #expect(try floors.globalSprite(id: 0x800) != nil && floors.globalSprite(id: 0x801) == nil)
    }

    @Test func aMissingGlobalFileIsAnError() throws {
        let install = try buildInstall()
        try FileManager.default.removeItem(at: install.root.appendingPathComponent("objectdata/globals/build.iff"))
        let empty = try FakeInstall()
        #expect(throws: ContentError.missingFile("objectdata/globals/floors.iff")) {
            try FloorProvider(files: GameFileIndex(root: empty.root))
        }
        #expect(throws: ContentError.missingFile("objectdata/globals/build.iff")) {
            try FloorProvider(files: GameFileIndex(root: install.root))
        }
    }

    @Test func aBrokenArchiveIsAnError() throws {
        let install = try buildInstall()
        try install.write(Data("FAR!byAZ".utf8), to: "housedata/floors2/floors2.far")
        #expect(throws: ContentError.self) { try FloorProvider(files: GameFileIndex(root: install.root)) }
    }
}

@Suite struct WallProviderTests {
    @Test func numbersPatternsAndStyles() throws {
        let install = try buildInstall()
        let walls = try WallProvider(files: GameFileIndex(root: install.root))
        #expect(walls.entries.map(\.id) == [1, 2, 3, 256, 257])
        #expect(walls.entry(id: 2)?.name == "Brick" && walls.entry(id: 2)?.price == 4)
        #expect(walls.entry(id: 257)?.fileName == "plaster.wll")
        #expect(walls.styleEntries.map(\.id) == [1, 2, 13, 12, 14])
        #expect(walls.styleEntries.map(\.name) == ["Wall", "Picket", "Iron", "Privacy", "Banister"])
        #expect(walls.missingArchives == ["housedata/walls2/walls2.far", "housedata/walls3/walls3.far", "housedata/walls4/walls4.far"])
        #expect(walls.failures.isEmpty)
    }

    @Test func globalPatternsAlwaysExistAndUnknownArchiveOnesFallBack() throws {
        let install = try buildInstall()
        let walls = try WallProvider(files: GameFileIndex(root: install.root))
        let one = try #require(try walls.pattern(id: 1))
        #expect(one.far?.id == 1537 && one.medium == nil && one.near?.id == 2049)
        let empty = try #require(try walls.pattern(id: 200))
        #expect(empty.far == nil && empty.medium == nil && empty.near == nil)
        #expect(try walls.pattern(id: 257)?.medium?.id == 1793)
        // FreeSO's tolerance: an ID no archive has is drawn as the first archive pattern.
        #expect(try walls.pattern(id: 4000)?.near?.id == 2049)
    }

    @Test func withoutArchivePatternsAnUnknownIDHasNone() throws {
        let install = try buildInstall(wallArchives: ["housedata/walls/walls.far": []])
        let walls = try WallProvider(files: GameFileIndex(root: install.root))
        #expect(try walls.pattern(id: 256) == nil)
    }

    @Test func aStyleWithoutCutDownMasksUsesItsFullOnes() throws {
        let install = try buildInstall()
        let walls = try WallProvider(files: GameFileIndex(root: install.root))
        let wall = try #require(try walls.style(id: 1))
        #expect(wall.wallsUp.far?.id == 2 && wall.wallsDown.far?.id == 2 && wall.wallsDown.near?.id == 1026)
        #expect(wall.entry?.name == "Wall")
        let picket = try #require(try walls.style(id: 2))
        #expect(picket.wallsDown.far?.id == 5 && picket.wallsDown.medium?.id == 517 && picket.wallsDown.near?.id == 1029)
        // DIFF-29: a style the catalog doesn't sell has no strings, where FreeSO gives it the wall's.
        #expect(try walls.style(id: 3)?.entry == nil)
        #expect(try walls.style(id: 0) == nil && walls.style(id: 256) == nil)
        let junctions = try walls.junctions()
        #expect(junctions.far?.id == 4096 && junctions.near?.id == 4098)
    }
}
