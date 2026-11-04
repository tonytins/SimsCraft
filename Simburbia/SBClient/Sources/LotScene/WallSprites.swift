import SimAntics
import TSOContent
import TSOFiles

/// How a wall is cut in a view (FreeSO's `WallCut`): standing, cut down, or one of the two
/// slanted cutaway styles a wall takes where the cut begins or ends.
public enum WallCut: UInt8, Sendable {
    case up = 0
    case downLeftUpRight = 1
    case downRightUpLeft = 2
    case down = 3

    /// The other slant, as a cut turned with the view.
    var flipped: WallCut {
        switch self {
        case .downLeftUpRight: .downRightUpLeft
        case .downRightUpLeft: .downLeftUpRight
        default: self
        }
    }
}

/// A tile's two cuts (FreeSO's `WallCuts`). The top-right one also serves the diagonals.
public struct WallCuts: Sendable, Equatable {
    public var topLeft: WallCut = .up
    public var topRight: WallCut = .up

    public init(topLeft: WallCut = .up, topRight: WallCut = .up) {
        self.topLeft = topLeft
        self.topRight = topRight
    }
}

/// An image a wall sprite is drawn with.
public enum WallImage: Hashable, Sendable {
    /// A frame of a wall pattern (one per side: top left, top right, and the two diagonals).
    case pattern(id: UInt16, zoom: SpriteZoom, frame: Int)
    /// A frame of a wall style's mask, standing or cut down.
    case mask(style: UInt16, down: Bool, zoom: SpriteZoom, frame: Int)
    /// A frame of a door's or window's own wall style, from six sprites of the object from
    /// `sprite` up: standing far, medium, near, then cut down (``ObjectWallStyle``).
    case objectMask(guid: UInt32, sprite: UInt16, down: Bool, zoom: SpriteZoom, frame: Int)
    /// A frame of the junction pieces drawn where walls meet.
    case junction(zoom: SpriteZoom, frame: Int)
    /// A floor's texture, drawn in halves on a diagonal tile.
    case floor(id: UInt16, zoom: SpriteZoom)
}

/// One sprite of the walls, placed as update-46's `WallComponent` places it.
public struct WallSprite: Sendable {
    public var level: Int
    public var image: WallImage
    /// The style's mask, whose alpha says which of the pattern's pixels show; `nil` when the
    /// image is drawn with its own alpha (FreeSO's `mask ?? sprite`).
    public var mask: WallImage?
    /// The point the sprite hangs from: the tile's top corner on screen, at its level's floor.
    public var anchor: SIMD3<Float>
    /// Where the sprite goes relative to the anchor, in the zoom's pixels: left, top, width, and height.
    public var destination: SIMD4<Float>
    /// The part of the image drawn, as fractions of it: left, top, width, and height.
    public var source: SIMD4<Float> = SIMD4(0, 0, 1, 1)
    /// The generated depth image it's drawn with (``LotScene/wallDepthBuffer(_:)``).
    public var depthBuffer: Int
    /// Where its depth starts and ends in the world, as for object sprites.
    public var back: SIMD3<Float>
    public var front: SIMD3<Float>
}

/// Which sides of a tile's cut boundary aren't cut (FreeSO's `CutawayEdges`).
struct CutawayEdges: OptionSet {
    let rawValue: UInt8
    static let positiveY = CutawayEdges(rawValue: 1)
    static let positiveX = CutawayEdges(rawValue: 2)
    static let negativeY = CutawayEdges(rawValue: 4)
    static let negativeX = CutawayEdges(rawValue: 8)
    static let specialPositiveY = CutawayEdges(rawValue: 16)
    static let specialPositiveX = CutawayEdges(rawValue: 32)
    static let specialNegativeY = CutawayEdges(rawValue: 64)
    static let specialNegativeX = CutawayEdges(rawValue: 128)
}

extension WallTile {
    /// A full-height wall on the top-left edge (FreeSO's `TopLeftThick`): style 1 or 255.
    var topLeftThick: Bool { segments.contains(.topLeft) && (topLeftStyle == 1 || topLeftStyle == 255) }
    /// A full-height wall on the top-right edge (FreeSO's `TopRightThick`).
    var topRightThick: Bool { segments.contains(.topRight) && (topRightStyle == 1 || topRightStyle == 255) }
}

extension LotScene {
    // MARK: Placement

    /// Each zoom's wall rectangles, relative to its tile's top corner on screen, for the top-left
    /// and top-right sides and the horizontal and vertical diagonals: `WallComponent`'s
    /// `DESTINATION_NEAR`, `_MED`, and `_FAR`, less the top corner's place in them (68, 316 at
    /// near, where the two sides meet and a wall's foot reaches the tile).
    static func wallDestinations(_ zoom: SpriteZoom) -> [SIMD4<Float>] {
        let (rectangles, top): ([SIMD4<Float>], SIMD2<Float>) = switch zoom {
        case .near: ([SIMD4(4, 77, 64, 271), SIMD4(68, 77, 64, 271), SIMD4(4, 109, 128, 240), SIMD4(60, 145, 16, 232)], SIMD2(68, 316))
        case .medium: ([SIMD4(2, 39, 32, 136), SIMD4(34, 39, 32, 136), SIMD4(2, 55, 64, 120), SIMD4(30, 73, 8, 116)], SIMD2(34, 159))
        case .far: ([SIMD4(1, 20, 16, 68), SIMD4(17, 20, 16, 68), SIMD4(1, 28, 32, 60), SIMD4(15, 37, 4, 58)], SIMD2(17, 80))
        }
        return rectangles.map { SIMD4($0.x - top.x, $0.y - top.y, $0.z, $0.w) }
    }

