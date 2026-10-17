import Foundation
import TSOFiles

private final class ArchiveStorage {
    let archive: DBPFArchive

    init(_ archive: DBPFArchive) {
        self.archive = archive
    }
}

private func dataPointer(_ pointer: UnsafePointer<UInt8>?, count: Int64) -> Data? {
    guard count >= 0, count <= Int64(Int.max) else { return nil }
    guard count == 0 else {
        guard let pointer else { return nil }
        return Data(bytes: pointer, count: Int(count))
    }
    return Data()
}

private func allocateBuffer(from data: Data, output: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?,
                            outputSize: UnsafeMutablePointer<Int64>?) -> Int32 {
    guard let output, let outputSize else { return 1 }
    output.pointee = nil
    outputSize.pointee = 0
    guard !data.isEmpty else { return 0 }

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
    let destination = UnsafeMutableBufferPointer(start: buffer, count: data.count)
    _ = data.copyBytes(to: destination)
    output.pointee = buffer
    outputSize.pointee = Int64(data.count)
    return 0
}

private func storage(for handle: UnsafeRawPointer?) -> ArchiveStorage? {
    guard let handle else { return nil }
    return Unmanaged<ArchiveStorage>.fromOpaque(UnsafeMutableRawPointer(mutating: handle)).takeUnretainedValue()
}

/// Decompresses RefPack bytes through `TSOFiles.RefPack`.
///
/// Returns `0` on success. Returned bytes belong to the caller and must be freed
/// with ``tsofiles_c_buffer_free``.
@_cdecl("tsofiles_swift_refpack_decompress")
public func tsofilesCRefPackDecompress(
    _ compressed: UnsafePointer<UInt8>?,
    _ compressedSize: Int64,
    _ decompressedSize: Int64,
    _ output: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?,
    _ outputSize: UnsafeMutablePointer<Int64>?
) -> Int32 {
    guard let output, let outputSize else { return 1 }
    output.pointee = nil
    outputSize.pointee = 0
    guard decompressedSize >= 0, decompressedSize <= Int64(Int.max),
          let input = dataPointer(compressed, count: compressedSize) else { return 1 }

    do {
        let decompressed = try RefPack.decompress(input, decompressedSize: Int(decompressedSize))
        return allocateBuffer(from: decompressed, output: output, outputSize: outputSize)
    } catch {
        switch error {
        case .truncatedInput:
            return 2
        case .invalidBackReference:
            return 3
        }
    }
}

/// Releases a buffer returned by a TSOFiles C API function.
@_cdecl("tsofiles_swift_buffer_free")
public func tsofilesCBufferFree(_ buffer: UnsafeMutablePointer<UInt8>?) {
    buffer?.deallocate()
}

/// Opens a DBPF archive through `TSOFiles.DBPFArchive`.
///
/// Returns `0` on success. The returned handle must be released with
/// ``tsofiles_c_dbpf_close``.
@_cdecl("tsofiles_swift_dbpf_open")
public func tsofilesCDBPFOpen(
    _ bytes: UnsafePointer<UInt8>?,
    _ byteCount: Int64,
    _ archive: UnsafeMutablePointer<UnsafeMutableRawPointer?>?
) -> Int32 {
    guard let archive else { return 1 }
    archive.pointee = nil
    guard let data = dataPointer(bytes, count: byteCount) else { return 1 }

    do {
        let value = try DBPFArchive(bytes: data)
        archive.pointee = Unmanaged.passRetained(ArchiveStorage(value)).toOpaque()
        return 0
    } catch {
        switch error {
        case .notADBPFArchive:
            return 4
        case .truncated:
            return 5
        case .entryOutOfBounds:
            return 6
        }
    }
}

/// Releases a DBPF handle returned by ``tsofiles_c_dbpf_open``.
@_cdecl("tsofiles_swift_dbpf_close")
public func tsofilesCDBPFClose(_ archive: UnsafeMutableRawPointer?) {
    guard let archive else { return }
    Unmanaged<ArchiveStorage>.fromOpaque(archive).release()
}

