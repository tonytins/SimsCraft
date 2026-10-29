import Foundation
import SimAntics
import TSOContent
import TSOFiles

/// The names behind a routine's numbers, from the files that hold its code.
///
/// Routines are named by their `BHAV` labels, parameters and locals by the routine's `TPRP`,
/// the owner's attributes by its `STR#` 256 (as FreeSO's `VMEntity` names them), and constants
/// by the `TRCN` that labels each `BCON`, or by the OTF table the constant comes from. Names are
/// only for reading: a chunk that's missing or doesn't parse leaves its numbers unnamed rather
/// than stopping the listing.
public struct RoutineNames: Sendable {
    /// The object (or global file) whose routines are listed, with its semi-global.
    let owner: (any IFFResource)?
    /// The global file, for global routines and constants.
    let global: (any IFFResource)?

    /// No names: every number is written as a number.
    public init() {
        owner = nil
        global = nil
    }

    public init(owner: some IFFResource, global: (some IFFResource)?) {
        self.owner = owner
        self.global = global
    }

    /// The file a routine with this ID lives in: global below 4096, the owner's own up to
    /// 8191, and its semi-global from 8192, as `VM.routine(opcode:codeOwner:)` finds them.
    func file(ofRoutine id: UInt16) -> (any IFFResource)? {
        switch id {
        case ..<4096: global
        case ..<8192: owner
        default: owner?.semiGlobal ?? owner
        }
    }

    /// A routine's label, or `nil` if it has none.
    public func routineLabel(_ id: UInt16) -> String? {
        guard let routine = try? file(ofRoutine: id)?.chunk(BHAV.self, id: id), !routine.label.isEmpty else { return nil }
        return routine.label
    }

    /// The routine itself, for its argument count.
    func routine(_ id: UInt16) -> BHAV? {
        try? file(ofRoutine: id)?.chunk(BHAV.self, id: id)
    }

    /// A routine's parameter and local names, from its `TPRP`.
    func labels(ofRoutine id: UInt16) -> TPRP? {
        try? file(ofRoutine: id)?.chunk(TPRP.self, id: id)
    }

    /// The owner's attribute name at an index.
    public func attributeName(_ index: Int16) -> String? {
        guard index >= 0, let table = try? owner?.chunk(STR.self, id: 256)?.table,
              let name = table.string(at: Int(index)), !name.isEmpty else { return nil }
        return name
    }

    /// A constant's label and value, for a `tuning` variable's data, found as
    /// `VMMemory.tuningValue` finds the value.
    public func constant(_ data: Int16) -> (label: String?, value: Int16?) {
        let raw = UInt16(bitPattern: data)
        let table = raw >> 7, key = Int(raw & 0x7F)
        let places: [(file: (any IFFResource)?, id: UInt16)] = switch table {
        case 64..<128: [(owner, table - 64 + 8192), (owner?.semiGlobal, table - 64 + 8192)]
        case 128..<192: [(global, table - 128 + 256)]
        default: [(owner, table &+ 4096)]
        }
        for place in places {
            guard let file = place.file else { continue }
            if let bcon = try? file.chunk(BCON.self, id: place.id), key < bcon.constants.count {
                let label = (try? file.chunk(TRCN.self, id: place.id))?.entries[safe: key]?.label
                return (label.flatMap { $0.isEmpty ? nil : $0 }, Int16(bitPattern: bcon.constants[key]))
            }
            if let otf = file.tuningTable(id: place.id), let entry = otf.key(id: Int32(key)) {
                return (entry.label.isEmpty ? nil : entry.label, Int16(truncatingIfNeeded: entry.value))
            }
        }
        return (nil, nil)
    }
}

