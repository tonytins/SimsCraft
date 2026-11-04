/// A hash of the VM state that matches `fso-oracle`'s digest version 1, for comparing a
/// Swift VM with FreeSO's tick by tick.
///
/// SHA-256 over little-endian values: the random seed (64 bits); the entity count (32);
/// then for each entity in object ID order: object ID (16), GUID (32), tile x (16),
/// tile y (16), level (8), direction (8, FreeSO's compass flag), the object data count (32)
/// and values (16 each), and the stack depth (32), then each frame's routine ID (16) and
/// instruction pointer (16).
///
/// Version 1 adds, after a Sim's stack only (``Entity/isAvatar``), so lots without Sims keep
/// version 0's digests: the person data count (32) and values (16 each); the motive count (32)
/// and values (16 each); the animation count (32) and each animation, then whether there's a
/// carry animation (8) and it if so; and the action queue's length (32) and each action. An
/// animation is its name's UTF-8 length (32) and bytes, its current frame and speed as 32-bit
/// float bits, and whether it plays backwards, loops, and has ended (8 each), and how many events
/// it has run (8). An action is its routine ID (16), callee's object ID (16, 0 for none),
/// interaction number (32), priority (16), mode (8), ID (16), and whether it's cancelled (8).
/// Simburbia has no animations or queue yet, so its Sims write none of either.
public enum StateDigest {
    public static let version = 1

    /// The digest as 64 lower-case hexadecimal digits.
    public static func hex(of vm: VM) -> String {
        SHA256.hash(bytes(of: vm)).map { byte in
            let digits = Array("0123456789abcdef")
            return String([digits[Int(byte >> 4)], digits[Int(byte & 15)]])
        }.joined()
    }

    /// The digested fields, readable, one line per entity in object ID order, as
    /// `fso-oracle run-lot --dump` prints them: `  id guid x y level direction data=... stack=routine:ip,...`,
    /// and for a Sim, ` person=... motives=... animations= carry=- queue=`.
    public static func lines(of vm: VM) -> [String] {
        vm.entities.map { entity in
            "  \(entity.objectID) \(String(format: "%08x", entity.object.guid)) \(entity.position.x) \(entity.position.y) "
                + "\(entity.position.level) \(entity.direction.rawValue) data=\(entity.objectData.map(String.init).joined(separator: ",")) "
                + "stack=\(entity.thread.stack.map { "\($0.routine.id):\($0.instructionPointer)" }.joined(separator: ","))"
                + (entity.isAvatar
                    ? " person=\(entity.personData.map(String.init).joined(separator: ",")) "
                        + "motives=\(entity.motiveData.map(String.init).joined(separator: ",")) animations= carry=- queue="
                    : "")
        }
    }

    static func bytes(of vm: VM) -> [UInt8] {
        var bytes: [UInt8] = []
        func append<Value: FixedWidthInteger>(_ value: Value) {
            withUnsafeBytes(of: value.littleEndian) { bytes.append(contentsOf: $0) }
        }
        append(vm.random.seed)
        append(Int32(vm.entities.count))
        for entity in vm.entities {
            append(entity.objectID)
            append(entity.object.guid)
            append(entity.position.x)
            append(entity.position.y)
            append(entity.position.level)
            append(entity.direction.rawValue)
            append(Int32(entity.objectData.count))
            for value in entity.objectData { append(value) }
            append(Int32(entity.thread.stack.count))
            for frame in entity.thread.stack {
                append(frame.routine.id)
                append(frame.instructionPointer)
            }
            if entity.isAvatar {
                append(Int32(entity.personData.count))
                for value in entity.personData { append(value) }
                append(Int32(entity.motiveData.count))
                for value in entity.motiveData { append(value) }
                append(Int32(0))  // animations
                append(UInt8(0))  // no carry animation
                append(Int32(0))  // the action queue
            }
        }
        return bytes
    }
}
