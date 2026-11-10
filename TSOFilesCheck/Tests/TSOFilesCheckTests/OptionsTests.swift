import ArgumentParser
import Configuration
import Foundation
import Testing
import TSOContent
import TSOFiles
@testable import TSOFilesCheck

@Suite struct OptionsTests {
    /// The installs a command picks from an environment, as `run` reads it.
    func installs(_ command: TSOFilesCheck, _ environment: [String: String]) throws -> [TSOFilesCheck.Install] {
        try command.installs(in: ConfigReader(provider: EnvironmentVariablesProvider(environmentVariables: environment)))
    }

    @Test func readsEveryOption() throws {
        let command = try TSOFilesCheck.parse(["--far1-variant", "a", "--headers-only", "--max-failures", "5", "/games/tso"])
        #expect(command.far1Variant == .a)
        #expect(command.headersOnly)
        #expect(command.maxFailures == 5)
        let installs = try installs(command, ["TSO_GAME_DIR": "/opt/tso", "TSO_BETA_DIR": "/opt/beta"])
        #expect(installs.map(\.directory.path) == ["/games/tso"] && installs[0].source == nil)
    }

    @Test func fallsBackToTheEnvironment() throws {
        let command = try TSOFilesCheck.parse([])
        let installs = try installs(command, ["TSO_GAME_DIR": "/opt/tso"])
        #expect(installs == [.init(source: "TSO_GAME_DIR", directory: URL(fileURLWithPath: "/opt/tso", isDirectory: true))])
        #expect(command.far1Variant == .b)
        #expect(!command.headersOnly)
        #expect(command.maxFailures == 50)
        #expect(command.install.isEmpty)
    }

    @Test func checksEveryInstallGameFirst() throws {
        let environment = ["TSO_BETA_DIR": "/opt/beta", "TSO_GAME_DIR": "/opt/tso", "TSO_CLASSIC_DIR": "/opt/classic"]
        let all = try installs(TSOFilesCheck.parse([]), environment)
        #expect(all.map(\.source) == ["TSO_GAME_DIR", "TSO_CLASSIC_DIR", "TSO_BETA_DIR"])
        #expect(all.map(\.directory.path) == ["/opt/tso", "/opt/classic", "/opt/beta"])
        #expect(try installs(TSOFilesCheck.parse([]), ["TSO_BETA_DIR": "/opt/beta"]).map(\.source) == ["TSO_BETA_DIR"])
        #expect(try installs(TSOFilesCheck.parse(["--install", "beta"]), environment).map(\.source) == ["TSO_BETA_DIR"])
        #expect(try installs(TSOFilesCheck.parse(["--install", "game"]), environment).map(\.source) == ["TSO_GAME_DIR"])
        // Repeated, in the installs' own order whatever the order given.
        #expect(try installs(TSOFilesCheck.parse(["--install", "beta", "--install", "classic"]), environment).map(\.source)
                == ["TSO_CLASSIC_DIR", "TSO_BETA_DIR"])
    }

    @Test func checksOneFolderOnce() throws {
        let installs = try installs(TSOFilesCheck.parse([]), ["TSO_GAME_DIR": "/opt/tso", "TSO_BETA_DIR": "/opt/x/../tso/"])
        #expect(installs.map(\.source) == ["TSO_GAME_DIR"])
    }

    @Test func needsADirectory() throws {
        let command = try TSOFilesCheck.parse([])
        #expect(throws: ValidationError.self) { try installs(command, [:]) }
        #expect(throws: ValidationError.self) { try installs(command, ["TSO_GAME_DIR": "", "TSO_BETA_DIR": ""]) }
        #expect(throws: ValidationError.self) {
            try installs(TSOFilesCheck.parse(["--install", "beta"]), ["TSO_GAME_DIR": "/opt/tso"])
        }
    }

    @Test func headsEachInstallWithItsVersion() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("tsofiles-install-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let install = TSOFilesCheck.Install(source: "TSO_GAME_DIR", directory: root)
        #expect(TSOFilesCheck.header(for: install) == "== TSO_GAME_DIR: \(root.path)")
        try Data("1.1097.1.0".utf8).write(to: root.appendingPathComponent("version"))
        #expect(TSOFilesCheck.header(for: install) == "== TSO_GAME_DIR: \(root.path) (1.1097.1.0)")
        try Data("1.1097".utf8).write(to: root.appendingPathComponent("version"))
        #expect(TSOFilesCheck.header(for: install).contains("(version unknown: "))
    }

    @Test(arguments: [
        ["--far1-variant", "c", "/x"],
        ["--max-failures", "-1", "/x"],
        ["--max-failures"],
        ["--verbose", "/x"],
        ["/x", "/y"],
        ["--install", "beta", "/x"],
        ["--install", "demo"],
        ["--install", "all"],
        ["--help"],
    ])
    func rejectsBadArguments(arguments: [String]) {
        #expect(throws: (any Error).self) { try TSOFilesCheck.parse(arguments) }
    }
}