    /// A diagonal tile's floor rectangle, relative to the same corner: `WallComponent`'s
    /// `FLRDEST_*`, one wider, one left, and one down, as `GetFloorSprite` moves it.
    static func halfFloorDestination(_ zoom: SpriteZoom) -> SIMD4<Float> {
        switch zoom {
        case .near: SIMD4(3 - 68, 318 - 316, 128, 64)
        case .medium: SIMD4(1 - 34, 159 - 159, 64, 32)
        case .far: SIMD4(0 - 17, 80 - 80, 32, 16)
        }
    }

    /// The depth image index of a wall side at a zoom (`WallZBuffers[side + 4 × (3 − zoom)]`), and
    /// of a diagonal tile's floor (12 to 14).
    static func wallDepthIndex(side: Int, zoom: SpriteZoom) -> Int {
        side + 4 * Int(3 - zoom.rawValue)
    }

    static func floorDepthIndex(_ zoom: SpriteZoom) -> Int {
        12 + Int(3 - zoom.rawValue)
    }

    /// The tile corner at the top of a tile's diamond on screen in a view.
    static func topCorner(x: Int, y: Int, worldRotation: UInt32) -> SIMD2<Float> {
        switch worldRotation % 4 {
        case 1: SIMD2(Float(x), Float(y + 1))
        case 2: SIMD2(Float(x + 1), Float(y + 1))
        case 3: SIMD2(Float(x + 1), Float(y))
        default: SIMD2(Float(x), Float(y))
        }
    }

    // MARK: Depth images

    /// A generated depth image (`TextureGenerator.GetWallZBuffer`): width, height, then the
    /// depth of each pixel, rising by a step across and another down from a start, rounded half to
    /// even as .NET's `Math.Round` does and capped at 255. Indices 0 to 11 are wall sides (near,
    /// medium, far; top left, top right, horizontal and vertical diagonal), 12 to 17 floors, and
    /// 18 to 20 junctions.
    public static func wallDepthBuffer(_ index: Int) -> (width: Int, height: Int, depth: [UInt8])? {
        let flat: Float = 1.525
        let configs: [[Float]] = [
            [64, 271, 74, 1, 0.5], [64, 271, 135, -1, 0.5], [128, 240, 89.5, 0, 0.5], [16, 232, 45, 0, 0.5],
            [32, 135, 74, 2, 1], [32, 135, 135, -2, 1], [64, 120, 89.5, 0, 1], [8, 116, 45, 0, 1],
            [16, 67, 74, 4, 2], [16, 67, 135, -4, 2], [32, 60, 89.5, 0, 2], [4, 58, 45, 0, 2],
            [128, 64, 255, 0, -flat], [64, 32, 255, 0, -flat * 2], [32, 16, 255, 0, -flat * 4],
            [128, 64, 153, 0, flat], [64, 32, 153, 0, flat * 2], [32, 16, 153, 0, flat * 4],
            [128, 64, 263, 0, -flat], [64, 32, 263, 0, -flat * 2], [32, 16, 263, 0, -flat * 4],
        ]
        guard configs.indices.contains(index) else { return nil }
        let config = configs[index]
        let width = Int(config[0]), height = Int(config[1])
        var depth = [UInt8](repeating: 0, count: width * height)
        var rowStart = config[2]
        for y in 0..<height {
            var value = rowStart
            for x in 0..<width {
                let rounded = min(255, value).rounded(.toNearestOrEven)
                // C#'s unchecked byte cast wraps; these configs never go below 0.
                depth[y * width + x] = UInt8(truncatingIfNeeded: Int(rounded))
                value += config[3]
            }
            rowStart += config[4]
        }
        return (width, height, depth)
    }

    // MARK: Turning with the view

