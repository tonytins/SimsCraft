// Walls as update-46's WallComponent lays them out: turned with the view, cut, and placed.

import Foundation
@testable import LotScene
import SimAntics
import Testing
import TSOContent
import TSOFiles

private let mockInstall = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("../../../MockInstall/TSOClient").standardizedFileURL

private func lot(_ walls: [(x: Int, y: Int, wall: WallTile)]) throws -> Architecture {
    var architecture = try Architecture(width: 6, height: 6)
    for entry in walls { try architecture.setWall(entry.wall, atX: entry.x, y: entry.y, level: 1) }
    return architecture
}

private func wall(_ segments: WallSegments, pattern: UInt16 = 3, style: UInt16 = 1) -> WallTile {
    WallTile(segments: segments, topLeftPattern: pattern, topRightPattern: pattern + 1, bottomLeftPattern: pattern + 2,
             bottomRightPattern: pattern + 3, topLeftStyle: style, topRightStyle: style)
}

@Test func depthImagesFollowFreeSOsGradients() throws {
    let topLeft = try #require(LotScene.wallDepthBuffer(0))
    #expect(topLeft.width == 64 && topLeft.height == 271)
    #expect(Array(topLeft.depth[0..<3]) == [74, 75, 76])
    #expect(topLeft.depth[64] == 74) // 74.5 rounds half to even
    #expect(topLeft.depth[3 * 64] == 76) // 75.5 rounds up to even
    #expect(topLeft.depth.last == 255) // 74 + 63 + 135 caps at 255
    let diagonal = try #require(LotScene.wallDepthBuffer(2))
    #expect(diagonal.depth[0] == 90) // 89.5 to even
    let floor = try #require(LotScene.wallDepthBuffer(12))
    #expect(floor.depth[0] == 255 && floor.depth[128] == 253) // 255 − 1.525, rounded
    #expect(LotScene.wallDepthBuffer(18) == nil)
}

@Test(arguments: [(UInt32(0), SIMD2<Float>(2, 3)), (1, SIMD2(2, 4)), (2, SIMD2(3, 4)), (3, SIMD2(3, 3))])
func aTilesTopCornerTurnsWithTheView(rotation: UInt32, corner: SIMD2<Float>) {
    #expect(LotScene.topCorner(x: 2, y: 3, worldRotation: rotation) == corner)
}

@Test func wallsTurnWithTheViewAsTheSidesOfTheTilesDiamond() throws {
    // A top-left wall on (2, 2) and a top-right wall on (2, 3), its neighbor along y.
    var tl = wall(.topLeft, style: 2)
    tl.topLeftDoor = true
    let architecture = try lot([(2, 2, tl), (2, 3, wall(.topRight, style: 13))])
    let walls = architecture.walls[0]
    let turned = LotScene.rotatedWall(walls, x: 2, y: 2, width: 6, height: 6, worldRotation: 1)
    // Turned a quarter, the top-left edge reads as the top right, and the neighbor's top right as the top left.
    #expect(turned.segments == .topRight)
    #expect(turned.topRightPattern == 3 && turned.topRightStyle == 2 && turned.topRightDoor)
    #expect(turned.topLeftStyle == 13)
    #expect(LotScene.rotatedWall(walls, x: 2, y: 2, width: 6, height: 6, worldRotation: 0) == walls[2 * 6 + 2])
    // A horizontal diagonal reads as a vertical one a quarter turn on, its halves swapped.
    let diagonal = try lot([(2, 2, wall(.horizontalDiagonal))]).walls[0]
    let turnedDiagonal = LotScene.rotatedWall(diagonal, x: 2, y: 2, width: 6, height: 6, worldRotation: 1)
    #expect(turnedDiagonal.segments == .verticalDiagonal)
    #expect(turnedDiagonal.bottomRightPattern == 5 && turnedDiagonal.topLeftPattern == 1 && turnedDiagonal.topLeftStyle == 3)
}

