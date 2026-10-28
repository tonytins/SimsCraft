import Foundation
import Testing
@testable import TSOFiles

// MARK: PALT

@Test func paletteReadsItsColors() throws {
    let palette = try PALT(record: record("PALT") { w in
        w.uint32(1)
        w.uint32(2)
        w.raw([UInt8](repeating: 0, count: 8))
        w.raw([255, 0, 0, 1, 2, 3])
    })
    #expect(palette.colors == [RGBColor(red: 255, green: 0, blue: 0), RGBColor(red: 1, green: 2, blue: 3)])
    #expect(palette.color(at: 1) == RGBColor(red: 1, green: 2, blue: 3))
    #expect(palette.color(at: 2) == nil)
}

@Test func aPaletteLongerThanItsDataIsAnError() {
    #expect(throws: IFFChunkError.self) {
        try PALT(record: record("PALT") { w in
            w.uint32(1)
            w.uint32(0xFFFF_FFFF)
            w.raw([UInt8](repeating: 0, count: 8))
            w.raw([1, 2, 3])
        })
    }
}

@Test func aUniformPaletteHasAllTwoHundredFiftySixColors() {
    let palette = PALT(uniform: .black)
    #expect(palette.colors.count == 256)
    #expect(Set(palette.colors) == [.black])
}

// MARK: DGRP

/// One image with one sprite, in the layout of `version`.
private func drawGroup(version: UInt16, direction: UInt32 = 0x10, zoom: UInt32 = 3) -> IFFChunkRecord {
    record("DGRP") { w in
        w.uint16(version)
        if version < 20003 {
            w.uint16(1)
            w.uint16(1)
            w.uint8(UInt8(direction))
            w.uint8(UInt8(zoom))
            w.uint16(0xBEEF) // Ignored type.
            w.uint16(200)
            w.uint16(3)
            w.uint16(0x5)
            w.int16(-12)
            w.int16(40)
            if version == 20001 { w.uint32(Float(1.5).bitPattern) }
        } else {
            w.uint32(1)
            w.uint32(direction)
            w.uint32(zoom)
            w.uint32(1)
            w.uint32(200)
            w.uint32(3)
            w.int32(-12)
            w.int32(40)
            w.uint32(Float(1.5).bitPattern)
            w.uint32(0x5)
            if version == 20004 {
                w.uint32(Float(0.25).bitPattern)
                w.uint32(Float(-0.5).bitPattern)
            }
        }
    }
}

@Test(arguments: [UInt16(20000), 20001, 20002, 20003, 20004])
func drawGroupsReadEveryVersion(version: UInt16) throws {
    let group = try DGRP(record: drawGroup(version: version))
    #expect(group.version == version)
    let image = try #require(group.images.first)
    #expect(image.direction == 0x10 && image.zoom == 3)
    let sprite = try #require(image.sprites.first)
    #expect(sprite.spriteID == 200 && sprite.frameIndex == 3)
    #expect(sprite.flags == [.flip, .luminous])
    #expect(sprite.spriteOffset == SIMD2(-12, 40))
    let z: Float = version == 20000 || version == 20002 ? 0 : 1.5
    let xy: SIMD2<Float> = version == 20004 ? SIMD2(0.25, -0.5) : SIMD2(0, 0)
    #expect(sprite.objectOffset == SIMD3(xy.x, xy.y, z))
}

@Test func laterDrawGroupVersionsReadAs20003() throws {
    // FreeSO reads any version from 20003 up with 20003's layout.
    var bytes = drawGroup(version: 20003)
    bytes.data.replaceSubrange(0..<2, with: [0x26, 0x4E]) // 20006
    let group = try DGRP(record: bytes)
    #expect(group.version == 20006)
    #expect(group.images.first?.sprites.first?.objectOffset == SIMD3(0, 0, 1.5))
}

