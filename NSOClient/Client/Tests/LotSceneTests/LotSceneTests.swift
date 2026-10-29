// The client's view of a lot, checked on MockInstall's lot without a window.

import Foundation
import LotScene
import SimAntics
import Testing
import TSOContent
import TSOFiles

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

@Test func systemMessagesSayWhatWentWrongInWords() throws {
    #expect(SystemMessages.text(tick: 30, objectID: 12, objectName: "Lamp", error: .unsupported("animate"))
            == "Tick 30: Lamp (#12) reached behavior NewSO doesn't run yet: animate")
    #expect(SystemMessages.text(tick: 2, objectID: 7, objectName: nil, error: .infiniteLoop)
            == "Tick 2: Object #7 ran too many instructions in one tick and was reset")
    let session = try mockSession()
    #expect(SystemMessages.messages(of: session.vm).count == session.vm.reportedErrors.count)
    for (full, bare) in zip(SystemMessages.messages(of: session.vm), SystemMessages.messages(of: session.vm, includingTick: false)) {
        #expect(full.hasSuffix(bare) && full.hasPrefix("Tick ") && !bare.hasPrefix("Tick "))
    }
}

@Test func runReportsStampLinesWithGameTimeNotTheWallClock() throws {
    let session = try mockSession()
    let vm = session.vm
    #expect(RunReport.stamp(vm) == "tick \(vm.clock.ticks), 0:00")
    #expect(RunReport.ticksPerGameDay(vm) == 216_000)
    #expect(RunReport.gameDayLength(vm) == "2 h 0 min")
    let start = RunReport.start(session, install: "/games/mock")
    #expect(start.first == "tick \(vm.clock.ticks), 0:00: lot mock-lot, install /games/mock")
    #expect(start[1].contains("a game day is 216000 ticks, 2 h 0 min at normal speed"))
    #expect(RunReport.summary(vm, ticks: 9_000, seconds: nil).count == 1)
    #expect(RunReport.summary(vm, ticks: 9_000, seconds: nil)[0].contains("ran 9000 ticks, 1 h of game time"))
    #expect(RunReport.summary(vm, ticks: 300, seconds: 0.5)[1].hasSuffix("took 0.5 s, 600 ticks a second, 20x normal speed"))
}

@Test(arguments: [(0.0, "0 min"), (5, "5 min"), (60, "1 h"), (1_440, "1 day"), (1_530, "1 day 1 h 30 min"), (2_880, "2 days")])
func gameDurationsLeaveOutWhatsZero(minutes: Double, text: String) {
    #expect(RunReport.gameDuration(minutes: minutes) == text)
}

@Test func brokenOrConflictingModsBecomeSystemMessages() throws {
    let mods = FileManager.default.temporaryDirectory.appendingPathComponent("newso-mods-\(UUID().uuidString)/Mods")
    defer { try? FileManager.default.removeItem(at: mods.deletingLastPathComponent()) }
    try FileManager.default.createDirectory(at: mods.appendingPathComponent("Objects"), withIntermediateDirectories: true)
    try Data("not an IFF".utf8).write(to: mods.appendingPathComponent("Objects/broken.iff"))
    // A copy of the mock chair: its GUID already belongs to the install's chair.
    let chair = try FAR1Archive(contentsOf: nsoclient.appendingPathComponent("MockInstall/TSOClient/objectdata/objects/objiff.far"),
                                variant: .b)
    let entry = try #require(chair.entries.first { $0.fileName == "mockchair.iff" })
    try chair.data(for: entry).write(to: mods.appendingPathComponent("Objects/copy.iff"))

    let session = try LotSession(ClientOptions(installs: [], nsoclient: nsoclient, modsDirectory: mods))
    #expect(session.contentProblems.count == 2)
    #expect(session.contentProblems[0].hasPrefix("Couldn't read the custom object broken.iff"))
    #expect(session.contentProblems[1].hasPrefix("Left out the custom object Mock Chair (copy.iff): its GUID 4d4f4301 belongs to"))
    #expect(session.systemMessages.prefix(2) == session.contentProblems[...])
}

