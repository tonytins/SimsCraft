import SimAntics

/// A lot as boxes, in world units: one unit is a tile, x runs along the lot's x, z along its y,
/// and y is up. Until the game's sprites and Sims are decoded, these stand in for them.
///
/// The architecture (ground, floors, walls) is rebuilt with ``rebuildArchitecture(of:)`` when
/// walls, floors, or rooms change; objects are rebuilt every frame, into the same storage.
public struct LotScene: Sendable {
    /// How tall a floor is, in tiles. FreeSO's walls stand about three tiles high.
    public static let levelHeight: Float = 2.95
    /// How tall a fence is.
    public static let fenceHeight: Float = 0.8
    /// How thick a wall is.
    public static let wallThickness: Float = 0.12
    /// How tall an object's box is, standing in for its sprite.
    public static let objectHeight: Float = 0.9

    /// One box to draw.
    public struct Box: Sendable, Equatable {
        public enum Kind: Sendable, Equatable {
            case ground
            /// A floor tile, with the room it's in.
            case floor(room: UInt16, isOutside: Bool)
            case water
            case wall
            case fence
            /// An object, by its ID in the VM.
            case object(Int16)
        }

        public var kind: Kind
        /// The level, 1 for the ground floor.
        public var level: Int
        public var center: SIMD3<Float>
        public var size: SIMD3<Float>
        /// A turn about the vertical axis in degrees, for diagonal walls.
        public var yaw: Float = 0
    }

    public private(set) var lotWidth = 0
    public private(set) var lotHeight = 0
    /// Ground, floors, and walls.
    public private(set) var architecture: [Box] = []
    /// Objects on the lot.
    public private(set) var objects: [Box] = []

    public init() {}

    /// The middle of the lot at ground level.
    public var center: SIMD3<Float> { SIMD3(Float(lotWidth) / 2, 0, Float(lotHeight) / 2) }

    /// Rebuilds the ground, floors, and walls from the VM's architecture.
    public mutating func rebuildArchitecture(of vm: VM) {
        let architecture = vm.architecture
        lotWidth = architecture.width
        lotHeight = architecture.height
        self.architecture.removeAll(keepingCapacity: true)
        // The ground's top is a hair under the floors', so the two don't fight where they meet.
        self.architecture.append(Box(kind: .ground, level: 1, center: SIMD3(Float(lotWidth) / 2, -0.06, Float(lotHeight) / 2),
                                     size: SIMD3(Float(lotWidth), 0.1, Float(lotHeight))))

        for level in 0..<min(Architecture.stories, architecture.floors.count) {
            let base = Float(level) * Self.levelHeight
            let floors = architecture.floors[level]
            let roomMap = architecture.roomMaps.indices.contains(level) ? architecture.roomMaps[level].map : []
            for index in floors.indices {
                let pattern = floors[index]
                guard pattern != 0 else { continue }
                let tileX = index % lotWidth, tileY = index / lotWidth
                // A floor's top is the floor line, where objects stand, as in FreeSO.
                let center = SIMD3(Float(tileX) + 0.5, base - 0.02, Float(tileY) + 0.5)
                if pattern >= Architecture.poolPattern - 1 {
                    append(.water, level + 1, center - SIMD3(0, 0.1, 0), SIMD3(1, 0.04, 1))
                } else {
                    let room = roomMap.indices.contains(index) ? UInt16(truncatingIfNeeded: roomMap[index]) : 0
                    let isOutside = architecture.rooms.indices.contains(Int(room)) ? architecture.rooms[Int(room)].isOutside : true
                    append(.floor(room: room, isOutside: isOutside), level + 1, center, SIMD3(1, 0.04, 1))
                }
            }
            guard architecture.walls.indices.contains(level) else { continue }
            for (index, wall) in architecture.walls[level].enumerated() where !wall.segments.isEmpty {
                appendWalls(wall, tileX: index % lotWidth, tileY: index / lotWidth, level: level + 1, base: base)
            }
        }
    }

    private mutating func append(_ kind: Box.Kind, _ level: Int, _ center: SIMD3<Float>, _ size: SIMD3<Float>, yaw: Float = 0) {
        architecture.append(Box(kind: kind, level: level, center: center, size: size, yaw: yaw))
    }

