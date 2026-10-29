import Foundation
import Testing
import TSOContent

@Suite struct InstallKindTests {
    @Test func eachKindHasItsOwnVariable() {
        #expect(InstallKind.allCases.map(\.environmentVariable) == ["TSO_GAME_DIR", "TSO_CLASSIC_DIR", "TSO_BETA_DIR"])
        #expect(GameLocator.environmentVariable == "TSO_GAME_DIR")
    }

    @Test func listsTheInstallsTheEnvironmentNamesInOrder() {
        let installs = InstallKind.installs(in: ["TSO_BETA_DIR": "/games/beta", "TSO_GAME_DIR": "/games/tso",
                                                "TSO_CLASSIC_DIR": "", "HOME": "/home"])
        #expect(installs == [NamedInstall(kind: .game, directory: URL(fileURLWithPath: "/games/tso", isDirectory: true)),
                             NamedInstall(kind: .beta, directory: URL(fileURLWithPath: "/games/beta", isDirectory: true))])
        #expect(InstallKind.installs(in: [:]).isEmpty)
    }

    @Test func keepsAFolderNamedTwiceOnceUnderTheFirstKind() {
        let installs = InstallKind.installs(in: ["TSO_GAME_DIR": "/games/tso/", "TSO_CLASSIC_DIR": "/games/../games/tso"])
        #expect(installs.map(\.kind) == [.game])
    }
}

@Suite struct GameVersionTests {
    @Test func readsTheDottedLayout() throws {
        #expect(try GameVersion(parsing: "1.1097.1.0") == GameVersion(major: 1, minor: 1097, patch: 1, build: 0))
        #expect(try GameVersion(parsing: "1.145.1.0\r\n").description == "1.145.1.0")
    }

    @Test func readsTheBetasKeyValueLayout() throws {
        let version = try GameVersion(parsing: "major:1\r\nminor:3\r\npatch:2\r\nbuild:121\r\n")
        #expect(version == GameVersion(major: 1, minor: 3, patch: 2, build: 121))
        #expect(try GameVersion(parsing: "build: 121\nMAJOR:1\nminor:3\npatch:2") == version)
    }

    @Test func ordersByEachNumberInTurn() throws {
        #expect(try GameVersion(parsing: "1.145.1.0") < GameVersion(parsing: "1.1097.1.0"))
        #expect(try GameVersion(parsing: "major:1\nminor:3\npatch:2\nbuild:121") < GameVersion(parsing: "1.145.1.0"))
    }

    @Test(arguments: ["", "1.1097.1", "1.1097.1.0.5", "1..1.0", "1.x.1.0", "1.-5.1.0", "1.1234567890.1.0",
                      "1.1097.1.0\n1.1097.1.0", "major:1\nminor:3\npatch:2", "major:1\nminor:3\npatch:2\nbuild:1\nrevision:4",
                      "major:1\nmajor:1\nminor:3\npatch:2\nbuild:1", "major 1\nminor:3\npatch:2\nbuild:1"])
    func reportsAnythingElse(text: String) {
        #expect(throws: ContentError.self) { try GameVersion(parsing: text) }
    }

    @Test func readsAnInstallsFileInAnyLetterCase() throws {
        let install = try FakeInstall()
        #expect(try GameVersion.read(install: install.root) == nil)
        try install.write("1.1097.1.0", to: "Version")
        #expect(try GameVersion.read(install: install.root)?.description == "1.1097.1.0")
    }

    @Test func reportsAnUnreadableFileWithItsPath() throws {
        let install = try FakeInstall()
        try install.write(Data(repeating: 0x31, count: 2048), to: "version")
        #expect {
            try GameVersion.read(install: install.root)
        } throws: { error in
            guard case ContentError.invalidFile(let path, _) = error else { return false }
            return path.hasSuffix("/version")
        }
        try install.write("1.1097", to: "version")
        #expect {
            try GameVersion.read(install: install.root)
        } throws: { error in
            guard case ContentError.invalidFile(let path, let reason) = error else { return false }
            return path.hasSuffix("/version") && reason.contains("four dotted numbers")
        }
    }
}