@Suite struct ScanReportTextTests {
    /// A folder with one good IFF and one truncated FAR1.
    func scanTestFolder() throws -> ScanReport {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("tsofiles-check-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        var iff = Data("IFF FILE 2.5:TYPE FOLLOWED BY SIZE\0 JAMIE DOORNBOS & MAXIS 1".utf8)
        iff.append(Data(count: 60 - iff.count + 4))
        try iff.write(to: root.appendingPathComponent("empty.iff"))
        try Data("FAR!byAZ".utf8 + [1, 0, 0, 0, 0xff]).write(to: root.appendingPathComponent("broken.far"))
        try Data("text".utf8).write(to: root.appendingPathComponent("notes.txt"))
        return try InstallScanner(far1Variant: .b, readsEntries: true, parsesChunks: true).scan(directory: root)
    }

    @Test func summarizesAndListsFailures() throws {
        let lines = ScanReportText.lines(for: try scanTestFolder(), maxFailures: 50)
        #expect(lines.contains("FAR1: 1 files") && lines.contains("IFF: 1 files"))
        #expect(lines.contains("other files: 1"))
        #expect(lines.contains("failures: 1"))
        #expect(lines.contains { $0.hasPrefix("  broken.far: ") })
    }

    @Test func countsFailuresPastTheLimit() throws {
        let lines = ScanReportText.lines(for: try scanTestFolder(), maxFailures: 0)
        #expect(lines.contains("failures: 1"))
        #expect(lines.last == "  ... and 1 more")
    }
}

@Suite struct DifferencesTests {
    func temporaryFolder() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tsofiles-differences-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @Test func writesTheDifferencesOnce() throws {
        let root = try temporaryFolder()
        defer { try? FileManager.default.removeItem(at: root) }
        let game = root.appendingPathComponent("game"), beta = root.appendingPathComponent("beta")
        for folder in [game, beta] {
            try FileManager.default.createDirectory(at: folder.appendingPathComponent("objectdata"), withIntermediateDirectories: true)
        }
        try Data("new".utf8).write(to: game.appendingPathComponent("objectdata/new.txt"))
        let notes = root.appendingPathComponent("install-differences.md")
        let command = try TSOFilesCheck.parse(["--differences", notes.path])
        let installs = [TSOFilesCheck.Install(source: "TSO_GAME_DIR", directory: game),
                        TSOFilesCheck.Install(source: "TSO_BETA_DIR", directory: beta)]

        #expect(command.noteDifferences(between: installs, date: Date(timeIntervalSince1970: 0)))
        let written = try String(contentsOf: notes, encoding: .utf8)
        #expect(written.contains("`tsofiles-check` wrote this on 1970-01-01."))
        // Oldest first: the beta, then the game.
        #expect(written.contains("## `TSO_BETA_DIR` to `TSO_GAME_DIR`"))
        #expect(written.contains("### Only in `TSO_GAME_DIR`\n\n- `objectdata/new.txt`"))

        // A second run leaves the notes alone, even when the installs change.
        try Data("newer".utf8).write(to: beta.appendingPathComponent("objectdata/newer.txt"))
        #expect(command.noteDifferences(between: installs))
        #expect(try String(contentsOf: notes, encoding: .utf8) == written)
    }

