import Foundation
import Testing
import TSOFiles
@testable import TSOContent

/// A FAR3 archive of uncompressed files, as TSOFiles' tests build one.
private func makeFAR3(_ files: [(name: String, id: AssetID, contents: Data)]) -> Data {
    var writer = ByteWriter()
    writer.ascii("FAR!byAZ")
    writer.uint32(3)
    writer.uint32(0)
    var offsets: [Int] = []
    for file in files {
        offsets.append(writer.count)
        writer.raw(file.contents)
    }
    writer.patchUInt32(UInt32(writer.count), at: 12)
    writer.uint32(UInt32(files.count))
    for (file, offset) in zip(files, offsets) {
        writer.uint32(UInt32(file.contents.count))
        writer.uint24(UInt32(file.contents.count))
        writer.uint8(0)
        writer.uint32(UInt32(offset))
        writer.uint8(0)
        writer.uint8(0)
        writer.uint16(UInt16(file.name.utf8.count))
        writer.uint32(file.id.typeID)
        writer.uint32(file.id.fileID)
        writer.ascii(file.name)
    }
    return writer.bytes
}

/// A 2 by 1, 24-bit BMP: magenta, then near-magenta that FreeSO also masks.
private func magentaBMP(_ second: [UInt8] = [0xFE, 0x02, 0xFE]) -> Data {
    var writer = ByteWriter()
    writer.ascii("BM")
    writer.uint32(54 + 8)
    writer.uint32(0)
    writer.uint32(54)
    writer.uint32(40)
    writer.uint32(2)
    writer.uint32(1)
    writer.uint16(1)
    writer.uint16(24)
    writer.raw([UInt8](repeating: 0, count: 24))
    writer.raw([0xFF, 0x00, 0xFF] + [second[2], second[1], second[0]] + [0, 0])
    return writer.bytes
}

@Suite struct UIGraphicsProviderTests {
    @Test func findsGraphicsByIDAcrossArchivesTheFirstKeepingARepeatedOne() throws {
        let install = try FakeInstall()
        let setup = AssetID(packed: 0x3A3_0000_0001)
        try install.write(makeFAR3([("setup.bmp", setup, Data("first".utf8))]), to: "uigraphics/a/a.dat")
        try install.write(makeFAR3([("setup.bmp", setup, Data("second".utf8)),
                                    ("other.bmp", AssetID(fileID: 7, typeID: 1), Data("other".utf8))]), to: "uigraphics/b/b.DAT")
        try install.write(Data("not a FAR3".utf8), to: "uigraphics/broken.dat")
        try install.write(Data("loose".utf8), to: "uigraphics/hints/hint_mechanicskill.bmp")
        let graphics = UIGraphicsProvider(files: try GameFileIndex(root: install.root))
        #expect(try graphics.data(id: setup) == Data("first".utf8))
        #expect(graphics.duplicates == [setup])
        #expect(graphics.failures.map(\.path) == ["uigraphics/broken.dat"])
        #expect(graphics.ids == [AssetID(fileID: 7, typeID: 1), setup])
        // One of FreeSO's loose files, and an ID with no graphic.
        #expect(try graphics.data(id: AssetID(packed: 0x0000_CBFB_0000_0001)) == Data("loose".utf8))
        #expect(try graphics.data(id: AssetID(fileID: 99, typeID: 1)) == nil)
    }

    @Test func theRacksPanelGraphicIsFoundUnderItsOtherID() throws {
        let install = try FakeInstall()
        try install.write(makeFAR3([("rack.bmp", AssetID(packed: 0x0000_0946_0000_0001), Data("rack".utf8))]), to: "uigraphics/eods.dat")
        let graphics = UIGraphicsProvider(files: try GameFileIndex(root: install.root))
        #expect(try graphics.data(id: AssetID(packed: 0x0000_0288_0000_0001)) == Data("rack".utf8))
    }

    @Test func bitmapsLoseTheirMagentaAndOtherFormatsAreReported() throws {
        let install = try FakeInstall()
        let bitmap = AssetID(fileID: 1, typeID: 1), almost = AssetID(fileID: 2, typeID: 1), png = AssetID(fileID: 3, typeID: 24)
        try install.write(makeFAR3([("m.bmp", bitmap, magentaBMP()), ("n.bmp", almost, magentaBMP([0xF0, 0x02, 0xFE])),
                                    ("p.png", png, Data([0x89, 0x50, 0x4E, 0x47, 0, 0]))]), to: "uigraphics/ui.dat")
        let graphics = UIGraphicsProvider(files: try GameFileIndex(root: install.root))
        let image = try #require(try graphics.image(id: bitmap))
        #expect(image.rgba == [0, 0, 0, 0, 0, 0, 0, 0])
        // Red 240 is past FreeSO's range, so the second pixel stays.
        #expect(try graphics.image(id: almost)?.rgba.suffix(4) == [0xF0, 0x02, 0xFE, 255])
        #expect(throws: ContentError.self) { try graphics.image(id: png) }
    }
}
