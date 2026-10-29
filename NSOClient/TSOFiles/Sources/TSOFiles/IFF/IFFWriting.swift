import Foundation

extension IFFFile {
    /// A file of the given chunks, in order, with no resource map.
    public init(chunks: [IFFChunkRecord]) {
        self.init(resourceMapOffset: 0, chunks: chunks)
    }

    /// The file's bytes, as FreeSO's `IffFile.Write` lays them out: the version 2.5 header, a
    /// zero resource map offset, then each chunk's header and data, big-endian.
    ///
    /// Reading the result gives back the same chunks. The resource map offset is always written
    /// as zero, as FreeSO writes it, whatever the file was read with.
    ///
    /// - Throws: ``IFFWriteError`` for a chunk the format can't hold: a type that isn't four
    ///   ASCII characters, a label that isn't ASCII or is longer than 64 bytes, or data too
    ///   large for the 32-bit size.
    public func encoded() throws(IFFWriteError) -> Data {
        var bytes = Data(Self.headerText.utf8)
        bytes.append(contentsOf: repeatElement(0, count: 60 - bytes.count))
        Self.append(UInt32(0), to: &bytes)
        for chunk in chunks {
            let type = Array(chunk.typeCode.utf8)
            guard type.count == 4, type.allSatisfy({ $0 < 0x80 }) else {
                throw .invalidTypeCode(chunk.typeCode)
            }
            let label = Array(chunk.label.utf8)
            guard label.count <= 64, label.allSatisfy({ $0 < 0x80 && $0 != 0 }) else {
                throw .invalidLabel(typeCode: chunk.typeCode, id: chunk.id, label: chunk.label)
            }
            guard chunk.data.count <= Int(UInt32.max) - Self.chunkHeaderSize else {
                throw .chunkTooLarge(typeCode: chunk.typeCode, id: chunk.id, size: chunk.data.count)
            }
            bytes.append(contentsOf: type)
            Self.append(UInt32(chunk.data.count + Self.chunkHeaderSize), to: &bytes)
            Self.append(chunk.id, to: &bytes)
            Self.append(chunk.flags, to: &bytes)
            bytes.append(contentsOf: label)
            bytes.append(contentsOf: repeatElement(0, count: 64 - label.count))
            bytes.append(chunk.data)
        }
        return bytes
    }

    /// The header FreeSO writes, before its NUL padding to 60 bytes.
    static let headerText = "IFF FILE 2.5:TYPE FOLLOWED BY SIZE\0 JAMIE DOORNBOS & MAXIS 1"

    private static func append<Value: FixedWidthInteger>(_ value: Value, to bytes: inout Data) {
        withUnsafeBytes(of: value.bigEndian) { bytes.append(contentsOf: $0) }
    }
}

/// Why an IFF file couldn't be written.
public enum IFFWriteError: Error, Equatable, Sendable {
    /// A chunk's type isn't four ASCII characters.
    case invalidTypeCode(String)
    /// A chunk's label isn't ASCII without NULs, or is longer than 64 bytes.
    case invalidLabel(typeCode: String, id: UInt16, label: String)
    /// A chunk's data is too large for the format's 32-bit size.
    case chunkTooLarge(typeCode: String, id: UInt16, size: Int)
}