@Test(arguments: [
    // Direction, world rotation, the direction FreeSO looks for.
    (UInt32(0x10), UInt32(0), UInt32(0x10)),
    (0x10, 1, 0x40),
    (0x10, 2, 0x01),
    (0x10, 3, 0x04),
    (0x40, 1, 0x01),
    (0x01, 3, 0x40),
])
func imagesAreFoundByRotatedDirection(direction: UInt32, rotation: UInt32, stored: UInt32) throws {
    let group = try DGRP(record: drawGroup(version: 20004, direction: stored))
    #expect(group.image(direction: direction, zoom: 3, worldRotation: rotation) != nil)
    #expect(group.image(direction: direction, zoom: 2, worldRotation: rotation) == nil)
}

@Test(arguments: [20002, 20004] as [UInt16])
func drawGroupCountsBeyondTheirDataAreErrors(version: UInt16) {
    #expect(throws: IFFChunkError.self) {
        try DGRP(record: record("DGRP") { w in
            w.uint16(version)
            if version < 20003 { w.uint16(0xFFFF) } else { w.uint32(0xFFFF_FFFF) }
        })
    }
    #expect(throws: IFFChunkError.self) {
        var truncated = drawGroup(version: version)
        truncated.data.removeLast(3)
        return try DGRP(record: truncated)
    }
}

// MARK: SPR2

/// Builds an `SPR2` frame's run-length data.
private struct SpriteRows {
    var writer = ByteWriter()

    /// A row of pixel runs; `runs` holds each run's command, count, and data bytes.
    mutating func row(_ runs: [(UInt16, Int, [UInt8])]) {
        var body = ByteWriter()
        for (command, count, data) in runs {
            body.uint16(command << 13 | UInt16(count))
            body.raw(data)
        }
        writer.uint16(UInt16(body.bytes.count + 2))
        writer.raw(body.bytes)
    }

    mutating func transparentRows(_ count: Int) { writer.uint16(4 << 13 | UInt16(count)) }
    mutating func end() { writer.uint16(5 << 13) }
}

/// A version 1001 `SPR2` with one frame.
private func sprite(width: UInt16, height: UInt16, flags: UInt32, palette: UInt16 = 7, transparent: UInt16 = 0,
                    defaultPalette: UInt32 = 9, rows: SpriteRows) -> IFFChunkRecord {
    record("SPR2") { w in
        w.uint32(1001)
        w.uint32(defaultPalette)
        w.uint32(1)
        var frame = ByteWriter()
        frame.uint16(width)
        frame.uint16(height)
        frame.uint32(flags)
        frame.uint16(palette)
        frame.uint16(transparent)
        frame.int16(-5) // y
        frame.int16(3) // x
        frame.raw(rows.writer.bytes)
        w.uint32(1001)
        w.uint32(UInt32(frame.bytes.count))
        w.raw(frame.bytes)
    }
}

/// A palette where index i is (i, 2i, 3i), wrapping.
private func rampPalette() throws -> PALT {
    try PALT(record: record("PALT") { w in
    w.uint32(1)
    w.uint32(256)
    w.raw([UInt8](repeating: 0, count: 8))
    for i in 0..<256 { w.raw([UInt8(i), UInt8(truncatingIfNeeded: i * 2), UInt8(truncatingIfNeeded: i * 3)]) }
    })
}

private func pixel(_ image: SpriteImage, _ x: Int, _ y: Int) -> [UInt8] {
    let at = (y * image.width + x) * 4
    return Array(image.rgba?[at..<at + 4] ?? [])
}

