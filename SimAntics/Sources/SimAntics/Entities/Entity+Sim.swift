import Foundation
import TSOContent
import TSOFiles

/// Indexes into a Sim's person data that Simburbia's code names (FreeSO's `VMPersonDataVariable`).
public enum PersonData {
    public static let moneyAmountOverHead = 1
    public static let neatPersonality = 7
    public static let isHousemate = 21
    public static let tickCounter = 27
    public static let priority = 33
    public static let personsAge = 58
    public static let skinColor = 60
    public static let incomingFriends = 61
    public static let gender = 65
    public static let isGhost = 68
    public static let skillLock = 70
    public static let renderDisplayFlags = 74
    public static let onlineJobID = 91
    public static let onlineJobGrade = 92
    public static let onlineJobXP = 93
    public static let onlineJobSickDays = 94
    public static let onlineJobStatusFlags = 98
    public static let numOutgoingFriends = 99
    /// The highest index (`PersonData` has 101 values).
    public static let last = 100
}

/// Indexes into a Sim's motives (FreeSO's `VMMotive`).
public enum Motive {
    public static let mood = 3
    public static let energy = 5
    public static let comfort = 6
    public static let hunger = 7
    public static let hygiene = 8
    public static let bladder = 9
    public static let sleepState = 11
    public static let room = 13
    public static let social = 14
    public static let fun = 15
    /// The highest index (16 motives).
    public static let last = 15
}

extension Entity {
    // MARK: Person data and motives

    /// A Sim's person data value, as `VMAvatar.GetPersonData` reads it in TSO mode: most are as
    /// stored, but some are worked out. Priority is the first queued action's, 0 with an empty
    /// queue (Simburbia has none yet); whether it's a housemate comes from its permissions; its
    /// friend counts from its relationships whose second value is 60 or more; Skill Lock reads 0;
    /// and the online job's grade, sick days, status flags, and experience come from the job its
    /// job ID names, 0 without one.
    ///
    /// - Throws: ``SimAnticsError/indexOutOfRange(_:)`` past 0 to 100, where FreeSO throws.
    public func personDatum(_ index: Int) throws(SimAnticsError) -> Int16 {
        guard (0...PersonData.last).contains(index) else { throw .indexOutOfRange("person data \(index)") }
        switch index {
        case PersonData.onlineJobGrade: return currentJob?.level ?? 0
        case PersonData.onlineJobSickDays: return currentJob?.sickDays ?? 0
        case PersonData.onlineJobStatusFlags: return currentJob?.statusFlags ?? 0
        case PersonData.onlineJobXP: return currentJob?.experience ?? 0
        case PersonData.priority: return 0
        case PersonData.isHousemate:
            return sim.permissions >= .buildBuyRoommate ? 2 : sim.permissions >= .roommate ? 1 : 0
        case PersonData.numOutgoingFriends, PersonData.incomingFriends:
            // FreeSO counts in key order; the count doesn't depend on it.
            return Int16(truncatingIfNeeded: sim.relationships.filter { $0.key < 16_777_216 && $0.value.count > 1 && $0.value[1] >= 60 }.count)
        case PersonData.skillLock: return 0
        default: return personData[index]
        }
    }

