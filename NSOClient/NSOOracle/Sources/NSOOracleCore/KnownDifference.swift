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

    public static let all: [KnownDifference] = [
        KnownDifference(
            id: "DIFF-27", comparison: "Sprites",
            keyPrefix: "objectdata/objects/objspf.far/mockchair.spf\tSPR2\t102\t",
            reason: "SPR2 alpha past 31 saturates at 255, where FreeSO's byte cast wraps (MockInstall's frame uses 40)"
        ),
    ]

    /// The known difference that covers a record of a comparison, if any.
    public static func covering(_ key: String, in comparison: String) -> KnownDifference? {
        all.first { $0.comparison == comparison && key.hasPrefix($0.keyPrefix) }
    }
}
