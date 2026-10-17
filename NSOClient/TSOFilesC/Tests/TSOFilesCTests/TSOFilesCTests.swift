import Foundation
import Testing
import TSOFilesCBridge

@Suite struct TSOFilesCTests {
    @Test func decompressesRefPackAndReturnsAFreeableBuffer() throws {
        let compressed: [UInt8] = [0x0E, 0x01, 0x61, 0x62, 0xFC, 0x00, 0x00]
        var output: UnsafeMutablePointer<UInt8>?
        var outputSize: Int64 = -1

        let status = compressed.withUnsafeBufferPointer {
            tsofilesCRefPackDecompress($0.baseAddress, Int64($0.count), 8, &output, &outputSize)
        }

        #expect(status == 0)
        #expect(outputSize == 8)
        let bytes = try #require(output)
        defer { tsofilesCBufferFree(bytes) }
        #expect(Data(bytes: bytes, count: Int(outputSize)) == Data("abababab".utf8))
    }

    @Test func mapsRefPackErrorsToCStatuses() {
        let compressed: [UInt8] = [0x0E, 0x05, 0x61, 0x62, 0xFC, 0x00, 0x00]
        var output: UnsafeMutablePointer<UInt8>?
        var outputSize: Int64 = -1

        let status = compressed.withUnsafeBufferPointer {
            tsofilesCRefPackDecompress($0.baseAddress, Int64($0.count), 8, &output, &outputSize)
        }

        #expect(status == 3)
        #expect(output == nil)
        #expect(outputSize == 0)
    }

    @Test func mapsInvalidAndTruncatedRefPackInputs() {
        var output: UnsafeMutablePointer<UInt8>?
        var outputSize: Int64 = -1
        #expect(tsofilesCRefPackDecompress(nil, 1, 8, &output, &outputSize) == 1)
        #expect(output == nil)
        #expect(outputSize == 0)

        let truncated: [UInt8] = [0xE4, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36]
        let status = truncated.withUnsafeBufferPointer {
            tsofilesCRefPackDecompress($0.baseAddress, Int64($0.count), 8, &output, &outputSize)
        }
        #expect(status == 2)
        #expect(output == nil)
        #expect(outputSize == 0)
    }

