import Foundation
import Testing
import TSOContent
@testable import SimAntics

/// Sims on the lot as FreeSO's `VMAvatar` places them, on `mock-lot-sim.xml` with the mock Sim
/// joined on 3,3: a small obstacle, its own placement rules, and a hand.
@Suite struct SimPlacementTests {
    private func withJoinedSim(_ body: (VM, Entity, Entity) throws -> Void) throws {
        let vm = try VM(content: try GameContent(.init(gameDirectory: mockInstall)), seed: 1)
        let file = mockInstall.deletingLastPathComponent().appendingPathComponent("Lots/mock-lot-sim.xml")
        try vm.load(try Blueprint(xml: try Data(contentsOf: file)))
        let sim = try #require(try vm.joinSim(template: mockSimGUID, identity: SimIdentity(name: "Joiner", persistID: 9, bodyOutfit: 0)))
        let chair = try #require(vm.entities.first { $0.object.guid == mockChairGUID && $0.position == .center(ofTileX: 4, y: 4, level: 1) })
        try body(vm, sim, chair)
    }

    private let flags = Int(ObjectVariable.flags.rawValue)

    @Test func aSimTakesASmallSquareAndHasOneHand() throws {
        try withJoinedSim { _, sim, _ throws in
            // 3,3's center is (56, 56); FreeSO's obstacle is 3 each way, whatever the facing.
            #expect(sim.footprint == Obstacle(53, 53, 59, 59))
            #expect(sim.obstacle(at: .center(ofTileX: 1, y: 1, level: 1), facing: .east) == Obstacle(21, 21, 27, 27))
            #expect(sim.totalSlots == 1 && sim.slotHeight(0) == 5 && sim.slotHeight(9) == 5)
        }
    }

    @Test func objectsAreInASimsWayUnlessTheyLetPeopleThrough() throws {
        try withJoinedSim { vm, sim, chair throws in
            let onChair = LotPosition.center(ofTileX: 4, y: 4, level: 1)
            let blocked = try sim.placement(at: onChair, facing: .north)
            #expect(blocked.status == .cantIntersectOtherObjects && blocked.object === chair)
            chair.objectData[flags] |= EntityFlag.allowPersonIntersection
            #expect(try sim.placement(at: onChair, facing: .north).status == .success)
            chair.objectData[flags] |= EntityFlag.disallowPersonIntersection  // disallowing wins
            #expect(try sim.placement(at: onChair, facing: .north).status == .cantIntersectOtherObjects)
            // A tile's corner is clear of the chair's footprint but would be inside an object's.
            #expect(try sim.placement(at: LotPosition(x: 82, y: 82, level: 1), facing: .north).status == .success)
            #expect(vm.reportedErrors.isEmpty)
        }
    }

    /// Another Sim is in the way unless the Sim moving lets people through, or the one standing
    /// there does (the object rule applies to Sims too).
    @Test func sameForOtherSims() throws {
        try withJoinedSim { vm, sim, _ throws in
            let other = try #require(try vm.createObject(guid: mockSimGUID)?.objects.first)
            #expect(try vm.place(other.group, at: .center(ofTileX: 5, y: 5, level: 1), facing: .north).status == .success)
            let onOther = LotPosition.center(ofTileX: 5, y: 5, level: 1)
            #expect(try sim.placement(at: onOther, facing: .north).object === other)
            sim.objectData[flags] |= EntityFlag.allowPersonIntersection
            #expect(try sim.placement(at: onOther, facing: .north).status == .success)
            sim.objectData[flags] &= ~EntityFlag.allowPersonIntersection
            other.objectData[flags] |= EntityFlag.allowPersonIntersection
            #expect(try sim.placement(at: onOther, facing: .north).status == .success)
        }
    }

    @Test func whatASimHoldsMovesWithIt() throws {
        try withJoinedSim { vm, sim, chair throws in
            // Any slot number is the hand, and the object keeps the number it was put in with.
            #expect(try sim.placeInSlot(chair, slot: 7, cleanOld: true))
            #expect(sim.slot(0) === chair && sim.slot(3) === chair && chair.container === sim && chair.containerSlot == 7)
            #expect(chair.position == sim.position && chair.footprint == nil)
            let other = try #require(try vm.createObject(guid: mockChairGUID)?.objects.first)
            #expect(try sim.placeInSlot(other, slot: 0, cleanOld: true) == false)  // the hand is full
            #expect(try vm.place(sim.group, at: .center(ofTileX: 6, y: 6, level: 1), facing: .north).status == .success)
            #expect(chair.position == .center(ofTileX: 6, y: 6, level: 1) && sim.footprint == Obstacle(101, 101, 107, 107))
            sim.clearSlot(5)
            #expect(sim.slot(0) == nil && chair.container == nil && chair.containerSlot == -1)
            sim.clearSlot(0)  // an empty hand: nothing to do (FreeSO fails here)
            #expect(vm.reportedErrors.isEmpty)
        }
    }
}
