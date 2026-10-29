import Foundation
import Testing
import SimAntics
import TSOContent
import TSOFiles
@testable import SimsScript

/// Little-endian chunk data for the name chunks a listing reads.
private struct ChunkBytes {
    var data = Data()
    mutating func int8(_ value: UInt8) { data.append(value) }
    mutating func int16(_ value: Int16) { withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) } }
    mutating func int32(_ value: Int32) { withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) } }
    mutating func cString(_ text: String) { data.append(contentsOf: Array(text.utf8) + [0]) }
}

private func instruction(_ opcode: UInt16, _ operand: [UInt8], _ yes: UInt8, _ no: UInt8) -> BHAV.Instruction {
    BHAV.Instruction(opcode: opcode, truePointer: yes, falsePointer: no, operand: Data(operand))
}

private func expression(_ lhs: Variable, _ op: UInt8, _ rhs: Variable) -> [UInt8] {
    Primitives.Expression.Operand(lhs, op, rhs, isSigned: 0).encoded()
}

/// An object file with labels for everything a listing names.
private func namedObject() throws -> ObjectResource {
    var parameters = ChunkBytes()                   // TPRP version 4: NUL-terminated names
    parameters.int32(0); parameters.int32(4); parameters.data.append(contentsOf: Array("PRPT".utf8))
    parameters.int32(2); parameters.int32(1)
    parameters.cString("amount"); parameters.cString(""); parameters.cString("count")

    var attributes = ChunkBytes()                   // STR# format -2: value, comment
    attributes.int16(-2); attributes.int16(2)
    attributes.cString("charges"); attributes.cString(""); attributes.cString("owner"); attributes.cString("")

    var constants = ChunkBytes()                    // BCON 4097: two constants
    constants.int8(2); constants.int8(0); constants.int16(50); constants.int16(-3)

    var labels = ChunkBytes()                       // TRCN version 0: NUL-terminated labels
    labels.int32(0); labels.int32(0); labels.int32(0); labels.int32(2)
    for label in ["Lighting", ""] { labels.int32(0); labels.int32(0); labels.cString(label); labels.cString("") }

    let helper = BHAV(id: 4097, label: "Add Charge", version: 0x8002, type: 0, argumentCount: 2, localCount: 0,
                      flags: 0, instructions: [])
    let file = IFFFile(chunks: [
        IFFChunkRecord(typeCode: "BHAV", id: 4097, label: helper.label, data: helper.encoded()),
        IFFChunkRecord(typeCode: "TPRP", id: 4096, data: parameters.data),
        IFFChunkRecord(typeCode: "STR#", id: 256, data: attributes.data),
        IFFChunkRecord(typeCode: "BCON", id: 4097, data: constants.data),
        IFFChunkRecord(typeCode: "TRCN", id: 4097, data: labels.data),
    ])
    return try ObjectResource(name: "lamp", mainFile: file)
}

@Suite struct ListingTests {
    let routine = BHAV(id: 4096, label: "main", version: 0x8002, type: 0, argumentCount: 2, localCount: 1, flags: 0,
                       instructions: [
                           instruction(2, expression(Variable(.myObjectAttributes, 0), 5, Variable(.tuning, 1 << 7)), 1, 255),
                           instruction(4097, SubroutineOperand(arguments: [-1, 7, 0, 0]).encoded(), 254, 253),
                           instruction(2, expression(Variable(.parameters, 0), 0, .literal(3)), 3, 4),
                           instruction(2, expression(Variable(.myObject, ObjectVariable.room.rawValue), 8, .literal(2)), 254, 255),
                           instruction(44, [1, 0, 2, 0, 0, 0, 0, 0], 4, 253),
                       ])

    @Test func namesWhatTheFilesName() throws {
        let object = try namedObject()
        let text = Listing.text(of: routine, names: RoutineNames(owner: object, global: Optional<GlobalResource>.none))
        #expect(text == """
            4096 "main": 2 parameters (amount, parameter 1), 1 local (count)
              0: "charges" (my attribute 0) := "Lighting" (constant = 50)        then 1, else return false
              1: call "Add Charge" (temp 0, 7)                                   then return true, else unset
              2: amount > 3                                                      then 3, else 4
              3: my room has flag 2                                              then return true, else return false
              4: animate (not ported yet) 0100020000000000                       then 4, else unset

            """)
    }

    @Test func writesNumbersWithoutNames() {
        let text = Listing.text(of: routine)
        #expect(text.hasPrefix("4096 \"main\": 2 parameters (parameter 0, parameter 1), 1 local (local 0)\n"))
        #expect(text.contains("0: my attribute 0 := constant 128"))
        #expect(text.contains("1: call 4097 (temp 0, 7, 0, 0)"))
        #expect(text.contains("2: parameter 0 > 3"))
    }

    @Test func spellsOutPortedOperands() {
        let sleep = BHAV(id: 4100, label: "nap", version: 0x8002, type: 0, argumentCount: 0, localCount: 0, flags: 0,
                         instructions: [instruction(0, Primitives.Sleep.Operand(argument: 2).encoded(), 254, 255)])
        #expect(Listing.text(of: sleep).contains("0: sleep (argument: 2)"))
    }

    @Test(arguments: [("get_distance_to", "get distance to"), ("stackObjectAttributes", "stack object attributes"),
                      ("objectID", "object id"), ("placementFlags", "placement flags"), ("GUID", "guid")])
    func turnsNamesIntoWords(name: String, words: String) {
        #expect(Listing.words(name) == words)
    }
}
