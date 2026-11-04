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

/// The sprites of walls' sides and floors, without the caps and junction pieces.
private func sides(_ sprites: [WallSprite]) -> [WallSprite] {
    sprites.filter { sprite in
        if case .junction = sprite.image { return false }
        return sprite.destination.z != 12
    }
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
    #expect(LotScene.wallDepthBuffer(18)?.depth.first == 255) // a junction's, from 263, capped
    #expect(LotScene.wallDepthBuffer(21) == nil)
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
    let up = sides(LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0, wallsDown: nil))
    #expect(up.map(\.image) == [.pattern(id: 3, zoom: .near, frame: 0), .pattern(id: 4, zoom: .near, frame: 1)])
    #expect(up.map(\.mask) == [.mask(style: 1, down: false, zoom: .near, frame: 0), .mask(style: 1, down: false, zoom: .near, frame: 1)])
    #expect(up[0].anchor == SIMD3(2, 0, 2))
    #expect(up[0].destination == SIMD4(-64, -239, 64, 271))
    // Walls down: masks cut down, and the door's wall is left out, the door being the wall there.
    let down = sides(LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0,
                                          wallsDown: Array(repeating: true, count: 36)))
    #expect(down.map(\.mask) == [.mask(style: 1, down: true, zoom: .near, frame: 0)])
    // A level below the one in view keeps its walls up.
    #expect(sides(LotScene.wallSprites(of: architecture, level: 2, zoom: .near, worldRotation: 0,
                                       wallsDown: Array(repeating: true, count: 36))).count == 2)
}

@Test func aDiagonalTileDrawsItsTwoFloorHalves() throws {
    // On a diagonal tile the top-left pattern and style hold the halves' floors.
    let architecture = try lot([(2, 2, WallTile(segments: .horizontalDiagonal, topLeftPattern: 7, bottomRightPattern: 2,
                                                topLeftStyle: 8, topRightStyle: 1))])
    let sprites = sides(LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0, wallsDown: nil))
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

@Test func junctionsMarkWhereFullHeightWallsEnd() throws {
    // A top-left wall on (2, 2) and a top-right wall on (3, 3): each marks its two ends.
    let architecture = try lot([(2, 2, wall(.topLeft)), (3, 3, wall(.topRight)), (4, 4, wall(.topLeft, style: 2))])
    let walls = architecture.walls[0]
    let joins = LotScene.junctions(walls, cuts: [WallCuts](repeating: WallCuts(), count: 36), width: 6, height: 6)
    #expect(joins.up[2 * 6 + 2] == LotScene.Junction.bottomLeft && joins.up[3 * 6 + 2] == LotScene.Junction.topRight)
    #expect(joins.up[3 * 6 + 3] == LotScene.Junction.bottomRight && joins.up[3 * 6 + 4] == LotScene.Junction.topLeft)
    // A fence isn't full height, so it marks nothing.
    #expect(joins.up[4 * 6 + 4] == 0 && joins.down.allSatisfy { $0 == 0 })
    // Cut down, the ends are marked as cut.
    let cut = LotScene.junctions(walls, cuts: [WallCuts](repeating: WallCuts(topLeft: .down, topRight: .down), count: 36), width: 6, height: 6)
    #expect(cut.down[2 * 6 + 2] == LotScene.Junction.bottomLeft && cut.up[2 * 6 + 2] == 0)
}

@Test func junctionsTurnWithTheView() {
    #expect(LotScene.rotatedJunction(1, worldRotation: 0) == 1)
    #expect(LotScene.rotatedJunction(1, worldRotation: 1) == 2)
    #expect(LotScene.rotatedJunction(8, worldRotation: 1) == 1)
    #expect(LotScene.rotatedJunction(128, worldRotation: 1) == 16)
    #expect(LotScene.rotatedJunction(0b0011_0011, worldRotation: 2) == 0b1100_1100)
    #expect(LotScene.junctionFrames.count == 46 && LotScene.junctionFrames[15] == 14 && LotScene.junctionFrames[240] == 45)
}

