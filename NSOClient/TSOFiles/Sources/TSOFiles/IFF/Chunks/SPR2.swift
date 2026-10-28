import Foundation

/// A sprite with color, depth, and alpha: the object graphics of TSO.
///
/// Ports FreeSO's `SPR2`. Reading the chunk reads each frame's header and keeps its
/// run-length data; ``decode(frameAt:palette:)`` turns a frame into pixels with the palette
/// its header names, which lives elsewhere in the IFF (a `PALT`), the way FreeSO decodes a
/// frame only when it's first drawn.
///
/// Version 1000 locates frames with an offset table and sizes each by the next offset; version
/// 1001 gives each frame its own size. Other versions have no frames, as in FreeSO.
public struct SPR2: IFFChunk {
    public static let typeCode = "SPR2"

    public let id: UInt16
    public let label: String
    public let version: UInt32
    /// The palette a frame uses when its own names none.
    public let defaultPaletteID: UInt32
    public let frames: [Frame]

    /// One frame's header and run-length data (FreeSO's `SPR2Frame`).
    public struct Frame: Sendable, Hashable {
        public var width: Int
        public var height: Int
        public var flags: Flags
        /// The `PALT` to decode with: the chunk's default for version 1000, and for a frame
        /// whose own ID is 0 or 0xA3A3, as FreeSO does.
        public var paletteID: UInt16
        /// The palette index that stands for "nothing here".
        public var transparentColorIndex: UInt16
        /// Where the frame's top left sits relative to the object, in pixels.
        public var position: SIMD2<Int16>
        /// The run-length data after the header.
        public var encoded: Data
    }

    /// What a frame holds (FreeSO tests these bits of `Flags`).
    public struct Flags: OptionSet, Sendable, Hashable {
        public var rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }

        public static let color = Flags(rawValue: 0x1)
        public static let depth = Flags(rawValue: 0x2)
        public static let alpha = Flags(rawValue: 0x4)
    }

    public init(record: IFFChunkRecord) throws(IFFChunkError) {
        id = record.id
        label = record.label
        (version, defaultPaletteID, frames) = try record.parse(byteOrder: .littleEndian) { reader in
            let version = try reader.readUInt32()
            var frames: [Frame] = []
            switch version {
            case 1000:
                let count = try reader.readUInt32()
                let defaultPaletteID = try reader.readUInt32()
                guard UInt64(count) * 4 <= UInt64(reader.remaining) else {
                    throw ChunkFormatError(reason: "an offset table of \(count) frames can't fit in \(reader.remaining) bytes")
                }
                var offsets: [UInt32] = []
                for _ in 0..<count { offsets.append(try reader.readUInt32()) }
                let total = UInt32(clamping: reader.remaining + reader.offset)
                for (index, offset) in offsets.enumerated() {
                    try reader.seek(to: Int(offset))
                    // FreeSO sizes a frame by the next offset (or the chunk's end) in unsigned
                    // arithmetic, then reads what's there: a size that wraps reads to the end.
                    let next = index + 1 < offsets.count ? offsets[index + 1] : total
                    let data = reader.readBytes(upTo: Int(next &- offset))
                    frames.append(try Self.frame(from: data, version: 1000, defaultPaletteID: defaultPaletteID))
                }
                return (version, defaultPaletteID, frames)
            case 1001:
                let defaultPaletteID = try reader.readUInt32()
                let count = try reader.readUInt32()
                // A frame is at least its 8-byte prefix.
                guard UInt64(count) * 8 <= UInt64(reader.remaining) else {
                    throw ChunkFormatError(reason: "\(count) frames can't fit in \(reader.remaining) bytes")
                }
                for _ in 0..<count {
                    _ = try reader.readUInt32() // The frame's own version, which FreeSO ignores.
                    let size = try reader.readUInt32()
                    guard UInt64(size) <= UInt64(reader.remaining) else {
                        throw ChunkFormatError(reason: "a frame of \(size) bytes can't fit in \(reader.remaining)")
                    }
                    let data = try reader.readBytes(Int(size))
                    frames.append(try Self.frame(from: data, version: 1001, defaultPaletteID: defaultPaletteID))
                }
                return (version, defaultPaletteID, frames)
            default:
                return (version, 0, [])
            }
        }
    }

    private static func frame(from data: Data, version: UInt32, defaultPaletteID: UInt32) throws -> Frame {
        var reader = ByteReader(data, byteOrder: .littleEndian)
        let width = Int(try reader.readUInt16())
        let height = Int(try reader.readUInt16())
        let flags = Flags(rawValue: try reader.readUInt32())
        var paletteID = try reader.readUInt16()
        if version == 1000 || paletteID == 0 || paletteID == 0xA3A3 {
            paletteID = UInt16(truncatingIfNeeded: defaultPaletteID)
        }
        let transparent = try reader.readUInt16()
        let y = try reader.readInt16()
        let x = try reader.readInt16()
        let encoded = reader.readBytes(upTo: reader.remaining)
        return Frame(width: width, height: height, flags: flags, paletteID: paletteID,
                     transparentColorIndex: transparent, position: SIMD2(x, y), encoded: encoded)
    }

    /// Decodes a frame with its palette, which the caller finds by ``Frame/paletteID``; pass
    /// `nil` when the IFF has none, and every color is transparent black, as in FreeSO.
    public func decode(frameAt index: Int, palette: PALT?) throws(SpriteError) -> SpriteImage {
        guard frames.indices.contains(index) else { throw .noSuchFrame(index) }
        return try SpriteDecoder.decodeSPR2(frames[index], palette: palette)
    }
}