@Test func floorsAreNamedAsTheTopBarShowsThem() {
    #expect((1...5).map(LotSession.floorName) == ["1st Floor", "2nd Floor", "3rd Floor", "4th Floor", "5th Floor"])
    #expect([11, 12, 13, 21, 22, 103, 111].map(LotSession.floorName)
            == ["11th Floor", "12th Floor", "13th Floor", "21st Floor", "22nd Floor", "103rd Floor", "111th Floor"])
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

@Test(arguments: [(UInt32(0), SIMD3<Float>(5, 0, 7), SIMD3<Float>(6, 0, 8)),     // TopLeft: (0,0,0), (3,0,3)
                  (1, SIMD3(5, 0, 8), SIMD3(6, 0, 7)),                           // TopRight: (0,0,3), (3,0,-3)
                  (2, SIMD3(6, 0, 8), SIMD3(5, 0, 7)),                           // BottomRight: (3,0,3), (-3,0,-3)
                  (3, SIMD3(6, 0, 7), SIMD3(5, 0, 8))])                          // BottomLeft: (3,0,0), (-3,0,3)
func spriteDepthRunsFromTheFarCornerTowardTheViewer(worldRotation: UInt32, back: SIMD3<Float>, front: SIMD3<Float>) {
    // FreeSO's BackOffForRot and FrontDirForRot, in its 3 world units to a tile.
    let line = LotScene.depthLine(corner: SIMD3(5, 0, 7), worldRotation: worldRotation)
    #expect(line.back == back && line.front == front)
}

@Test func eachSpritesDepthLineStartsAtItsTileCorner() throws {
    let session = try mockSession()
    var sprites: [ObjectSprite] = []
    LotScene.objectSprites(of: session.vm, zoom: .near, worldRotation: 0, library: SpriteLibrary(), into: &sprites)
    #expect(!sprites.isEmpty)
    for sprite in sprites {
        #expect(sprite.back == sprite.anchor - SIMD3(0.5, 0, 0.5))
        #expect(sprite.front == sprite.back + SIMD3(1, 0, 1))
    }
}

@Test func floorsAreDrawnBackAndDownAsFreeSODrawsThem() {
    // update-46's TerrainComponent: a quarter world unit away from the viewer, and down by
    // 3, 5, or 7 × 20/522 world units, more at smaller scales; 3 world units to a tile.
    let away = SIMD3<Float>(0, 0.5, -0.8)
    for (zoom, steps) in [(SpriteZoom.near, Float(3)), (.medium, 5), (.far, 7)] {
        let bias = zoom.floorBias(scale: 1, towardViewer: -away)
        let expected = (0.25 * away - SIMD3(0, steps * 20 / 522, 0)) / 3
        #expect(simdLength(bias - expected) < 1e-6)
    }
    let quarter = SpriteZoom.far.floorBias(scale: 0.25, towardViewer: SIMD3(0, 1, 0))
    #expect(abs(quarter.y - (-0.25 - 4 * 7 * 20 / 522) / 3) < 1e-6)
}

@Test func floorTopsAreTheFloorLineAboveTheGround() throws {
    let session = try mockSession()
    var scene = LotScene()
    scene.rebuildArchitecture(of: session.vm)
    let ground = try #require(scene.architecture.first { $0.kind == .ground })
    let floors = scene.architecture.filter { if case .floor = $0.kind { true } else { false } }
    #expect(!floors.isEmpty)
    for floor in floors where floor.level == 1 {
        // Objects stand on the floor line, y = 0, as do FreeSO's floors.
        #expect(abs(floor.center.y + floor.size.y / 2) < 1e-6)
    }
    #expect(ground.center.y + ground.size.y / 2 < 0)
}

private func simdLength(_ vector: SIMD3<Float>) -> Float {
    (vector * vector).sum().squareRoot()
}

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
