import Testing
@testable import SimAntics

/// The operands of primitives this port decodes without running, checked against FreeSO's
/// layouts. `fso-oracle operands` compares them with FreeSO on a real install.
@Suite struct UnportedOperandTests {
    @Test func everyOperandEncodesBackToTheBytesFreeSOWrites() {
        // Bytes FreeSO's Write would produce: unread and padding bytes are zero.
        let samples: [UInt8: [UInt8]] = [
            1: [7, 0, 0, 0, 0, 0, 0, 0], 6: [3, 2, 0x01, 0x80, 0, 0, 0, 0], 9: [2, 1, 0, 0, 0, 0, 0, 0],
            13: [5, 1, 2, 3, 4, 0, 0, 0], 14: [0x34, 0x12, 0, 0, 0, 0, 0, 0], 20: [0x34, 0x12, 9, 0, 0, 0, 0, 0],
            22: [3, 0, 0, 0, 0, 0, 0, 0], 24: [1, 2, 3, 4, 5, 0, 0, 0], 26: [1, 2, 3, 4, 8, 0, 0xFF, 0xFF],
            27: [1, 0, 0xFE, 0x7F, 2, 0, 5, 0], 29: [8, 7, 4, 1, 0x10, 0, 0x20, 0], 36: [1, 2, 3, 4, 5, 6, 7, 8],
            40: [4, 0, 0, 0, 0, 0, 0, 0], 43: [1, 0, 2, 0, 3, 0, 4, 0], 44: [0x10, 0, 2, 0, 1, 0x20, 3, 0],
            45: [5, 0, 2, 0, 1, 0, 0, 0], 46: [6, 0, 1, 0, 3, 0, 0, 0], 47: [1, 0, 2, 0, 3, 0, 0, 0],
            50: [0x2D, 0x01, 1, 0, 9, 0, 0, 0], 62: [1, 2, 3, 1, 0x78, 0x56, 0x34, 0x12], 67: [0xEF, 0xBE, 0xAD, 0xDE, 4, 0, 0, 0],
        ]
        for (opcode, bytes) in samples {
            let operand = PrimitiveTable.unportedOperand(opcode: UInt16(opcode), bytes: bytes)
            #expect(operand?.encoded() == bytes, "opcode \(opcode)")
        }
        for opcode: UInt16 in [4, 5, 30, 37, 65] {
            #expect(PrimitiveTable.unportedOperand(opcode: opcode, bytes: [1, 2, 3])?.encoded() == [UInt8](repeating: 0, count: 8))
        }
    }

    @Test func fieldsReadAsFreeSOReadsThem() throws {
        let animate = try #require(PrimitiveTable.unportedOperand(opcode: 44, bytes: [0x10, 0, 2, 9, 1, 0x20, 3, 0])
            as? Primitives.AnimateSim.Operand)
        #expect(animate.animationID == 16 && animate.localEventNumber == 2 && animate.source == 1)
        #expect(animate.flags == 0x20 && animate.expectedEventCount == 3)
        // FreeSO reads the byte after the event number as padding and writes it back as zero.
        #expect(animate.encoded() == [0x10, 0, 2, 0, 1, 0x20, 3, 0])

        let motives = try #require(PrimitiveTable.unportedOperand(opcode: 29, bytes: [8, 7, 4, 1, 0x10, 0, 0xFF, 0xFF])
            as? Primitives.SetMotiveChange.Operand)
        #expect(motives.delta == Variable(.temps, 16) && motives.max == Variable(.literal, -1))
        #expect(motives.motive == 4 && motives.flags == 1)

        let relative = try #require(PrimitiveTable.unportedOperand(opcode: 27, bytes: [1, 0, 0xFE, 0x7F, 2, 0, 5, 0])
            as? Primitives.GotoRelativePosition.Operand)
        #expect(relative.location == -2 && relative.direction == 127 && relative.routeCount == 2)

        let old = try #require(PrimitiveTable.unportedOperand(opcode: 24, bytes: [1, 2, 3, 4, 5]) as? Primitives.OldRelationship.Operand)
        #expect(old.variable == Variable(.parameters, 3) && old.fsoCompatFields.first?.name == "SetMode")
    }

    @Test func shortOperandsReadAsZeroAndUnknownOpcodesDecodeToNothing() {
        #expect(PrimitiveTable.unportedOperand(opcode: 44, bytes: [])?.encoded() == [UInt8](repeating: 0, count: 8))
        #expect(PrimitiveTable.unportedOperand(opcode: 2, bytes: [1, 2]) == nil)     // expression: ported
        #expect(PrimitiveTable.unportedOperand(opcode: 51, bytes: [1, 2]) == nil)    // FreeSO registers none
        #expect(PrimitiveTable.unportedOperand(opcode: 300, bytes: [1, 2]) == nil)   // a call
    }

    @Test func noOperandIsBothPortedAndUnported() {
        for opcode in PrimitiveTable.unportedOperands.keys {
            #expect(PrimitiveTable.standard.name(of: opcode) == nil, "opcode \(opcode)")
        }
    }
}
