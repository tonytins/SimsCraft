import Foundation
import Testing
@testable import SimAntics
import TSOContent
import TSOFiles

/// A string table in format -1: a count, then C strings.
private func strChunk(id: UInt16, _ strings: [String]) -> ChunkFixture {
    var writer = ByteWriter()
    writer.int16(-1)
    writer.uint16(UInt16(strings.count))
    for string in strings { writer.raw(Array(string.utf8) + [0]) }
    return ChunkFixture(type: "STR#", id: id, contents: writer.bytes)
}

/// Body strings by index: 0 type, 1 body, 2 head, 9 random heads, 10 random bodies, 11 names,
/// 12 gender, 13 age, 14 skin tone.
private func bodyStrings(type: String = "adult", body: String = "", head: String = "", randomHeads: String = "",
                         randomBodies: String = "", names: String = "Pat", gender: String = "female", age: String = "27",
                         skin: String = "med") -> [String] {
    [type, body, head, "", "", "", "", "", "", randomHeads, randomBodies, names, gender, age, skin]
}

private let globalAnimations = [strChunk(id: 150, ["walk0", "walk1", "walk2"]), strChunk(id: 158, ["swim0"])]

/// A VM whose chair is a person (object type 2) with body strings in `STR#` 200, made with
/// `createObject`, as Sims are.
private func withSim(_ strings: [String]?, ownWalks: [String]? = nil,
                     _ body: (VM, Entity, VMRandom) throws -> Void) throws {
    var chunks: [ChunkFixture] = []
    if let strings { chunks.append(strChunk(id: 200, strings)) }
    if let ownWalks { chunks.append(strChunk(id: 150, ownWalks)) }
    try withVM(chair: chunks, chairWords: [7: 2, 17: 200], global: globalAnimations) { vm, _ throws in
        let before = vm.random
        let sim = try #require(try vm.createObject(guid: chairGUID)?.objects.first)
        try body(vm, sim, before)
    }
}

@Suite struct SimSetupTests {
    @Test func setsASimUpFromItsBodyStrings() throws {
        try withSim(bodyStrings(body: "0x1A0000000D", head: "2B0000000D"), ownWalks: ["", "mywalk"]) { vm, sim, _ throws in
            #expect(sim.isAvatar && sim.sim.kind == .adult)
            #expect(sim.sim.daywear == 0x1A_0000_000D && sim.sim.bodyOutfit == 0x1A_0000_000D && sim.sim.headOutfit == 0x2B_0000_000D)
            #expect(sim.sim.name == "Pat" && sim.sim.skinTone == .medium)
            #expect(try sim.personDatum(PersonData.gender) == 1 && sim.personDatum(PersonData.personsAge) == 27)
            #expect(try sim.personDatum(PersonData.neatPersonality) == 1000)
            // Every motive at 100 but sleep state.
            #expect((0...Motive.last).allSatisfy { $0 == Motive.sleepState ? sim.motiveData[$0] == 0 : sim.motiveData[$0] == 100 })
            // The global's walks, then the object's over them where it names one.
            #expect(Array(sim.sim.walkAnimations.prefix(3)) == ["walk0", "mywalk", "walk2"] && sim.sim.swimAnimations[0] == "swim0")
            #expect(vm.reportedErrors.isEmpty)
        }
    }

    /// FreeSO's draws: an outfit list draws `NextRandom(count − 1)`, a name list `NextRandom(count)`.
    @Test func picksOutfitsAndNamesWithFreeSOsDraws() throws {
        let strings = bodyStrings(randomHeads: "0x1;0x2", randomBodies: "0xA;0xB;0xC", names: "Ann;Bo;Cy")
        try withSim(strings) { vm, sim, before throws in
            var random = before
            let body = random.next(below: 2), head = random.next(below: 1), name = random.next(below: 3)
            #expect(sim.sim.daywear == [0xA, 0xB, 0xC][Int(body)] && sim.sim.headOutfit == [0x1, 0x2][Int(head)])
            #expect(sim.sim.name == ["Ann", "Bo", "Cy"][Int(name)])
            #expect(vm.random == random)
        }
    }

    @Test func oneChoiceDrawsNothingButOneNameDoes() throws {
        try withSim(bodyStrings(randomBodies: "0x5", names: "Solo")) { vm, sim, before throws in
            var random = before
            _ = random.next(below: 1)  // the name; the single body draws nothing
            #expect(sim.sim.daywear == 0x5 && vm.random == random)
        }
    }

    @Test func anOutfitThatIsntHexadecimalStopsTheOutfits() throws {
        try withSim(bodyStrings(body: "not hex", randomHeads: "0x1;0x2")) { vm, sim, before throws in
            var random = before
            _ = random.next(below: 1)  // only the name: the head's pick is never drawn
            #expect(sim.sim.bodyOutfit == 0 && sim.sim.headOutfit == 0 && vm.random == random)
            #expect(sim.sim.name == "Pat" && vm.reportedErrors.isEmpty)
        }
    }

    /// Where FreeSO crashes (DIFF-32), Simburbia reports against the Sim and carries on.
    @Test func reportsWhatFreeSOWouldCrashOn() throws {
        try withSim(nil) { vm, sim, _ throws in
            #expect(sim.sim.kind == .adult && sim.motiveData[Motive.hunger] == 100)
            #expect(vm.reportedErrors.map(\.error) == [.simantics("a Sim with no body strings (STR# 200)")])
        }
        try withSim(Array(bodyStrings(age: "old").prefix(14))) { vm, sim, _ throws in
            #expect(try sim.personDatum(PersonData.personsAge) == 0 && sim.sim.skinTone == .light)
            #expect(vm.reportedErrors.map(\.error) == [.simantics("the Sim's age \"old\" isn't a number"),
                                                       .simantics("the body strings have no entry 14")])
        }
    }
}

