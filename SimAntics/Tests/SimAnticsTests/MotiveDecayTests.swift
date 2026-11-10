import Foundation
import Testing
import TSOContent
import TSOFiles
@testable import SimAntics

/// The mock install's made-up motive tuning in thousandths: every lot weight 1 (1000), and rates
/// of 0.5 (500) or 0.25 (250), so Hunger's rate (500 × 200) runs past a `short`.
private let mockSimMotives: [(key: String, value: String)] = [
    ("HungerDecrementRatio", "0.5"), ("ComfortDecrementActive", "0.5"), ("HygieneDecrementAwake", "0.5"),
    ("HygieneDecrementAsleep", "0.25"), ("BladderDecrementAwake", "0.5"), ("BladderDecrementAsleep", "0.25"),
    ("HungerToBladderMultiplier", "0.5"), ("EnergySpan", "100"), ("WakeHours", "16"), ("EntDecrementAwake", "0.5"),
    ("SocialDecrementBase", "0.25"), ("SocialDecrementMultiplier", "0.5"),
]

private func lotMotives(weight: String = "1") -> TuningFile.Entry {
    TuningFile.Entry(name: "lotmotives", values: MotiveTuning.categoryNames.flatMap { category in
        MotiveTuning.lotMotiveNames.map { (key: "\(category)_\($0)Weight", value: weight) }
    })
}

