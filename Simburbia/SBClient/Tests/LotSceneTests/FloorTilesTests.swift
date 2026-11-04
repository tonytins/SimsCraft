// Floors as update-46 draws them: which tiles take which texture, and where in it.

import Foundation
import LotScene
import SimAntics
import Testing
import TSOContent
import TSOFiles

private let mockInstall = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("../../../MockInstall/TSOClient").standardizedFileURL

/// A 6 by 6 lot, so tiles 1 to 4 are inside its edge.
private func lot(_ floors: [(x: Int, y: Int, level: Int, pattern: UInt16)]) throws -> Architecture {
    var architecture = try Architecture(width: 6, height: 6)
    for floor in floors { try architecture.setFloor(floor.pattern, atX: floor.x, y: floor.y, level: floor.level) }
    return architecture
}

@Test func floorTilesSkipTheEdgeAndEmptyTilesAndGroupByTexture() throws {
    let architecture = try lot([(0, 2, 1, 5), (2, 2, 1, 5), (3, 2, 1, 2), (2, 5, 1, 5), (3, 3, 2, 5), (4, 4, 1, 0)])
    let groups = LotScene.floorTiles(of: architecture)
    #expect(groups.map(\.texture) == [.pattern(2), .pattern(5)])
    #expect(groups[1].tiles == [FloorTile(level: 1, x: 2, y: 2), FloorTile(level: 2, x: 3, y: 3)])
}

@Test func poolAndWaterTilesTakeTheShapeOfTheirNeighbors() throws {
    // A pool at (2, 2) and (3, 2); water at (4, 4), beside the edge on two sides.
    let architecture = try lot([(2, 2, 1, 65535), (3, 2, 1, 65535), (4, 4, 1, 65534)])
    let tiles = Dictionary(uniqueKeysWithValues: LotScene.floorTiles(of: architecture).flatMap { group in
        group.tiles.map { (SIMD2($0.x, $0.y), group.texture) }
    })
    // Bit 1 is y − 1, 2 x − 1, 4 y + 1, 8 x + 1.
    #expect(tiles[SIMD2(2, 2)] == .pool(shape: 8))
    #expect(tiles[SIMD2(3, 2)] == .pool(shape: 2))
    // Tiles on (or past) the lot's edge count as joined: x + 1 and y + 1 are at 5.
    #expect(tiles[SIMD2(4, 4)] == .water(shape: 4 | 8))
}

@Test func aRawPatternInThePoolRangeIsDrawnAsThatShape() {
    #expect(FloorTexture(convertedID: 65510) == .water(shape: 6))
    #expect(FloorTexture(convertedID: 65523) == .pool(shape: 3))
    #expect(FloorTexture(convertedID: 0) == nil && FloorTexture(convertedID: 65503) == nil)
    #expect(FloorTexture(convertedID: 300) == .pattern(300))
}

@Test func poolShapesTurnWithTheView() {
    // FreeSO rotates the four bits by (4 − rotation) mod 4.
    #expect(LotScene.shape(0b0001, worldRotation: 0) == 0b0001)
    #expect(LotScene.shape(0b0001, worldRotation: 1) == 0b1000)
    #expect(LotScene.shape(0b0001, worldRotation: 2) == 0b0100)
    #expect(LotScene.shape(0b1001, worldRotation: 3) == 0b0011)
}

@Test(arguments: [(UInt32(0), false, SIMD2<Float>(1.5, 2)), (1, false, SIMD2(2, 1.5)), (2, false, SIMD2(1.5, 2)),
                  (3, false, SIMD2(2, 1.5)), (1, true, SIMD2(-2, 1.5)), (2, true, SIMD2(-1.5, -2)), (3, true, SIMD2(2, -1.5))])
func textureCoordinatesFollowTheTerrainAndTheView(rotation: UInt32, counter: Bool, expected: SIMD2<Float>) {
    // The point (3, 1): u = (3 − 1 + 1) / 2 and v = (3 + 1) / 2, then the view's matrix, then a
    // half-pixel nudge down.
    let texture: FloorTexture = counter ? .pool(shape: 0) : .pattern(1)
    let uv = LotScene.textureCoordinates(x: 3, y: 1, texture: texture, worldRotation: rotation, zoom: .near)
    let nudge = SIMD2<Float>(0, 0.5 / 64)
    #expect(abs(uv.x - (expected + nudge).x) < 1e-6 && abs(uv.y - (expected + nudge).y) < 1e-6)
}

@Test func floorImagesDecodeTheMockInstallsFloorsAsTextures() throws {
    let images = FloorImages(floors: try FloorProvider(files: GameFileIndex(root: mockInstall)))
    for (zoom, size) in [(SpriteZoom.far, SIMD2(32, 16)), (.medium, SIMD2(64, 32)), (.near, SIMD2(128, 64))] {
        for texture in [FloorTexture.pattern(1), .pattern(257), .pool(shape: 5), .water(shape: 9)] {
            let image = try #require(images.image(for: texture, zoom: zoom))
            #expect(SIMD2(image.width, image.height) == size, "\(texture) at \(zoom)")
        }
    }
    // Water is opaque inside its diamond and clear outside, its depth turned into alpha.
    let water = try #require(images.image(for: .water(shape: 9), zoom: .near)?.rgba)
    #expect(water[(32 * 128 + 64) * 4 + 3] == 255)
    #expect(images.image(for: .pattern(3), zoom: .near) == nil)
    #expect(images.failures.isEmpty)
}