    /// A tile's walls as they read in a view (`WallComponent.RotateWall`): the sides of its
    /// diamond on screen, some of which the lot stores on the next tile, and its diagonals.
    static func rotatedWall(_ walls: [WallTile], x: Int, y: Int, width: Int, height: Int, worldRotation: UInt32) -> WallTile {
        let input = walls[y * width + x]
        let turn = Int(worldRotation % 4)
        guard turn != 0 else { return input }
        func tile(_ tx: Int, _ ty: Int) -> WallTile? {
            tx < width && ty < height ? walls[ty * width + tx] : nil
        }
        var output = WallTile()
        if input.segments == .horizontalDiagonal || input.segments == .verticalDiagonal {
            let horizontal = input.segments == .horizontalDiagonal
            output.segments = (turn % 2 == 0) == horizontal ? .horizontalDiagonal : .verticalDiagonal
            output.topRightStyle = input.topRightStyle
            // Which turns swap the two sides' patterns and floors.
            let flips = horizontal ? (turn == 1 || turn == 2) : (turn == 2 || turn == 3)
            if flips {
                output.bottomRightPattern = input.bottomLeftPattern
                output.bottomLeftPattern = input.bottomRightPattern
                output.topLeftStyle = input.topLeftPattern
                output.topLeftPattern = input.topLeftStyle
            } else {
                output.bottomRightPattern = input.bottomRightPattern
                output.bottomLeftPattern = input.bottomLeftPattern
                output.topLeftStyle = input.topLeftStyle
                output.topLeftPattern = input.topLeftPattern
            }
            return output
        }
        let segments = input.segments
        switch turn {
        case 1:
            if segments.contains(.topLeft) { output.segments.insert(.topRight) }
            if segments.contains(.topRight) { output.segments.insert(.bottomRight) }
            if segments.contains(.bottomRight) { output.segments.insert(.bottomLeft) }
            if segments.contains(.bottomLeft) { output.segments.insert(.topLeft) }
            output.topLeftPattern = input.bottomLeftPattern
            output.topRightPattern = input.topLeftPattern
            output.bottomRightPattern = input.topRightPattern
            output.bottomLeftPattern = input.bottomRightPattern
            if let left = tile(x, y + 1) {
                output.topLeftStyle = left.topRightStyle
                output.objectTopLeftStyle = left.objectTopRightStyle
                output.topLeftDoor = left.topRightDoor
            }
            output.topRightStyle = input.topLeftStyle
            output.objectTopRightStyle = input.objectTopLeftStyle
            output.topRightDoor = input.topLeftDoor
        case 2:
            if segments.contains(.topLeft) { output.segments.insert(.bottomRight) }
            if segments.contains(.topRight) { output.segments.insert(.bottomLeft) }
            if segments.contains(.bottomRight) { output.segments.insert(.topLeft) }
            if segments.contains(.bottomLeft) { output.segments.insert(.topRight) }
            output.topLeftPattern = input.bottomRightPattern
            output.topRightPattern = input.bottomLeftPattern
            output.bottomRightPattern = input.topLeftPattern
            output.bottomLeftPattern = input.topRightPattern
            if let right = tile(x, y + 1) {
                output.topRightStyle = right.topRightStyle
                output.objectTopRightStyle = right.objectTopRightStyle
                output.topRightDoor = right.topRightDoor
            }
            if let left = tile(x + 1, y) {
                output.topLeftStyle = left.topLeftStyle
                output.objectTopLeftStyle = left.objectTopLeftStyle
                output.topLeftDoor = left.topLeftDoor
            }
        default:
            if segments.contains(.topLeft) { output.segments.insert(.bottomLeft) }
            if segments.contains(.topRight) { output.segments.insert(.topLeft) }
            if segments.contains(.bottomRight) { output.segments.insert(.topRight) }
            if segments.contains(.bottomLeft) { output.segments.insert(.bottomRight) }
            output.topLeftPattern = input.topRightPattern
            output.topRightPattern = input.bottomRightPattern
            output.bottomRightPattern = input.bottomLeftPattern
            output.bottomLeftPattern = input.topLeftPattern
            output.topLeftStyle = input.topRightStyle
            output.topLeftDoor = input.topRightDoor
            output.objectTopLeftStyle = input.objectTopRightStyle
            if let right = tile(x + 1, y) {
                output.topRightStyle = right.topLeftStyle
                output.objectTopRightStyle = right.objectTopLeftStyle
                output.topRightDoor = right.topLeftDoor
            }
        }
        return output
    }

    /// A tile's cuts as they read in a view (`WallComponent.RotateCuts`), for walls on the sides.
    static func rotatedCuts(_ cuts: [WallCuts], x: Int, y: Int, width: Int, height: Int, worldRotation: UInt32) -> WallCuts {
        let input = cuts[y * width + x]
        var output = WallCuts()
        switch worldRotation % 4 {
        case 1:
            output.topRight = input.topLeft
            if y + 1 < height { output.topLeft = cuts[(y + 1) * width + x].topRight.flipped }
        case 2:
            // FreeSO sets the top right from the top left, then overwrites it when there's a next row.
            output.topRight = input.topLeft
            if y + 1 < height { output.topRight = cuts[(y + 1) * width + x].topRight }
            if x + 1 < width { output.topLeft = cuts[y * width + x + 1].topLeft }
            output.topLeft = output.topLeft.flipped
            output.topRight = output.topRight.flipped
        case 3:
            output.topLeft = input.topRight
            if x + 1 < width { output.topRight = cuts[y * width + x + 1].topLeft.flipped }
        default:
            return input
        }
        return output
    }

    // MARK: Cuts

    /// Each tile's cuts on a level whose walls can be cut (`WallComponent.GenerateWallData`), from
    /// which tiles have their walls down. A tile with its walls down cuts its full-height walls
    /// down, or slants them where the cut ends beside it; a wall on the cut's very edge stays up.
    /// FreeSO reads past a row's end into the next row; past the lot's end it would crash, and
    /// here that counts as down.
    static func wallCuts(_ walls: [WallTile], width: Int, height: Int, wallsDownAt down: [Bool]) -> [WallCuts] {
        func isDown(_ x: Int, _ y: Int) -> Bool {
            let index = y * width + x
            return down.indices.contains(index) ? down[index] : true
        }
        var cuts = [WallCuts](repeating: WallCuts(), count: walls.count)
        for (index, wall) in walls.enumerated() where !wall.segments.isEmpty {
            let x = index % width, y = index / width
            guard isDown(x, y) else { continue }
            var edges: CutawayEdges = []
            if !isDown(x + 1, y) { edges.insert(.positiveX) }
            if !isDown(x - 1, y) { edges.insert(.negativeX) }
            if !isDown(x, y + 1) { edges.insert(.positiveY) }
            if !isDown(x, y - 1) { edges.insert(.negativeY) }
            if !isDown(x - 1, y - 1) { edges.formUnion([.specialNegativeX, .specialNegativeY]) }
            if !isDown(x - 1, y + 1) { edges.insert(.specialPositiveY) }
            if !isDown(x + 1, y - 1) { edges.insert(.specialPositiveX) }
            var result = WallCuts()
            if wall.topLeftThick, wall.topLeftStyle != 255 {
                result.topLeft = Self.sideCut(edges, edge: .negativeX, toward: [.positiveY, .specialPositiveY],
                                              away: [.negativeY, .specialNegativeY], towardCut: .downRightUpLeft, awayCut: .downLeftUpRight)
            }
            // FreeSO's note: the top-right style also covers the diagonals.
            if wall.topRightStyle == 1 {
                if wall.segments == .horizontalDiagonal || wall.segments == .verticalDiagonal {
                    let horizontal = wall.segments == .horizontalDiagonal
                    let onLeft = !edges.isDisjoint(with: horizontal ? [.positiveY, .negativeX] : [.positiveY, .positiveX])
                    let onRight = !edges.isDisjoint(with: horizontal ? [.negativeY, .positiveX] : [.negativeY, .negativeX])
                    result.topRight = onLeft && onRight ? .down : onLeft ? .downRightUpLeft : onRight ? .downLeftUpRight : .down
                } else {
                    result.topRight = Self.sideCut(edges, edge: .negativeY, toward: [.positiveX, .specialPositiveX],
                                                   away: [.negativeX, .specialNegativeX], towardCut: .downLeftUpRight, awayCut: .downRightUpLeft)
                }
            }
            cuts[index] = result
        }
        return cuts
    }