@Test func cutsFollowWhereTheWallsAreDown() throws {
    let architecture = try lot([(2, 2, wall([.topLeft, .topRight])), (3, 3, wall(.topLeft, style: 2)), (4, 2, wall(.topLeft))])
    let walls = architecture.walls[0]
    // Everything down: full-height walls go down, a fence stays up.
    let allDown = LotScene.wallCuts(walls, width: 6, height: 6, wallsDownAt: Array(repeating: true, count: 36))
    #expect(allDown[2 * 6 + 2] == WallCuts(topLeft: .down, topRight: .down))
    #expect(allDown[3 * 6 + 3] == WallCuts())
    // Only (4, 2) down, so the tile at x − 1 is up: the wall on that edge of the cut stays up.
    var oneDown = Array(repeating: false, count: 36)
    oneDown[2 * 6 + 4] = true
    #expect(LotScene.wallCuts(walls, width: 6, height: 6, wallsDownAt: oneDown)[2 * 6 + 4].topLeft == .up)
    // Down with the tile at y + 1 up and y − 1 down: slanted.
    var slant = Array(repeating: true, count: 36)
    slant[3 * 6 + 2] = false
    slant[1 * 6 + 1] = true
    #expect(LotScene.wallCuts(walls, width: 6, height: 6, wallsDownAt: slant)[2 * 6 + 2].topLeft == .downRightUpLeft)
}

@Test func wallSpritesTakeTheirStylesMasksAndDoors() throws {
    var door = wall(.topRight)
    door.topRightDoor = true
    let architecture = try lot([(2, 2, wall(.topLeft)), (3, 2, door)])
    let up = LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0, wallsDown: nil)
    #expect(up.map(\.image) == [.pattern(id: 3, zoom: .near, frame: 0), .pattern(id: 4, zoom: .near, frame: 1)])
    #expect(up.map(\.mask) == [.mask(style: 1, down: false, zoom: .near, frame: 0), .mask(style: 1, down: false, zoom: .near, frame: 1)])
    #expect(up[0].anchor == SIMD3(2, 0, 2))
    #expect(up[0].destination == SIMD4(-64, -239, 64, 271))
    // Walls down: masks cut down, and the door's wall is left out, the door being the wall there.
    let down = LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0,
                                    wallsDown: Array(repeating: true, count: 36))
    #expect(down.map(\.mask) == [.mask(style: 1, down: true, zoom: .near, frame: 0)])
    // A level below the one in view keeps its walls up.
    #expect(LotScene.wallSprites(of: architecture, level: 2, zoom: .near, worldRotation: 0,
                                 wallsDown: Array(repeating: true, count: 36)).count == 2)
}

@Test func aDiagonalTileDrawsItsTwoFloorHalves() throws {
    // On a diagonal tile the top-left pattern and style hold the halves' floors.
    let architecture = try lot([(2, 2, WallTile(segments: .horizontalDiagonal, topLeftPattern: 7, bottomRightPattern: 2,
                                                topLeftStyle: 8, topRightStyle: 1))])
    let sprites = LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0, wallsDown: nil)
    #expect(sprites.map(\.image) == [.pattern(id: 2, zoom: .near, frame: 2), .floor(id: 7, zoom: .near), .floor(id: 8, zoom: .near)])
    // The bottom half, then the top half.
    #expect(sprites[1].source == SIMD4(0, 0.5, 1, 0.5) && sprites[2].source == SIMD4(0, 0, 1, 0.5))
    #expect(sprites[1].depthBuffer == 12)
}

@Test func wallImagesDecodeTheMockInstallsWalls() throws {
    let floors = FloorImages(floors: try FloorProvider(files: GameFileIndex(root: mockInstall)))
    let images = WallImages(walls: try WallProvider(files: GameFileIndex(root: mockInstall)), floors: floors)
    let pattern = try #require(images.image(for: .pattern(id: 2, zoom: .near, frame: 0)))
    #expect(pattern.width == 64 && pattern.height == 271)
    let mask = try #require(images.image(for: .mask(style: 1, down: true, zoom: .medium, frame: 1)))
    #expect(mask.width == 32 && mask.height == 135)
    #expect(images.image(for: .floor(id: 1, zoom: .near))?.width == 128)
    #expect(images.image(for: .mask(style: 3, down: false, zoom: .near, frame: 0)) == nil)
    #expect(images.failures.isEmpty)
}
