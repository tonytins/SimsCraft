import Foundation
import SimAntics

/// The randomized study: a seeded sample of the install's objects, placed on a lot and run over
/// game time on both VMs, as `docs/sb/tools.md` describes.
///
/// Rather than run every object, each study run samples lots for a time budget. Every lot is
/// repeatable from its seed, which picks the objects and their facings; the objects the ledger
/// hasn't seen yet are picked first, so coverage grows run to run. When a lot disagrees,
/// ``shrink(_:maxRuns:disagrees:)`` narrows it to the fewest objects that still disagree.
public enum Study {
    /// Objects on each sampled lot.
    public static let objectsPerLot = 32
    /// Tiles between objects on the grid, room for one up to three tiles wide.
    public static let spacing = 4

    /// SplitMix64: a small, fully specified generator, so a seed gives the same sample on every
    /// machine and Swift version (the standard library's generator promises neither).
    struct Generator: RandomNumberGenerator {
        var state: UInt64

        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    /// Picks up to `count` candidates for a lot, in a seeded random order with the ones `tested`
    /// doesn't hold first. The candidates' own order doesn't matter.
    public static func sample(_ candidates: [UInt32], count: Int, seed: UInt64, tested: Set<UInt32>) -> [UInt32] {
        var generator = Generator(state: seed)
        let shuffled = candidates.sorted().shuffled(using: &generator)
        let untested = shuffled.filter { !tested.contains($0) }
        let seen = shuffled.filter { tested.contains($0) }
        return Array((untested + seen).prefix(max(0, count)))
    }

    /// Picks up to `count` candidates for a lot by weight, in a seeded order: a weighted sample
    /// without replacement (Efraimidis and Spirakis' exponential keys), so a heavier candidate is
    /// likelier to be picked but any can be. The candidates' own order doesn't matter, and a
    /// weight below 1 counts as 1.
    ///
    /// The study weighs each object by the instructions its code can reach that no run has
    /// reached yet (``coverageWeight(uncovered:lots:)``), so coverage grows toward code nothing
    /// has run, rather than only toward objects nothing has tried.
    ///
    /// The ones `tested` doesn't hold still come first, as in the unweighted sample: trying an
    /// object nothing has tried reaches more than retrying one, so the weights choose among the
    /// untested, and then among the rest.
    public static func sample(_ candidates: [UInt32], count: Int, seed: UInt64, weights: [UInt32: Double],
                              tested: Set<UInt32> = []) -> [UInt32] {
        var generator = Generator(state: seed)
        var keyed: [(key: Double, guid: UInt32)] = []
        for guid in candidates.sorted() {
            // A uniform draw in (0, 1], never 0, so its logarithm is finite.
            let uniform = (Double(generator.next() >> 11) + 1) / 9_007_199_254_740_992
            let weight: Double = max(1, weights[guid] ?? 1)
            keyed.append((-Foundation.log(uniform) / weight, guid))
        }
        keyed.sort { $0.key < $1.key || ($0.key == $1.key && $0.guid < $1.guid) }
        let untested = keyed.filter { !tested.contains($0.guid) }, seen = keyed.filter { tested.contains($0.guid) }
        return (untested + seen).prefix(max(0, count)).map(\.guid)
    }

    /// An object's weight: 1, plus the instructions its code can reach that no run has reached
    /// yet, shared out over the lots it has already been on, so an object whose code never runs
    /// (it waits on something not ported) stops crowding out the rest.
    public static func coverageWeight(uncovered: Int, lots: Int) -> Double {
        1 + Double(max(0, uncovered)) / Double(1 + max(0, lots))
    }

    /// How many visitor Sims join a lot, 0 to `most`, picked by its seed (a stream of its own, so
    /// adding Sims doesn't change which objects or facings an older seed picks).
    public static func simCount(most: Int, seed: UInt64) -> Int {
        guard most > 0 else { return 0 }
        var generator = Generator(state: seed ^ 0x51A5_0F0A_1CE5_D00D)
        return Int(generator.next() % UInt64(most + 1))
    }

    /// The stand-in IDs halving uses for a lot's Sims, so they can be taken out like objects:
    /// above every GUID an object table uses.
    public static func simTokens(_ count: Int) -> [UInt32] {
        (0..<max(0, count)).map { 0xFFFF_FF00 | UInt32($0 & 0xFF) }
    }

    /// Whether an ID from ``simTokens(_:)`` stands for a Sim.
    public static func isSimToken(_ id: UInt32) -> Bool { id & 0xFFFF_FF00 == 0xFFFF_FF00 }

    /// Which of `count` floor plans a lot is laid out on, picked by its seed (a different stream
    /// from the sample's and the facings').
    public static func floorPlan(of count: Int, seed: UInt64) -> Int {
        guard count > 1 else { return 0 }
        var generator = Generator(state: seed ^ 0xF100_8F1A_F100_8F1A)
        return Int(generator.next() % UInt64(count))
    }

    /// The tiles the grid uses on a lot this size, row by row.
    static func gridTiles(lotSize: Int) -> [(x: Int, y: Int)] {
        stride(from: spacing, to: lotSize - spacing, by: spacing).flatMap { y in
            stride(from: spacing, to: lotSize - spacing, by: spacing).map { x in (x, y) }
        }
    }