/// Routines written to be read: one line per instruction, with the names the files give its
/// numbers, primitives named and their operands spelled out.
///
/// Unlike ``Assembly``, a listing doesn't convert back to routines; it's for understanding what
/// an object does. Each line reads like this:
///
///     4096 "main": 2 parameters (count, target), 1 local (i)
///        0: "charges" (my attribute 3) := 5                              then 1, else return false
///        1: call "Get In" (target, 0, 0, 0)                              then return true, else return false
///        2: sleep (argument: count)                                      then 2, else 3
///        3: animate (not ported yet) 0a00000100000000                    then 4, else return false
///
/// A primitive NSOClient has ported shows its decoded operand; one it hasn't shows its 8 bytes.
/// A branch to 253 reads as `unset`: FreeSO's `VMThread` then goes on along the other branch,
/// and errors only if both are unset, while the SimAntics Wiki describes an unset branch as an
/// error in the original engine (**Unverified** against TSO itself).
public enum Listing {
    /// Routines as readable text.
    public static func text(of routines: [BHAV], names: RoutineNames = RoutineNames(),
                            primitives: PrimitiveTable = .standard) -> String {
        routines.map { text(of: $0, names: names, primitives: primitives) }.joined(separator: "\n")
    }

    public static func text(of routine: BHAV, names: RoutineNames = RoutineNames(),
                            primitives: PrimitiveTable = .standard) -> String {
        let writer = Writer(routine: routine, names: names, primitives: primitives)
        var lines = [writer.header()]
        let width = String(max(routine.instructions.count - 1, 0)).count
        for (index, instruction) in routine.instructions.enumerated() {
            let number = String(repeating: " ", count: width - String(index).count) + "\(index)"
            let body = writer.body(of: instruction)
            let padding = String(repeating: " ", count: max(1, 64 - body.count))
            lines.append("  \(number): \(body)\(padding)\(writer.branches(of: instruction))")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Writes one routine's lines.
    struct Writer {
        let routine: BHAV
        let names: RoutineNames
        let primitives: PrimitiveTable
        let labels: TPRP?

        init(routine: BHAV, names: RoutineNames, primitives: PrimitiveTable) {
            self.routine = routine
            self.names = names
            self.primitives = primitives
            labels = names.labels(ofRoutine: routine.id)
        }

        func header() -> String {
            func list(_ count: Int, _ singular: String, _ given: [String]) -> String? {
                guard count > 0 else { return nil }
                let shown = (0..<count).map { given[safe: $0].flatMap { $0.isEmpty ? nil : $0 } ?? "\(singular) \($0)" }
                return "\(count) \(singular)\(count == 1 ? "" : "s") (\(shown.joined(separator: ", ")))"
            }
            let parts = [list(Int(routine.argumentCount), "parameter", labels?.parameterNames ?? []),
                         list(Int(routine.localCount), "local", labels?.localNames ?? [])].compactMap { $0 }
            return "\(routine.id) \(quoted(routine.label))" + (parts.isEmpty ? "" : ": " + parts.joined(separator: ", "))
        }

        func body(of instruction: BHAV.Instruction) -> String {
            let bytes = [UInt8](instruction.operand.prefix(8)) + [UInt8](repeating: 0, count: max(0, 8 - instruction.operand.count))
            if instruction.opcode >= 256 { return call(instruction.opcode, SubroutineOperand(bytes: bytes)) }
            if instruction.opcode == Primitives.Expression.opcode {
                return expression(Primitives.Expression.Operand(bytes: bytes))
            }
            let raw = bytes.map { String(format: "%02x", $0) }.joined()
            switch primitives.decode(opcode: instruction.opcode, operand: bytes) {
            case .primitive(let prepared):
                return "\(words(prepared.name)) (\(fields(of: prepared.operand)))"
            case .unportedPrimitive(let name):
                return "\(words(name)) (not ported yet) \(raw)"
            default:
                return "primitive \(instruction.opcode) (unknown) \(raw)"
            }
        }

        func branches(of instruction: BHAV.Instruction) -> String {
            "then \(target(instruction.truePointer)), else \(target(instruction.falsePointer))"
        }

        private func target(_ pointer: UInt8) -> String {
            switch pointer {
            case 253: "unset"
            case 254: "return true"
            case 255: "return false"
            default: "\(pointer)"
            }
        }

        private func call(_ opcode: UInt16, _ operand: SubroutineOperand) -> String {
            let callee = names.routineLabel(opcode).map(quoted) ?? "\(opcode)"
            let count = names.routine(opcode).map { max(Int($0.argumentCount), 0) } ?? 4
            let arguments = operand.arguments.prefix(min(count, 4)).enumerated().map { index, argument in
                argument == -1 && operand.usesTemps ? "temp \(index)" : "\(argument)"
            }
            return "call \(callee) (\(arguments.joined(separator: ", ")))"
        }

        private func expression(_ operand: Primitives.Expression.Operand) -> String {
            let lhs = name(of: operand.lhs), rhs = name(of: operand.rhs)
            let text = switch operand.rawOperator {
            case 8: "\(lhs) has flag \(rhs)"
            case 9: "set flag \(rhs) of \(lhs)"
            case 10: "clear flag \(rhs) of \(lhs)"
            case 11: "\(lhs) += 1, then \(lhs) < \(rhs)"
            case 17: "\(lhs) -= 1, then \(lhs) > \(rhs)"
            case 18: "push \(rhs) onto \(lhs)"
            case 19: "pop \(lhs) into \(rhs)"
            default: "\(lhs) \(Assembly.operatorName(operand.rawOperator)) \(rhs)"
            }
            return operand.isSigned != 0 ? text + " (signed)" : text
        }

        /// A primitive operand's fields, with variables named: GUIDs, flags, and options in
        /// hexadecimal, raw-valued types by their raw values, and padding left out.
        private func fields(of operand: any PrimitiveOperand) -> String {
            Mirror(reflecting: operand).children.compactMap { child in
                guard let label = child.label, !["padding", "unused", "reserved"].contains(label.lowercased()) else { return nil }
                return "\(Listing.words(label)): \(value(child.value, label: label.lowercased()))"
            }.joined(separator: ", ")
        }

        private func value(_ value: Any, label: String) -> String {
            if let variable = value as? Variable { return name(of: variable) }
            var value = value
            if let raw = value as? any RawRepresentable { value = raw.rawValue }
            let hexadecimal = label.contains("guid") || label.contains("flags") || label.contains("options")
            if hexadecimal, let number = value as? any BinaryInteger {
                return "0x" + String(number, radix: 16)
            }
            return "\(value)"
        }

        /// A variable as it reads: a literal as its value, others by name where the files name them.
        func name(of variable: Variable) -> String {
            let data = variable.data
            guard let scope = variable.scope else { return "scope \(variable.rawScope) \(data)" }
            switch scope {
            case .literal:
                return "\(data)"
            case .parameters:
                return labels?.parameterNames[safe: Int(data)].flatMap { $0.isEmpty ? nil : $0 } ?? "parameter \(data)"
            case .local:
                return labels?.localNames[safe: Int(data)].flatMap { $0.isEmpty ? nil : $0 } ?? "local \(data)"
            case .temps:
                return "temp \(data)"
            case .myObjectAttributes:
                return names.attributeName(data).map { "\(quoted($0)) (my attribute \(data))" } ?? "my attribute \(data)"
            case .myObject:
                return "my " + (ObjectVariable(rawValue: data).map { Listing.words("\($0)") } ?? "object data \(data)")
            case .stackObject:
                return "stack object's " + (ObjectVariable(rawValue: data).map { Listing.words("\($0)") } ?? "object data \(data)")
            case .stackObjectDefinition:
                return "stack object's definition " + (DefinitionVariable(rawValue: data).map { Listing.words("\($0)") } ?? "\(data)")
            case .tuning:
                let constant = names.constant(data)
                let value = constant.value.map { " = \($0)" } ?? ""
                return constant.label.map { "\(quoted($0)) (constant\(value))" } ?? "constant \(UInt16(bitPattern: data))\(value)"
            default:
                return "\(words("\(scope)")) \(data)"
            }
        }
    }

    /// A name such as `get_distance_to`, `stackObjectAttributes`, or `objectID` in plain
    /// words; a run of capitals (an acronym) stays one word.
    static func words(_ name: String) -> String {
        var text = ""
        var previous: Character?
        for character in name {
            defer { previous = character }
            if character == "_" { text.append(" "); continue }
            if character.isUppercase, let previous, previous != "_", !previous.isUppercase { text.append(" ") }
            text.append(Character(character.lowercased()))
        }
        return text
    }

    static func quoted(_ text: String) -> String {
        "\"" + text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