    @Test func comparesEachInstallWithTheNextNewer() throws {
        let root = try temporaryFolder()
        defer { try? FileManager.default.removeItem(at: root) }
        let names = ["game", "classic", "beta"]
        for name in names {
            try FileManager.default.createDirectory(at: root.appendingPathComponent("\(name)/objectdata"), withIntermediateDirectories: true)
            try Data(name.utf8).write(to: root.appendingPathComponent("\(name)/objectdata/\(name).txt"))
        }
        let notes = root.appendingPathComponent("install-differences.md")
        let command = try TSOFilesCheck.parse(["--differences", notes.path])
        // In InstallKind order, newest first, as the scan checks them.
        let installs = names.map { TSOFilesCheck.Install(source: "TSO_\($0.uppercased())_DIR", directory: root.appendingPathComponent($0)) }

        #expect(command.noteDifferences(between: installs, date: Date(timeIntervalSince1970: 0)))
        let written = try String(contentsOf: notes, encoding: .utf8)
        #expect(written.contains("| `TSO_BETA_DIR` to `TSO_CLASSIC_DIR` | 0 | 1 | 1 | 0 |"))
        #expect(written.contains("| `TSO_CLASSIC_DIR` to `TSO_GAME_DIR` | 0 | 1 | 1 | 0 |"))
        let first = try #require(written.range(of: "## `TSO_BETA_DIR` to `TSO_CLASSIC_DIR`"))
        let second = try #require(written.range(of: "## `TSO_CLASSIC_DIR` to `TSO_GAME_DIR`"))
        #expect(first.lowerBound < second.lowerBound)
        #expect(written.contains("### Only in `TSO_CLASSIC_DIR`\n\n- `objectdata/classic.txt`"))
    }

    @Test func skipsWithoutAFolderForTheNotes() throws {
        let root = try temporaryFolder()
        defer { try? FileManager.default.removeItem(at: root) }
        let notes = root.appendingPathComponent("missing/install-differences.md")
        let command = try TSOFilesCheck.parse(["--differences", notes.path])
        let installs = [TSOFilesCheck.Install(source: "A", directory: root), TSOFilesCheck.Install(source: "B", directory: root)]
        #expect(command.noteDifferences(between: installs))
        #expect(!FileManager.default.fileExists(atPath: notes.path))
    }

    @Test func describesChangedEntries() {
        var differences = InstallDifferences()
        differences.identicalFileCount = 3
        differences.changedFiles = [
            FileDifference(path: "objiff.far", firstSize: 10, secondSize: 12, kind: .far1, entries: [
                EntryDifference(name: "a|b.iff", change: .onlyInSecond),
                EntryDifference(name: "chair.iff: BHAV #4096", change: .onlyInFirst),
                EntryDifference(name: "chair.iff: BHAV #4097", change: .onlyInFirst),
                EntryDifference(name: "chair.iff: OBJD #128", change: .changed, guid: "000000ab"),
                EntryDifference(name: "chair.iff: STR# #128", change: .changed),
            ]),
            FileDifference(path: "global.iff", firstSize: 1, secondSize: 2, kind: .iff, entries: [
                EntryDifference(name: "BCON #4096", change: .onlyInSecond),
            ]),
            FileDifference(path: "meshes.dat", firstSize: 5, secondSize: 6, kind: .far3, entries: [
                EntryDifference(name: "a.mesh [1]", change: .onlyInFirst),
                EntryDifference(name: "b.mesh [2]", change: .changed),
                EntryDifference(name: "c.mesh [3]", change: .changed),
            ]),
        ]
        let step = DifferencesReport.Step(older: "`TSO_BETA_DIR` (1.3.2.121)", newer: "`TSO_GAME_DIR`", differences: differences)
        let text = DifferencesReport.markdown([step], date: Date(timeIntervalSince1970: 0))
        #expect(text.contains("| `TSO_BETA_DIR` (1.3.2.121) to `TSO_GAME_DIR` | 3 | 0 | 0 | 3 |"))
        #expect(text.contains("FAR1, 10 bytes in the older, 12 in the newer."))
        #expect(text.contains("| `a\\|b.iff` |  | whole entry |  |  |"))
        #expect(text.contains("| `chair.iff` | BHAV 4096, 4097 |  | OBJD 128; STR# 128 | 000000ab |"))
        #expect(text.contains("| `(this file)` |  | BCON 4096 |  |  |"))
        #expect(text.contains("Entries only in the older: 1, only in the newer: 0, changed: 2."))
        #expect(!text.contains("a.mesh"))
        #expect(!text.contains("The installs are identical."))
    }
}