    @Test func opensAndReadsDBPFEntries() throws {
        let archiveBytes = makeDBPF()
        var handle: UnsafeMutableRawPointer?
        let openStatus = archiveBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(openStatus == 0)
        let archive = try #require(handle)
        defer { tsofilesCDBPFClose(archive) }

        var major: UInt32 = 0
        var minor: UInt32 = 0
        #expect(tsofilesCDBPFVersion(UnsafeRawPointer(archive), &major, &minor) == 0)
        #expect(major == 1)
        #expect(minor == 0)

        var count: Int64 = -1
        #expect(tsofilesCDBPFEntryCount(UnsafeRawPointer(archive), &count) == 0)
        #expect(count == 1)

        var entryIndex: Int64 = -1
        #expect(tsofilesCDBPFFindEntry(UnsafeRawPointer(archive), 12, 0x1D07_EB4B, &entryIndex) == 0)
        #expect(entryIndex == 0)

        var typeID: UInt32 = 0
        var groupID: UInt32 = 0
        var instanceID: UInt32 = 0
        var fileOffset: UInt32 = 0
        var fileSize: UInt32 = 0
        #expect(tsofilesCDBPFEntryAt(UnsafeRawPointer(archive), entryIndex, &typeID, &groupID, &instanceID,
                                     &fileOffset, &fileSize) == 0)
        #expect(typeID == 0x1D07_EB4B)
        #expect(groupID == 0x9DBD_BF89)
        #expect(instanceID == 12)
        #expect(fileOffset == 48)
        #expect(fileSize == 3)

        var contents: UnsafeMutablePointer<UInt8>?
        var contentsSize: Int64 = -1
        #expect(tsofilesCDBPFEntryData(UnsafeRawPointer(archive), entryIndex, &contents, &contentsSize) == 0)
        let data = try #require(contents)
        defer { tsofilesCBufferFree(data) }
        #expect(contentsSize == 3)
        #expect(Data(bytes: data, count: Int(contentsSize)) == Data("SFX".utf8))
    }

    @Test func reportsBadArchivesAndEntryIndexes() throws {
        let badBytes: [UInt8] = Array("NOPE".utf8)
        var handle: UnsafeMutableRawPointer?
        let openStatus = badBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(openStatus == 4)
        #expect(handle == nil)

        let archiveBytes = makeDBPF()
        let validOpenStatus = archiveBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(validOpenStatus == 0)
        let archive = try #require(handle)
        defer { tsofilesCDBPFClose(archive) }

        var typeID: UInt32 = 0
        var groupID: UInt32 = 0
        var instanceID: UInt32 = 0
        var fileOffset: UInt32 = 0
        var fileSize: UInt32 = 0
        #expect(tsofilesCDBPFEntryAt(UnsafeRawPointer(archive), -1, &typeID, &groupID, &instanceID,
                                     &fileOffset, &fileSize) == 8)
    }

    @Test func reportsTruncatedArchivesMissingEntriesAndOutOfBoundsData() throws {
        let truncatedBytes: [UInt8] = Array("DBPF".utf8)
        var handle: UnsafeMutableRawPointer?
        let truncatedStatus = truncatedBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(truncatedStatus == 5)
        #expect(handle == nil)

        let validBytes = makeDBPF()
        let openStatus = validBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(openStatus == 0)
        let archive = try #require(handle)
        defer { tsofilesCDBPFClose(archive) }

        var index: Int64 = -1
        #expect(tsofilesCDBPFFindEntry(UnsafeRawPointer(archive), 99, 0x1D07_EB4B, &index) == 7)

        let outOfBoundsBytes = makeDBPF(entryOffset: 500)
        var invalidHandle: UnsafeMutableRawPointer?
        let invalidOpenStatus = outOfBoundsBytes.withUnsafeBufferPointer {
            tsofilesCDBPFOpen($0.baseAddress, Int64($0.count), &invalidHandle)
        }
        #expect(invalidOpenStatus == 0)
        let invalidArchive = try #require(invalidHandle)
        defer { tsofilesCDBPFClose(invalidArchive) }

        var data: UnsafeMutablePointer<UInt8>?
        var dataSize: Int64 = -1
        #expect(tsofilesCDBPFEntryData(UnsafeRawPointer(invalidArchive), 0, &data, &dataSize) == 6)
        #expect(data == nil)
        #expect(dataSize == 0)
    }

    @Test(arguments: [Int32(0), 1])
    func opensFAR1VariantsAndReadsNamesAndData(variant: Int32) throws {
        let archiveBytes = makeFAR1(variant: variant)
        var handle: UnsafeMutableRawPointer?
        let openStatus = archiveBytes.withUnsafeBufferPointer {
            tsofilesCFAR1Open($0.baseAddress, Int64($0.count), variant, &handle)
        }
        #expect(openStatus == 0)
        let archive = try #require(handle)
        defer { tsofilesCFAR1Close(archive) }

        var count: Int64 = -1
        #expect(tsofilesCFAR1EntryCount(UnsafeRawPointer(archive), &count) == 0)
        #expect(count == 1)

        var index: Int64 = -1
        let searchName = Array("chair.iff".utf8)
        let findStatus = searchName.withUnsafeBufferPointer {
            tsofilesCFAR1FindEntry(UnsafeRawPointer(archive), $0.baseAddress, Int64($0.count), &index)
        }
        #expect(findStatus == 0)
        #expect(index == 0)

        var dataLength: Int64 = -1
        var compressedLength: Int64 = -1
        var dataOffset: Int64 = -1
        #expect(tsofilesCFAR1EntryAt(UnsafeRawPointer(archive), index, &dataLength,
                                     &compressedLength, &dataOffset) == 0)
        #expect(dataLength == 5)
        #expect(compressedLength == 5)
        #expect(dataOffset == 16)

        var name: UnsafeMutablePointer<UInt8>?
        var nameSize: Int64 = -1
        #expect(tsofilesCFAR1EntryName(UnsafeRawPointer(archive), index, &name, &nameSize) == 0)
        let nameBytes = try #require(name)
        defer { tsofilesCBufferFree(nameBytes) }
        #expect(Data(bytes: nameBytes, count: Int(nameSize)) == Data("chair.iff".utf8))

        var data: UnsafeMutablePointer<UInt8>?
        var dataSize: Int64 = -1
        #expect(tsofilesCFAR1EntryData(UnsafeRawPointer(archive), index, &data, &dataSize) == 0)
        let contents = try #require(data)
        defer { tsofilesCBufferFree(contents) }
        #expect(Data(bytes: contents, count: Int(dataSize)) == Data("CHAIR".utf8))
    }

    @Test func opensFAR3AndReadsRawAndRefPackEntries() throws {
        let stream = Data([0x0E, 0x01, 0x61, 0x62, 0xFC, 0x00, 0x00])
        let compressed = makeFAR3Compressed(stream: stream)
        var handle: UnsafeMutableRawPointer?
        let openStatus = compressed.withUnsafeBufferPointer {
            tsofilesCFAR3Open($0.baseAddress, Int64($0.count), &handle)
        }
        #expect(openStatus == 0)
        let archive = try #require(handle)
        defer { tsofilesCFAR3Close(archive) }

        var count: Int64 = -1
        #expect(tsofilesCFAR3EntryCount(UnsafeRawPointer(archive), &count) == 0)
        #expect(count == 2)

        var rawIndex: Int64 = -1
        let rawName = Array("raw.bin".utf8)
        let findRawStatus = rawName.withUnsafeBufferPointer {
            tsofilesCFAR3FindEntryByName(UnsafeRawPointer(archive), $0.baseAddress, Int64($0.count), &rawIndex)
        }
        #expect(findRawStatus == 0)
        #expect(rawIndex == 0)

        var returnedName: UnsafeMutablePointer<UInt8>?
        var returnedNameSize: Int64 = -1
        #expect(tsofilesCFAR3EntryName(UnsafeRawPointer(archive), rawIndex, &returnedName, &returnedNameSize) == 0)
        let returnedNameBytes = try #require(returnedName)
        defer { tsofilesCBufferFree(returnedNameBytes) }
        #expect(Data(bytes: returnedNameBytes, count: Int(returnedNameSize)) == Data("raw.bin".utf8))

        var fileID: UInt32 = 0
        var typeID: UInt32 = 0
        var decompressedSize: UInt32 = 0
        var compressedSize: UInt32 = 0
        var dataType: UInt8 = 0
        var dataOffset: UInt32 = 0
        var compressionFlag: UInt8 = 0
        var accessCount: UInt8 = 0
        #expect(tsofilesCFAR3EntryAt(UnsafeRawPointer(archive), rawIndex, &fileID, &typeID,
                                     &decompressedSize, &compressedSize, &dataType, &dataOffset,
                                     &compressionFlag, &accessCount) == 0)
        #expect(fileID == 7)
        #expect(typeID == 2)
        #expect(decompressedSize == 3)
        #expect(compressedSize == 3)
        #expect(dataOffset == 16)
        #expect(compressionFlag == 0)

        var compressedIndex: Int64 = -1
        #expect(tsofilesCFAR3FindEntryByAssetID(UnsafeRawPointer(archive), 8, 3, &compressedIndex) == 0)
        #expect(compressedIndex == 1)
        var data: UnsafeMutablePointer<UInt8>?
        var dataSize: Int64 = -1
        #expect(tsofilesCFAR3EntryData(UnsafeRawPointer(archive), compressedIndex, &data, &dataSize) == 0)
        let contents = try #require(data)
        defer { tsofilesCBufferFree(contents) }
        #expect(Data(bytes: contents, count: Int(dataSize)) == Data("abababab".utf8))
    }

    @Test func reportsFAR1AndFAR3Errors() throws {
        let wrongVariantBytes = makeFAR1(variant: 1)
        var far1: UnsafeMutableRawPointer?
        let invalidVariantStatus = wrongVariantBytes.withUnsafeBufferPointer {
            tsofilesCFAR1Open($0.baseAddress, Int64($0.count), 2, &far1)
        }
        #expect(invalidVariantStatus == 1)
        #expect(far1 == nil)

        var notArchive = Array("NOPE".utf8)
        append(0, to: &notArchive)
        append(0, to: &notArchive)
        append(0, to: &notArchive)
        let notFar1Status = notArchive.withUnsafeBufferPointer {
            tsofilesCFAR1Open($0.baseAddress, Int64($0.count), 1, &far1)
        }
        #expect(notFar1Status == 9)
        #expect(far1 == nil)
        let notFar3Status = notArchive.withUnsafeBufferPointer {
            tsofilesCFAR3Open($0.baseAddress, Int64($0.count), &far1)
        }
        #expect(notFar3Status == 11)
        #expect(far1 == nil)

        let truncated = Array("FAR!byAZ".utf8)
        let truncatedFar1Status = truncated.withUnsafeBufferPointer {
            tsofilesCFAR1Open($0.baseAddress, Int64($0.count), 1, &far1)
        }
        #expect(truncatedFar1Status == 10)
        let truncatedFar3Status = truncated.withUnsafeBufferPointer {
            tsofilesCFAR3Open($0.baseAddress, Int64($0.count), &far1)
        }
        #expect(truncatedFar3Status == 12)

        let validFar3 = makeFAR3Raw()
        let openStatus = validFar3.withUnsafeBufferPointer {
            tsofilesCFAR3Open($0.baseAddress, Int64($0.count), &far1)
        }
        #expect(openStatus == 0)
        let archive = try #require(far1)
        defer { tsofilesCFAR3Close(archive) }

        var missingIndex: Int64 = -1
        #expect(tsofilesCFAR3FindEntryByAssetID(UnsafeRawPointer(archive), 900, 2, &missingIndex) == 7)
        var outOfRangeData: UnsafeMutablePointer<UInt8>?
        var outOfRangeSize: Int64 = -1
        #expect(tsofilesCFAR3EntryData(UnsafeRawPointer(archive), -1, &outOfRangeData, &outOfRangeSize) == 8)
        #expect(outOfRangeData == nil)
        #expect(outOfRangeSize == 0)

        var outOfBoundsFAR1Bytes = makeFAR1(variant: 1)
        outOfBoundsFAR1Bytes[33] = 0xE8
        outOfBoundsFAR1Bytes[34] = 0x03
        outOfBoundsFAR1Bytes[35] = 0
        outOfBoundsFAR1Bytes[36] = 0
        var outOfBoundsFAR1: UnsafeMutableRawPointer?
        let outOfBoundsOpenStatus = outOfBoundsFAR1Bytes.withUnsafeBufferPointer {
            tsofilesCFAR1Open($0.baseAddress, Int64($0.count), 1, &outOfBoundsFAR1)
        }
        #expect(outOfBoundsOpenStatus == 0)
        let outOfBoundsArchive = try #require(outOfBoundsFAR1)
        defer { tsofilesCFAR1Close(outOfBoundsArchive) }
        var data: UnsafeMutablePointer<UInt8>?
        var dataSize: Int64 = -1
        #expect(tsofilesCFAR1EntryData(UnsafeRawPointer(outOfBoundsArchive), 0, &data, &dataSize) == 6)
        #expect(data == nil)
        #expect(dataSize == 0)

        let badRefPack = makeFAR3Compressed(stream: Data([0x0E, 0x05, 0x61, 0x62, 0xFC, 0, 0]))
        var badFAR3: UnsafeMutableRawPointer?
        let badOpenStatus = badRefPack.withUnsafeBufferPointer {
            tsofilesCFAR3Open($0.baseAddress, Int64($0.count), &badFAR3)
        }
        #expect(badOpenStatus == 0)
        let badArchive = try #require(badFAR3)
        defer { tsofilesCFAR3Close(badArchive) }
        var badData: UnsafeMutablePointer<UInt8>?
        var badDataSize: Int64 = -1
        #expect(tsofilesCFAR3EntryData(UnsafeRawPointer(badArchive), 1, &badData, &badDataSize) == 13)
        #expect(badData == nil)
        #expect(badDataSize == 0)
    }
}

