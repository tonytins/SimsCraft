/// An operand that names the variables it reads or writes.
///
/// Operands store variables in different ways: most hold a ``Variable`` property, while some keep
/// a scope byte beside its data. This protocol lets a tool (`sb-oracle census`) count the
/// variables without knowing each primitive's layout.
///
/// A variable a flag may make the primitive ignore is still listed, because it's written in the
/// file and the flag can change; the list is the operand's fields in their order.
public protocol VariableOperand: PrimitiveOperand {
    /// The variables the operand names, in field order.
    var variables: [Variable] { get }
}