    /// One side's cut: up on the cut's edge, down with cuts on both sides or none, else slanted.
    private static func sideCut(_ edges: CutawayEdges, edge: CutawayEdges, toward: CutawayEdges, away: CutawayEdges,
                                towardCut: WallCut, awayCut: WallCut) -> WallCut {
        guard !edges.isEmpty else { return .down }
        if edges.contains(edge) { return .up }
        if !edges.isDisjoint(with: toward) { return edges.isDisjoint(with: away) ? towardCut : .down }
        if !edges.isDisjoint(with: away) { return awayCut }
        return .down
    }

    // MARK: Junctions

    /// The ways walls can meet at a tile's corner (FreeSO's `JunctionFlags`).
    enum Junction {
        static let topLeft: UInt8 = 1, topRight: UInt8 = 2, bottomRight: UInt8 = 4, bottomLeft: UInt8 = 8
        static let diagonalLeft: UInt8 = 16, diagonalTop: UInt8 = 32, diagonalRight: UInt8 = 64, diagonalBottom: UInt8 = 128
    }

    /// Which frame of the junction pieces draws each way walls meet (`WallComponent.JunctionMap`).
    static let junctionFrames: [UInt8: Int] = [
        2: 0, 1: 1, 3: 2, 8: 3, 10: 4, 9: 5, 11: 6, 4: 7, 6: 8, 5: 9, 7: 10, 12: 11, 14: 12, 13: 13, 15: 14,
        32: 15, 40: 16, 36: 17, 44: 18, 16: 19, 18: 20, 20: 21, 22: 22, 48: 23, 52: 24,
        128: 25, 130: 26, 129: 27, 131: 28, 160: 29, 144: 30, 146: 31, 176: 32,
        64: 33, 65: 34, 72: 35, 73: 36, 96: 37, 104: 38, 80: 39, 112: 40, 192: 41, 193: 42, 224: 43, 208: 44, 240: 45,
    ]

    /// A junction turned with the view (`WallComponent.RotateJunction`): the four sides and the
    /// four diagonals each move round by the view's turn.
    static func rotatedJunction(_ flags: UInt8, worldRotation: UInt32) -> UInt8 {
        let turn = Int(worldRotation % 4)
        let lower = (Int(flags) & 15) << turn
        let higher = (Int(flags) & 240) << turn
        return UInt8(truncatingIfNeeded: (lower & 15) | (lower >> 4) | ((higher | higher >> 4) & 240))
    }

    /// Where walls meet on a level, standing and cut down (`WallComponent.GenerateWallData`): each
    /// full-height wall marks its two ends, on its own tile and the next, as standing or cut by its cut.
    static func junctions(_ walls: [WallTile], cuts: [WallCuts], width: Int, height: Int) -> (up: [UInt8], down: [UInt8]) {
        var up = [UInt8](repeating: 0, count: walls.count), down = up
        func mark(_ index: Int, _ flag: UInt8, cut: Bool) {
            guard walls.indices.contains(index) else { return }
            if cut { down[index] |= flag } else { up[index] |= flag }
        }
        for (index, wall) in walls.enumerated() where !wall.segments.isEmpty {
            let result = cuts[index]
            let hasNextX = walls.count > index + 1, hasNextY = walls.count > index + width
            if wall.segments.contains(.topLeft), !(wall.topLeftDoor && result.topLeft != .up), wall.topLeftThick {
                mark(index, Junction.bottomLeft, cut: result.topLeft != .up)
                if hasNextY { mark(index + width, Junction.topRight, cut: result.topLeft != .up) }
            }
            if wall.segments.contains(.topRight), !(wall.topRightDoor && result.topRight != .up), wall.topRightThick {
                mark(index, Junction.bottomRight, cut: result.topRight != .up)
                if hasNextX { mark(index + 1, Junction.topLeft, cut: result.topRight != .up) }
            }
            let diagonalStyle = wall.topRightStyle == 1 || wall.topRightStyle == 255
            if wall.segments == .verticalDiagonal, diagonalStyle {
                mark(index, Junction.diagonalBottom, cut: result.topRight != .up)
                if walls.count > index + 1 + width { mark(index + 1 + width, Junction.diagonalTop, cut: result.topRight != .up) }
            } else if wall.segments == .horizontalDiagonal, diagonalStyle {
                if hasNextX { mark(index + 1, Junction.diagonalLeft, cut: result.topRight != .up) }
                if hasNextY { mark(index + width, Junction.diagonalRight, cut: result.topRight != .up) }
            }
        }
        return (up, down)
    }

    /// The junction pieces' rectangle relative to a tile's top corner (`JUNCDEST_*`).
    static func junctionDestination(_ zoom: SpriteZoom) -> SIMD4<Float> {
        switch zoom {
        case .near: SIMD4(4 - 68, 317 - 316, 128, 64)
        case .medium: SIMD4(2 - 34, 159 - 159, 64, 32)
        case .far: SIMD4(1 - 17, 80 - 80, 32, 16)
        }
    }