private func makeDBPF(entryOffset: UInt32 = 48) -> [UInt8] {
    var bytes = Array("DBPF".utf8)
    append(1, to: &bytes)
    append(0, to: &bytes)
    bytes.append(contentsOf: repeatElement(0, count: 12))
    append(1_000, to: &bytes)
    append(2_000, to: &bytes)
    append(7, to: &bytes)
    append(1, to: &bytes)
    append(51, to: &bytes)
    append(20, to: &bytes)
    bytes.append(contentsOf: "SFX".utf8)
    append(0x1D07_EB4B, to: &bytes)
    append(0x9DBD_BF89, to: &bytes)
    append(12, to: &bytes)
    append(entryOffset, to: &bytes)
    append(3, to: &bytes)
    return bytes
}

private func makeFAR1(variant: Int32) -> [UInt8] {
    var bytes = Array("FAR!byAZ".utf8)
    append(1, to: &bytes)
    append(21, to: &bytes)
    bytes.append(contentsOf: "CHAIR".utf8)
    append(1, to: &bytes)
    append(5, to: &bytes)
    append(5, to: &bytes)
    append(16, to: &bytes)
    if variant == 0 {
        append(9, to: &bytes)
    } else {
        bytes.append(9)
        bytes.append(0)
    }
    bytes.append(contentsOf: "chair.iff".utf8)
    return bytes
}