/// A mock Sim made on the mock install, out of the world (room 0, which scores 0).
private func withMockSim(_ body: (VM, Entity) throws -> Void) throws {
    let vm = try VM(content: try GameContent(.init(gameDirectory: mockInstall)), seed: 1)
    try body(vm, try #require(try vm.createObject(guid: mockSimGUID)?.objects.first))
}

@Suite struct MotiveTuningTests {
    @Test func readsTheMockInstallsTuningInThousandths() throws {
        let tuning = try MotiveTuning(simMotives: TuningFile.Entry(name: "simmotives", values: mockSimMotives), lotMotives: lotMotives())
        #expect(tuning.hungerDecrementRatio == 500 && tuning.hygieneDecrementAsleep == 250 && tuning.socialDecrementBase == 250)
        // 100,000 over 60 × 16.
        #expect(tuning.energyPerMinute == 104)
        #expect(tuning.weights.count == 11 && tuning.weights.allSatisfy { $0 == [Int32](repeating: 1000, count: 7) })
        #expect(throws: SimAnticsError.indexOutOfRange("property category 11")) { try tuning.weights(category: 11) }
        // A VM reads the mock's tuning.dat once: the same rates, None's weights at 1, and the other
        // categories' made-up weights (generators/mock_tuning.py), which don't divide 1000 evenly.
        let vm = try VM(content: try GameContent(.init(gameDirectory: mockInstall)), seed: 1)
        let mock = try vm.motiveTuning().tuning.get()
        #expect(vm.motiveTuning().isNew == false)
        #expect(mock.hungerDecrementRatio == tuning.hungerDecrementRatio && mock.energyPerMinute == tuning.energyPerMinute)
        #expect(try mock.weights(category: 0) == tuning.weights(category: 0))
        #expect(try mock.weights(category: 1) == [1375, 875, 1625, 1125, 2125, 750, 2375])  // Money: the bases times 1.25
    }

    /// Simburbia's defaults (`Tuning/tuning.xml`), which the unpatched discs run on, make
    /// usable tuning: every rate is at least a thousandth, so none truncates to nothing.
    @Test func simburbiasDefaultsAreUsable() throws {
        let tuning = try MotiveTuning(try GameContent.defaultTuning())
        #expect(tuning.hungerDecrementRatio == 1 && tuning.socialDecrementMultiplier == 1 && tuning.comfortDecrementActive == 500)
        #expect(tuning.energyPerMinute == 208)  // 200,000 over 60 × 16: empty after 16 waking hours
        #expect(try tuning.weights(category: 0) == [1000, 500, 500, 1000, 2000, 500, 2000])
        #expect(try tuning.weights(category: 1) == [1250, 625, 625, 1250, 2500, 625, 2500])  // Money: hard
        #expect(try tuning.weights(category: 3) == [800, 400, 400, 800, 1600, 400, 1600])    // Romance: easy
    }

    /// `ToFixed1000` multiplies as a 32-bit float and truncates; `FracMul` cuts the product to 32
    /// bits before dividing.
    @Test func keepsFreeSOsFixedPointQuirks() {
        #expect(MotiveTuning.fixed1000(0.001429) == 1 && MotiveTuning.fixed1000(-0.0019) == -1)
        #expect(MotiveTuning.fixed1000(0.315) == 315)  // the float is 0.3149999…, but its product rounds to 315
        #expect(MotiveTuning.fixed1000(3e9) == nil && MotiveTuning.fixed1000(.nan) == nil)
        #expect(MotiveTuning.fracMul(100_000, 500) == 50_000)
        // 3,000,000 × 2,000 is 6e9, which wraps to 1,705,032,704 before dividing.
        #expect(MotiveTuning.fracMul(3_000_000, 2_000) == 1_705_032)
    }

    @Test func refusesTuningItCantUse() {
        func tuning(_ change: (inout [(key: String, value: String)]) -> Void, weight: String = "1") throws(SimAnticsError) {
            var values = mockSimMotives
            change(&values)
            _ = try MotiveTuning(simMotives: TuningFile.Entry(name: "simmotives", values: values), lotMotives: lotMotives(weight: weight))
        }
        #expect(throws: SimAnticsError.simantics("tuning.dat's simmotives has no number for EnergySpan")) {
            try tuning { $0.removeAll { $0.key == "EnergySpan" } }
        }
        #expect(throws: SimAnticsError.simantics("tuning.dat's simmotives has no number for WakeHours")) {
            try tuning { $0[8].value = "lots" }
        }
        #expect(throws: SimAnticsError.simantics("tuning.dat's simmotives WakeHours is 0, which Energy divides by")) {
            try tuning { $0[8].value = "0.9" }  // truncated to 0
        }
        #expect(throws: SimAnticsError.simantics("tuning.dat's lotmotives None_HungerWeight is out of range")) {
            try tuning({ _ in }, weight: "1e30")
        }
    }

    /// A fake install has no tuning.dat, so there's no motive tuning (Simburbia's defaults fill in
    /// only under an install's own file): the first Sim's tick says so, once, and its motives stay put.
    @Test func noTuningIsReportedOnceAndNothingDecays() throws {
        try withVM(chairWords: [7: 2]) { vm, _ throws in
            let sim = try #require(try vm.createObject(guid: chairGUID)?.objects.first)
            let before = vm.reportedErrors.count  // the bare person's missing body strings
            vm.clock.minutes = 5
            sim.decayMotives()
            sim.decayMotives()
            #expect(vm.reportedErrors.dropFirst(before).map(\.error) == [.content(.missingFile("tuning.dat"))])
            #expect(sim.motiveData[Motive.hunger] == 100 && sim.sim.lastMinute == 0)
        }
    }
}

@Suite struct MotiveDecayTests {
    /// Worked out by hand from FreeSO's `VMAvatarMotiveDecay.Tick` on the mock tuning.
    @Test func decaysOnceAMinuteWithFreeSOsWraps() throws {
        try withMockSim { vm, sim throws in
            // Minute 0 is where decay starts: only the room score is set.
            sim.motiveData[Motive.room] = 50
            sim.decayMotives()
            #expect(sim.motiveData[Motive.room] == 0 && sim.sim.motiveFractions == [0, 0, 0, 0, 0, 0, 0])

            vm.clock.minutes = 1
            sim.decayMotives()
            // Hunger's 100,000 and Bladder's 50,500 and Social's 50,125 wrap as shorts.
            #expect(sim.sim.motiveFractions == [-31_072, 500, 500, -15_036, 104, 500, -15_411])
            #expect(sim.motiveData[Motive.hunger] == 100 && sim.motiveData[Motive.mood] == 87)  // 700 / 8
            sim.decayMotives()  // the same minute: nothing more
            #expect(sim.sim.motiveFractions[1] == 500)

            vm.clock.minutes = 2
            sim.decayMotives()
            // Hunger's sum wraps back to 3,392: 3 points off. Bladder's rate uses Hunger at 97.
            #expect(sim.motiveData[Motive.hunger] == 97 && sim.motiveData[Motive.comfort] == 99)
            #expect(sim.motiveData[Motive.hygiene] == 99 && sim.motiveData[Motive.fun] == 99)
            #expect(sim.sim.motiveFractions == [392, 0, 0, -30_822, 208, 0, -30_822])
            #expect(sim.motiveData[Motive.mood] == 86)  // 694 / 8
            #expect(vm.reportedErrors.isEmpty)
        }
    }