    // MARK: Cutaway

    /// The direction the cutaway reaches from a tile, toward the viewer (`VMArchitectureTools.CutCheckDir`).
    static func cutDirection(worldRotation: UInt32) -> SIMD2<Int> {
        switch worldRotation % 4 {
        case 1: SIMD2(-1, 1)
        case 2: SIMD2(1, 1)
        case 3: SIMD2(1, -1)
        default: SIMD2(-1, -1)
        }
    }

    /// Whether a tile and the four beside it are bare of walls, which the cutaway skips
    /// (`VMArchitectureTools`'s test). Kept as FreeSO has it: a neighbor off the lot's end makes a
    /// tile count as walled, so the last row and the end of the last column are always cut, and
    /// the tiles behind are checked with `> 0` rather than `>= 0`.
    private static func isBare(_ walls: [WallTile], _ index: Int, width: Int) -> Bool {
        walls[index].segments.isEmpty
            && index + width < walls.count && walls[index + width].segments.isEmpty
            && index + 1 < walls.count && walls[index + 1].segments.isEmpty
            && index - width > 0 && walls[index - width].segments.isEmpty
            && index - 1 > 0 && walls[index - 1].segments.isEmpty
    }

    /// The tiles whose walls are down in TSO's cutaway mode for some rooms
    /// (`VMArchitectureTools.GenerateRoomCut`): a tile with walls near it is cut when a cut room is
    /// within four tiles of it toward the viewer, straight or along either axis.
    public static func roomCut(of architecture: Architecture, level: Int, worldRotation: UInt32, rooms: Set<UInt16>) -> [Bool] {
        let width = architecture.width, height = architecture.height
        var result = [Bool](repeating: false, count: width * height)
        guard architecture.walls.indices.contains(level - 1), architecture.roomMaps.indices.contains(level - 1) else { return result }
        let walls = architecture.walls[level - 1], map = architecture.roomMaps[level - 1].map
        guard walls.count == result.count, map.count == result.count else { return result }
        let direction = cutDirection(worldRotation: worldRotation)
        for y1 in 0..<height {
            for x1 in 0..<width {
                let index = y1 * width + x1
                guard !isBare(walls, index, width: width) else { continue }
                search: for start in 0..<3 {
                    var x = x1 + (start == 1 ? direction.x : 0)
                    var y = y1 + (start == 2 ? direction.y : 0)
                    for _ in 0..<(start > 0 ? 4 : 5) {
                        if x < 0 || x >= width || y < 0 || y >= height { break }
                        if rooms.contains(UInt16(truncatingIfNeeded: map[y * width + x])) {
                            result[index] = true
                            break search
                        }
                        x += direction.x
                        y += direction.y
                    }
                }
            }
        }
        return result
    }

    /// Cuts the tiles with walls near them in a rectangle (`VMArchitectureTools.ApplyCutRectangle`),
    /// as TSO's cutaway does around the pointer. Returns whether a tile was newly cut.
    @discardableResult
    public static func applyCut(_ cuts: inout [Bool], of architecture: Architecture, level: Int,
                                x left: Int, y top: Int, width rectWidth: Int, height rectHeight: Int) -> Bool {
        let width = architecture.width, height = architecture.height
        guard architecture.walls.indices.contains(level - 1), cuts.count == width * height else { return false }
        let walls = architecture.walls[level - 1]
        guard walls.count == cuts.count else { return false }
        var changed = false
        for x in left..<(left + rectWidth) {
            for y in top..<(top + rectHeight) {
                guard x >= 0, x < width, y >= 0, y < height else { continue }
                let index = y * width + x
                guard !isBare(walls, index, width: width), !cuts[index] else { continue }
                cuts[index] = true
                changed = true
            }
        }
        return changed
    }

    /// The rectangle TSO's cutaway cuts around a pointer over a tile: five tiles a side, moved two
    /// away from the viewer (`UILotControl.UpdateCutaway`).
    public static func pointerCut(at tile: SIMD2<Float>, worldRotation: UInt32) -> (x: Int, y: Int, width: Int, height: Int) {
        let direction = cutDirection(worldRotation: worldRotation)
        // C#'s (int) cast truncates toward zero.
        let x = Int(tile.x - 2.5) - direction.x * 2, y = Int(tile.y - 2.5) - direction.y * 2
        return (x, y, 5, 5)
    }

    // MARK: Doors and windows

    /// A door's or window's own wall style: the object, and the first of its six sprites.
    public struct ObjectWallStyle: Sendable, Equatable {
        public var guid: UInt32
        public var sprite: UInt16
    }

    /// The VM's architecture as the client draws it, with each door's and window's own wall style
    /// in place, as FreeSO's `VMGameObject.PositionChange` makes it: an object whose definition's
    /// style is 22 to 255 keeps that style in its own sprites (from `WallStyleSpriteID`), so each
    /// kind of object gets a style from 256 up, numbered in VM order, put on the walls it styles.
    /// The VM itself keeps the definition's number (the scorecard's DIFF-20).
    public static func drawnArchitecture(of vm: VM) -> (architecture: Architecture, objectStyles: [UInt16: ObjectWallStyle]) {
        var architecture = vm.architecture
        var styles: [UInt16: ObjectWallStyle] = [:]
        var styleByGUID: [UInt32: UInt16] = [:]
        for entity in vm.entities where !entity.isDead && entity.container == nil && entity.position != .outOfWorld {
            let definition = entity.object.definition
            let own = definition.wallStyle
            guard own > 21, own < 256 else { continue }
            let sides = entity.architecturalWallSides.filter { $0 == 0 || $0 == 3 }
            guard !sides.isEmpty else { continue }
            let guid = entity.object.guid
            let id: UInt16
            if let known = styleByGUID[guid] {
                id = known
            } else {
                id = 256 &+ UInt16(truncatingIfNeeded: styleByGUID.count)
                styleByGUID[guid] = id
                styles[id] = ObjectWallStyle(guid: guid, sprite: definition.wallStyleSpriteID)
            }
            let x = Int(entity.position.tileX), y = Int(entity.position.tileY), level = Int(entity.position.level)
            guard var wall = try? architecture.wall(atX: x, y: y, level: level) else { continue }
            for side in sides {
                if side == 0, wall.objectTopRightStyle == own { wall.objectTopRightStyle = id }
                if side == 3, wall.objectTopLeftStyle == own { wall.objectTopLeftStyle = id }
            }
            try? architecture.setWall(wall, atX: x, y: y, level: level)
        }
        return (architecture, styles)
    }