/// Reads the major and minor DBPF version.
@_cdecl("tsofiles_swift_dbpf_version")
public func tsofilesCDBPFVersion(
    _ archive: UnsafeRawPointer?,
    _ majorVersion: UnsafeMutablePointer<UInt32>?,
    _ minorVersion: UnsafeMutablePointer<UInt32>?
) -> Int32 {
    guard let storage = storage(for: archive), let majorVersion, let minorVersion else { return 1 }
    majorVersion.pointee = storage.archive.majorVersion
    minorVersion.pointee = storage.archive.minorVersion
    return 0
}

/// Reads the number of DBPF entries.
@_cdecl("tsofiles_swift_dbpf_entry_count")
public func tsofilesCDBPFEntryCount(
    _ archive: UnsafeRawPointer?,
    _ count: UnsafeMutablePointer<Int64>?
) -> Int32 {
    guard let storage = storage(for: archive), let count else { return 1 }
    count.pointee = Int64(storage.archive.entries.count)
    return 0
}

/// Reads DBPF entry metadata by its zero-based archive index.
@_cdecl("tsofiles_swift_dbpf_entry_at")
public func tsofilesCDBPFEntryAt(
    _ archive: UnsafeRawPointer?,
    _ index: Int64,
    _ typeID: UnsafeMutablePointer<UInt32>?,
    _ groupID: UnsafeMutablePointer<UInt32>?,
    _ instanceID: UnsafeMutablePointer<UInt32>?,
    _ fileOffset: UnsafeMutablePointer<UInt32>?,
    _ fileSize: UnsafeMutablePointer<UInt32>?
) -> Int32 {
    guard let storage = storage(for: archive), let typeID, let groupID, let instanceID,
          let fileOffset, let fileSize else { return 1 }
    guard let entry = storage.archive.entries[safe: index] else { return 8 }
    typeID.pointee = entry.typeID.rawValue
    groupID.pointee = entry.groupID.rawValue
    instanceID.pointee = entry.instanceID
    fileOffset.pointee = entry.fileOffset
    fileSize.pointee = entry.fileSize
    return 0
}

/// Finds the first DBPF entry matching its instance and type IDs.
@_cdecl("tsofiles_swift_dbpf_find_entry")
public func tsofilesCDBPFFindEntry(
    _ archive: UnsafeRawPointer?,
    _ instanceID: UInt32,
    _ typeID: UInt32,
    _ index: UnsafeMutablePointer<Int64>?
) -> Int32 {
    guard let storage = storage(for: archive), let index else { return 1 }
    guard let entry = storage.archive.entry(instanceID: instanceID, typeID: DBPFTypeID(rawValue: typeID)),
          let entryIndex = storage.archive.entries.firstIndex(of: entry) else { return 7 }
    index.pointee = Int64(entryIndex)
    return 0
}

/// Copies DBPF entry contents into a caller-owned buffer.
@_cdecl("tsofiles_swift_dbpf_entry_data")
public func tsofilesCDBPFEntryData(
    _ archive: UnsafeRawPointer?,
    _ index: Int64,
    _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?,
    _ dataSize: UnsafeMutablePointer<Int64>?
) -> Int32 {
    guard let data, let dataSize else { return 1 }
    data.pointee = nil
    dataSize.pointee = 0
    guard let storage = storage(for: archive) else { return 1 }
    guard let entry = storage.archive.entries[safe: index] else { return 8 }

    do {
        return allocateBuffer(from: try storage.archive.data(for: entry), output: data, outputSize: dataSize)
    } catch {
        switch error {
        case .entryOutOfBounds:
            return 6
        case .notADBPFArchive:
            return 4
        case .truncated:
            return 5
        }
    }
}

private extension Collection {
    subscript(safe index: Int64) -> Element? {
        guard index >= 0, index <= Int64(Int.max) else { return nil }
        let offset = Int(index)
        guard offset < count else { return nil }
        return self[self.index(startIndex, offsetBy: offset)]
    }
}
