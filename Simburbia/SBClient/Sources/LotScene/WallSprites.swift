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
    /// medium, far; top left, top right, horizontal and vertical diagonal), 12 to 17 floors.
    public static func wallDepthBuffer(_ index: Int) -> (width: Int, height: Int, depth: [UInt8])? {
        let flat: Float = 1.525
        let configs: [[Float]] = [
            [64, 271, 74, 1, 0.5], [64, 271, 135, -1, 0.5], [128, 240, 89.5, 0, 0.5], [16, 232, 45, 0, 0.5],
            [32, 135, 74, 2, 1], [32, 135, 135, -2, 1], [64, 120, 89.5, 0, 1], [8, 116, 45, 0, 1],
            [16, 67, 74, 4, 2], [16, 67, 135, -4, 2], [32, 60, 89.5, 0, 2], [4, 58, 45, 0, 2],
            [128, 64, 255, 0, -flat], [64, 32, 255, 0, -flat * 2], [32, 16, 255, 0, -flat * 4],
            [128, 64, 153, 0, flat], [64, 32, 153, 0, flat * 2], [32, 16, 153, 0, flat * 4],
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

    // MARK: Sprites

    /// The wall sprites of the levels up to `level`, as `WallComponent.Draw` lays them out, without
    /// end caps and junctions yet. On `level` itself, walls are cut as `wallsDown` says (one entry a
    /// tile, `true` where its walls are down); below it, and with `nil`, they stand.
    public static func wallSprites(of architecture: Architecture, level viewLevel: Int, zoom: SpriteZoom,
                                   worldRotation: UInt32, wallsDown: [Bool]?) -> [WallSprite] {
        let width = architecture.width, height = architecture.height
        let destinations = wallDestinations(zoom)
        var sprites: [WallSprite] = []
        for levelIndex in 0..<min(viewLevel, architecture.walls.count) {
            let walls = architecture.walls[levelIndex]
            guard walls.count == width * height else { continue }
            let level = levelIndex + 1
            let base = Float(levelIndex) * levelHeight
            let cuts: [WallCuts] = if level == viewLevel, let wallsDown, wallsDown.count == walls.count {
                wallCuts(walls, width: width, height: height, wallsDownAt: wallsDown)
            } else {
                [WallCuts](repeating: WallCuts(), count: walls.count)
            }
            for y in 0..<height {
                for x in 0..<width where !walls[y * width + x].segments.isEmpty {
                    let wall = rotatedWall(walls, x: x, y: y, width: width, height: height, worldRotation: worldRotation)
                    var tileCuts = cuts[y * width + x]
                    if wall.segments.rawValue < 16 {
                        tileCuts = rotatedCuts(cuts, x: x, y: y, width: width, height: height, worldRotation: worldRotation)
                    } else if worldRotation % 4 > 1 {
                        // Diagonals just swap their slants on the two farthest turns.
                        tileCuts = WallCuts(topLeft: tileCuts.topLeft.flipped, topRight: tileCuts.topRight.flipped)
                    }
                    let corner = topCorner(x: x, y: y, worldRotation: worldRotation)
                    let anchor = SIMD3(corner.x, base, corner.y)
                    let (back, front) = depthLine(corner: SIMD3(Float(x), base, Float(y)), worldRotation: worldRotation)

                    func add(side: Int, pattern: UInt16, styleID: UInt16, overlay: UInt16, down: Bool) {
                        sprites.append(WallSprite(level: level, image: .pattern(id: pattern, zoom: zoom, frame: side),
                                                  mask: .mask(style: styleID, down: down, zoom: zoom, frame: side), anchor: anchor,
                                                  destination: destinations[side], depthBuffer: wallDepthIndex(side: side, zoom: zoom),
                                                  back: back, front: front))
                        if overlay != 0 {
                            sprites.append(WallSprite(level: level, image: .pattern(id: overlay, zoom: zoom, frame: side), mask: nil,
                                                      anchor: anchor, destination: destinations[side],
                                                      depthBuffer: wallDepthIndex(side: side, zoom: zoom), back: back, front: front))
                        }
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
                        let (styleID, overlay, down) = style(tileCuts.topLeft, style: wall.topLeftStyle, objectStyle: wall.objectTopLeftStyle)
                        add(side: 0, pattern: wall.topLeftPattern, styleID: styleID, overlay: overlay, down: down)
                    }
                    if wall.segments.contains(.topRight), !(tileCuts.topRight != .up && wall.topRightDoor) {
                        let (styleID, overlay, down) = style(tileCuts.topRight, style: wall.topRightStyle, objectStyle: wall.objectTopRightStyle)
                        add(side: 1, pattern: wall.topRightPattern, styleID: styleID, overlay: overlay, down: down)
                    }
                    for (segment, side) in [(WallSegments.horizontalDiagonal, 2), (.verticalDiagonal, 3)] where wall.segments == segment {
                        let (styleID, overlay, down) = style(tileCuts.topRight, style: wall.topRightStyle, objectStyle: wall.objectTopRightStyle)
                        add(side: side, pattern: wall.bottomRightPattern, styleID: styleID, overlay: overlay, down: down)
                        // The floors of the diagonal's two halves: bottom and top, or right and left.
                        let halves: [(UInt16, SIMD4<Float>)] = side == 2
                            ? [(wall.topLeftPattern, SIMD4(0, 0.5, 1, 0.5)), (wall.topLeftStyle, SIMD4(0, 0, 1, 0.5))]
                            : [(wall.topLeftPattern, SIMD4(0.5, 0, 0.5, 1)), (wall.topLeftStyle, SIMD4(0, 0, 0.5, 1))]
                        for (floor, part) in halves where floor != 0 {
                            let whole = halfFloorDestination(zoom)
                            let destination = SIMD4(whole.x + part.x * whole.z, whole.y + part.y * whole.w, whole.z * part.z, whole.w * part.w)
                            sprites.append(WallSprite(level: level, image: .floor(id: floor, zoom: zoom), mask: nil, anchor: anchor,
                                                      destination: destination, source: part, depthBuffer: floorDepthIndex(zoom),
                                                      back: back, front: front))
                        }
                    }
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
    private var images: [WallImage: SpriteImage] = [:]
    private var missing: Set<WallImage> = []
    /// Images that failed to decode, each with why, for the system messages.
    public private(set) var failures: [String] = []

    public init(walls: WallProvider, floors: FloorImages?) {
        self.walls = walls
        self.floors = floors
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
        }
    }
}
