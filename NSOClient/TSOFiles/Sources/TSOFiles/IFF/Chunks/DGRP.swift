import Foundation

/// A drawing group: how one tile of an object looks from each direction at each zoom.
///
/// Ports FreeSO's `DGRP`. Each image names a direction and zoom and lists the sprites
/// (`SPR2` or `SPR#` frames) drawn for it, each with an offset on screen and, from version
/// 20001, an offset in the world. That world offset is what turns a sprite's depth into depth
/// across the lot (roadmap decision 7).
///
/// Versions below 20003 use 16-bit fields; 20003 and later use 32-bit ones, and 20004 adds
/// the world offset's x and y. FreeSO reads any version from 20003 up as 20003, and so does
/// this. A count larger than the data could hold is an error, where FreeSO would allocate it.
public struct DGRP: IFFChunk {
    public static let typeCode = "DGRP"

    public let id: UInt16
    public let label: String
    public let version: UInt16
    public let images: [Image]

    /// One direction and zoom of a drawing group (FreeSO's `DGRPImage`).
    public struct Image: Sendable, Hashable {
        /// A direction bit: 0x01, 0x04, 0x10, or 0x40 (FreeSO's `RightBack`, `RightFront`,
        /// `LeftFront`, `LeftBack`).
        public var direction: UInt32
        /// 1 is the farthest zoom, 3 the closest.
        public var zoom: UInt32
        /// The sprites, drawn in order.
        public var sprites: [Sprite]
    }

    /// One sprite of an image (FreeSO's `DGRPSprite`).
    public struct Sprite: Sendable, Hashable {
        /// The `SPR2` or `SPR#` chunk's ID.
        public var spriteID: UInt32
        /// The frame within it.
        public var frameIndex: UInt32
        public var flags: Flags
        /// Where the sprite sits on screen, in pixels.
        public var spriteOffset: SIMD2<Int32>
        /// Where the sprite sits in the world, in tiles: z from version 20001, x and y from 20004.
        public var objectOffset: SIMD3<Float>
    }

    /// A sprite's flags (FreeSO's `DGRPSpriteFlags`). Unnamed bits are kept.
    public struct Flags: OptionSet, Sendable, Hashable {
        public var rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }

        /// Drawn mirrored left to right.
        public static let flip = Flags(rawValue: 0x1)
        /// Drawn lit, ignoring the room's light.
        public static let luminous = Flags(rawValue: 0x4)
    }

    public init(record: IFFChunkRecord) throws(IFFChunkError) {
        id = record.id
        label = record.label
        (version, images) = try record.parse(byteOrder: .littleEndian) { reader in
            let version = try reader.readUInt16()
            let isWide = version >= 20003
            let imageCount = isWide ? try reader.readUInt32() : UInt32(try reader.readUInt16())
            // The smallest image is its header with no sprites.
            try Self.require(count: imageCount, eachAtLeast: isWide ? 12 : 4, in: reader, of: "images")
            var images: [Image] = []
            images.reserveCapacity(Int(imageCount))
            for _ in 0..<imageCount {
                images.append(try Self.readImage(&reader, version: version))
            }
            return (version, images)
        }
    }

    private static func readImage(_ reader: inout ByteReader, version: UInt16) throws -> Image {
        let direction: UInt32, zoom: UInt32, spriteCount: UInt32
        if version < 20003 {
            spriteCount = UInt32(try reader.readUInt16())
            direction = UInt32(try reader.readUInt8())
            zoom = UInt32(try reader.readUInt8())
        } else {
            direction = try reader.readUInt32()
            zoom = try reader.readUInt32()
            spriteCount = try reader.readUInt32()
        }
        let spriteSize = version < 20003 ? (version == 20001 ? 16 : 12) : (version == 20004 ? 32 : 24)
        try require(count: spriteCount, eachAtLeast: spriteSize, in: reader, of: "sprites")
        var sprites: [Sprite] = []
        sprites.reserveCapacity(Int(spriteCount))
        for _ in 0..<spriteCount {
            sprites.append(try readSprite(&reader, version: version))
        }
        return Image(direction: direction, zoom: zoom, sprites: sprites)
    }

    private static func readSprite(_ reader: inout ByteReader, version: UInt16) throws -> Sprite {
        var offset = SIMD3<Float>(0, 0, 0)
        if version < 20003 {
            _ = try reader.readUInt16() // A type field FreeSO ignores.
            let spriteID = UInt32(try reader.readUInt16())
            let frameIndex = UInt32(try reader.readUInt16())
            let flags = Flags(rawValue: UInt32(try reader.readUInt16()))
            let x = Int32(try reader.readInt16()), y = Int32(try reader.readInt16())
            if version == 20001 { offset.z = try reader.readFloat32() }
            return Sprite(spriteID: spriteID, frameIndex: frameIndex, flags: flags, spriteOffset: SIMD2(x, y), objectOffset: offset)
        }
        let spriteID = try reader.readUInt32()
        let frameIndex = try reader.readUInt32()
        let x = try reader.readInt32(), y = try reader.readInt32()
        offset.z = try reader.readFloat32()
        let flags = Flags(rawValue: try reader.readUInt32())
        if version == 20004 {
            offset.x = try reader.readFloat32()
            offset.y = try reader.readFloat32()
        }
        return Sprite(spriteID: spriteID, frameIndex: frameIndex, flags: flags, spriteOffset: SIMD2(x, y), objectOffset: offset)
    }

    private static func require(count: UInt32, eachAtLeast size: Int, in reader: ByteReader, of what: String) throws {
        guard UInt64(count) * UInt64(size) <= UInt64(reader.remaining) else {
            throw ChunkFormatError(reason: "\(count) \(what) can't fit in the \(reader.remaining) bytes left")
        }
    }

    /// The image for an object facing `direction` (a direction bit) at a zoom, in a world
    /// turned `worldRotation` quarter turns, as FreeSO's `GetImage` finds it: the direction bit
    /// rotated two bits a quarter turn, wrapping within a byte. The first match wins; `nil`
    /// when there's none.
    public func image(direction: UInt32, zoom: UInt32, worldRotation: UInt32) -> Image? {
        // FreeSO computes this in a C# int: the shift count is masked to 5 bits, and the
        // right shift keeps the sign.
        let shifted = Int32(truncatingIfNeeded: direction) &<< Int32(truncatingIfNeeded: worldRotation &* 2)
        let rotated = UInt32(bitPattern: (shifted & 255) | (shifted &>> 8))
        return images.first { $0.direction == rotated && $0.zoom == zoom }
    }
}