    // MARK: Sprites

    /// A world offset turned with the view (`WallComponent.RotateOffset`).
    static func rotatedOffset(_ offset: SIMD2<Int>, worldRotation: UInt32) -> SIMD2<Int> {
        switch worldRotation % 4 {
        case 1: SIMD2(offset.y, -offset.x)
        case 2: SIMD2(-offset.x, -offset.y)
        case 3: SIMD2(-offset.y, offset.x)
        default: offset
        }
    }

    /// The wall sprites of the levels up to `level`, as `WallComponent.Draw` lays them out: each
    /// side and diagonal, the floors of diagonal tiles, the caps that round off a full-height wall
    /// where it stops, and the junction pieces where walls meet. On `level` itself, walls are cut
    /// as `wallsDown` says (one entry a tile, `true` where its walls are down); below it, and with
    /// `nil`, they stand. `objectStyles` are the doors' and windows' own styles
    /// (``drawnArchitecture(of:)``).
    ///
    /// Unlike FreeSO, a wall's caps and a diagonal tile's floors are laid out whether or not the
    /// wall's pattern has a sprite; the drawing leaves out what it can't find.
    public static func wallSprites(of architecture: Architecture, level viewLevel: Int, zoom: SpriteZoom,
                                   worldRotation: UInt32, wallsDown: [Bool]?,
                                   objectStyles: [UInt16: ObjectWallStyle] = [:]) -> [WallSprite] {
        let width = architecture.width, height = architecture.height
        let destinations = wallDestinations(zoom)
        let capWidth: Float = switch zoom {
        case .near: 12
        case .medium: 6
        case .far: 3
        }
        func mask(_ style: UInt16, down: Bool, frame: Int) -> WallImage {
            if let object = objectStyles[style] {
                return .objectMask(guid: object.guid, sprite: object.sprite, down: down, zoom: zoom, frame: frame)
            }
            return .mask(style: style, down: down, zoom: zoom, frame: frame)
        }
        var sprites: [WallSprite] = []
        for levelIndex in 0..<min(viewLevel, architecture.walls.count) {
            let walls = architecture.walls[levelIndex]
            guard walls.count == width * height else { continue }
            let level = levelIndex + 1
            let base = Float(levelIndex) * levelHeight
            let canCut = level == viewLevel
            let down: [Bool] = if canCut, let wallsDown, wallsDown.count == walls.count { wallsDown } else { [] }
            let cuts: [WallCuts] = down.isEmpty
                ? [WallCuts](repeating: WallCuts(), count: walls.count)
                : wallCuts(walls, width: width, height: height, wallsDownAt: down)
            let joins = junctions(walls, cuts: cuts, width: width, height: height)
            func downAt(_ x: Int, _ y: Int) -> Bool {
                let index = y * width + x
                return down.indices.contains(index) && down[index]
            }
            func isTile(_ tile: SIMD2<Int>) -> Bool { tile.x >= 0 && tile.y >= 0 && tile.x < width && tile.y < height }
            func turned(_ tile: SIMD2<Int>) -> WallTile {
                rotatedWall(walls, x: tile.x, y: tile.y, width: width, height: height, worldRotation: worldRotation)
            }
            /// Whether the world tile behind and left of (x, y) holds a vertical diagonal, which
            /// shortens a cap by a third.
            func diagonalBehind(_ x: Int, _ y: Int) -> Bool {
                guard x > 0, y > 0 else { return false }
                return walls[(y - 1) * width + x - 1].segments.contains(.verticalDiagonal)
            }
            func place(_ tile: SIMD2<Int>) -> (anchor: SIMD3<Float>, back: SIMD3<Float>, front: SIMD3<Float>) {
                let corner = topCorner(x: tile.x, y: tile.y, worldRotation: worldRotation)
                let (back, front) = depthLine(corner: SIMD3(Float(tile.x), base, Float(tile.y)), worldRotation: worldRotation)
                return (SIMD3(corner.x, base, corner.y), back, front)
            }

            for y in 0..<height {
                for x in 0..<width {
                    let tile = SIMD2(x, y)
                    if !walls[y * width + x].segments.isEmpty {
                        let wall = turned(tile)
                        var tileCuts = cuts[y * width + x]
                        if wall.segments.rawValue < 16 {
                            tileCuts = rotatedCuts(cuts, x: x, y: y, width: width, height: height, worldRotation: worldRotation)
                        } else if worldRotation % 4 > 1 {
                            // Diagonals just swap their slants on the two farthest turns.
                            tileCuts = WallCuts(topLeft: tileCuts.topLeft.flipped, topRight: tileCuts.topRight.flipped)
                        }
                        let here = place(tile)

                        func add(side: Int, pattern: UInt16, styleID: UInt16, overlay: UInt16, isDown: Bool) {
                            sprites.append(WallSprite(level: level, image: .pattern(id: pattern, zoom: zoom, frame: side),
                                                      mask: mask(styleID, down: isDown, frame: side), anchor: here.anchor,
                                                      destination: destinations[side], depthBuffer: wallDepthIndex(side: side, zoom: zoom),
                                                      back: here.back, front: here.front))
                            if overlay != 0 {
                                sprites.append(WallSprite(level: level, image: .pattern(id: overlay, zoom: zoom, frame: side), mask: nil,
                                                          anchor: here.anchor, destination: destinations[side],
                                                          depthBuffer: wallDepthIndex(side: side, zoom: zoom), back: here.back, front: here.front))
                            }
                        }
                        /// Part of a side, at another tile: a cap rounding off a wall's end. The cap takes
                        /// `capWidth` pixels from the side's left or right edge.
                        func cap(side: Int, pattern: UInt16, mask capMask: WallImage, at other: SIMD2<Int>, fromRight: Bool, shorter: Bool) {
                            let whole = destinations[side]
                            let pixels = shorter ? (capWidth * 2 / 3).rounded(.towardZero) : capWidth
                            let fraction = pixels / whole.z
                            let there = place(other)
                            sprites.append(WallSprite(
                                level: level, image: .pattern(id: pattern, zoom: zoom, frame: side), mask: capMask, anchor: there.anchor,
                                destination: SIMD4(fromRight ? whole.x + whole.z - pixels : whole.x, whole.y, pixels, whole.w),
                                source: SIMD4(fromRight ? 1 - fraction : 0, 0, fraction, 1),
                                depthBuffer: wallDepthIndex(side: side, zoom: zoom), back: there.back, front: there.front))
                        }
                        /// The style a side is drawn with for a cut, and its cutaway overlay.
                        func style(_ cut: WallCut, style: UInt16, objectStyle: UInt16) -> (UInt16, UInt16, Bool) {
                            switch cut {
                            case .down: (style, 0, true)
                            case .downLeftUpRight: (7, 252, false)
                            case .downRightUpLeft: (8, 253, false)
                            case .up: (style != 1 ? style : objectStyle != 0 ? objectStyle : 1, 0, false)
                            }
                        }

                        if wall.segments.contains(.topLeft), !(tileCuts.topLeft != .up && wall.topLeftDoor) {
                            let (styleID, overlay, isDown) = style(tileCuts.topLeft, style: wall.topLeftStyle, objectStyle: wall.objectTopLeftStyle)
                            add(side: 0, pattern: wall.topLeftPattern, styleID: styleID, overlay: overlay, isDown: isDown)
                            if wall.topLeftThick {
                                // The far end: round it off if the wall doesn't go on.
                                let far = tile &+ rotatedOffset(SIMD2(0, -1), worldRotation: worldRotation)
                                if !wall.topRightThick, isTile(far), !turned(far).topLeftThick {
                                    cap(side: 0, pattern: wall.topLeftPattern,
                                        mask: mask(wall.topLeftStyle, down: canCut && downAt(far.x, far.y), frame: 0),
                                        at: far, fromRight: false, shorter: diagonalBehind(x, y))
                                }
                                // The near end, drawn on the tile diagonally in front.
                                let near = tile &+ rotatedOffset(SIMD2(0, 1), worldRotation: worldRotation)
                                let front = tile &+ rotatedOffset(SIMD2(-1, 1), worldRotation: worldRotation)
                                if isTile(near), isTile(front), !turned(near).topLeftThick, !turned(near).topRightThick,
                                   !turned(front).topRightThick {
                                    let capDown = canCut && downAt(x, y) && styleID != 8
                                    cap(side: 1, pattern: wall.topLeftPattern, mask: mask(wall.topLeftStyle, down: capDown, frame: 1),
                                        at: front, fromRight: true, shorter: false)
                                }
                            }
                        }
                        if wall.segments.contains(.topRight), !(tileCuts.topRight != .up && wall.topRightDoor) {
                            let (styleID, overlay, isDown) = style(tileCuts.topRight, style: wall.topRightStyle, objectStyle: wall.objectTopRightStyle)
                            add(side: 1, pattern: wall.topRightPattern, styleID: styleID, overlay: overlay, isDown: isDown)
                            if wall.topRightThick {
                                let far = tile &+ rotatedOffset(SIMD2(-1, 0), worldRotation: worldRotation)
                                if !wall.topLeftThick, isTile(far), !turned(far).topRightThick {
                                    cap(side: 1, pattern: wall.topRightPattern,
                                        mask: mask(wall.topRightStyle, down: canCut && downAt(far.x, far.y), frame: 1),
                                        at: far, fromRight: true, shorter: diagonalBehind(x, y))
                                }
                                let near = tile &+ rotatedOffset(SIMD2(1, 0), worldRotation: worldRotation)
                                let front = tile &+ rotatedOffset(SIMD2(1, -1), worldRotation: worldRotation)
                                if isTile(near), isTile(front), !turned(near).topLeftThick, !turned(near).topRightThick,
                                   !turned(front).topLeftThick {
                                    let capDown = canCut && downAt(x, y) && styleID != 8
                                    cap(side: 0, pattern: wall.topRightPattern, mask: mask(wall.topRightStyle, down: capDown, frame: 0),
                                        at: front, fromRight: false, shorter: false)
                                }
                            }
                        }
                        for (segment, side) in [(WallSegments.horizontalDiagonal, 2), (.verticalDiagonal, 3)] where wall.segments == segment {
                            let (styleID, overlay, isDown) = style(tileCuts.topRight, style: wall.topRightStyle, objectStyle: wall.objectTopRightStyle)
                            add(side: side, pattern: wall.bottomRightPattern, styleID: styleID, overlay: overlay, isDown: isDown)
                            // The floors of the diagonal's two halves: bottom and top, or right and left.
                            let halves: [(UInt16, SIMD4<Float>)] = side == 2
                                ? [(wall.topLeftPattern, SIMD4(0, 0.5, 1, 0.5)), (wall.topLeftStyle, SIMD4(0, 0, 1, 0.5))]
                                : [(wall.topLeftPattern, SIMD4(0.5, 0, 0.5, 1)), (wall.topLeftStyle, SIMD4(0, 0, 0.5, 1))]
                            for (floor, part) in halves where floor != 0 {
                                let whole = halfFloorDestination(zoom)
                                let destination = SIMD4(whole.x + part.x * whole.z, whole.y + part.y * whole.w, whole.z * part.z, whole.w * part.w)
                                sprites.append(WallSprite(level: level, image: .floor(id: floor, zoom: zoom), mask: nil, anchor: here.anchor,
                                                          destination: destination, source: part, depthBuffer: floorDepthIndex(zoom),
                                                          back: here.back, front: here.front))
                            }
                        }
                    }

                    // Junctions, on every tile: standing ones at the walls' tops, cut ones near the floor.
                    let index = y * width + x
                    let standing = joins.up[index] != 0
                    let flags = standing ? joins.up[index] : joins.down[index]
                    guard flags != 0, junctionFrames[flags] != nil,
                          let frame = junctionFrames[rotatedJunction(flags, worldRotation: worldRotation)] else { continue }
                    let junctionHeight = standing ? Float(level) * levelHeight : 0.3 + base
                    let corner = topCorner(x: x, y: y, worldRotation: worldRotation)
                    let shift = corner - SIMD2(Float(x), Float(y))
                    let (back, front) = depthLine(corner: SIMD3(Float(x) - 0.5, junctionHeight, Float(y) - 0.5), worldRotation: worldRotation)
                    sprites.append(WallSprite(level: level, image: .junction(zoom: zoom, frame: frame), mask: nil,
                                              anchor: SIMD3(Float(x) - 0.5 + shift.x, junctionHeight, Float(y) - 0.5 + shift.y),
                                              destination: junctionDestination(zoom), depthBuffer: 18 + Int(3 - zoom.rawValue),
                                              back: back, front: front))
                }
            }
        }
        return sprites
    }
}

