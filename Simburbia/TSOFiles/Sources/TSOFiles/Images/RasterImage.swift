import Foundation

/// A decoded picture: red, green, blue, and alpha for each pixel, row by row from the top.
public struct RasterImage: Sendable, Equatable {
    public var width: Int
    public var height: Int
    public var rgba: [UInt8]

    public init(width: Int, height: Int, rgba: [UInt8]) {
        self.width = width
        self.height = height
        self.rgba = rgba
    }

    /// The most pixels an image may claim, so a hostile header can't ask for gigabytes: 64
    /// million, far past TSO's largest (its 800 by 600 backgrounds).
    public static let mostPixels = 1 << 26
}

/// Why an image couldn't be decoded.
public enum ImageError: Error, Equatable, Sendable {
    /// The file isn't the format it was read as.
    case notThisFormat
    /// A header or the pixel data ends early.
    case truncated
    /// The header holds something this reader doesn't support, such as a depth or compression.
    case unsupported(String)
    /// The header's numbers don't make a picture: a zero or oversized size, a palette past the
    /// end, or a run that writes past the picture.
    case invalid(String)
}

/// A Windows bitmap (`.bmp`), as TSO's interface graphics use them: 8-bit with a palette, plain
/// or run-length encoded (RLE8), or 24-bit, with the 40-byte header, rows bottom-up unless the
/// height is negative.
///
/// FreeSO hands these to MonoGame's `Texture2D.FromStream`, which isn't in the snapshot; this
/// follows the format, and is checked against stb_image where stb reads the file too. Pixels an
/// RLE8 bitmap skips are transparent black.
public enum BMPImage {
    public static func decode(_ data: Data) throws(ImageError) -> RasterImage {
        let bytes = [UInt8](data)
        func u16(_ at: Int) throws(ImageError) -> Int {
            guard at >= 0, at + 2 <= bytes.count else { throw .truncated }
            return Int(bytes[at]) | Int(bytes[at + 1]) << 8
        }
        func u32(_ at: Int) throws(ImageError) -> Int {
            guard at >= 0, at + 4 <= bytes.count else { throw .truncated }
            return Int(bytes[at]) | Int(bytes[at + 1]) << 8 | Int(bytes[at + 2]) << 16 | Int(bytes[at + 3]) << 24
        }
        guard bytes.count >= 2, bytes[0] == 0x42, bytes[1] == 0x4D else { throw .notThisFormat }
        let pixelOffset = try u32(10)
        let headerSize = try u32(14)
        guard headerSize >= 40 else { throw .unsupported("a \(headerSize)-byte header") }
        let width = Int(Int32(truncatingIfNeeded: try u32(18)))
        let rawHeight = Int(Int32(truncatingIfNeeded: try u32(22)))
        let bits = try u16(28)
        let compression = try u32(30)
        let colorsUsed = try u32(46)
        let topDown = rawHeight < 0
        let height = abs(rawHeight)
        // Each side first, so their product can't overflow.
        guard width > 0, height > 0, width <= RasterImage.mostPixels, height <= RasterImage.mostPixels,
              width * height <= RasterImage.mostPixels else {
            throw .invalid("a size of \(width) by \(rawHeight)")
        }
        guard pixelOffset <= bytes.count else { throw .truncated }

        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        func put(_ x: Int, _ row: Int, _ r: UInt8, _ g: UInt8, _ b: UInt8) {
            let y = topDown ? row : height - 1 - row
            let at = (y * width + x) * 4
            rgba[at] = r
            rgba[at + 1] = g
            rgba[at + 2] = b
            rgba[at + 3] = 255
        }

        switch (bits, compression) {
        case (24, 0):
            let stride = (width * 3 + 3) & ~3
            guard pixelOffset + stride * height <= bytes.count else { throw .truncated }
            for row in 0..<height {
                let start = pixelOffset + row * stride
                for x in 0..<width {
                    let at = start + x * 3
                    put(x, row, bytes[at + 2], bytes[at + 1], bytes[at])
                }
            }
        case (8, 0), (8, 1):
            let count = colorsUsed == 0 ? 256 : colorsUsed
            let paletteStart = 14 + headerSize
            guard count <= 256, paletteStart + count * 4 <= pixelOffset else {
                throw .invalid("a palette of \(colorsUsed) colours before offset \(pixelOffset)")
            }
            func color(_ index: UInt8) throws(ImageError) -> (UInt8, UInt8, UInt8) {
                guard Int(index) < count else { throw .invalid("palette index \(index) of \(count)") }
                let at = paletteStart + Int(index) * 4
                return (bytes[at + 2], bytes[at + 1], bytes[at])
            }
            if compression == 0 {
                let stride = (width + 3) & ~3
                guard pixelOffset + stride * height <= bytes.count else { throw .truncated }
                for row in 0..<height {
                    for x in 0..<width {
                        let (r, g, b) = try color(bytes[pixelOffset + row * stride + x])
                        put(x, row, r, g, b)
                    }
                }
            } else {
                guard !topDown else { throw .invalid("a top-down RLE8 bitmap") }
                try decodeRLE8(bytes, from: pixelOffset, width: width, height: height) { x, row, index throws(ImageError) in
                    let (r, g, b) = try color(index)
                    put(x, row, r, g, b)
                }
            }
        default:
            throw .unsupported("\(bits)-bit pixels with compression \(compression)")
        }
        return RasterImage(width: width, height: height, rgba: rgba)
    }

