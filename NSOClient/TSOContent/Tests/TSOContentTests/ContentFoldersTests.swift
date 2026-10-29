import Foundation
import Testing
import TSOFiles
@testable import TSOContent

@Suite struct UserFolderLocatorTests {
    let home = URL(fileURLWithPath: "/home/player", isDirectory: true)

    @Test func usesTheOSsDataFolder() throws {
        let locator = UserFolderLocator(environment: [:], homeDirectory: home)
        #if os(Linux)
        #expect(try locator.locate().path == "/home/player/.local/share/NewSO")
        #expect(UserFolderLocator(environment: ["XDG_DATA_HOME": "/data"], homeDirectory: home).defaultDirectory.path
                == "/data/NewSO")
        #elseif os(macOS)
        #expect(try locator.locate().path == "/home/player/Library/Application Support/NewSO")
        #endif
        #expect(try locator.modsDirectory().lastPathComponent == "Mods")
    }

    @Test func prefersAConfiguredFolderThenTheEnvironment() throws {
        let configured = URL(fileURLWithPath: "/chosen", isDirectory: true)
        #expect(try UserFolderLocator(configuredDirectory: configured, environment: ["NSO_USER_DIR": "/elsewhere"],
                                      homeDirectory: home).locate().path == "/chosen")
        #expect(try UserFolderLocator(environment: ["NSO_USER_DIR": "/elsewhere"], homeDirectory: home).locate().path
                == "/elsewhere")
        // A folder that doesn't exist yet is fine: a player with no mods has none.
        #expect(try UserFolderLocator(environment: ["NSO_USER_DIR": "/no/such/folder"], homeDirectory: home).locate().path
                == "/no/such/folder")
    }

    @Test func refusesAFileForTheFolder() throws {
        let install = try FakeInstall()
        try install.write("not a folder", to: "file")
        #expect(throws: ContentError.self) {
            try UserFolderLocator(environment: ["NSO_USER_DIR": install.root.appendingPathComponent("file").path],
                                  homeDirectory: home).locate()
        }
    }
}

@Suite struct FreeSOContentLocatorTests {
    @Test func findsTheFolderInOrder() throws {
        let place = try FakeInstall()
        try place.write("", to: "configured/Patch/a.piff")
        try place.write("", to: "app/Content/Objects/a.iff")
        try place.write("", to: "snapshot/Patch/a.piff")
        let configured = place.root.appendingPathComponent("configured")
        let app = place.root.appendingPathComponent("app")
        let snapshot = place.root.appendingPathComponent("snapshot")

        #expect(try FreeSOContentLocator(configuredDirectory: configured, environment: [:], executableDirectory: app,
                                         fallback: snapshot).locate() == configured)
        #expect(try FreeSOContentLocator(environment: ["FSO_CONTENT_DIR": configured.path], executableDirectory: app,
                                         fallback: snapshot).locate()?.path == configured.path)
        #expect(try FreeSOContentLocator(environment: [:], executableDirectory: app, fallback: snapshot).locate()
                == app.appendingPathComponent("Content", isDirectory: true))
        #expect(try FreeSOContentLocator(environment: [:], executableDirectory: place.root, fallback: snapshot).locate()
                == snapshot)
        #expect(try FreeSOContentLocator(environment: [:], executableDirectory: place.root, fallback: nil).locate() == nil)
    }

    @Test func refusesANamedFolderThatIsntOne() throws {
        let place = try FakeInstall()
        try place.write("", to: "typo/readme.txt")
        #expect(throws: ContentError.self) {
            try FreeSOContentLocator(environment: ["FSO_CONTENT_DIR": place.root.appendingPathComponent("typo").path],
                                     executableDirectory: nil).locate()
        }
    }
}

@Suite struct ModsTests {
    /// The install, with FreeSO's content and NewSO's mods in folders beside it.
    func withMods(_ install: FakeInstall, _ body: (GameContent) throws -> Void) throws {
        try withExtendedLifetime(install) {
            try body(try GameContent(.init(gameDirectory: install.root,
                                           freeSOContentDirectory: install.root.appendingPathComponent("FreeSO"),
                                           modsDirectory: install.root.appendingPathComponent("NewSO/Mods"))))
        }
    }

    @Test func loadsCustomObjectsAfterFreeSOs() throws {
        let install = try makeInstall()
        try install.write(makeIFF([objdChunk(label: "freeso lamp", guid: 0x200)]), to: "FreeSO/Objects/lamp.iff")
        try install.write(makeIFF([objdChunk(label: "custom sofa", guid: 0x300)]), to: "NewSO/Mods/Objects/sofa.iff")
        try withMods(install) { content throws in
            #expect(content.objects.reference(guid: 0x200)?.source == .standalone)
            #expect(try content.objects.object(guid: 0x300)?.definition.label == "custom sofa")
        }
    }

    @Test func aCustomObjectCantReplaceOneAlreadyRegistered() throws {
        let install = try makeInstall()
        try install.write(makeIFF([objdChunk(label: "impostor", guid: 0x100)]), to: "NewSO/Mods/Objects/impostor.iff")
        try withMods(install) { content throws in
            #expect(content.objects.reference(guid: 0x100)?.source == .archive)
            #expect(content.objects.duplicates.map(\.ignored.name) == ["impostor"])
        }
    }

    @Test func aBrokenModIsReportedAndTheRestLoad() throws {
        let install = try makeInstall()
        try install.write(Data("not an IFF".utf8), to: "NewSO/Mods/Objects/broken.iff")
        try install.write(makeIFF([objdChunk(label: "custom sofa", guid: 0x300)]), to: "NewSO/Mods/Objects/sofa.iff")
        try withMods(install) { content throws in
            #expect(content.objects.standaloneFailures.map { URL(fileURLWithPath: $0.path).lastPathComponent } == ["broken.iff"])
            #expect(content.objects.reference(guid: 0x300) != nil)
        }
    }

    @Test func aPlayersPatchReplacesTheShippedOneForTheSameFile() throws {
        let install = try makeInstall()
        try install.write(addingPatch(source: "chair.iff", chunks: [objdChunk(id: 200, label: "shipped", guid: 0x400)]),
                          to: "FreeSO/Patch/chair.piff")
        try install.write(addingPatch(source: "chair.iff", chunks: [objdChunk(id: 201, label: "player's", guid: 0x401)]),
                          to: "NewSO/Mods/Patch/chair.piff")
        try withMods(install) { content throws in
            let chair = try #require(try content.objects.object(guid: 0x100))
            #expect(chair.resource.patches.applied == ["chair.piff"])
            #expect(content.objects.reference(guid: 0x401)?.name == "player's")
            #expect(content.objects.reference(guid: 0x400) == nil)
        }
    }

    @Test func noModsFolderMeansNoMods() throws {
        try withMods(try makeInstall()) { content throws in
            #expect(content.objects.references.map(\.guid) == [0x100, 0x101, 0x102, 0x103])
            #expect(content.objects.standaloneFailures.isEmpty && content.patches.failures.isEmpty)
        }
    }
}