/// The decoded images of walls, made from an install's ``WallProvider`` (and, for the floors on
/// diagonal tiles, ``FloorImages``) the first time each is asked for, and kept.
public final class WallImages {
    public let walls: WallProvider
    public let floors: FloorImages?
    /// The objects, for the masks of doors' and windows' own wall styles.
    public let objects: ObjectProvider?
    private var images: [WallImage: SpriteImage] = [:]
    private var missing: Set<WallImage> = []
    /// Images that failed to decode, each with why, for the system messages.
    public private(set) var failures: [String] = []

    public init(walls: WallProvider, floors: FloorImages?, objects: ObjectProvider? = nil) {
        self.walls = walls
        self.floors = floors
        self.objects = objects
    }

    /// An image, or `nil` if the install has none.
    ///
    /// A mask falls back to `nil` too, and then the pattern is drawn with its own alpha, as
    /// FreeSO's `GetWallSprite` does when a style or its sprite is missing.
    public func image(for image: WallImage) -> SpriteImage? {
        if let found = images[image] { return found }
        guard !missing.contains(image) else { return nil }
        do {
            let decoded = try decode(image)
            if let decoded { images[image] = decoded } else { missing.insert(image) }
            return decoded
        } catch {
            missing.insert(image)
            failures.append("wall image \(image): \(error)")
            return nil
        }
    }

