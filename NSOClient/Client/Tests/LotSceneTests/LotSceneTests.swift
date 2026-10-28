// The client's view of a lot, checked on MockInstall's lot without a window.

import Foundation
import LotScene
import SimAntics
import Testing

private let nsoclient = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

private func mockSession() throws -> LotSession {
    try LotSession(ClientOptions(environment: [:], nsoclient: nsoclient))
}

@Test func optionsFallBackToMockInstall() {
    let options = ClientOptions(environment: [:], nsoclient: nsoclient)
    #expect(options.gameDirectory.path.hasSuffix("MockInstall/TSOClient"))
    #expect(options.lot.lastPathComponent == "mock-lot.xml")
    #expect(options.freeSOContent == nil)
}

@Test func optionsPreferTheInstallsTheEnvironmentNames() {
    let options = ClientOptions(environment: ["TSO_BETA_DIR": "/games/beta"], nsoclient: nsoclient)
    #expect(options.gameDirectory.path == "/games/beta")
    #expect(options.lot.lastPathComponent == "tonys-house.xml")
    #expect(options.freeSOContent?.path.hasSuffix("TSOClient/tso.content/Content") == true)
    let chosen = ClientOptions(game: "/games/tso", lot: "/lots/a.xml", environment: ["TSO_GAME_DIR": "/elsewhere"],
                               nsoclient: nsoclient)
    #expect(chosen.gameDirectory.path == "/games/tso")
    #expect(chosen.lot.path == "/lots/a.xml")
}

@Test func aMissingLotIsReported() {
    #expect(throws: ClientError.self) {
        try LotSession(ClientOptions(lot: "/no/such/lot.xml", environment: [:], nsoclient: nsoclient))
    }
}

@Test func theMockLotBecomesBoxes() throws {
    let session = try mockSession()
    var scene = LotScene()
    scene.rebuildArchitecture(of: session.vm)
    scene.rebuildObjects(of: session.vm)
    #expect(scene.lotWidth == session.vm.architecture.width)
    #expect(scene.architecture.first?.kind == .ground)
    #expect(scene.architecture.contains { $0.kind == .wall })
    #expect(scene.architecture.contains { if case .floor = $0.kind { true } else { false } })

    let placed = session.vm.entities.filter { !$0.isDead && $0.position != .outOfWorld && $0.container == nil }
    #expect(!placed.isEmpty)
    #expect(scene.objects.count >= placed.count)
    for box in scene.objects {
        #expect(box.size.x > 0 && box.size.y > 0 && box.size.z > 0)
        #expect(box.center.x >= 0 && box.center.x <= Float(scene.lotWidth))
    }
}

@Test func rebuildingReusesTheSameBoxes() throws {
    let session = try mockSession()
    var scene = LotScene()
    scene.rebuildObjects(of: session.vm)
    let first = scene.objects
    scene.rebuildObjects(of: session.vm)
    #expect(scene.objects == first)
}

@Test func timeRunsAtThirtyTicksASecondTimesTheSpeed() throws {
    let session = try mockSession()
    let start = session.vm.clock.ticks
    #expect(session.advance(seconds: 0.5) == 15)
    session.setSpeed(index: 1)
    #expect(session.advance(seconds: 0.2) == 18)
    #expect(session.vm.clock.ticks == start + 33)
    session.isPaused = true
    #expect(session.advance(seconds: 1) == 0)
}

@Test func aLongFrameRunsAtMostItsShare() throws {
    let session = try mockSession()
    session.setSpeed(index: 2)
    #expect(session.advance(seconds: 5) == LotSession.mostTicksPerFrame)
    // The backlog isn't kept, so the next frame doesn't pay for the slow one.
    #expect(session.advance(seconds: 1.0 / 60) == 5)
}

@Test func theInspectorNamesWhatAnObjectIsAndDoes() throws {
    let session = try mockSession()
    let entity = try #require(session.vm.entities.first { $0.position != .outOfWorld })
    let inspection = Inspection(entity)
    #expect(!inspection.title.isEmpty)
    #expect(inspection.lines.first?.hasPrefix("GUID 0x") == true)
    #expect(inspection.lines.contains { $0.hasPrefix("Tile ") })
}