    @Test func aSleepingSimUsesTheAsleepRatesAndLosesNoFun() throws {
        try withMockSim { vm, sim throws in
            sim.motiveData[Motive.sleepState] = 1
            vm.clock.minutes = 1
            sim.decayMotives()
            #expect(sim.sim.motiveFractions[2] == 250 && sim.sim.motiveFractions[5] == 0)
            // Bladder: 250 plus half of Hunger's 100,000, as a short.
            #expect(sim.sim.motiveFractions[3] == Int16(truncatingIfNeeded: 50_250))
        }
    }

    @Test func motivesStopAtMinusOneHundred() throws {
        try withMockSim { vm, sim throws in
            sim.motiveData[Motive.comfort] = -100
            sim.sim.motiveFractions[1] = 999
            vm.clock.minutes = 1
            sim.decayMotives()
            #expect(sim.motiveData[Motive.comfort] == -100 && sim.sim.motiveFractions[1] == 499)
        }
    }

    @Test func aCategoryPastTheLastIsReportedEachMinute() throws {
        try withMockSim { vm, sim throws in
            vm.propertyCategory = 12
            vm.clock.minutes = 1
            sim.decayMotives()
            vm.clock.minutes = 2
            sim.decayMotives()
            #expect(vm.reportedErrors.map(\.error) == [.indexOutOfRange("property category 12"), .indexOutOfRange("property category 12")])
            #expect(sim.motiveData[Motive.mood] == 100)
        }
    }
}

@Suite struct MotiveChangeTests {
    /// 9,000 an hour is exactly a point a tick (9,000 / 60 / 30 / 5).
    @Test func changesAPointATickUpToTheLimit() throws {
        try withMockSim { _, sim throws in
            sim.setMotiveChange(Motive.fun, perHour: 9000, max: 52)
            #expect(sim.sim.motiveChanges[Motive.fun].perHourChange == 0, "a change that hasn't ticked can't be set")
            sim.tickMotiveChange(Motive.fun)
            sim.setMotiveChange(Motive.fun, perHour: 9000, max: 52)
            sim.motiveData[Motive.fun] = 50
            for _ in 0..<4 { sim.tickMotiveChange(Motive.fun) }
            #expect(sim.motiveData[Motive.fun] == 52)
            // It stays set at the limit, as FreeSO's does.
            #expect(sim.sim.motiveChanges[Motive.fun].perHourChange == 9000)
        }
    }

    @Test func gathersFractionsAndLeavesAMotivePastItsLimitAlone() throws {
        try withMockSim { _, sim throws in
            sim.tickMotiveChange(Motive.social)
            sim.setMotiveChange(Motive.social, perHour: -4500, max: 0)  // half a point down a tick
            sim.motiveData[Motive.social] = 10
            sim.tickMotiveChange(Motive.social)
            #expect(sim.motiveData[Motive.social] == 10 && sim.sim.motiveChanges[Motive.social].fractional == -0.5)
            sim.tickMotiveChange(Motive.social)
            #expect(sim.motiveData[Motive.social] == 9 && sim.sim.motiveChanges[Motive.social].fractional == 0)

            sim.motiveData[Motive.social] = -5  // already past the limit: the fraction keeps growing
            for _ in 0..<4 { sim.tickMotiveChange(Motive.social) }
            #expect(sim.motiveData[Motive.social] == -5 && sim.sim.motiveChanges[Motive.social].fractional == -2)
        }
    }

    @Test func clearingStopsEveryChange() throws {
        try withMockSim { _, sim throws in
            sim.tickMotiveChange(Motive.hunger)
            sim.setMotiveChange(Motive.hunger, perHour: 100, max: 5)
            sim.clearMotiveChanges()
            #expect(sim.sim.motiveChanges.allSatisfy { $0.perHourChange == 0 && $0.maxValue == .max })
        }
    }
}