    private func decode(_ image: WallImage) throws -> SpriteImage? {
        func pick(_ sprites: (far: SPR?, medium: SPR?, near: SPR?), _ zoom: SpriteZoom) -> SPR? {
            switch zoom {
            case .far: sprites.far
            case .medium: sprites.medium
            case .near: sprites.near
            }
        }
        func frame(_ sprite: SPR?, _ index: Int, in file: IFFFile) throws -> SpriteImage? {
            guard let sprite, sprite.frames.indices.contains(index) else { return nil }
            return try sprite.decode(frameAt: index, palette: try file.chunk(PALT.self, id: sprite.paletteID))
        }
        switch image {
        case .pattern(let id, let zoom, let index):
            guard let pattern = try walls.pattern(id: id) else { return nil }
            return try frame(pick((pattern.far, pattern.medium, pattern.near), zoom), index, in: pattern.file)
        case .mask(let styleID, let down, let zoom, let index):
            guard let style = try walls.style(id: styleID) else { return nil }
            return try frame(pick(down ? style.wallsDown : style.wallsUp, zoom), index, in: walls.globals)
        case .floor(let id, let zoom):
            return floors?.image(for: .pattern(id), zoom: zoom)
        case .junction(let zoom, let index):
            let junctions = try walls.junctions()
            return try frame(pick((junctions.far, junctions.medium, junctions.near), zoom), index, in: walls.globals)
        case .objectMask(let guid, let base, let down, let zoom, let index):
            // FreeSO's dynamic style: standing far, medium, near, then cut down, from `base` up.
            guard let resource = try objects?.object(guid: guid)?.resource else { return nil }
            let offset: UInt16 = (down ? 3 : 0) + (zoom == .far ? 0 : zoom == .medium ? 1 : 2)
            let id = base &+ offset
            for file in [resource.mainFile] + (resource.sprites.map { [$0] } ?? []) {
                if let sprite = try file.chunk(SPR.self, id: id) { return try frame(sprite, index, in: file) }
            }
            return nil
        }
    }
}
