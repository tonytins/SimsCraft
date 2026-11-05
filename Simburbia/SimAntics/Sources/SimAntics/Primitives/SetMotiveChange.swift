extension Primitives {
    /// Sets how a Sim's motive changes over time, or changes it once (opcode 29, Set Motive
    /// Deltas).
    ///
    /// Ports FreeSO's `VMSetMotiveChange` in TSO mode. With Clear All, every motive change
    /// stops (``Entity/clearMotiveChanges()``). Otherwise the delta is scaled for the lot
    /// (``VM/scaledMotiveRate(_:motive:)``) and cut to 16 bits. With Once, the motive moves by
    /// the delta at once, stopping at the limit, unless it's already past it; without, the motive
    /// changes by the delta an hour from now on (``Entity/setMotiveChange(_:perHour:max:)``), if
    /// its change has ticked since it was last set. Always true.
    ///
    /// FreeSO casts the caller to a Sim, so an object caller fails, as does a motive past the
    /// sixteenth, and anything the rate's scaling fails on.
    public enum SetMotiveChange: Primitive {
        public static let name = "set_motive_deltas"
        public static let opcode: UInt8 = 29

        /// FreeSO's `VMSetMotiveChangeOperand`; its owner and data pairs are ``Variable``s here.
        public struct Operand: PrimitiveOperand, Equatable {
            public var delta: Variable
            public var max: Variable
            /// The motive (`VMMotive`).
            public var motive: UInt8
            /// 1 Clear All, 2 Once.
            public var flags: UInt8

            public var clearsAll: Bool { flags & 1 != 0 }
            public var once: Bool { flags & 2 != 0 }

            public init(delta: Variable, max: Variable, motive: UInt8, flags: UInt8) {
                self.delta = delta
                self.max = max
                self.motive = motive
                self.flags = flags
            }

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                let deltaOwner = reader.uint8(), maxOwner = reader.uint8()
                motive = reader.uint8()
                flags = reader.uint8()
                delta = Variable(rawScope: UInt16(deltaOwner), data: reader.int16())
                max = Variable(rawScope: UInt16(maxOwner), data: reader.int16())
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint8(UInt8(truncatingIfNeeded: delta.rawScope))
                    writer.uint8(UInt8(truncatingIfNeeded: max.rawScope))
                    writer.uint8(motive)
                    writer.uint8(flags)
                    writer.int16(delta.data)
                    writer.int16(max.data)
                }
            }
        }

        public static func execute(_ operand: Operand, in frame: StackFrame) throws(SimAnticsError) -> ExitCode {
            guard let sim = frame.caller else { throw .nullReference("Set Motive Deltas with no caller") }
            guard sim.isAvatar else { throw .invalidCast("Set Motive Deltas needs a Sim to call it") }
            if operand.clearsAll {
                sim.clearMotiveChanges()
                return .gotoTrue
            }
            let motive = Int(operand.motive)
            guard motive <= Motive.last else { throw .indexOutOfRange("motive \(motive)") }
            let rate = Int16(truncatingIfNeeded: try frame.vm.scaledMotiveRate(Int32(try frame.value(of: operand.delta)), motive: motive))
            let limit = try frame.value(of: operand.max)
            guard operand.once else {
                sim.setMotiveChange(motive, perHour: rate, max: limit)
                return .gotoTrue
            }
            func isPastLimit(_ value: Int16) -> Bool { (rate > 0 && value > limit) || (rate < 0 && value < limit) }
            var value = sim.motiveData[motive]
            if isPastLimit(value) { return .gotoTrue }
            value &+= rate
            if isPastLimit(value) { value = limit }
            sim.motiveData[motive] = Entity.clampedMotive(Int32(value))
            return .gotoTrue
        }
    }
}
