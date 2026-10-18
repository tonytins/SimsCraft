import Foundation
import SimAntics
import TSOFiles

/// Turns routines back into a simplified script form.
public enum Decompiler {
    /// Decompile a single routine to a basic script representation.
    public static func decompile(_ routine: BHAV) -> String {
        var lines: [String] = []
        lines.append("// Decompiled: \(routine.label)")
        for (i, inst) in routine.instructions.enumerated() {
            if inst.opcode == 2 && inst.operand.count <= 8 {
                let bytes = Array(inst.operand.prefix(8)) + [UInt8](repeating: 0, count: max(0, 8 - inst.operand.count))
                let op = Primitives.Expression.Operand(bytes: bytes)
                if op.encoded() == bytes {
                    lines.append("  // \(i): \(Assembly.operatorName(op.rawOperator))")
                } else {
                    lines.append("  // \(i): expr (raw)")
                }
            } else if inst.opcode >= 256 {
                lines.append("  // \(i): call \(inst.opcode)")
            } else {
                lines.append("  // \(i): prim \(inst.opcode)")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }
    
    /// Decompile multiple routines.
    public static func decompile(_ routines: [BHAV]) -> String {
        return routines.map(decompile).joined(separator: "\n")
    }
}