private func makeFAR3Raw() -> [UInt8] {
    var bytes = Array("FAR!byAZ".utf8)
    append(3, to: &bytes)
    append(19, to: &bytes)
    bytes.append(contentsOf: "RAW".utf8)
    append(1, to: &bytes)
    append(3, to: &bytes)
    append24LittleEndian(3, to: &bytes)
    bytes.append(0)
    append(16, to: &bytes)
    bytes.append(contentsOf: [0, 0])
    append16(7, to: &bytes)
    append(2, to: &bytes)
    append(7, to: &bytes)
    bytes.append(contentsOf: "raw.bin".utf8)
    return bytes
}

private func makeFAR3Compressed(stream: Data) -> [UInt8] {
    var persist = [UInt8](repeating: 0, count: 9)
    append(UInt32(stream.count), to: &persist)
    persist.append(contentsOf: [0x10, 0xFB, 0, 0, 8])
    persist.append(contentsOf: stream)

    var bytes = Array("FAR!byAZ".utf8)
    append(3, to: &bytes)
    append(UInt32(16 + 3 + persist.count), to: &bytes)
    bytes.append(contentsOf: "RAW".utf8)
    bytes.append(contentsOf: persist)
    append(2, to: &bytes)
    append(3, to: &bytes)
    append24LittleEndian(3, to: &bytes)
    bytes.append(0)
    append(16, to: &bytes)
    bytes.append(contentsOf: [0, 0])
    append16(7, to: &bytes)
    append(2, to: &bytes)
    append(7, to: &bytes)
    bytes.append(contentsOf: "raw.bin".utf8)

    append(8, to: &bytes)
    let storedCount = UInt32(persist.count)
    append24LittleEndian(storedCount, to: &bytes)
    bytes.append(0x80)
    append(19, to: &bytes)
    bytes.append(1)
    bytes.append(0)
    append16(10, to: &bytes)
    append(3, to: &bytes)
    append(8, to: &bytes)
    bytes.append(contentsOf: "compressed".utf8)
    return bytes
}

private func append16(_ value: UInt16, to bytes: inout [UInt8]) {
    bytes.append(UInt8(truncatingIfNeeded: value))
    bytes.append(UInt8(truncatingIfNeeded: value >> 8))
}

private func append24LittleEndian(_ value: UInt32, to bytes: inout [UInt8]) {
    bytes.append(UInt8(truncatingIfNeeded: value))
    bytes.append(UInt8(truncatingIfNeeded: value >> 8))
    bytes.append(UInt8(truncatingIfNeeded: value >> 16))
}

private func append(_ value: UInt32, to bytes: inout [UInt8]) {
    bytes.append(UInt8(truncatingIfNeeded: value))
    bytes.append(UInt8(truncatingIfNeeded: value >> 8))
    bytes.append(UInt8(truncatingIfNeeded: value >> 16))
    bytes.append(UInt8(truncatingIfNeeded: value >> 24))
}
