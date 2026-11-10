import Foundation
import Testing
import TSOFiles
@testable import SimAntics

/// Room score as FreeSO's `RefreshLighting` and `RefreshRoomScore` work it out, on an 8 by 8 lot
/// with a walled room from (2, 3) to (4, 4): 6 tiles, indoors. Low priority (it moves with object
/// decay, which isn't ported), so these pin down the formula and its quirks only.
@Suite struct RoomScoreTests {
    private let roomImpact = Int(ObjectVariable.roomImpact.rawValue)

    private func withRoom(style: UInt16 = 1, _ body: (VM, MultitileGroup, UInt16) throws -> Void) throws {
        try withVM(chair: [objdChunk(label: "lamp", guid: lampGUID, id: 133)], objects: [lampGUID]) { vm, _ throws in
            var architecture = try Architecture(width: 8, height: 8)
            func add(_ segments: WallSegments, _ x: Int, _ y: Int) throws {
                var tile = try architecture.wall(atX: x, y: y, level: 1)
                tile.segments.formUnion(segments)
                if segments.contains(.topLeft) { tile.topLeftStyle = style }
                if segments.contains(.topRight) { tile.topRightStyle = style }
                try architecture.setWall(tile, atX: x, y: y, level: 1)
            }
            for y in 3..<5 { try add(.topLeft, 2, y); try add(.topLeft, 5, y) }
            for x in 2..<5 { try add(.topRight, x, 3); try add(.topRight, x, 5) }
            architecture.regenerateRooms()
            vm.architecture = architecture
            let lamp = try #require(try vm.createObject(guid: lampGUID))
            lamp.objects[0].objectData[Int(ObjectVariable.placementFlags.rawValue)] = PlacementFlags.onTerrain.rawValue
            lamp.objects[0].objectData[Int(ObjectVariable.allowedHeightFlags.rawValue)] = 1
            try body(vm, lamp, vm.architecture.room(at: .center(ofTileX: 3, y: 3, level: 1)))
        }
    }

    @Test func anEmptyRoomScoresMinusTenIndoorsAndFifteenOut() throws {
        try withRoom { vm, _, inside throws in
            #expect(vm.roomScore(inside) == -10 && vm.roomScore(1) == -15)
            #expect(vm.roomScore(0) == 0 && vm.roomScore(999) == 0)
        }
    }

    @Test func objectsAddTheirImpactOverTheAreaInTwelfths() throws {
        try withRoom { vm, lamp, inside throws in
            lamp.objects[0].objectData[roomImpact] = 15
            #expect(try vm.place(lamp, at: .center(ofTileX: 3, y: 3, level: 1), facing: .north).status == .success)
            // 6 tiles over 12 is half, so the scale is 1: 15 − 10.
            #expect(vm.roomScore(inside) == 5)
            // Outdoors the scale is 30: 15 / 30 truncates to 0, then − 15.
            #expect(try vm.place(lamp, at: .center(ofTileX: 6, y: 6, level: 1), facing: .north).status == .success)
            #expect(vm.roomScore(inside) == -10 && vm.roomScore(1) == -15)
            lamp.objects[0].objectData[roomImpact] = 500
            try vm.place(lamp, at: .center(ofTileX: 3, y: 3, level: 1), facing: .north)
            #expect(vm.roomScore(inside) == 100)  // within −100 to 100
        }
    }

    /// FreeSO refreshes a room when an object comes or goes only if it adds to the score or lights
    /// the room; an object that takes away changes nothing until the next full refresh.
    @Test func aNegativeImpactWaitsForTheNextFullRefresh() throws {
        try withRoom { vm, lamp, inside throws in
            lamp.objects[0].objectData[roomImpact] = -30
            try vm.place(lamp, at: .center(ofTileX: 3, y: 3, level: 1), facing: .north)
            #expect(vm.roomScore(inside) == -10)
            vm.refreshRoomScore(inside)
            #expect(vm.roomScore(inside) == -40)
        }
    }

    /// A room that shares another's lighting (a fence lets light through) keeps its own record at
    /// 0, as FreeSO's keeps its own lighting record, never refreshed.
    @Test func aRoomLitByAnotherScoresZero() throws {
        try withRoom(style: 2) { vm, lamp, inside throws in
            #expect(vm.architecture.rooms[Int(inside)].lightBaseRoom == 1)
            lamp.objects[0].objectData[roomImpact] = 60
            try vm.place(lamp, at: .center(ofTileX: 3, y: 3, level: 1), facing: .north)
            #expect(vm.roomScore(inside) == 0)
            // The base room counts the fenced room's area and objects: outdoors, 60 / 30 − 15.
            #expect(vm.roomScore(1) == -13)
        }
    }

    @Test func theRefreshPrimitiveWorksTheTargetsRoomOut() throws {
        try withRoom { vm, lamp, inside throws in
            let entity = lamp.objects[0]
            entity.objectData[roomImpact] = -30
            try vm.place(lamp, at: .center(ofTileX: 3, y: 3, level: 1), facing: .north)
            let (prepared, frame) = try vm.makePrimitiveFrame(opcode: 7, operand: Primitives.Refresh.Operand(target: 0, type: 2).encoded(),
                                                              caller: entity)
            #expect(try prepared.execute(in: frame) == .gotoTrue)
            #expect(vm.roomScore(inside) == -40)
        }
    }
}