@Suite struct PersonDataTests {
    @Test func someValuesAreWorkedOutNotStored() throws {
        try withSim(bodyStrings()) { _, sim, _ throws in
            // Priority with no queue, Skill Lock, and Render Display Flags aren't stored.
            #expect(try sim.setPersonDatum(PersonData.priority, to: 9) && sim.personDatum(PersonData.priority) == 0)
            try sim.setPersonDatum(PersonData.skillLock, to: 5)
            try sim.setPersonDatum(PersonData.renderDisplayFlags, to: 3)
            #expect(sim.personData[PersonData.skillLock] == 0 && sim.personData[PersonData.renderDisplayFlags] == 0)
            // Is Ghost is stored; its change to Render Display Flags does nothing.
            try sim.setPersonDatum(PersonData.isGhost, to: 1)
            #expect(try sim.personDatum(PersonData.isGhost) == 1 && sim.personDatum(PersonData.renderDisplayFlags) == 0)
            // Housemates by permission.
            sim.sim.permissions = .roommate
            #expect(try sim.personDatum(PersonData.isHousemate) == 1)
            sim.sim.permissions = .owner
            #expect(try sim.personDatum(PersonData.isHousemate) == 2)
            // Friends: relationships whose second value is 60 or more, to Sims (persist IDs under 2^24).
            sim.sim.relationships = [5: [0, 60], 6: [0, 59], 1 << 24: [0, 90], 7: [80]]
            #expect(try sim.personDatum(PersonData.numOutgoingFriends) == 1 && sim.personDatum(PersonData.incomingFriends) == 1)
        }
    }

    @Test func onlineJobValuesGoToTheJobTheIDNames() throws {
        try withSim(bodyStrings()) { _, sim, _ throws in
            #expect(try sim.setPersonDatum(PersonData.onlineJobID, to: 5) == false)
            #expect(try sim.personDatum(PersonData.onlineJobID) == 0)
            // No job yet: the grade isn't kept anywhere.
            try sim.setPersonDatum(PersonData.onlineJobGrade, to: 3)
            #expect(try sim.personDatum(PersonData.onlineJobGrade) == 0)
            try sim.setPersonDatum(PersonData.onlineJobID, to: 2)
            #expect(try sim.sim.jobs[2] == SimState.Job(statusFlags: 1) && sim.personDatum(PersonData.onlineJobStatusFlags) == 1)
            try sim.setPersonDatum(PersonData.onlineJobGrade, to: 3)
            #expect(try sim.personDatum(PersonData.onlineJobGrade) == 3 && sim.personData[PersonData.onlineJobGrade] == 0)
        }
    }

    @Test func boundsAndMotiveLimits() throws {
        try withSim(bodyStrings()) { _, sim, _ throws in
            #expect(throws: SimAnticsError.indexOutOfRange("person data 101")) { try sim.personDatum(101) }
            #expect(throws: SimAnticsError.indexOutOfRange("person data -1")) { try sim.setPersonDatum(-1, to: 0) }
            #expect(throws: SimAnticsError.indexOutOfRange("motive 16")) { try sim.motive(16) }
            try sim.setMotive(Motive.fun, to: 300)
            try sim.setMotive(Motive.social, to: -300)
            #expect(try sim.motive(Motive.fun) == 100 && sim.motive(Motive.social) == -100)
        }
    }

    @Test func aSimsTickCountsAndSetsTheJobFlag() throws {
        try withSim(bodyStrings()) { vm, sim, _ throws in
            sim.tickSim()
            sim.tickSim()
            #expect(sim.personData[PersonData.tickCounter] == 2)
            // This install has no tuning.dat, so there's no motive decay: the first tick says so, once.
            #expect(vm.reportedErrors.map(\.error) == [.content(.missingFile("tuning.dat"))])
            // Stored as 1, but read through the (absent) job as 0, as FreeSO's digest reads it.
            #expect(try sim.personData[PersonData.onlineJobStatusFlags] == 1 && sim.personDatum(PersonData.onlineJobStatusFlags) == 0)
        }
    }

    /// A joining player's state (`VMNetAvatarPersistState.Apply`).
    @Test func aPlayersSavedStateIsApplied() throws {
        try withSim(bodyStrings()) { _, sim, _ throws in
            var identity = SimIdentity(name: "Joiner", persistID: 42, bodyOutfit: 0x99)
            identity.permissions = .roommate
            identity.skinTone = 2
            identity.motives[Motive.hunger] = 150
            identity.personData[0] = 300  // cooking skill (person data 10)
            identity.personData[10] = 4   // the skill-lock value
            identity.personData[22] = 7   // goes to Badge Level (100), as FreeSO's short map has it
            try sim.apply(identity)
            #expect(sim.sim.name == "Joiner" && sim.persistID == 42 && sim.sim.bodyOutfit == 0x99 && sim.sim.skinTone == .dark)
            #expect(try sim.personDatum(10) == 300 && sim.personDatum(PersonData.skinColor) == 2 && sim.personDatum(100) == 7)
            #expect(sim.personData[PersonData.skillLock] == 4 && sim.motiveData[Motive.hunger] == 100)
            // Its online job ID 0 started job 0, which the saved jobs then replace.
            #expect(try sim.sim.jobs.isEmpty && sim.personDatum(PersonData.isHousemate) == 1)
        }
    }
}