    /// Sets a Sim's person data value, as `VMAvatar.SetPersonData` does in TSO mode. Most are
    /// stored; some do something else. Setting the online job ID (to 4 or less; anything more is
    /// refused) starts that job, with status flags 1, if it's new; the job's grade, sick days,
    /// status flags, and experience go to the job, not to person data; Priority would change the
    /// running action's, and with no queue does nothing; Render Display Flags and Skill Lock aren't
    /// stored; Is Ghost tries to change Render Display Flags first, which does nothing. Returns
    /// whether it was set, as FreeSO's does.
    ///
    /// - Throws: ``SimAnticsError/indexOutOfRange(_:)`` past 0 to 100, where FreeSO throws.
    @discardableResult
    public func setPersonDatum(_ index: Int, to value: Int16) throws(SimAnticsError) -> Bool {
        guard (0...PersonData.last).contains(index) else { throw .indexOutOfRange("person data \(index)") }
        switch index {
        case PersonData.onlineJobID:
            guard value <= 4 else { return false }
            if sim.jobs[value] == nil { sim.jobs[value] = SimState.Job(statusFlags: 1) }
        case PersonData.onlineJobGrade:
            updateCurrentJob { $0.level = value }
            return true
        case PersonData.onlineJobSickDays:
            updateCurrentJob { $0.sickDays = value }
            return true
        case PersonData.onlineJobStatusFlags:
            updateCurrentJob { $0.statusFlags = value }
            return true
        case PersonData.onlineJobXP:
            updateCurrentJob { $0.experience = value }
            return true
        case PersonData.priority, PersonData.renderDisplayFlags, PersonData.skillLock:
            return true
        default:
            break
        }
        personData[index] = value
        return true
    }

    /// A Sim's motive (`VMAvatar.GetMotiveData`).
    ///
    /// - Throws: ``SimAnticsError/indexOutOfRange(_:)`` past 0 to 15, where FreeSO throws.
    public func motive(_ index: Int) throws(SimAnticsError) -> Int16 {
        guard (0...Motive.last).contains(index) else { throw .indexOutOfRange("motive \(index)") }
        return motiveData[index]
    }

    /// Sets a Sim's motive, kept within −100 to 100 (`VMAvatar.SetMotiveData`).
    ///
    /// - Throws: ``SimAnticsError/indexOutOfRange(_:)`` past 0 to 15, where FreeSO throws.
    public func setMotive(_ index: Int, to value: Int16) throws(SimAnticsError) {
        guard (0...Motive.last).contains(index) else { throw .indexOutOfRange("motive \(index)") }
        motiveData[index] = max(-100, min(100, value))
    }

    /// The job the online job ID names, if the Sim has it.
    private var currentJob: SimState.Job? {
        sim.jobs[personData[PersonData.onlineJobID]]
    }

    private func updateCurrentJob(_ change: (inout SimState.Job) -> Void) {
        let id = personData[PersonData.onlineJobID]
        guard var job = sim.jobs[id] else { return }
        change(&job)
        sim.jobs[id] = job
    }

    // MARK: Setting a Sim up

    /// Sets a Sim up as FreeSO's `VMAvatar` constructor and `Init` do, after the entity's own
    /// initialization has run its init entry point and pushed main.
    ///
    /// From its body strings (the `STR#` its definition's Body String ID names): its kind (entry
    /// 0), daywear (a random pick from entry 10, else entry 1) and head (entry 9, else 2), name (a
    /// random pick from entry 11), gender (12), age (13), and skin tone (14). Then its walk and swim
    /// animations (the global's `STR#` 150 and 158, then the object's `STR#` 150 over them), every
    /// motive at 100 but sleep state at 0, and Neat at 1000, FreeSO's own test value.
    ///
    /// Kept from FreeSO: an outfit pick draws `NextRandom(count − 1)`, so it never picks the last,
    /// and draws nothing with one choice; a name pick draws `NextRandom(count)`. An outfit that
    /// isn't hexadecimal stops the outfits there, so the head's pick isn't drawn.
    ///
    /// Where FreeSO crashes, Simburbia reports the problem against the Sim and carries on (DIFF-32
    /// in the scorecard): no body strings (an adult with nothing set), a missing gender, name list,
    /// age, or skin tone entry (treated as empty), an age that isn't a number (0), more than 50
    /// walk or swim animations (the rest left out), or no global walk or swim table.
    func setUpSim() {
        sim = SimState()
        let definition = object.definition
        let strings: StringTable?
        do {
            strings = try object.resource.chunk(STR.self, id: definition.bodyStringID)?.table
        } catch {
            vm.report(.simantics("the body strings (STR# \(definition.bodyStringID)) don't parse: \(error)"), by: self)
            strings = nil
        }
        if let strings {
            applyBodyStrings(strings)
        } else {
            vm.report(.simantics("a Sim with no body strings (STR# \(definition.bodyStringID))"), by: self)
        }
        loadWalkAndSwimAnimations()
        for index in 0...Motive.last { motiveData[index] = 100 }
        motiveData[Motive.sleepState] = 0
        personData[PersonData.neatPersonality] = 1000
    }

