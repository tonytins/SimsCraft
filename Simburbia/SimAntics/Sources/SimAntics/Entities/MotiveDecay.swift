import TSOFiles

/// The global motive tuning a Sim's decay and Set Motive Deltas read: `tuning.dat`'s
/// `simmotives` and `lotmotives` entries, as FreeSO's `VMAvatarMotiveDecay` reads them, each
/// value already in thousandths (``fixed1000(_:)``).
///
/// They come from ``GameContent/globalTuning()``: Simburbia's defaults with the install's
/// `tuning.dat` laid over them, so 1.1097.1.0 runs on its own values and the unpatched 2002 and
/// beta discs, which lack them, on Simburbia's (DIFF-33).
///
/// FreeSO looks every value up as it needs it, and fails on the first that's missing; Simburbia
/// reads them all once, when a VM's first Sim needs them, and fails if any is missing or can't be
/// used.
struct MotiveTuning: Sendable, Equatable {
    /// The lot categories by property category (`VMAvatarMotiveDecay.CategoryNames`).
    static let categoryNames = ["None", "Money", "Offbeat", "Romance", "Services", "Shopping", "Skills", "Welcome",
                                "Games", "Entertain", "Residence"]
    /// The motives that decay, in the order they're worked out (`DecrementMotives`).
    static let decrementMotives = [Motive.hunger, Motive.comfort, Motive.hygiene, Motive.bladder, Motive.energy,
                                   Motive.fun, Motive.social]
    /// Their names in `lotmotives` (`LotMotiveNames`), in the same order.
    static let lotMotiveNames = ["Hunger", "Comfort", "Hygiene", "Bladder", "Energy", "Fun", "Social"]

    let hungerDecrementRatio: Int32
    let comfortDecrementActive: Int32
    let hygieneDecrementAwake: Int32
    let hygieneDecrementAsleep: Int32
    let bladderDecrementAwake: Int32
    let bladderDecrementAsleep: Int32
    let hungerToBladderMultiplier: Int32
    let entDecrementAwake: Int32
    let socialDecrementBase: Int32
    let socialDecrementMultiplier: Int32
    /// Energy's fixed loss a minute: `EnergySpan` in thousandths over 60 times `WakeHours`
    /// (truncated to a whole number first, as FreeSO casts it).
    let energyPerMinute: Int32
    /// Each category's weights for the seven decaying motives, in ``decrementMotives`` order.
    let weights: [[Int32]]

    init(_ tuning: TuningFile) throws(SimAnticsError) {
        guard let sim = tuning.entry(named: "simmotives") else { throw .simantics("tuning.dat has no simmotives") }
        guard let lot = tuning.entry(named: "lotmotives") else { throw .simantics("tuning.dat has no lotmotives") }
        try self.init(simMotives: sim, lotMotives: lot)
    }

    init(simMotives sim: TuningFile.Entry, lotMotives lot: TuningFile.Entry) throws(SimAnticsError) {
        func number(_ entry: TuningFile.Entry, _ key: String) throws(SimAnticsError) -> Float {
            guard let value = entry.number(forKey: key) else {
                throw .simantics("tuning.dat's \(entry.name) has no number for \(key)")
            }
            return value
        }
        func fixed(_ entry: TuningFile.Entry, _ key: String) throws(SimAnticsError) -> Int32 {
            guard let value = Self.fixed1000(try number(entry, key)) else {
                throw .simantics("tuning.dat's \(entry.name) \(key) is out of range")
            }
            return value
        }
        hungerDecrementRatio = try fixed(sim, "HungerDecrementRatio")
        comfortDecrementActive = try fixed(sim, "ComfortDecrementActive")
        hygieneDecrementAwake = try fixed(sim, "HygieneDecrementAwake")
        hygieneDecrementAsleep = try fixed(sim, "HygieneDecrementAsleep")
        bladderDecrementAwake = try fixed(sim, "BladderDecrementAwake")
        bladderDecrementAsleep = try fixed(sim, "BladderDecrementAsleep")
        hungerToBladderMultiplier = try fixed(sim, "HungerToBladderMultiplier")
        entDecrementAwake = try fixed(sim, "EntDecrementAwake")
        socialDecrementBase = try fixed(sim, "SocialDecrementBase")
        socialDecrementMultiplier = try fixed(sim, "SocialDecrementMultiplier")
        let wakeHours = try number(sim, "WakeHours").rounded(.towardZero)
        guard let hours = Int32(exactly: wakeHours) else { throw .simantics("tuning.dat's simmotives WakeHours is out of range") }
        // C#'s int arithmetic wraps; a multiple of 60 is never -1, so the division can't overflow.
        let minutes = 60 &* hours
        guard minutes != 0 else { throw .simantics("tuning.dat's simmotives WakeHours is 0, which Energy divides by") }
        energyPerMinute = try fixed(sim, "EnergySpan") / minutes
        var weights: [[Int32]] = []
        for category in Self.categoryNames {
            var row: [Int32] = []
            for name in Self.lotMotiveNames { row.append(try fixed(lot, "\(category)_\(name)Weight")) }
            weights.append(row)
        }
        self.weights = weights
    }