/// A decoded sprite frame, as plain values.
public struct SpriteImage: Sendable, Hashable {
    public var width: Int
    public var height: Int
    /// Where the frame's top left sits relative to the object, in pixels.
    public var position: SIMD2<Int16>
    /// Red, green, blue, and alpha for each pixel, row by row; `nil` when the frame has no
    /// color. A transparent pixel keeps its palette color with alpha 0, as FreeSO's do.
    public var rgba: [UInt8]?
    /// Each pixel's depth, 0 nearest and 255 farthest; `nil` when the frame has none.
    public var depth: [UInt8]?
    /// Each pixel's palette index; `nil` when the frame has no color.
    public var paletteIndices: [UInt8]?
}

/// Why a sprite frame couldn't be decoded. FreeSO crashes on each of these.
public enum SpriteError: Error, Equatable, Sendable {
    /// The chunk has no frame at that index.
    case noSuchFrame(Int)
    /// The run-length data ends inside a run.
    case truncated
    /// A run writes past the end of the frame.
    case pixelOutOfBounds(row: Int, column: Int)
    /// A run writes color or depth that the frame's flags say it doesn't have.
    case missingLayer(String)
    /// A pixel or the transparent color names an index past the palette's end.
    case paletteIndexOutOfRange(Int)
}