@Test func spritesDecodeColorAndDepthRuns() throws {
    var rows = SpriteRows()
    // Row 0: two pixels with depth, a transparent pixel, and the last left for the row's end.
    rows.row([(1, 2, [10, 4, 20, 5]), (3, 1, [])])
    rows.transparentRows(1)
    // Row 2: one palette-only pixel, padded.
    rows.row([(6, 1, [6, 0])])
    rows.end()
    let chunk = try SPR2(record: sprite(width: 4, height: 4, flags: 0x3, transparent: 1, rows: rows))
    let image = try chunk.decode(frameAt: 0, palette: try rampPalette())
    #expect(image.position == SIMD2(3, -5))
    #expect(pixel(image, 0, 0) == [4, 8, 12, 255])
    #expect(pixel(image, 1, 0) == [5, 10, 15, 255])
    // A transparent pixel keeps its palette color with alpha 0.
    #expect(pixel(image, 2, 0) == [1, 2, 3, 0])
    // The row's unwritten end keeps its color (none) and gets the far depth.
    #expect(pixel(image, 3, 0) == [0, 0, 0, 0])
    #expect(image.depth?[0...3] == [10, 20, 255, 255])
    #expect(pixel(image, 0, 1) == [1, 2, 3, 0])
    #expect(image.depth?[4] == 255)
    // A palette-only run has depth 0.
    #expect(pixel(image, 0, 2) == [6, 12, 18, 255])
    #expect(image.depth?[8] == 0)
    // A row the data never reaches is transparent black at depth 0.
    #expect(pixel(image, 0, 3) == [0, 0, 0, 0])
    #expect(image.depth?[12] == 0)
    #expect(image.paletteIndices?[0...2] == [4, 5, 1])
}

@Test func alphaRunsScaleFiveBitsAndPad() throws {
    var rows = SpriteRows()
    // One pixel with alpha: three bytes, then a padding byte.
    rows.row([(2, 1, [7, 2, 31, 0xEE]), (2, 1, [8, 3, 1, 0xEE])])
    rows.end()
    let chunk = try SPR2(record: sprite(width: 2, height: 1, flags: 0x7, rows: rows))
    let image = try chunk.decode(frameAt: 0, palette: try rampPalette())
    #expect(pixel(image, 0, 0) == [2, 4, 6, 255]) // 31 × 8.2258… = 255
    #expect(pixel(image, 1, 0) == [3, 6, 9, 8]) // 1 × 8.2258… truncates to 8
    #expect(image.depth == [7, 8])
}

@Test func alphaPastFiveBitsSaturates() throws {
    // 40 × 8.2258… is 329: FreeSO's byte cast wraps it to 73; NewSO keeps it at 255 (DIFF-27).
    var rows = SpriteRows()
    rows.row([(2, 1, [7, 2, 40, 0xEE])])
    rows.end()
    let image = try SPR2(record: sprite(width: 1, height: 1, flags: 0x7, rows: rows)).decode(frameAt: 0, palette: try rampPalette())
    #expect(pixel(image, 0, 0) == [2, 4, 6, 255])
}

@Test(arguments: [(UInt16(0), UInt16(9)), (0xA3A3, 9), (12, 12)])
func framesFallBackToTheDefaultPalette(own: UInt16, used: UInt16) throws {
    var rows = SpriteRows()
    rows.end()
    let chunk = try SPR2(record: sprite(width: 1, height: 1, flags: 0x1, palette: own, rows: rows))
    #expect(chunk.frames.first?.paletteID == used)
}

@Test func version1000FramesUseAnOffsetTableAndTheDefaultPalette() throws {
    var rows = SpriteRows()
    rows.row([(6, 2, [1, 2])])
    rows.end()
    let chunk = try SPR2(record: record("SPR2") { w in
        w.uint32(1000)
        w.uint32(2)
        w.uint32(30) // default palette
        let start = 4 + 4 + 4 + 8
        var frame = ByteWriter()
        frame.uint16(2); frame.uint16(1); frame.uint32(0x1); frame.uint16(12); frame.uint16(0)
        frame.int16(0); frame.int16(0)
        frame.raw(rows.writer.bytes)
        w.uint32(UInt32(start))
        w.uint32(UInt32(start + frame.bytes.count))
        w.raw(frame.bytes)
        w.raw(frame.bytes)
    })
    #expect(chunk.frames.count == 2)
    #expect(chunk.frames.allSatisfy { $0.paletteID == 30 })
    let image = try chunk.decode(frameAt: 1, palette: try rampPalette())
    #expect(pixel(image, 1, 0) == [2, 4, 6, 255])
}