    /// The weights for a lot's property category.
    ///
    /// - Throws: ``SimAnticsError/indexOutOfRange(_:)`` past the last category, where FreeSO's
    ///   lookup of the category's name fails.
    func weights(category: UInt8) throws(SimAnticsError) -> [Int32] {
        guard Int(category) < weights.count else { throw .indexOutOfRange("property category \(category)") }
        return weights[Int(category)]
    }

    /// A tuning number in thousandths (`ToFixed1000`): multiplied by 1000 as a 32-bit float, then
    /// truncated; `nil` if that's not a 32-bit integer.
    static func fixed1000(_ value: Float) -> Int32? {
        Int32(exactly: (value * 1000).rounded(.towardZero))
    }

    /// Thousandths times thousandths (`FracMul`). As in FreeSO, the 64-bit product is cut to 32
    /// bits before it's divided.
    static func fracMul(_ value: Int32, _ fraction: Int32) -> Int32 {
        Int32(truncatingIfNeeded: Int64(value) * Int64(fraction)) / 1000
    }
}

extension VM {
    /// The motive tuning, read from the content on first use and kept, failure included; `isNew`
    /// is true on the call that read it, so a failure is reported once.
    func motiveTuning() -> (tuning: Result<MotiveTuning, SimAnticsError>, isNew: Bool) {
        if let motiveTuningStorage { return (motiveTuningStorage, false) }
        let tuning: Result<MotiveTuning, SimAnticsError>
        do throws(SimAnticsError) {
            let file: TuningFile
            do {
                file = try content.globalTuning().tuning
            } catch {
                throw .content(error)
            }
            tuning = .success(try MotiveTuning(file))
        } catch {
            tuning = .failure(error)
        }
        motiveTuningStorage = tuning
        return (tuning, true)
    }

    /// Set Motive Deltas' rate in TSO mode (`VMMotiveChange.ScaleRate`): half again on a Services
    /// lot (category 4) for any motive past the first; Comfort as it is; the other decaying
    /// motives over their lot weight.
    ///
    /// - Throws: An error where FreeSO's would fail: the tuning can't be read, the motive doesn't
    ///   decay (FreeSO indexes its names with -1), the category is past the last, or the weight is
    ///   0 (a division by zero).
    func scaledMotiveRate(_ rate: Int32, motive: Int) throws(SimAnticsError) -> Int32 {
        let tuning = try motiveTuning().tuning.get()
        var rate = rate
        if propertyCategory == 4 && motive > 0 { rate = rate &* 3 / 2 }
        if motive == Motive.comfort { return rate }
        guard let index = MotiveTuning.decrementMotives.firstIndex(of: motive) else {
            throw .indexOutOfRange("motive \(motive) has no lot weight")
        }
        let weight = try tuning.weights(category: propertyCategory)[index]
        guard weight != 0 else { throw .simantics("the lot weight for motive \(motive) is 0, which the rate divides by") }
        // Rates come from 16-bit values, so neither the product nor the division overflows.
        return rate &* 1000 / weight
    }
}