@Suite struct SetMotiveChangeTests {
    private typealias Operand = Primitives.SetMotiveChange.Operand

    @discardableResult
    private func run(_ operand: Operand, on vm: VM, caller: Entity) throws(SimAnticsError) -> ExitCode {
        let (prepared, frame) = try vm.makePrimitiveFrame(opcode: 29, operand: operand.encoded(), caller: caller)
        return try prepared.execute(in: frame)
    }

    @Test func readsTheOperandAsFreeSODoes() {
        let operand = Operand(bytes: [8, 7, 4, 3, 0x10, 0, 0xFF, 0xFF])
        #expect(operand.delta == Variable(.temps, 16) && operand.max == Variable(.literal, -1))
        #expect(operand.motive == 4 && operand.clearsAll && operand.once)
        #expect(operand.encoded() == [8, 7, 4, 3, 0x10, 0, 0xFF, 0xFF])
    }

    @Test func onceMovesTheMotiveScaledForTheLot() throws {
        try withMockSim { vm, sim throws in
            sim.motiveData[Motive.hunger] = 50
            let once = Operand(delta: Variable(.literal, 10), max: Variable(.literal, 55), motive: UInt8(Motive.hunger), flags: 2)
            #expect(try run(once, on: vm, caller: sim) == .gotoTrue)
            #expect(sim.motiveData[Motive.hunger] == 55)  // 60, stopped at the limit
            try run(once, on: vm, caller: sim)
            #expect(sim.motiveData[Motive.hunger] == 55)  // not past it, so it moves and stops again
            sim.motiveData[Motive.hunger] = 70
            try run(once, on: vm, caller: sim)
            #expect(sim.motiveData[Motive.hunger] == 70)  // already past: left alone
            // A Services lot gains half again: 10 becomes 15.
            vm.propertyCategory = 4
            sim.motiveData[Motive.comfort] = 0
            try run(Operand(delta: Variable(.literal, 10), max: Variable(.literal, 100), motive: UInt8(Motive.comfort), flags: 2), on: vm, caller: sim)
            #expect(sim.motiveData[Motive.comfort] == 15)
        }
    }

    @Test func setsAChangeAnHourAndClearsThemAll() throws {
        try withMockSim { vm, sim throws in
            sim.tickMotiveChange(Motive.energy)
            try run(Operand(delta: Variable(.literal, -30), max: Variable(.literal, -20), motive: UInt8(Motive.energy), flags: 0), on: vm, caller: sim)
            #expect(sim.sim.motiveChanges[Motive.energy] == {
                var change = SimState.MotiveChange()
                change.perHourChange = -30
                change.maxValue = -20
                return change
            }())
            try run(Operand(delta: Variable(.literal, 0), max: Variable(.literal, 0), motive: 0, flags: 1), on: vm, caller: sim)
            #expect(sim.sim.motiveChanges[Motive.energy].perHourChange == 0 && sim.sim.motiveChanges[Motive.energy].maxValue == .max)
        }
    }

    @Test func failsWhereFreeSOWould() throws {
        try withMockSim { vm, sim throws in
            // Mood doesn't decay, so it has no lot weight (FreeSO indexes the names with -1).
            #expect(throws: SimAnticsError.indexOutOfRange("motive 3 has no lot weight")) {
                try run(Operand(delta: Variable(.literal, 1), max: Variable(.literal, 1), motive: UInt8(Motive.mood), flags: 2), on: vm, caller: sim)
            }
            #expect(throws: SimAnticsError.indexOutOfRange("motive 16")) {
                try run(Operand(delta: Variable(.literal, 1), max: Variable(.literal, 1), motive: 16, flags: 2), on: vm, caller: sim)
            }
            let chair = try #require(try vm.createObject(guid: mockChairGUID)?.objects.first)
            #expect(throws: SimAnticsError.invalidCast("Set Motive Deltas needs a Sim to call it")) {
                try run(Operand(delta: Variable(.literal, 1), max: Variable(.literal, 1), motive: 0, flags: 1), on: vm, caller: chair)
            }
        }
    }
}
