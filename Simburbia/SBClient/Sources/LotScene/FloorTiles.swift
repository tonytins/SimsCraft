import SimAntics
import TSOContent
import TSOFiles

/// What a floor tile is drawn with: a floor pattern, or one of the global pool and water tiles,
/// each in one of 16 shapes (which of its four sides join another tile of the same kind).
///
/// Ports update-46's tile IDs from `_3DFloorGeometry.PatternConvert`: 65520 to 65535 are pool
/// shapes, 65504 to 65519 water shapes, and 65503 the build-mode air tile.
public enum FloorTexture: Hashable, Sendable, Comparable {
    case pattern(UInt16)
    case water(shape: UInt16)
    case pool(shape: UInt16)

    /// The texture of a converted tile ID, or `nil` for one drawn without a texture: grass (0) and
    /// the air tile (65503), which the client doesn't draw yet. A raw blueprint pattern in the
    /// water or pool range is drawn as that shape, as in FreeSO.
    public init?(convertedID id: UInt16) {
        switch id {
        case 0, LotScene.airTileID: return nil
        case 65504...65519: self = .water(shape: id - 65504)
        case 65520...65535: self = .pool(shape: id - 65520)
        default: self = .pattern(id)
        }
    }

    /// Pools and water keep their texture upright on screen as the view turns
    /// (`_3DFloorGeometry.CounterTexMat`); floor patterns turn with the lot.
    public var turnsAgainstTheView: Bool {
        if case .pattern = self { return false }
        return true
    }

    /// FreeSO draws a water tile with a plain tile under it, and itself a little above
    /// (0.05 world units, a sixtieth of a tile).
    public var isRaised: Bool {
        if case .water = self { return true }
        return false
    }
}

/// One tile of one level, drawn with a ``FloorTexture``.
public struct FloorTile: Sendable, Equatable {
    /// The level, 1 for the ground floor.
    public var level: Int
    public var x: Int
    public var y: Int

    public init(level: Int, x: Int, y: Int) {
        self.level = level
        self.x = x
        self.y = y
    }
}

extension LotScene {
    /// The build-mode air tile's ID.
    static let airTileID: UInt16 = 65503

    /// FreeSO's `_3DFloorGeometry.PatternConvert` outside build mode: a pattern below 65534 is
    /// itself; pool (65535) and water (65534) become a shape from the four tiles beside it:
    /// bit 1 the tile at y − 1, 2 at x − 1, 4 at y + 1, and 8 at x + 1, each set when that tile
    /// holds the same pattern or is on (or past) the lot's edge.
    static func convertedID(of pattern: UInt16, x: Int, y: Int, level floors: [UInt16], width: Int, height: Int) -> UInt16 {
        guard pattern >= 65534 else { return pattern }
        func joins(_ dx: Int, _ dy: Int) -> Bool {
            let tx = x + dx, ty = y + dy
            if tx <= 0 || tx >= width - 1 || ty <= 0 || ty >= height - 1 { return true }
            return floors[ty * width + tx] == pattern
        }
        var shape: UInt16 = 0
        if joins(0, -1) { shape |= 1 }
        if joins(-1, 0) { shape |= 2 }
        if joins(0, 1) { shape |= 4 }
        if joins(1, 0) { shape |= 8 }
        return pattern == 65535 ? shape + 65520 : shape + 65504
    }

    /// Every textured floor tile, grouped by texture in texture order, as update-46's
    /// `_3DFloorGeometry.FullReset` groups them: tiles on the lot's edge aren't drawn, nor is an
    /// empty tile (grass on the ground floor, which the ground stands in for).
    public static func floorTiles(of architecture: Architecture) -> [(texture: FloorTexture, tiles: [FloorTile])] {
        let width = architecture.width, height = architecture.height
        var groups: [FloorTexture: [FloorTile]] = [:]
        for (levelIndex, floors) in architecture.floors.enumerated() where floors.count == width * height {
            guard height > 2, width > 2 else { break }
            for y in 1..<(height - 1) {
                for x in 1..<(width - 1) {
                    let id = convertedID(of: floors[y * width + x], x: x, y: y, level: floors, width: width, height: height)
                    guard let texture = FloorTexture(convertedID: id) else { continue }
                    groups[texture, default: []].append(FloorTile(level: levelIndex + 1, x: x, y: y))
                }
            }
        }
        return groups.keys.sorted().map { ($0, groups[$0] ?? []) }
    }

    /// The shape a pool or water tile draws with in a view: its sides turned with the world
    /// (`_3DFloorGeometry.DrawFloor`), since the sprite is drawn upright on screen.
    public static func shape(_ shape: UInt16, worldRotation: UInt32) -> UInt16 {
        let turn = UInt16((4 - worldRotation % 4) % 4)
        guard turn > 0 else { return shape & 15 }
        return ((shape << turn) & 15) | ((shape & 15) >> (4 - turn))
    }