@Test func aFullHeightWallsEndsAreCappedAndItsCornersJoined() throws {
    // A lone top-left wall: a cap at each end, and two junction pieces.
    let architecture = try lot([(2, 2, wall(.topLeft))])
    let sprites = LotScene.wallSprites(of: architecture, level: 1, zoom: .near, worldRotation: 0, wallsDown: nil)
    let caps = sprites.filter { $0.destination.z == 12 }
    #expect(caps.count == 2)
    // The far end on the tile behind (2, 1), the left 12 pixels of the side; the near end on the
    // tile in front (1, 3), the right 12 pixels of the top-right side.
    #expect(caps[0].anchor == SIMD3(2, 0, 1) && caps[0].source.x == 0 && caps[0].image == .pattern(id: 3, zoom: .near, frame: 0))
    #expect(caps[1].anchor == SIMD3(1, 0, 3) && caps[1].source.x == 1 - 12.0 / 64 && caps[1].image == .pattern(id: 3, zoom: .near, frame: 1))
    let joins = sprites.compactMap { sprite -> Int? in
        if case .junction(_, let frame) = sprite.image { return frame }
        return nil
    }
    #expect(joins == [LotScene.junctionFrames[LotScene.Junction.bottomLeft], LotScene.junctionFrames[LotScene.Junction.topRight]])
}

@Test func cutawayCutsWallsInFrontOfACutRoomAndAroundThePointer() throws {
    // An indoor room from (2, 3) to (4, 4) on a 10 by 10 lot.
    var architecture = try Architecture(width: 10, height: 10)
    func add(_ segments: WallSegments, _ x: Int, _ y: Int) throws {
        var tile = try architecture.wall(atX: x, y: y, level: 1)
        tile.segments.formUnion(segments)
        if segments.contains(.topLeft) { tile.topLeftStyle = 1 }
        if segments.contains(.topRight) { tile.topRightStyle = 1 }
        try architecture.setWall(tile, atX: x, y: y, level: 1)
    }
    for y in 3..<5 { try add(.topLeft, 2, y); try add(.topLeft, 5, y) }
    for x in 2..<5 { try add(.topRight, x, 3); try add(.topRight, x, 5) }
    architecture.regenerateRooms()
    let inside = UInt16(truncatingIfNeeded: architecture.roomMaps[0].map[3 * 10 + 2])
    #expect(!architecture.rooms[Int(inside)].isOutside)
    // A wall tile is cut when the room is on it or up to four tiles away from the viewer: in the
    // default view (from higher x and y), the front wall at x = 5 is cut for the room behind it.
    let front = LotScene.roomCut(of: architecture, level: 1, worldRotation: 0, rooms: [inside])
    #expect(front[3 * 10 + 5] && front[3 * 10 + 2])
    // From the opposite side, the room is behind the wall at x = 2, which is cut, and the wall at
    // x = 5 is behind the room, and stands.
    let back = LotScene.roomCut(of: architecture, level: 1, worldRotation: 2, rooms: [inside])
    #expect(back[3 * 10 + 2] && !back[3 * 10 + 5])
    // Bare tiles are never cut.
    #expect(!front[8 * 10 + 8])
    // The pointer's rectangle, five tiles a side moved two toward the viewer, cuts what's near walls.
    let rect = LotScene.pointerCut(at: SIMD2(4.2, 4.2), worldRotation: 0)
    #expect(rect.x == 3 && rect.y == 3 && rect.width == 5)
    var cuts = [Bool](repeating: false, count: 100)
    #expect(LotScene.applyCut(&cuts, of: architecture, level: 1, x: rect.x, y: rect.y, width: rect.width, height: rect.height))
    #expect(cuts[3 * 10 + 3] && !cuts[7 * 10 + 7])
    // FreeSO's test for a bare tile needs the tile below it, so the last row always counts as walled.
    var edge = [Bool](repeating: false, count: 100)
    LotScene.applyCut(&edge, of: architecture, level: 1, x: 7, y: 9, width: 1, height: 1)
    #expect(edge[9 * 10 + 7])
}

@Test func theMockLotHasNoDoorsOrWindowsWithStylesOfTheirOwn() throws {
    let session = try LotSession(ClientOptions(installs: [], simburbiaFolder: URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()))
    let (architecture, styles) = LotScene.drawnArchitecture(of: session.vm)
    #expect(styles.isEmpty)
    #expect(architecture.walls == session.vm.architecture.walls)
}

@Test func wallImagesDecodeTheJunctionPieces() throws {
    let images = WallImages(walls: try WallProvider(files: GameFileIndex(root: mockInstall)), floors: nil)
    #expect(images.image(for: .junction(zoom: .near, frame: 45))?.width == 128)
    #expect(images.image(for: .junction(zoom: .far, frame: 46)) == nil)
    // Without the objects, a door's own style has no mask, and its wall is drawn with its own alpha.
    #expect(images.image(for: .objectMask(guid: 1, sprite: 100, down: false, zoom: .near, frame: 0)) == nil)
}
