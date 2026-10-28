import Foundation

/// A color without alpha, as palettes store them.
public struct RGBColor: Sendable, Hashable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Black.
    public static let black = RGBColor(red: 0, green: 0, blue: 0)
}

/// A palette of up to 256 colors that sprites index into.
///
/// Ports FreeSO's `PALT`: a version, an entry count, eight reserved bytes, then three bytes
/// (red, green, blue) for each entry. FreeSO gives each color full alpha; sprites decide
/// which index is transparent. A count larger than the data that follows is an error, where
/// FreeSO would allocate the whole count and then run out of data.
public struct PALT: IFFChunk {
    public static let typeCode = "PALT"

    public let id: UInt16
    public let label: String
    /// The version field, which FreeSO doesn't use.
    public let version: UInt32
    /// The colors, by index.
    public let colors: [RGBColor]

    public init(record: IFFChunkRecord) throws(IFFChunkError) {
        id = record.id
        label = record.label
        (version, colors) = try record.parse(byteOrder: .littleEndian) { reader in
            let version = try reader.readUInt32()
            let count = try reader.readUInt32()
            try reader.skip(8)
            guard UInt64(count) * 3 <= UInt64(reader.remaining) else {
                throw ChunkFormatError(reason: "\(count) colors need \(UInt64(count) * 3) bytes, but \(reader.remaining) remain")
            }
            var colors: [RGBColor] = []
            colors.reserveCapacity(Int(count))
            for _ in 0..<count {
                colors.append(RGBColor(red: try reader.readUInt8(), green: try reader.readUInt8(), blue: try reader.readUInt8()))
            }
            return (version, colors)
        }
    }

    /// A palette of one color, as FreeSO makes for `SPR#`'s missing palettes (`DEFAULT_PALT`).
    public init(uniform color: RGBColor, id: UInt16 = 0) {
        self.id = id
        label = ""
        version = 0
        colors = Array(repeating: color, count: 256)
    }

    /// The color at an index, or `nil` when the palette is shorter.
    public func color(at index: Int) -> RGBColor? {
        colors.indices.contains(index) ? colors[index] : nil
    }
}
