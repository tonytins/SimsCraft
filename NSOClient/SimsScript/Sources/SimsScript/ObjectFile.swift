import Foundation
import TSOFiles

extension CompiledObject {
    /// The `OBJD` version written: 142, the newest FreeSO reads, with 103 words.
    static let definitionVersion: UInt32 = 142

    /// The object as an IFF file on its own, such as FreeSO loads from its `Content/Objects`
    /// folder: an `OBJD` (ID 128) with the GUID, the attribute count, and a function table, the
    /// `OBJf` that table is (ID 128), and the routines.
    ///
    /// The `OBJD` is a normal object (type 4) with every other field zero: no graphics, price,
    /// or catalog entry. That's enough to create and run it out of the world, which is all a
    /// scripted experiment needs.
    ///
    /// - Throws: ``TSOFiles/IFFWriteError`` if `name` or a routine's label can't be a chunk
    ///   label (ASCII, at most 64 bytes).
    public func objectFile(guid: UInt32, name: String) throws(IFFWriteError) -> Data {
        var words = [UInt16](repeating: 0, count: 103)
        words[7] = 4                                           // objectType: normal
        words[12] = UInt16(truncatingIfNeeded: guid)           // guid, low word first
        words[13] = UInt16(truncatingIfNeeded: guid >> 16)
        words[20] = 1                                          // usesFnTable
        words[56] = UInt16(clamping: attributes.count)         // numAttributes
        var definition = Data()
        withUnsafeBytes(of: Self.definitionVersion.littleEndian) { definition.append(contentsOf: $0) }
        for word in words {
            withUnsafeBytes(of: word.littleEndian) { definition.append(contentsOf: $0) }
        }
        let chunks = [IFFChunkRecord(typeCode: "OBJD", id: 128, label: name, data: definition),
                      IFFChunkRecord(typeCode: "OBJf", id: 128, label: name, data: functionTableData())]
            + routines.map { IFFChunkRecord(typeCode: "BHAV", id: $0.id, label: $0.label, data: $0.encoded()) }
        return try IFFFile(chunks: chunks).encoded()
    }
}
