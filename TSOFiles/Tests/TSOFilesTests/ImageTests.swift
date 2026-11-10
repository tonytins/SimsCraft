import Foundation
import Testing
@testable import TSOFiles

/// A BMP with the 40-byte header: `palette` holds BGR colours for 8-bit pixels.
private func bmp(width: Int, height: Int, bits: Int, compression: Int = 0, palette: [[UInt8]] = [], colorsUsed: Int? = nil,
                 pixels: [UInt8]) -> Data {
    var header = [UInt8](repeating: 0, count: 54)
    let paletteBytes: [UInt8] = palette.flatMap { color -> [UInt8] in color + [0] }
    let offset = 54 + paletteBytes.count
    func put32(_ value: Int, _ at: Int) {
        let bits = UInt32(bitPattern: Int32(truncatingIfNeeded: value))
        for i in 0..<4 { header[at + i] = UInt8(truncatingIfNeeded: bits >> (8 * i)) }
    }
    header[0] = 0x42; header[1] = 0x4D
    put32(offset + pixels.count, 2)
    put32(offset, 10)
    put32(40, 14)
    put32(width, 18)
    put32(height, 22)
    header[26] = 1
    header[28] = UInt8(bits)
    put32(compression, 30)
    put32(colorsUsed ?? palette.count, 46)
    return Data(header + paletteBytes + pixels)
}

private func pixel(_ image: RasterImage, _ x: Int, _ y: Int) -> [UInt8] {
    let at = (y * image.width + x) * 4
    return Array(image.rgba[at..<at + 4])
}

@Test func bitmapsOf24BitsReadBottomUpWithPaddedRows() throws {
    // 2 by 2: the bottom row (stored first) red and green, the top row blue and white; each row
    // is padded from 6 bytes to 8.
    let image = try BMPImage.decode(bmp(width: 2, height: 2, bits: 24, pixels: [0, 0, 255, 0, 255, 0, 0, 0,
                                                                                  255, 0, 0, 255, 255, 255, 0, 0]))
    #expect(pixel(image, 0, 1) == [255, 0, 0, 255] && pixel(image, 1, 1) == [0, 255, 0, 255])
    #expect(pixel(image, 0, 0) == [0, 0, 255, 255] && pixel(image, 1, 0) == [255, 255, 255, 255])
}

@Test func bitmapsOf8BitsUseTheirPaletteAndANegativeHeightIsTopDown() throws {
    let palette: [[UInt8]] = [[0, 0, 0], [0, 0, 200], [200, 0, 0]]
    let image = try BMPImage.decode(bmp(width: 3, height: -1, bits: 8, palette: palette, pixels: [1, 2, 0, 0]))
    #expect(image.height == 1)
    #expect([pixel(image, 0, 0), pixel(image, 1, 0), pixel(image, 2, 0)] == [[200, 0, 0, 255], [0, 0, 200, 255], [0, 0, 0, 255]])
    // A colour count of 0 means 256, which must fit before the pixels.
    #expect(throws: ImageError.self) { try BMPImage.decode(bmp(width: 1, height: 1, bits: 8, palette: palette, colorsUsed: 0, pixels: [0, 0, 0, 0])) }
    #expect(throws: ImageError.invalid("palette index 3 of 3")) {
        try BMPImage.decode(bmp(width: 1, height: 1, bits: 8, palette: palette, pixels: [3, 0, 0, 0]))
    }
}

@Test func runLengthBitmapsDecodeRunsLiteralsAndMoves() throws {
    let palette: [[UInt8]] = [[0, 0, 0], [0, 0, 200], [200, 0, 0]]
    // Bottom row: two of index 1, then three literal indices (2, 1, 2, padded), ending the row.
    // Next row: a move two right, one of index 2, then the end of the picture.
    let data: [UInt8] = [2, 1, 0, 3, 2, 1, 2, 0, 0, 0,
                         0, 2, 2, 0, 1, 2, 0, 1]
    let image = try BMPImage.decode(bmp(width: 5, height: 2, bits: 8, compression: 1, palette: palette, pixels: data))
    #expect((0..<5).map { pixel(image, $0, 1) } == [[200, 0, 0, 255], [200, 0, 0, 255], [0, 0, 200, 255], [200, 0, 0, 255], [0, 0, 200, 255]])
    // The move skipped two pixels on the top row, which stay transparent; the run lands at 2.
    #expect(pixel(image, 0, 0) == [0, 0, 0, 0] && pixel(image, 2, 0) == [0, 0, 200, 255])
    // A run past the row's end, and data that stops before the end marker, are errors.
    #expect(throws: ImageError.invalid("a run past row 0's end")) {
        try BMPImage.decode(bmp(width: 2, height: 1, bits: 8, compression: 1, palette: palette, pixels: [3, 1, 0, 1]))
    }
    #expect(throws: ImageError.truncated) {
        try BMPImage.decode(bmp(width: 2, height: 1, bits: 8, compression: 1, palette: palette, pixels: [2, 1]))
    }
}