    /// The texture coordinates of a point on the lot (in tiles) for a texture, as update-46's
    /// terrain vertices and `GrassShader` work them out: a tile's diamond spans one copy of the
    /// texture, which repeats, at `u = (x − y + 1) / 2` and `v = (x + y) / 2`; then the view's
    /// `TexMatrix` (or, for pools and water, `CounterTexMat`), and a half-pixel nudge down.
    public static func textureCoordinates(x: Float, y: Float, texture: FloorTexture, worldRotation: UInt32,
                                          zoom: SpriteZoom) -> SIMD2<Float> {
        let u = (x - y + 1) / 2, v = (x + y) / 2
        // (m.x, m.y, m.z, m.w): u' = u·m.x + v·m.z, v' = v·m.w + u·m.y.
        let m: SIMD4<Float> = switch (worldRotation % 4, texture.turnsAgainstTheView) {
        case (0, _), (2, false): SIMD4(1, 0, 0, 1)
        case (1, false), (3, false): SIMD4(0, 1, 1, 0)
        case (1, true): SIMD4(0, 1, -1, 0)
        case (2, true): SIMD4(-1, 0, 0, -1)
        default: SIMD4(0, -1, 1, 0)
        }
        let nudge: Float = switch zoom {
        case .near: 0.5 / 64
        case .medium: 0.5 / 32
        case .far: 0.5 / 16
        }
        return SIMD2(u * m.x + v * m.z, v * m.w + u * m.y + nudge)
    }
}

extension FloorTexture {
    /// Sorts patterns, then water, then pools, each by number.
    public static func < (lhs: FloorTexture, rhs: FloorTexture) -> Bool {
        func key(_ texture: FloorTexture) -> (Int, UInt16) {
            switch texture {
            case .pattern(let id): (0, id)
            case .water(let shape): (1, shape)
            case .pool(let shape): (2, shape)
            }
        }
        return key(lhs) < key(rhs)
    }
}

/// The decoded textures of floors, made from an install's ``FloorProvider`` the first time each
/// is asked for, and kept.
///
/// A floor pattern takes its sprite for the zoom; pools take the global sprites 0x400 (far),
/// 0x410 (medium), and 0x420 (near) plus the shape; water takes 0x800 plus the shape, with its
/// frames near, medium, far; as update-46's `_3DFloorGeometry.DrawFloor` picks them. Each is
/// decoded as ``FloorProvider/texture(of:frameAt:in:depthAsAlpha:)`` decodes it.
public final class FloorImages {
    public let floors: FloorProvider
    private var images: [Key: SpriteImage] = [:]
    private var missing: Set<Key> = []
    /// Textures that failed to decode, each with why, for the system messages.
    public private(set) var failures: [String] = []

    struct Key: Hashable {
        var texture: FloorTexture
        var zoom: SpriteZoom
    }

    public init(floors: FloorProvider) {
        self.floors = floors
    }

    /// A texture's image at a zoom, or `nil` if the install has none (FreeSO skips those tiles).
    public func image(for texture: FloorTexture, zoom: SpriteZoom) -> SpriteImage? {
        let key = Key(texture: texture, zoom: zoom)
        if let image = images[key] { return image }
        guard !missing.contains(key) else { return nil }
        do {
            let image = try decode(texture, zoom: zoom)
            if let image { images[key] = image } else { missing.insert(key) }
            return image
        } catch {
            missing.insert(key)
            failures.append("floor \(texture) at \(zoom): \(error)")
            return nil
        }
    }

    private func decode(_ texture: FloorTexture, zoom: SpriteZoom) throws -> SpriteImage? {
        switch texture {
        case .pattern(let id):
            guard let floor = try floors.floor(id: id) else { return nil }
            let sprite: SPR2? = switch zoom {
            case .far: floor.far
            case .medium: floor.medium
            case .near: floor.near
            }
            guard let sprite, !sprite.frames.isEmpty else { return nil }
            return try FloorProvider.texture(of: sprite, frameAt: 0, in: floor.file)
        case .pool(let shape):
            let base: UInt16 = switch zoom {
            case .far: 0x400
            case .medium: 0x410
            case .near: 0x420
            }
            guard let sprite = try floors.globalSprite(id: base + shape), !sprite.frames.isEmpty else { return nil }
            return try FloorProvider.texture(of: sprite, frameAt: 0, in: floors.globals)
        case .water(let shape):
            let id = 0x800 + shape
            let frame = switch zoom {
            case .far: 2
            case .medium: 1
            case .near: 0
            }
            guard let sprite = try floors.globalSprite(id: id), sprite.frames.indices.contains(frame) else { return nil }
            return try FloorProvider.texture(of: sprite, frameAt: frame, in: floors.globals,
                                             depthAsAlpha: FloorProvider.globalSpriteTakesDepthAsAlpha(id))
        }
    }
}
