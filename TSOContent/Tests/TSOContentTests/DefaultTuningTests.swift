import Foundation
import Testing
import TSOFiles
@testable import TSOContent

/// Simburbia's default tuning (`Tuning/tuning.xml`).
@Suite struct DefaultTuningTests {
    private let file = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().appendingPathComponent("../../../Tuning/tuning.xml").standardizedFileURL

    /// The libraries embed the file; `fso-oracle` reads the file itself. They must not drift.
    @Test func theEmbeddedCopyMatchesTheFile() throws {
        let contents = try String(contentsOf: file, encoding: .utf8)
        #expect(GameContent.defaultTuningXML + "\n" == contents)
    }

    @Test func readsWithNothingIgnored() throws {
        let document = try TuningXML(bytes: Data(GameContent.defaultTuningXML.utf8))
        #expect(document.ignored.isEmpty)
        #expect(document.tuning.entries.map(\.name) == ["SimMotives", "LotMotives"])
    }

    /// Exactly the keys FreeSO's `VMAvatarMotiveDecay` and `VMMotiveChange.ScaleRate` read, and
    /// every value a number.
    @Test func hasEveryMotiveKeyFreeSOReads() throws {
        let tuning = try GameContent.defaultTuning()
        let sim = try #require(tuning.entry(named: "SimMotives"))
        #expect(Set(sim.values.map(\.key)) == ["HungerDecrementRatio", "ComfortDecrementActive", "HygieneDecrementAwake",
                                               "HygieneDecrementAsleep", "BladderDecrementAwake", "BladderDecrementAsleep",
                                               "HungerToBladderMultiplier", "EnergySpan", "WakeHours", "EntDecrementAwake",
                                               "SocialDecrementBase", "SocialDecrementMultiplier"])
        let categories = ["None", "Money", "Offbeat", "Romance", "Services", "Shopping", "Skills", "Welcome", "Games",
                          "Entertain", "Residence"]
        let motives = ["Hunger", "Comfort", "Hygiene", "Bladder", "Energy", "Fun", "Social"]
        let lot = try #require(tuning.entry(named: "LotMotives"))
        #expect(Set(lot.values.map(\.key)) == Set(categories.flatMap { category in motives.map { "\(category)_\($0)Weight" } }))
        for entry in [sim, lot] {
            #expect(entry.values.allSatisfy { entry.number(forKey: $0.key) != nil })
        }
        // TSO Mania's difficulties: hard lots weigh more than average ones, easy ones less.
        #expect(lot.number(forKey: "Money_HungerWeight") == 1.25 && lot.number(forKey: "None_HungerWeight") == 1
            && lot.number(forKey: "Romance_HungerWeight") == 0.8)
    }
}