@Test func aMissingPaletteIsTransparentBlack() throws {
    var rows = SpriteRows()
    rows.row([(6, 1, [200, 0])])
    rows.end()
    let image = try SPR2(record: sprite(width: 1, height: 1, flags: 0x1, rows: rows)).decode(frameAt: 0, palette: nil)
    #expect(pixel(image, 0, 0) == [0, 0, 0, 0])
}

@Test func emptyTransparentRowsCostNothing() throws {
    var rows = SpriteRows()
    // 8,191 rows of nothing on a frame with no layers: nothing to write, so nothing to loop over.
    rows.transparentRows(8191)
    rows.end()
    let image = try SPR2(record: sprite(width: 0xFFFF, height: 1, flags: 0, rows: rows)).decode(frameAt: 0, palette: nil)
    #expect(image.rgba == nil && image.depth == nil)
}

@Test func unknownSpriteVersionsHaveNoFrames() throws {
    let chunk = try SPR2(record: record("SPR2") { w in w.uint32(999) })
    #expect(chunk.frames.isEmpty)
}

typealias SpriteRun = (UInt16, Int, [UInt8])

@Test(arguments: [
    // A run past the frame's end.
    (UInt32(0x3), [(UInt16(1), 3, [UInt8](repeating: 1, count: 6))], SpriteError.pixelOutOfBounds(row: 0, column: 2)),
    // Depth runs in a frame without depth, which FreeSO crashes on.
    (0x1, [(1, 1, [1, 1])], .missingLayer("depth")),
    // A run cut short.
    (0x3, [(1, 2, [1, 1, 1])], .truncated),
] as [(UInt32, [SpriteRun], SpriteError)])
func badRunsAreErrors(flags: UInt32, runs: [SpriteRun], expected: SpriteError) throws {
    var rows = SpriteRows()
    rows.row(runs)
    rows.end()
    let chunk = try SPR2(record: sprite(width: 2, height: 1, flags: flags, rows: rows))
    #expect(throws: expected) { try chunk.decode(frameAt: 0, palette: try rampPalette()) }
}

@Test func paletteIndicesPastThePalettesEndAreErrors() throws {
    let short = try PALT(record: record("PALT") { w in
        w.uint32(1); w.uint32(2); w.raw([UInt8](repeating: 0, count: 8)); w.raw([1, 1, 1, 2, 2, 2])
    })
    var rows = SpriteRows()
    rows.row([(6, 1, [9, 0])])
    rows.end()
    let chunk = try SPR2(record: sprite(width: 1, height: 1, flags: 0x1, rows: rows))
    #expect(throws: SpriteError.paletteIndexOutOfRange(9)) { try chunk.decode(frameAt: 0, palette: short) }
    #expect(throws: SpriteError.noSuchFrame(1)) { try chunk.decode(frameAt: 1, palette: short) }
}

// MARK: SPR#

/// A `SPR#` frame's header and run-length data: a 3×3 frame whose rows are a skip then a fill,
/// two skipped rows, and nothing past them.
private func olderFrame(bigEndian: Bool = false) -> [UInt8] {
    var w = ByteWriter()
    w.uint32(0) // Reserved.
    if bigEndian { w.raw([0, 3, 0, 3]) } else { w.uint16(3); w.uint16(3) } // height, width
    // Row 0: one transparent pixel, then two pixels of palette color 5.
    w.raw([0x04, 8, 0x01, 1, 0x02, 2, 5, 0])
    // Rows 1 and 2 skipped.
    w.raw([0x09, 2])
    w.raw([0x05, 0])
    return Array(w.bytes)
}