enum SpriteDecoder {
    /// Decodes an `SPR2` frame as FreeSO's `SPR2Frame.Decode` does.
    ///
    /// Kept from FreeSO: rows the data never reaches stay transparent black with depth 0; the
    /// unwritten end of a written row gets depth 255 and keeps its color; a run of transparent
    /// pixels takes the transparent color with alpha 0 and depth 255; 5-bit alpha is scaled by
    /// 8.2258… and truncated, saturating at 255 where FreeSO wraps (DIFF-27); unknown commands
    /// do nothing. FreeSO's `FloorCopy` and
    /// `ZAsAlpha`, which floors and walls ask for, aren't ported yet.
    static func decodeSPR2(_ frame: SPR2.Frame, palette: PALT?) throws(SpriteError) -> SpriteImage {
        let width = frame.width
        let pixelCount = frame.width * frame.height
        let hasColor = frame.flags.contains(.color)
        let hasDepth = frame.flags.contains(.depth)
        let hasAlpha = frame.flags.contains(.alpha)
        var rgba = hasColor ? [UInt8](repeating: 0, count: pixelCount * 4) : nil
        var indices = hasColor ? [UInt8](repeating: 0, count: pixelCount) : nil
        var depth = hasDepth ? [UInt8](repeating: 0, count: pixelCount) : nil

        // A missing palette is 256 transparent black colors.
        func color(_ index: Int) throws(SpriteError) -> (UInt8, UInt8, UInt8, UInt8) {
            guard let palette else {
                guard index < 256 else { throw .paletteIndexOutOfRange(index) }
                return (0, 0, 0, 0)
            }
            guard let c = palette.color(at: index) else { throw .paletteIndexOutOfRange(index) }
            return (c.red, c.green, c.blue, 255)
        }
        let transparentIndex = Int(frame.transparentColorIndex)
        let transparent = try color(transparentIndex)

        func offset(_ x: Int, _ y: Int) throws(SpriteError) -> Int {
            // FreeSO indexes y * width + x with no check on x, so a long row runs into the next.
            let offset = y * width + x
            guard offset >= 0, offset < pixelCount else { throw .pixelOutOfBounds(row: y, column: x) }
            return offset
        }
        func setColor(_ at: Int, _ c: (UInt8, UInt8, UInt8, UInt8), index: UInt8) throws(SpriteError) {
            guard rgba != nil, indices != nil else { throw .missingLayer("color") }
            rgba?[at * 4] = c.0
            rgba?[at * 4 + 1] = c.1
            rgba?[at * 4 + 2] = c.2
            rgba?[at * 4 + 3] = c.3
            indices?[at] = index
        }

        var reader = ByteReader(frame.encoded, byteOrder: .littleEndian)
        func byte() throws(SpriteError) -> UInt8 {
            do { return try reader.readUInt8() } catch { throw .truncated }
        }
        func word() throws(SpriteError) -> UInt16 {
            do { return try reader.readUInt16() } catch { throw .truncated }
        }

        var y = 0
        var ended = false
        while !ended && reader.remaining > 0 {
            let marker = try word()
            let command = marker >> 13
            let count = Int(marker & 0x1FFF)
            switch command {
            case 0x00:
                var bytes = count - 2
                var x = 0
                while bytes > 0 {
                    let pixelMarker = try word()
                    let pixelCommand = pixelMarker >> 13
                    let pixelCount = Int(pixelMarker & 0x1FFF)
                    bytes -= 2
                    switch pixelCommand {
                    case 0x01, 0x02:
                        let withAlpha = pixelCommand == 0x02
                        for _ in 0..<pixelCount {
                            let z = try byte()
                            let index = try byte()
                            bytes -= 2
                            var c = try color(Int(index))
                            if withAlpha {
                                let alpha = try byte()
                                // 5 bits of alpha scaled to 8, truncated; past 31, where FreeSO's cast
                                // wraps, it saturates (DIFF-27).
                                c.3 = UInt8(clamping: Int(Double(alpha) * 8.2258064516129032258064516129032))
                                bytes -= 1
                            }
                            let at = try offset(x, y)
                            try setColor(at, c, index: index)
                            guard depth != nil else { throw .missingLayer("depth") }
                            depth?[at] = z
                            x += 1
                        }
                        if withAlpha, (pixelCount * 3) % 2 != 0 {
                            bytes -= 1
                            _ = try byte()
                        }
                    case 0x03:
                        for _ in 0..<pixelCount {
                            let at = try offset(x, y)
                            try setColor(at, (transparent.0, transparent.1, transparent.2, 0), index: UInt8(truncatingIfNeeded: transparentIndex))
                            if hasDepth { depth?[at] = 255 }
                            x += 1
                        }
                    case 0x06:
                        for _ in 0..<pixelCount {
                            let index = try byte()
                            bytes -= 1
                            let at = try offset(x, y)
                            try setColor(at, try color(Int(index)), index: index)
                            if hasDepth { depth?[at] = 0 }
                            x += 1
                        }
                        if pixelCount % 2 != 0 {
                            bytes -= 1
                            _ = try byte()
                        }
                    default:
                        break
                    }
                }
                // The rest of the row is transparent: FreeSO sets its depth and leaves its color.
                if hasDepth {
                    while x < width {
                        depth?[try offset(x, y)] = 255
                        x += 1
                    }
                }
            case 0x04:
                if hasColor || hasAlpha || hasDepth {
                    for row in 0..<count {
                        for column in 0..<width {
                            let at = try offset(column, y + row)
                            if hasColor {
                                try setColor(at, (transparent.0, transparent.1, transparent.2, 0), index: UInt8(truncatingIfNeeded: transparentIndex))
                            } else if hasAlpha {
                                throw .missingLayer("color")
                            }
                            if hasDepth { depth?[at] = 255 }
                        }
                    }
                }
                y += count - 1
            case 0x05:
                ended = true
            default:
                break
            }
            y += 1
        }
        return SpriteImage(width: frame.width, height: frame.height, position: frame.position,
                           rgba: rgba, depth: depth, paletteIndices: indices)
    }
}
