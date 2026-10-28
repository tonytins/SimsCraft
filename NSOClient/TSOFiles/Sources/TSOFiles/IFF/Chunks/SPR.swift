import Foundation

/// An older sprite with color only, from The Sims 1's formats: some TSO objects still use it.
///
/// Ports FreeSO's `SPR` (type code `SPR#`). A file whose first 16-bit word is 0 is big-endian.
/// FreeSO works out a big-endian file's version with a mask that keeps the low byte as 0xFF
/// (`(version2 | 0xFF00) >> 8` where `&` was meant), so a big-endian file never reads as
/// version 1001 and always takes the offset table; that's kept. Version 1001 reads frames
/// until the data ends, each with its own size, ignoring the frame count.
public struct SPR: IFFChunk {
    public static let typeCode = "SPR#"

    public let id: UInt16
    public let label: String
    /// The version as FreeSO works it out, quirk included.
    public let version: UInt32
    public let byteOrder: ByteOrder
    /// The `PALT` every frame uses (the low 16 bits of a 32-bit field, as FreeSO casts it).
    public let paletteID: UInt16
    public let frames: [Frame]

    /// One frame's size and run-length data (FreeSO's `SPRFrame`).
    public struct Frame: Sendable, Hashable {
        public var width: Int
        public var height: Int
        /// The run-length data after the header.
        public var encoded: Data
    }

    public init(record: IFFChunkRecord) throws(IFFChunkError) {
        id = record.id
        label = record.label
        (version, byteOrder, paletteID, frames) = try record.parse(byteOrder: .littleEndian) { reader in
            let version1 = try reader.readUInt16()
            let version2 = try reader.readUInt16()
            var version = UInt32(version1)
            if version1 == 0 {
                reader.byteOrder = .bigEndian
                version = UInt32((UInt32(version2) | 0xFF00) >> 8 | (UInt32(version2) & 0xFF) << 8)
            }
            let count = try reader.readUInt32()
            let paletteID = UInt16(truncatingIfNeeded: try reader.readUInt32())
            var frames: [Frame] = []
            if version != 1001 {
                guard UInt64(count) * 4 <= UInt64(reader.remaining) else {
                    throw ChunkFormatError(reason: "an offset table of \(count) frames can't fit in \(reader.remaining) bytes")
                }
                var offsets: [UInt32] = []
                for _ in 0..<count { offsets.append(try reader.readUInt32()) }
                let total = UInt32(clamping: reader.offset + reader.remaining)
                for (index, offset) in offsets.enumerated() {
                    try reader.seek(to: Int(offset))
                    let next = index + 1 < offsets.count ? offsets[index + 1] : total
                    let data = reader.readBytes(upTo: Int(next &- offset))
                    frames.append(try Self.frame(from: data, byteOrder: reader.byteOrder))
                }
            } else {
                while reader.remaining > 0 {
                    _ = try reader.readUInt32() // The frame's own version.
                    let size = try reader.readUInt32()
                    // .NET's ReadBytes reads what's left when asked for more; kept.
                    let data = reader.readBytes(upTo: Int(size))
                    frames.append(try Self.frame(from: data, byteOrder: reader.byteOrder))
                }
            }
            return (version, reader.byteOrder, paletteID, frames)
        }
    }

    private static func frame(from data: Data, byteOrder: ByteOrder) throws -> Frame {
        var reader = ByteReader(data, byteOrder: byteOrder)
        _ = try reader.readUInt32() // Reserved.
        let height = Int(try reader.readUInt16())
        let width = Int(try reader.readUInt16())
        return Frame(width: width, height: height, encoded: reader.readBytes(upTo: reader.remaining))
    }

    /// Decodes a frame with the chunk's palette, which the caller finds by ``paletteID``; pass
    /// `nil` when the IFF has none, and every color is opaque black, FreeSO's `DEFAULT_PALT`.
    public func decode(frameAt index: Int, palette: PALT?) throws(SpriteError) -> SpriteImage {
        guard frames.indices.contains(index) else { throw .noSuchFrame(index) }
        return try SpriteDecoder.decodeSPR(frames[index], palette: palette ?? PALT(uniform: .black))
    }
}

extension SpriteDecoder {
    /// Decodes a `SPR#` frame as FreeSO's `SPRFrame.Decode` does.
    ///
    /// Pixels the data skips stay transparent black; every colored pixel is opaque. The format
    /// has no depth. Unknown commands do nothing, and a frame without an end marker runs until
    /// its data does, which is an error, as FreeSO's read past the end is.
    static func decodeSPR(_ frame: SPR.Frame, palette: PALT) throws(SpriteError) -> SpriteImage {
        let width = frame.width
        let pixelCount = frame.width * frame.height
        var rgba = [UInt8](repeating: 0, count: pixelCount * 4)
        var indices = [UInt8](repeating: 0, count: pixelCount)
        var reader = ByteReader(frame.encoded, byteOrder: .littleEndian)
        func byte() throws(SpriteError) -> UInt8 {
            do { return try reader.readUInt8() } catch { throw .truncated }
        }
        func set(_ x: Int, _ y: Int, _ index: UInt8) throws(SpriteError) {
            let at = y * width + x
            guard at >= 0, at < pixelCount else { throw .pixelOutOfBounds(row: y, column: x) }
            guard let c = palette.color(at: Int(index)) else { throw .paletteIndexOutOfRange(Int(index)) }
            rgba[at * 4] = c.red
            rgba[at * 4 + 1] = c.green
            rgba[at * 4 + 2] = c.blue
            rgba[at * 4 + 3] = 255
            indices[at] = index
        }

        var y = 0
        var ended = false
        while !ended {
            let command = try byte()
            let count = Int(try byte())
            switch command {
            case 0x04:
                var bytes = count - 2
                var x = 0
                while bytes > 0 {
                    let pixelCommand = try byte()
                    let pixelCount = Int(try byte())
                    bytes -= 2
                    switch pixelCommand {
                    case 0x01:
                        x += pixelCount
                    case 0x02:
                        let index = try byte()
                        _ = try byte() // Padding.
                        bytes -= 2
                        for _ in 0..<pixelCount {
                            try set(x, y, index)
                            x += 1
                        }
                    case 0x03:
                        for _ in 0..<pixelCount {
                            try set(x, y, try byte())
                            x += 1
                        }
                        bytes -= pixelCount
                        if pixelCount % 2 != 0 {
                            _ = try byte()
                            bytes -= 1
                        }
                    default:
                        break
                    }
                }
                y += 1
            case 0x05:
                ended = true
            case 0x09:
                y += count
            default:
                // 0x00 and 0x10 mark a start; anything else is skipped as FreeSO skips it.
                break
            }
        }
        return SpriteImage(width: frame.width, height: frame.height, position: SIMD2(0, 0),
                           rgba: rgba, depth: nil, paletteIndices: indices)
    }
}