@Test func olderSpritesReadLittleEndianOffsetTables() throws {
    let frame = olderFrame()
    let chunk = try SPR(record: record("SPR#") { w in
        w.uint16(505); w.uint16(0)
        w.uint32(1)
        w.uint32(0x0001_0007) // Palette 7 in the low 16 bits.
        w.uint32(16)
        w.raw(frame)
    })
    #expect(chunk.version == 505 && chunk.byteOrder == .littleEndian && chunk.paletteID == 7)
    let image = try chunk.decode(frameAt: 0, palette: try rampPalette())
    #expect(image.width == 3 && image.height == 3 && image.depth == nil)
    #expect(pixel(image, 0, 0) == [0, 0, 0, 0])
    #expect(pixel(image, 1, 0) == [5, 10, 15, 255])
    #expect(pixel(image, 2, 0) == [5, 10, 15, 255])
    #expect(pixel(image, 0, 1) == [0, 0, 0, 0])
}

@Test func olderSpritesVersion1001ReadSizedFramesUntilTheEnd() throws {
    let frame = olderFrame()
    let chunk = try SPR(record: record("SPR#") { w in
        w.uint16(1001); w.uint16(0)
        w.uint32(99) // Ignored: frames run to the end.
        w.uint32(7)
        for _ in 0..<2 {
            w.uint32(1001)
            w.uint32(UInt32(frame.count))
            w.raw(frame)
        }
    })
    #expect(chunk.frames.count == 2)
}

@Test func bigEndianOlderSpritesReadTheirVersionCorrectly() throws {
    // Version 1001, big-endian: sized frames. FreeSO's swap reads it as 1023 instead (DIFF-26).
    let frame = olderFrame(bigEndian: true)
    let chunk = try SPR(record: record("SPR#") { w in
        w.raw([0, 0, 0x03, 0xE9])
        w.raw([0, 0, 0, 1]) // one frame
        w.raw([0, 0, 0, 7]) // palette 7
        w.raw([0, 0, 0x03, 0xE9]) // the frame's version
        w.raw([0, 0, 0, UInt8(frame.count)]) // its size
        w.raw(frame)
    })
    #expect(chunk.byteOrder == .bigEndian && chunk.version == 1001)
    #expect(chunk.paletteID == 7)
    #expect(chunk.frames.first.map { ($0.width, $0.height) } ?? (0, 0) == (3, 3))
    let image = try chunk.decode(frameAt: 0, palette: try rampPalette())
    #expect(pixel(image, 1, 0) == [5, 10, 15, 255])
}

@Test func olderSpritesWithoutAPaletteAreOpaqueBlack() throws {
    let chunk = try SPR(record: record("SPR#") { w in
        w.uint16(505); w.uint16(0); w.uint32(1); w.uint32(7); w.uint32(16)
        w.raw(olderFrame())
    })
    let image = try chunk.decode(frameAt: 0, palette: nil)
    #expect(pixel(image, 1, 0) == [0, 0, 0, 255])
    #expect(pixel(image, 0, 0) == [0, 0, 0, 0])
}

@Test func olderSpritesWithoutAnEndAreErrors() throws {
    var frame = olderFrame()
    frame.removeLast(2)
    let chunk = try SPR(record: record("SPR#") { w in
        w.uint16(505); w.uint16(0); w.uint32(1); w.uint32(7); w.uint32(16)
        w.raw(frame)
    })
    #expect(throws: SpriteError.truncated) { try chunk.decode(frameAt: 0, palette: nil) }
}

@Test func olderSpriteRunsPastTheFrameAreErrors() throws {
    var w = ByteWriter()
    w.uint32(0); w.uint16(1); w.uint16(1)
    w.raw([0x04, 6, 0x02, 2, 5, 0, 0x05, 0]) // Two pixels in a one-pixel frame.
    let frame = w.bytes
    let chunk = try SPR(record: record("SPR#") { w in
        w.uint16(505); w.uint16(0); w.uint32(1); w.uint32(7); w.uint32(16)
        w.raw(frame)
    })
    #expect(throws: SpriteError.pixelOutOfBounds(row: 0, column: 1)) { try chunk.decode(frameAt: 0, palette: try rampPalette()) }
}
