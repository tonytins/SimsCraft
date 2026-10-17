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

private func append(_ value: UInt32, to bytes: inout [UInt8]) {
    bytes.append(UInt8(truncatingIfNeeded: value))
    bytes.append(UInt8(truncatingIfNeeded: value >> 8))
    bytes.append(UInt8(truncatingIfNeeded: value >> 16))
    bytes.append(UInt8(truncatingIfNeeded: value >> 24))
}
