// The client's view of a lot, checked on MockInstall's lot without a window.

import Foundation
import LotScene
import SimAntics
import Testing
import TSOContent

private let nsoclient = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

private func mockSession() throws -> LotSession {
    try LotSession(ClientOptions(installs: [], nsoclient: nsoclient))
}

@Test func optionsFallBackToMockInstall() {
    let options = ClientOptions(installs: [], nsoclient: nsoclient)
    #expect(options.gameDirectory.path.hasSuffix("MockInstall/TSOClient"))
    #expect(options.lot.lastPathComponent == "mock-lot.xml")
    #expect(options.freeSOContent == nil)
}

@Test func optionsPreferTheFirstInstallNamed() {
    let installs = InstallKind.installs(in: ["TSO_BETA_DIR": "/games/beta", "TSO_CLASSIC_DIR": "/games/classic"])
    let options = ClientOptions(installs: installs, nsoclient: nsoclient)
    #expect(options.gameDirectory.path == "/games/classic")
    #expect(options.lot.lastPathComponent == "tonys-house.xml")
    #expect(options.freeSOContent?.path.hasSuffix("TSOClient/tso.content/Content") == true)
    let chosen = ClientOptions(game: "/games/tso", lot: "/lots/a.xml",
                               installs: InstallKind.installs(in: ["TSO_GAME_DIR": "/elsewhere"]), nsoclient: nsoclient)
    #expect(chosen.gameDirectory.path == "/games/tso")
    #expect(chosen.lot.path == "/lots/a.xml")
}

@Test func aMissingLotIsReported() {
    #expect(throws: ClientError.self) {
        try LotSession(ClientOptions(lot: "/no/such/lot.xml", installs: [], nsoclient: nsoclient))
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

// MARK: Sprites

@Test func zoomsHaveTSOsPixelsPerUnit() {
    // √(tile width² / 2): FreeSO's OneUnitDistance for 32-, 64-, and 128-pixel tiles.
    #expect(abs(SpriteZoom.near.pixelsPerUnit - 90.50967) < 0.001)
    #expect(abs(SpriteZoom.medium.pixelsPerUnit - 45.254834) < 0.001)
    #expect(abs(SpriteZoom.far.pixelsPerUnit - 22.627417) < 0.001)
}

@Test func objectsDrawTheirGroupsSpritesPlacedAsFreeSOPlacesThem() throws {
    let session = try mockSession()
    var sprites: [ObjectSprite] = []
    LotScene.objectSprites(of: session.vm, zoom: .near, worldRotation: 0, library: SpriteLibrary(), into: &sprites)
    // Only the chairs have a drawing group (MockInstall's mockchair.spf, DGRP 0).
    let chairs = session.vm.entities.filter { $0.object.resource.name == "mockchair" && $0.position != .outOfWorld }
    #expect(!chairs.isEmpty)
    #expect(Set(sprites.map(\.objectID)) == Set(chairs.map(\.objectID)))

    for chair in chairs {
        let mine = sprites.filter { $0.objectID == chair.objectID }
        // Two sprites each: SPR2 100 frame 0 (flipped) and SPR2 101 frame 0 (luminous).
        #expect(mine.map(\.key.spriteID) == [100, 101])
        #expect(mine.map(\.flip) == [true, false])
        let base = SIMD3(Float(chair.position.x) / 16 + 0.5, 0, Float(chair.position.y) / 16 + 0.5)
        #expect(mine.allSatisfy { $0.objectAnchor == base })
        // The first sprite's object offset, (0.25, -0.5, 1.5) in sixteenths and fifths, turned with the chair.
        let offset = SIMD2<Float>(0.25 / 16, -0.5 / 16)
        let turned: SIMD2<Float> = chair.direction == .east ? SIMD2(-offset.y, offset.x) : offset
        let expected = base + SIMD3(turned.x, 1.5 / 5, turned.y)
        let anchor = mine[0].anchor
        #expect(abs(anchor.x - expected.x) < 1e-5 && abs(anchor.y - expected.y) < 1e-5 && abs(anchor.z - expected.z) < 1e-5)
        // Sprite offset (-20, 30), less the frame's height (4).
        #expect(mine[0].pixelOffset == SIMD2(-20, 26))
        #expect(mine[0].width == 4 && mine[0].height == 4)
    }
}

@Test func objectsWithoutAnImageForTheZoomDrawNothing() throws {
    let session = try mockSession()
    var sprites: [ObjectSprite] = []
    // The chairs' group has near images only.
    LotScene.objectSprites(of: session.vm, zoom: .medium, worldRotation: 0, library: SpriteLibrary(), into: &sprites)
    #expect(sprites.isEmpty)
}

@Test func turningTheWorldPicksAnotherFacingsImage() throws {
    let session = try mockSession()
    var sprites: [ObjectSprite] = []
    let library = SpriteLibrary()
    // Seen a quarter turn round, a north-facing chair needs the image for another direction bit,
    // which the group lacks, so only chairs whose turned facing it has still draw.
    LotScene.objectSprites(of: session.vm, zoom: .near, worldRotation: 1, library: library, into: &sprites)
    let drawn = Set(sprites.map(\.objectID))
    let chairs = session.vm.entities.filter { $0.object.resource.name == "mockchair" && $0.position != .outOfWorld }
    for chair in chairs {
        // Direction bits turn two places a quarter turn: north (0x01) becomes 0x04, which the group has.
        #expect(drawn.contains(chair.objectID) == (chair.direction == .north))
    }
}
