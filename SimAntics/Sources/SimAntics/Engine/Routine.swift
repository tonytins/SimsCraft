import Foundation
import TSOFiles

/// A BHAV prepared to run: every operand decoded once.
///
/// Ports FreeSO's `VMRoutine` and `VMTranslator.Assemble`.
public struct Routine: Sendable {
    public let id: UInt16
    public let name: String
    public let type: UInt8
    public let argumentCount: UInt16
    public let localCount: UInt16
    public let instructions: [Instruction]
    /// Where the BHAV lives, for coverage: `global`, `object NAME`, or `semi-global NAME`, the
    /// file's name as TSOContent names it; empty for a routine built directly.
    public internal(set) var file = ""
    /// The VM's number for this routine, which coverage records instead of the file's name; -1
    /// for a routine the VM didn't assemble.
    var number: Int32 = -1

    /// Decodes a BHAV's instructions with the primitives in `table`.
    public init(_ bhav: BHAV, primitives table: PrimitiveTable) {
        id = bhav.id
        name = bhav.label
        type = bhav.type
        argumentCount = UInt16(bhav.argumentCount)
        localCount = bhav.localCount
        instructions = bhav.instructions.enumerated().map { index, instruction in
            Instruction(index: UInt8(truncatingIfNeeded: index), opcode: instruction.opcode,
                        truePointer: instruction.truePointer, falsePointer: instruction.falsePointer,
                        operand: table.decode(opcode: instruction.opcode, operand: [UInt8](instruction.operand)))
        }
    }

    /// A routine built directly, for tests and tools.
    public init(id: UInt16, name: String = "", type: UInt8 = 0, argumentCount: UInt16 = 4, localCount: UInt16 = 0,
                instructions: [Instruction]) {
        self.id = id
        self.name = name
        self.type = type
        self.argumentCount = argumentCount
        self.localCount = localCount
        self.instructions = instructions
    }
}

/// One decoded instruction.
public struct Instruction: Sendable {
    public let index: UInt8
    public let opcode: UInt16
    public let truePointer: UInt8
    public let falsePointer: UInt8
    public let operand: DecodedOperand

    public init(index: UInt8, opcode: UInt16, truePointer: UInt8, falsePointer: UInt8, operand: DecodedOperand) {
        self.index = index
        self.opcode = opcode
        self.truePointer = truePointer
        self.falsePointer = falsePointer
        self.operand = operand
    }
}

/// An instruction's operand, decoded for what the opcode does.
public enum DecodedOperand: Sendable {
    /// A call to another routine (opcodes 256 and up).
    case subroutine(SubroutineOperand)
    /// A primitive, ready to run.
    case primitive(PrimitiveTable.Prepared)
    /// A primitive opcode with no implementation in FreeSO; it takes the true branch.
    case missingPrimitive
    /// A primitive FreeSO has that this port doesn't yet; running it throws ``SimAnticsError/unsupported(_:)``.
    case unportedPrimitive(String)
}

/// The arguments of a subroutine call.
///
/// Ports `VMSubRoutineOperand`: four little-endian 16-bit arguments. When any of
/// arguments 1 to 3 is non-zero, an argument of -1 takes the temp register with its index.
public struct SubroutineOperand: Sendable, Equatable {
    public var arguments: [Int16]
    public var usesTemps: Bool

    public init(bytes: [UInt8]) {
        var reader = OperandReader(bytes)
        arguments = (0..<4).map { _ in reader.int16() }
        usesTemps = !(arguments[1] == 0 && arguments[2] == 0 && arguments[3] == 0)
    }

    /// A call with up to four arguments; ``usesTemps`` follows from them, as when decoding.
    public init(arguments: [Int16]) {
        self.init(bytes: OperandWriter.bytes { writer in
            for argument in (arguments + [0, 0, 0, 0]).prefix(4) { writer.int16(argument) }
        })
    }

    public func encoded() -> [UInt8] {
        OperandWriter.bytes { writer in
            for argument in arguments { writer.int16(argument) }
        }
    }
}

/// One instruction of one BHAV, for coverage: the file it lives in (`global`, `object NAME`, or
/// `semi-global NAME`), the routine's ID, and the instruction's index.
public struct InstructionSite: Sendable, Hashable, Comparable, CustomStringConvertible {
    public var file: String
    public var routine: UInt16
    public var index: UInt8

    public init(file: String, routine: UInt16, index: UInt8) {
        self.file = file
        self.routine = routine
        self.index = index
    }

    public static func < (lhs: InstructionSite, rhs: InstructionSite) -> Bool {
        (lhs.file, lhs.routine, lhs.index) < (rhs.file, rhs.routine, rhs.index)
    }

    /// `FILE<tab>ROUTINE<tab>INDEX`, the form a coverage file keeps.
    public var description: String { "\(file)\t\(routine)\t\(index)" }

    /// Reads ``description``'s form back, or `nil` for a line that isn't one.
    public init?(line: some StringProtocol) {
        let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
        guard fields.count == 3, let routine = UInt16(fields[1]), let index = UInt8(fields[2]) else { return nil }
        self.init(file: String(fields[0]), routine: routine, index: index)
    }
}
