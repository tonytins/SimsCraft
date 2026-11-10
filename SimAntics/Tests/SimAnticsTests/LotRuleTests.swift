import Foundation
import Testing
import TSOContent
@testable import SimAntics

/// The lot's rules (`LotRule`) on the mock Sim's lot: none broken as it runs, and each one broken
/// on purpose, so a clean check means something.
@Suite struct LotRuleTests {
    private func simLot() throws -> (VM, Entity) {
        let vm = try VM(content: try GameContent(.init(gameDirectory: mockInstall)), seed: 1)
        let file = mockInstall.deletingLastPathComponent().appendingPathComponent("Lots/mock-lot-sim.xml")
        try vm.load(try Blueprint(xml: try Data(contentsOf: file)))
        let sim = try #require(try vm.joinSim(template: mockSimGUID, identity: SimIdentity(name: "Joiner", persistID: 9, bodyOutfit: 0)))
        return (vm, sim)
    }

    private func rules(_ vm: VM) -> [LotRule] { vm.brokenRules().map(\.rule) }

    @Test func theMockSimsLotBreaksNoRuleOverAGameHour() throws {
        let (vm, _) = try simLot()
        #expect(vm.brokenRules().isEmpty)
        for tick in 1...9_000 {
            vm.tick()
            if tick % 150 == 0 { #expect(vm.brokenRules().isEmpty, "at tick \(tick)") }
        }
    }

    @Test func aMotiveMayReach200ButNoFurther() throws {
        let (vm, sim) = try simLot()
        sim.motiveData[Motive.hunger] = 200
        sim.motiveData[Motive.fun] = -100
        #expect(rules(vm).isEmpty)
        sim.motiveData[Motive.hunger] = 201
        sim.motiveData[Motive.fun] = -101
        let broken = vm.brokenRules()
        #expect(broken.map(\.rule) == [.motiveRange, .motiveRange])
        #expect(broken.allSatisfy { $0.objectID == sim.objectID })
    }

    @Test func anOnlineJobIDPast4IsBroken() throws {
        let (vm, sim) = try simLot()
        sim.personData[PersonData.onlineJobID] = 5
        #expect(rules(vm) == [.onlineJobID])
    }

    @Test func anObjectOffTheLotIsBroken() throws {
        let (vm, sim) = try simLot()
        sim.position = .center(ofTileX: Int16(vm.lotSize.width), y: 3, level: 1)
        #expect(rules(vm) == [.onLot])
    }

    @Test func anObjectMissingFromItsTileIsBroken() throws {
        let (vm, sim) = try simLot()
        // Moved without the tile index knowing, to the lot's far corner.
        sim.position = .center(ofTileX: Int16(vm.lotSize.width - 1), y: Int16(vm.lotSize.height - 1), level: 1)
        #expect(rules(vm) == [.tileIndex])
    }

    @Test func aDeletedObjectStillOnTheLotIsBroken() throws {
        let (vm, sim) = try simLot()
        sim.isDead = true
        #expect(rules(vm) == [.objectIndex])
    }

    @Test func containmentThatPointsOneWayIsBroken() throws {
        let (vm, sim) = try simLot()
        let lamp = try #require(vm.objects(withGUID: mockLampGUID)?.first)
        lamp.container = sim                                     // the hand doesn't hold it
        let broken = vm.brokenRules()
        #expect(broken.map(\.rule).contains(.slots))
        #expect(broken.allSatisfy { $0.objectID == lamp.objectID })
    }

    @Test func aHeldObjectAwayFromItsHolderIsBroken() throws {
        let (vm, sim) = try simLot()
        let lamp = try #require(vm.objects(withGUID: mockLampGUID)?.first)
        #expect(try sim.placeInSlot(lamp, slot: 0, cleanOld: true))
        #expect(rules(vm).isEmpty)
        lamp.position = .outOfWorld
        #expect(rules(vm) == [.withContainer])
    }

    @Test func aPartItsGroupDoesntListIsBroken() throws {
        let (vm, _) = try simLot()
        let left = try #require(vm.objects(withGUID: mockLeftGUID)?.first)
        left.group.remove(left)
        #expect(vm.brokenRules().contains { $0.rule == .group && $0.objectID == left.objectID })
    }

    @Test func checkingChangesNothing() throws {
        let (vm, _) = try simLot()
        for _ in 0..<300 { vm.tick() }
        let before = StateDigest.hex(of: vm)
        _ = vm.brokenRules()
        #expect(StateDigest.hex(of: vm) == before)
    }
}