@Test func hostileBitmapHeadersAreErrors() {
    #expect(throws: ImageError.notThisFormat) { try BMPImage.decode(Data([0x50, 0x4B, 0, 0])) }
    #expect(throws: ImageError.truncated) { try BMPImage.decode(Data([0x42, 0x4D, 0, 0])) }
    #expect(throws: ImageError.invalid("a size of 100000 by 100000")) {
        try BMPImage.decode(bmp(width: 100_000, height: 100_000, bits: 24, pixels: []))
    }
    #expect(throws: ImageError.unsupported("16-bit pixels with compression 0")) {
        try BMPImage.decode(bmp(width: 1, height: 1, bits: 16, pixels: [0, 0, 0, 0]))
    }
    #expect(throws: ImageError.truncated) { try BMPImage.decode(bmp(width: 4, height: 4, bits: 24, pixels: [0, 0, 0])) }
}

/// A Targa with the 2.0 footer.
private func targa(type: UInt8, width: Int, height: Int, bits: UInt8 = 32, descriptor: UInt8 = 8, body: [UInt8]) -> Data {
    var header = [UInt8](repeating: 0, count: 18)
    header[2] = type
    header[12] = UInt8(width); header[13] = UInt8(width >> 8)
    header[14] = UInt8(height); header[15] = UInt8(height >> 8)
    header[16] = bits
    header[17] = descriptor
    let footer = [UInt8](repeating: 0, count: 8) + Array("TRUEVISION-XFILE".utf8) + [0x2E, 0]
    return Data(header + body + footer)
}

@Test func targasReadPlainAndRunLengthPixelsBottomUp() throws {
    // BGRA: the bottom row stored first.
    let plain = targa(type: 2, width: 2, height: 2, body: [0, 0, 255, 255, 0, 255, 0, 128, 255, 0, 0, 255, 1, 2, 3, 0])
    #expect(TargaImage.hasFooter(plain))
    let image = try TargaImage.decode(plain)
    #expect(pixel(image, 0, 1) == [255, 0, 0, 255] && pixel(image, 1, 1) == [0, 255, 0, 128])
    #expect(pixel(image, 0, 0) == [0, 0, 255, 255] && pixel(image, 1, 0) == [3, 2, 1, 0])
    // A repeat of three and a literal of one; top-down by the descriptor's bit 5.
    let packed = targa(type: 10, width: 4, height: 1, descriptor: 0x28, body: [0x82, 10, 20, 30, 255, 0x00, 1, 2, 3, 4])
    let runs = try TargaImage.decode(packed)
    #expect((0..<3).allSatisfy { pixel(runs, $0, 0) == [30, 20, 10, 255] } && pixel(runs, 3, 0) == [3, 2, 1, 4])
    #expect(throws: ImageError.invalid("a run past the picture's end")) {
        try TargaImage.decode(targa(type: 10, width: 2, height: 1, body: [0x82, 0, 0, 0, 0]))
    }
    #expect(throws: ImageError.unsupported("image type 1")) { try TargaImage.decode(targa(type: 1, width: 1, height: 1, body: [])) }
    #expect(!TargaImage.hasFooter(Data(repeating: 0, count: 40)))
}

@Test func a32BitTargaWithoutAlphaBitsIsOpaque() throws {
    // The descriptor's low four bits are 0: the fourth byte isn't alpha.
    let image = try TargaImage.decode(targa(type: 2, width: 1, height: 1, descriptor: 0, body: [1, 2, 3, 0]))
    #expect(pixel(image, 0, 0) == [3, 2, 1, 255])
}