extension Entity {
    /// A Sim's motive decay each tick (`VMAvatarMotiveDecay.Tick`): the Room motive becomes its
    /// room's score; then, once each game minute, the seven decaying motives each gain their rate
    /// in thousandths of a point and lose whole points, no lower than -100, and Mood becomes the
    /// sum of those seven and the room score over 8.
    ///
    /// Kept from FreeSO: a minute's rate is cut to 16 bits before it's added, and the thousandths
    /// wrap as a `short` does, so a rate past 32,767 can come out negative (the mock install's
    /// Hunger does), and points come off only on the minutes the sum wraps back past 1,000. Hunger's rate is worked out again for Bladder
    /// after Hunger has dropped. Mood counts the motives as they are, even ones that haven't
    /// changed. The first minute that passes is any minute but 0, since decay starts at minute 0.
    ///
    /// Where FreeSO would fail, Simburbia reports it and the Sim doesn't decay: with no
    /// `tuning.dat` or unusable motive tuning (reported once per VM), or with a property category
    /// past the last (reported each game minute).
    func decayMotives() {
        let (result, isNew) = vm.motiveTuning()
        let tuning: MotiveTuning
        switch result {
        case .success(let value): tuning = value
        case .failure(let error):
            if isNew { vm.report(error, by: self) }
            return
        }
        let roomScore = vm.roomScore(vm.architecture.room(at: position))
        motiveData[Motive.room] = Self.clampedMotive(Int32(roomScore))
        guard vm.clock.minutes != sim.lastMinute else { return }
        sim.lastMinute = vm.clock.minutes
        let weights: [Int32]
        do {
            weights = try tuning.weights(category: vm.propertyCategory)
        } catch {
            vm.report(error, by: self)
            return
        }
        let asleep = motiveData[Motive.sleepState] != 0
        var moodSum: Int32 = 0
        for (index, motiveIndex) in MotiveTuning.decrementMotives.enumerated() {
            let weight = weights[index]
            var motive = motiveData[motiveIndex]
            let hunger = MotiveTuning.fracMul(tuning.hungerDecrementRatio &* (100 + Int32(motiveData[Motive.hunger])), weights[0])
            let rate: Int32 = switch index {
            case 0: hunger
            case 1: MotiveTuning.fracMul(tuning.comfortDecrementActive, weight)
            case 2: MotiveTuning.fracMul(asleep ? tuning.hygieneDecrementAsleep : tuning.hygieneDecrementAwake, weight)
            case 3: MotiveTuning.fracMul(asleep ? tuning.bladderDecrementAsleep : tuning.bladderDecrementAwake, weight)
                &+ MotiveTuning.fracMul(hunger, tuning.hungerToBladderMultiplier)
            case 4: tuning.energyPerMinute
            case 5: asleep ? 0 : MotiveTuning.fracMul(tuning.entDecrementAwake, weight)
            default: (tuning.socialDecrementBase &+ MotiveTuning.fracMul(tuning.socialDecrementMultiplier &* (100 + Int32(motive)), weight)) / 2
            }
            sim.motiveFractions[index] &+= Int16(truncatingIfNeeded: rate)
            if sim.motiveFractions[index] >= 1000 {
                motive &-= sim.motiveFractions[index] / 1000
                sim.motiveFractions[index] %= 1000
                motive = max(motive, -100)
                motiveData[motiveIndex] = Self.clampedMotive(Int32(motive))
            }
            moodSum &+= Int32(motive)
        }
        moodSum &+= Int32(roomScore)
        motiveData[Motive.mood] = Self.clampedMotive(Int32(Int16(truncatingIfNeeded: moodSum / 8)))
    }

    /// One motive's change this tick (`VMMotiveChange.Tick` in TSO mode): the rate a tick is the
    /// change an hour over 60, then 30, then 5 (FreeSO's timing for 5-second minutes, in TSO's
    /// fifth of that), gathered until it makes a whole point. A motive already past the change's
    /// limit is left alone, its fraction still growing; one that would go past it stops there.
    /// The change stays set when the motive reaches its limit, as FreeSO's does.
    ///
    /// The whole points are cut to 16 bits as .NET 9 and later do it, saturating; FreeSO built
    /// on older .NET would wrap, but only a fraction kept growing for days past the limit gets
    /// that far. The arithmetic is IEEE double, so it's the same on every machine.
    func tickMotiveChange(_ index: Int) {
        sim.motiveChanges[index].ticked = true
        let change = sim.motiveChanges[index]
        guard change.perHourChange != 0 else { return }
        var rate = Double(change.perHourChange) / 60.0 / 30.0
        rate /= 5
        let fractional = change.fractional + rate
        sim.motiveChanges[index].fractional = fractional
        guard abs(fractional) >= 1 else { return }
        func isPastLimit(_ motive: Int16) -> Bool {
            (rate > 0 && motive > change.maxValue) || (rate < 0 && motive < change.maxValue)
        }
        var motive = motiveData[index]
        if isPastLimit(motive) { return }
        let points = Int16(max(Double(Int16.min), min(Double(Int16.max), fractional.rounded(.towardZero))))
        motive &+= points
        sim.motiveChanges[index].fractional = fractional.truncatingRemainder(dividingBy: 1)
        if isPastLimit(motive) { motive = change.maxValue }
        motiveData[index] = Self.clampedMotive(Int32(motive))
    }

    /// Sets a motive change if it has ticked since it was last set (`VMAvatar.SetMotiveChange`);
    /// otherwise the call does nothing.
    func setMotiveChange(_ index: Int, perHour: Int16, max: Int16) {
        guard sim.motiveChanges[index].ticked else { return }
        sim.motiveChanges[index].perHourChange = perHour
        sim.motiveChanges[index].maxValue = max
        sim.motiveChanges[index].ticked = false
    }

    /// Stops every motive change (`VMAvatar.ClearMotiveChanges`): no change an hour, and the
    /// limit at 32,767.
    func clearMotiveChanges() {
        for index in sim.motiveChanges.indices {
            sim.motiveChanges[index].perHourChange = 0
            sim.motiveChanges[index].maxValue = .max
        }
    }

    /// A motive's value kept within -100 to 100, as `SetMotiveData` keeps it.
    static func clampedMotive(_ value: Int32) -> Int16 {
        Int16(max(-100, min(100, value)))
    }
}