    private func applyBodyStrings(_ strings: StringTable) {
        func entry(_ index: Int) -> String? { strings.string(at: index) }
        // `SetAvatarType`, in the constructor.
        switch entry(0) {
        case "child": sim.kind = .child
        case "cat", "kat": sim.kind = .cat
        case "dog": sim.kind = .dog
        default: sim.kind = .adult
        }
        // `SetAvatarBodyStrings`: the outfits, in FreeSO's one try block.
        outfits: do {
            let body = entry(1) ?? "", randomBody = entry(10) ?? ""
            if !randomBody.isEmpty {
                let choices = randomBody.split(separator: ";", omittingEmptySubsequences: false)
                let pick = Int(vm.random.next(below: UInt64(choices.count - 1)))
                guard let id = Self.outfitID(String(choices[pick])) else { break outfits }
                sim.daywear = id
            } else if !body.isEmpty {
                guard let id = Self.outfitID(body) else { break outfits }
                sim.daywear = id
            }
            sim.bodyOutfit = sim.daywear
            let head = entry(2) ?? "", randomHead = entry(9) ?? ""
            if !randomHead.isEmpty {
                let choices = randomHead.split(separator: ";", omittingEmptySubsequences: false)
                let pick = Int(vm.random.next(below: UInt64(choices.count - 1)))
                guard let id = Self.outfitID(String(choices[pick])) else { break outfits }
                sim.headOutfit = id
            } else if !head.isEmpty {
                guard let id = Self.outfitID(head) else { break outfits }
                sim.headOutfit = id
            }
        }
        var missing: [Int] = []
        func required(_ index: Int) -> String {
            if let value = entry(index) { return value }
            missing.append(index)
            return ""
        }
        switch required(12).lowercased() {
        case "male": personData[PersonData.gender] = 0
        case "female": personData[PersonData.gender] = 1
        case "dogmale": personData[PersonData.gender] = 8
        case "dogfemale": personData[PersonData.gender] = 9
        case "catmale": personData[PersonData.gender] = 16
        case "catfemale": personData[PersonData.gender] = 17
        default: break
        }
        let names = required(11)
        if !names.isEmpty {
            let choices = names.split(separator: ";", omittingEmptySubsequences: false)
            sim.name = String(choices[Int(vm.random.next(below: UInt64(choices.count)))])
        }
        // `Convert.ToInt16`: a missing entry is 0, as null converts; anything else must be a number.
        if let age = entry(13) {
            if let value = Int16(age.trimmingCharacters(in: .whitespacesAndNewlines)) {
                personData[PersonData.personsAge] = value
            } else {
                vm.report(.simantics("the Sim's age \(age.debugDescription) isn't a number"), by: self)
            }
        }
        switch required(14).lowercased() {
        case "med": sim.skinTone = .medium
        case "drk": sim.skinTone = .dark
        case "lgt": sim.skinTone = .light
        default: break
        }
        if !missing.isEmpty {
            vm.report(.simantics("the body strings have no entry \(missing.map(String.init).joined(separator: ", "))"), by: self)
        }
    }

    /// An outfit ID as .NET's `Convert.ToUInt64(text, 16)` reads one: hexadecimal digits, with an
    /// optional `0x`, and nothing else; `nil` where it throws.
    static func outfitID(_ text: String) -> UInt64? {
        let digits = text.lowercased().hasPrefix("0x") ? text.dropFirst(2) : Substring(text)
        guard !digits.isEmpty, digits.allSatisfy(\.isHexDigit) else { return nil }
        return UInt64(digits, radix: 16)
    }