    // A tile owns its top-left (−x) and top-right (−y) edges. Blueprints mark the bottom edges
    // on the neighbor too, so a bottom edge is drawn only where there's no neighbor to own it.
    private mutating func appendWalls(_ wall: WallTile, tileX: Int, tileY: Int, level: Int, base: Float) {
        let x = Float(tileX), z = Float(tileY), t = Self.wallThickness
        func height(_ style: UInt16) -> Float { style == 1 || style == 0 ? Self.levelHeight : Self.fenceHeight }
        func kind(_ style: UInt16) -> Box.Kind { style == 1 || style == 0 ? .wall : .fence }
        func edge(_ style: UInt16, _ center: SIMD3<Float>, _ size: SIMD3<Float>) {
            let h = height(style)
            append(kind(style), level, center + SIMD3(0, base + h / 2, 0), SIMD3(size.x, h, size.z))
        }
        if wall.segments.contains(.topLeft) { edge(wall.topLeftStyle, SIMD3(x, 0, z + 0.5), SIMD3(t, 0, 1)) }
        if wall.segments.contains(.topRight) { edge(wall.topRightStyle, SIMD3(x + 0.5, 0, z), SIMD3(1, 0, t)) }
        if wall.segments.contains(.bottomLeft), tileX + 1 >= lotWidth { edge(wall.topLeftStyle, SIMD3(x + 1, 0, z + 0.5), SIMD3(t, 0, 1)) }
        if wall.segments.contains(.bottomRight), tileY + 1 >= lotHeight { edge(wall.topRightStyle, SIMD3(x + 0.5, 0, z + 1), SIMD3(1, 0, t)) }
        // Diagonals cross the tile corner to corner: horizontal from (x+1, z) to (x, z+1),
        // vertical from (x, z) to (x+1, z+1).
        let length = Float(2).squareRoot()
        let middle = SIMD3(x + 0.5, base + Self.levelHeight / 2, z + 0.5)
        if wall.segments.contains(.horizontalDiagonal) {
            append(.wall, level, middle, SIMD3(length, Self.levelHeight, t), yaw: 45)
        }
        if wall.segments.contains(.verticalDiagonal) {
            append(.wall, level, middle, SIMD3(length, Self.levelHeight, t), yaw: -45)
        }
    }

    /// Rebuilds the objects' boxes from where the VM has them: each object's footprint, or a
    /// tile-sized box where it has none. Objects in a slot sit on top of what holds them, and
    /// hidden objects (``isHidden(_:)``) have none.
    public mutating func rebuildObjects(of vm: VM, hiddenByBlueprint: [Int16: UInt32] = [:]) {
        objects.removeAll(keepingCapacity: true)
        for entity in vm.entities where !entity.isDead {
            var holder = entity
            var depth = 0
            while let container = holder.container, depth < 8 {
                holder = container
                depth += 1
            }
            let position = holder.position
            guard position != .outOfWorld, !Self.isHidden(entity, hiddenByBlueprint: hiddenByBlueprint) else { continue }
            let level = Int(position.level)
            let base = Float(level - 1) * Self.levelHeight + Self.objectHeight * Float(depth)
            if depth > 0 {
                let center = SIMD3(Float(position.x) / 16, base + 0.15, Float(position.y) / 16)
                objects.append(Box(kind: .object(entity.objectID), level: level, center: center, size: SIMD3(0.3, 0.3, 0.3)))
                continue
            }
            var minimum = SIMD2(Float(position.x) / 16 - 0.4, Float(position.y) / 16 - 0.4)
            var maximum = minimum + SIMD2(0.8, 0.8)
            if let footprint = entity.footprint, footprint.x2 > footprint.x1, footprint.y2 > footprint.y1 {
                minimum = SIMD2(Float(footprint.x1) / 16, Float(footprint.y1) / 16)
                maximum = SIMD2(Float(footprint.x2) / 16, Float(footprint.y2) / 16)
            }
            let size = maximum - minimum
            let center = (minimum + maximum) / 2
            objects.append(Box(kind: .object(entity.objectID), level: level,
                               center: SIMD3(center.x, base + Self.objectHeight / 2, center.y),
                               size: SIMD3(size.x, Self.objectHeight, size.y)))
        }
    }
}