    /// RLE8: pairs of a count and an index, or a zero then an escape: 0 ends the row, 1 ends the
    /// picture, 2 moves right and up by the next two bytes, and anything larger is that many
    /// indices as they are, padded to an even length. A run past the row's end is an error, as
    /// is data that stops before the end marker. A picture ended before its last row leaves the
    /// rest transparent: three of 1.1097.1.0's graphics do, and one of each 2002 copy's, which Pillow refuses.
    private static func decodeRLE8(_ bytes: [UInt8], from start: Int, width: Int, height: Int,
                                   put: (Int, Int, UInt8) throws(ImageError) -> Void) throws(ImageError) {
        var at = start, x = 0, row = 0
        func next() throws(ImageError) -> Int {
            guard at < bytes.count else { throw .truncated }
            defer { at += 1 }
            return Int(bytes[at])
        }
        while true {
            let count = try next()
            let value = try next()
            if count > 0 {
                guard row < height, x + count <= width else { throw .invalid("a run past row \(row)'s end") }
                for _ in 0..<count {
                    try put(x, row, UInt8(value))
                    x += 1
                }
                continue
            }
            switch value {
            case 0:
                x = 0
                row += 1
            case 1:
                return
            case 2:
                x += try next()
                row += try next()
                guard x <= width, row <= height else { throw .invalid("a move past the picture") }
            default:
                guard row < height, x + value <= width else { throw .invalid("a run past row \(row)'s end") }
                for _ in 0..<value {
                    try put(x, row, UInt8(try next()))
                    x += 1
                }
                if value % 2 != 0 { _ = try next() }
            }
        }
    }
}

/// A Targa (`.tga`), as TSO's interface graphics use them: 24- or 32-bit truecolor, plain (type 2)
/// or run-length encoded (type 10), its rows bottom-up unless the descriptor's bit 5 says top-down.
///
/// A 32-bit pixel's fourth byte is its alpha only when the descriptor says the pixels have alpha
/// bits (its low four bits); otherwise the pixel is opaque, as the format says and as Pillow reads
/// it. One of 1.1097.1.0's interface graphics is such a file, its alpha bytes all 0. FreeSO reads
/// these through TargaImagePCL, which isn't in the snapshot, so its exact behavior is unverified.
public enum TargaImage {
    /// Whether a file ends with the Targa 2.0 footer's signature, which is how FreeSO's
    /// `ImageLoader` tells a Targa apart.
    public static func hasFooter(_ data: Data) -> Bool {
        guard data.count >= 26 else { return false }
        return data.suffix(18).prefix(16).elementsEqual("TRUEVISION-XFILE".utf8)
    }

    public static func decode(_ data: Data) throws(ImageError) -> RasterImage {
        let bytes = [UInt8](data)
        guard bytes.count >= 18 else { throw .truncated }
        let idLength = Int(bytes[0])
        let colorMapType = bytes[1]
        let imageType = bytes[2]
        let width = Int(bytes[12]) | Int(bytes[13]) << 8
        let height = Int(bytes[14]) | Int(bytes[15]) << 8
        let bits = Int(bytes[16])
        let topDown = bytes[17] & 0x20 != 0
        let hasAlpha = bytes[17] & 0x0F != 0
        guard colorMapType == 0 else { throw .unsupported("a colour map") }
        guard imageType == 2 || imageType == 10 else { throw .unsupported("image type \(imageType)") }
        guard bits == 24 || bits == 32 else { throw .unsupported("\(bits)-bit pixels") }
        guard width > 0, height > 0, width * height <= RasterImage.mostPixels else {
            throw .invalid("a size of \(width) by \(height)")
        }
        let pixelSize = bits / 8
        var at = 18 + idLength
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        var index = 0
        func store(from source: Int) {
            let row = index / width, x = index % width
            let y = topDown ? row : height - 1 - row
            let target = (y * width + x) * 4
            rgba[target] = bytes[source + 2]
            rgba[target + 1] = bytes[source + 1]
            rgba[target + 2] = bytes[source]
            rgba[target + 3] = pixelSize == 4 && hasAlpha ? bytes[source + 3] : 255
            index += 1
        }
        let total = width * height
        if imageType == 2 {
            guard at + total * pixelSize <= bytes.count else { throw .truncated }
            while index < total {
                store(from: at)
                at += pixelSize
            }
        } else {
            while index < total {
                guard at < bytes.count else { throw .truncated }
                let header = Int(bytes[at])
                at += 1
                let count = (header & 0x7F) + 1
                guard index + count <= total else { throw .invalid("a run past the picture's end") }
                if header & 0x80 != 0 {
                    guard at + pixelSize <= bytes.count else { throw .truncated }
                    for _ in 0..<count { store(from: at) }
                    at += pixelSize
                } else {
                    guard at + count * pixelSize <= bytes.count else { throw .truncated }
                    for _ in 0..<count {
                        store(from: at)
                        at += pixelSize
                    }
                }
            }
        }
        return RasterImage(width: width, height: height, rgba: rgba)
    }
}