    /// The lot: `base`'s walls and floors with its own objects taken out, and `objects` on a
    /// grid on the ground floor, each facing a direction the seed picks. Objects past the grid's
    /// last tile are left off.
    public static func lot(_ objects: [UInt32], on base: Blueprint, seed: UInt64) -> Blueprint {
        var lot = base
        // A different stream from the sample's, so a lot's facings don't shift with its size.
        var generator = Generator(state: seed ^ 0x5EED_FACE_5EED_FACE)
        lot.objects = zip(objects, gridTiles(lotSize: base.size)).map { guid, tile in
            let dir = Int(generator.next() % 4) * 2
            return Blueprint.Object(guid: guid, level: 1, x: tile.x, y: tile.y, direction: Blueprint.Object.direction(dir: dir), dir: dir)
        }
        return lot
    }

    /// The fewest objects that still disagree, found by halving: whichever half still disagrees
    /// is kept, until one object is left, neither half disagrees alone (the disagreement needs
    /// objects from both), or `maxRuns` calls to `disagrees` are spent.
    public static func shrink(_ objects: [UInt32], maxRuns: Int, disagrees: ([UInt32]) -> Bool) -> (objects: [UInt32], runs: Int) {
        var current = objects
        var runs = 0
        while current.count > 1 && runs < maxRuns {
            let half = current.count / 2
            let first = Array(current.prefix(half)), second = Array(current.dropFirst(half))
            runs += 1
            if disagrees(first) {
                current = first
                continue
            }
            guard runs < maxRuns else { break }
            runs += 1
            if disagrees(second) {
                current = second
                continue
            }
            break
        }
        return (current, runs)
    }
}

/// What the study has found for each object over its runs, kept between runs as a TSV file
/// (`docs/results/sb-study-ledger.tsv`): the GUID, the object's name, how many lots it's been on,
/// its latest result, and the seed of that lot. It holds GUIDs and names only.
public struct StudyLedger: Sendable, Equatable {
    public struct Entry: Sendable, Equatable {
        public var name: String
        public var lots: Int
        /// `agree`, `disagree: …`, `unsupported: …`, or `left out: …`.
        public var result: String
        public var seed: UInt64
    }

    public private(set) var entries: [UInt32: Entry] = [:]

    public init() {}

    /// Reads a ledger, skipping its header and any line that isn't one.
    public init(tsv: String) {
        for line in tsv.split(separator: "\n") where !line.hasPrefix("guid\t") {
            let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard fields.count >= 5, let guid = UInt32(fields[0].dropFirst(2), radix: 16), let lots = Int(fields[2]),
                  let seed = UInt64(fields[4]) else { continue }
            entries[guid] = Entry(name: fields[1], lots: lots, result: fields[3], seed: seed)
        }
    }

    /// The objects the ledger has seen.
    public var tested: Set<UInt32> { Set(entries.keys) }

    public mutating func record(_ guid: UInt32, name: String, result: String, seed: UInt64) {
        let lots = (entries[guid]?.lots ?? 0) + 1
        entries[guid] = Entry(name: name, lots: lots, result: result, seed: seed)
    }

    /// The ledger as TSV, by GUID.
    public var tsv: String {
        let rows = entries.keys.sorted().compactMap { guid -> String? in
            guard let entry = entries[guid] else { return nil }
            let clean = { (text: String) in text.replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ") }
            return [String(format: "0x%08X", guid), clean(entry.name), "\(entry.lots)", clean(entry.result), "\(entry.seed)"]
                .joined(separator: "\t")
        }
        return (["guid\tname\tlots\tresult\tseed"] + rows).joined(separator: "\n") + "\n"
    }
}

extension Comparison {
    /// The study's records (`study.tsv`, written by `sb-oracle study`) as two comparisons: the
    /// sampled lots, and the objects on them.
    ///
    /// Each record is a line of tab-separated fields: `lot`, the seed, how many objects, and
    /// `agree`, `disagree`, `broken`, or `unrepeatable` and the first sign of it, or `inconclusive`
    /// and why; `object`, its
    /// GUID, and `agree`, `disagree`, or `unsupported` and why; or `shrunk`, the seed, the GUIDs
    /// that still disagree, and the first differing digest. A lot or object can also be `broken`
    /// (it broke one of the lot's rules) or `unrepeatable` (two of Simburbia's runs differed):
    /// findings on Simburbia alone, counted as disagreements.
    public static func study(_ records: [String]) -> [Comparison] {
        var lots = Comparison(name: "Study: sampled lots"), objects = Comparison(name: "Study: sampled objects")
        for record in records {
            let fields = record.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            // A lot and a shrunk set have their seed before the rest; an object, its GUID.
            func rest(from index: Int) -> String { fields.count > index ? fields[index...].joined(separator: " ") : "" }
            switch fields.first {
            case "lot" where fields.count >= 4:
                switch fields[3] {
                case "agree": lots.matched += 1
                case "inconclusive": lots.skip(fields.count > 4 ? rest(from: 4) : "inconclusive")
                default: break                                   // a disagreement is listed by its `shrunk` record
                }
            case "shrunk" where fields.count >= 3:
                lots.mismatches.append("seed \(fields[1]), objects \(fields[2]): \(rest(from: 3))")
            case "object" where fields.count >= 3:
                switch fields[2] {
                case "agree": objects.matched += 1
                case "disagree": objects.mismatches.append("\(fields[1]): \(rest(from: 3))")
                case "broken", "unrepeatable": objects.mismatches.append("\(fields[1]): \(fields[2]) \(rest(from: 3))")
                case "unsupported": objects.skip("unsupported: \(rest(from: 3))")
                case "left out": objects.skip("FreeSO left it out: \(rest(from: 3))")
                default: break
                }
            default:
                continue
            }
        }
        return [lots, objects]
    }
}