    /// `InitBodyData`: the global's adult walk and swim animations, then the object's own walk
    /// animations over them where it names one.
    private func loadWalkAndSwimAnimations() {
        func table(_ id: UInt16, from resource: any IFFResource) -> StringTable? {
            do {
                return try resource.chunk(STR.self, id: id)?.table
            } catch {
                vm.report(.simantics("STR# \(id) doesn't parse: \(error)"), by: self)
                return nil
            }
        }
        func fill(_ slots: inout [String?], from strings: StringTable, skipsEmpty: Bool, what: String) {
            if strings.count > SimState.animationSlots {
                vm.report(.simantics("\(strings.count) \(what) animations, of which only \(SimState.animationSlots) fit"), by: self)
            }
            for index in 0..<min(strings.count, SimState.animationSlots) {
                guard let name = strings.string(at: index) else { continue }
                if skipsEmpty && name.isEmpty { continue }
                slots[index] = name
            }
        }
        if let walk = table(150, from: vm.global) {
            fill(&sim.walkAnimations, from: walk, skipsEmpty: false, what: "walk")
        } else {
            vm.report(.simantics("the global has no walk animations (STR# 150)"), by: self)
        }
        if let swim = table(158, from: vm.global) {
            fill(&sim.swimAnimations, from: swim, skipsEmpty: false, what: "swim")
        } else {
            vm.report(.simantics("the global has no swim animations (STR# 158)"), by: self)
        }
        if let special = table(150, from: object.resource) {
            fill(&sim.walkAnimations, from: special, skipsEmpty: true, what: "walk")
        }
    }

    /// A player's saved state applied to a Sim that has joined (`VMNetAvatarPersistState.Apply`),
    /// through ``setPersonDatum(_:to:)`` as FreeSO's goes through `SetPersonData`.
    func apply(_ identity: SimIdentity) throws(SimAnticsError) {
        sim.skinTone = SimState.SkinTone(rawValue: identity.skinTone) ?? .light
        for (offset, index) in SimIdentity.personDataMap.enumerated() {
            try setPersonDatum(index, to: identity.personData[offset])
        }
        try setPersonDatum(PersonData.skinColor, to: Int16(identity.skinTone))
        sim.daywear = identity.daywear
        sim.swimwear = identity.swimwear
        sim.sleepwear = identity.sleepwear
        sim.bodyOutfit = identity.bodyOutfit
        sim.headOutfit = identity.headOutfit
        sim.name = identity.name
        sim.permissions = identity.permissions
        persistID = identity.persistID
        for index in 0...Motive.last { try setMotive(index, to: identity.motives[index]) }
        sim.relationships = identity.relationships
        sim.jobs = identity.jobs
        if identity.isWorker { try setPersonDatum(PersonData.onlineJobStatusFlags, to: 1) }
        personData[PersonData.skillLock] = identity.skillLock
    }

    // MARK: A Sim's tick

    /// What a Sim does each tick after its thread (`VMAvatar.Tick`), in FreeSO's order: the online
    /// job status flag that FreeSO sets to 1 whenever it's 0 (stored, though reading it goes to
    /// the job); motive decay (``decayMotives()``); a Sim out of the world tries again to find a
    /// place by the first mailbox part, in object ID order; each motive's change
    /// (``tickMotiveChange(_:)``); and the tick counter. Animations, the debugger's pause, and
    /// leaving the lot come with later phases.
    ///
    /// Where FreeSO's retry would fail and stop the lot, Simburbia reports it against the Sim.
    func tickSim() {
        if personData[PersonData.onlineJobStatusFlags] == 0 { personData[PersonData.onlineJobStatusFlags] = 1 }
        decayMotives()
        if position.isOutOfWorld, let mailbox = vm.entities.first(where: { VM.mailboxGUIDs.contains($0.object.guid) }) {
            do {
                _ = try vm.findLocation(for: self, near: mailbox, flags: [])
            } catch {
                vm.report(error, by: self)
            }
        }
        for index in sim.motiveChanges.indices { tickMotiveChange(index) }
        personData[PersonData.tickCounter] &+= 1
    }
}
