/// NSOClient's scenario results set beside FreeSO's records (`fso-oracle run-scenarios`).
public enum ScenarioComparison {
    /// How one scenario's two runs compare.
    public enum Outcome: Sendable, Equatable {
        /// Both left the same values.
        case agree
        /// Both ran, and the values differ.
        case differ(nso: String, fso: String)
        /// One side couldn't measure it, so it neither agrees nor differs.
        case inconclusive(String)
    }

    /// Compares each result with FreeSO's record for the same scenario and GUID.
    ///
    /// A result with errors, a FreeSO record of `missing` or `error`, or no FreeSO record at all
    /// is inconclusive, never agreement. FreeSO records for scenarios not run here are ignored.
    public static func compare(_ results: [ScenarioResult], freeSORecords: [String]) -> [(name: String, outcome: Outcome)] {
        var records: [String: String] = [:]
        for line in freeSORecords {
            let fields = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            guard fields.count == 3 else { continue }
            records["\(fields[0]) \(fields[1])"] = String(fields[2])
        }
        return results.map { result in
            let key = "\(result.name) \(String(result.guid, radix: 16).leftPadded(to: 8))"
            guard let record = records[key] else { return (result.name, .inconclusive("FreeSO has no record")) }
            guard result.errors.isEmpty else {
                return (result.name, .inconclusive("NSOClient hit errors: \(result.errors.joined(separator: "; "))"))
            }
            guard record.hasPrefix("attributes") else { return (result.name, .inconclusive("FreeSO: \(record)")) }
            let nso = String(result.recordLine.dropFirst(key.count + 1))
            return (result.name, nso == record ? .agree : .differ(nso: nso, fso: record))
        }
    }
}

private extension String {
    func leftPadded(to length: Int) -> String {
        count >= length ? self : String(repeating: "0", count: length - count) + self
    }
}
