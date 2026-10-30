/// A difference from FreeSO that NewSO makes on purpose, as the comparisons expect it.
///
/// Each one is a row of the scorecard's "Known differences from FreeSO": a FreeSO bug NewSO
/// fixes, or a choice NewSO makes its own way. A disagreement it covers is counted as
/// explained, not as a disagreement. Keep the list to records known to show the difference,
/// so a new instance elsewhere still surfaces as a finding to look at.
public struct KnownDifference: Sendable, Equatable {
    /// The scorecard's ID, such as `DIFF-27`.
    public var id: String
    /// The comparison it applies to, by name.
    public var comparison: String
    /// The start of the records it covers.
    public var keyPrefix: String
    /// What NewSO does differently, and why.
    public var reason: String

    public init(id: String, comparison: String, keyPrefix: String, reason: String) {
        self.id = id
        self.comparison = comparison
        self.keyPrefix = keyPrefix
        self.reason = reason
    }

    /// None at the moment: DIFF-27, the only one, was withdrawn on 2026-10-29, when TSO's own
    /// skill objects turned out to rely on the FreeSO behavior it changed.
    public static let all: [KnownDifference] = []

    /// The known difference among `known` that covers a record of a comparison, if any.
    public static func covering(_ key: String, in comparison: String,
                                known: [KnownDifference] = all) -> KnownDifference? {
        known.first { $0.comparison == comparison && key.hasPrefix($0.keyPrefix) }
    }
}
