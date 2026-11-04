import ArgumentParser
import Configuration
import Foundation
import TSOConfig
import TSOContent
import TSOFiles

/// `tsofiles-check`: opens every container in a TSO install and reports failures.
@main
struct TSOFilesCheck: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tsofiles-check",
        abstract: "Open every FAR1, FAR3, DBPF, and IFF file in a TSO install and read every entry.",
        discussion: """
            Without a folder, checks every install named by $TSO_GAME_DIR, $TSO_CLASSIC_DIR, and \
            $TSO_BETA_DIR, one after the other. When two or more are checked and the differences \
            file doesn't exist yet, it compares each with the next newer one (beta, classic, game) and \
            writes how they differ there. Exits with 0 when everything reads, 1 when anything fails, \
            and 2 when a folder isn't an install or can't be listed.
            """)

    /// The FAR1 layouts, by the names the command line takes.
    enum Variant: String, ExpressibleByArgument, CaseIterable {
        case a, b

        var layout: FAR1Archive.Variant {
            switch self {
            case .a: .a
            case .b: .b
            }
        }
    }

    @Option(name: .customLong("far1-variant"), help: "FAR1 layout: b for TSO, a for The Sims 1.")
    var far1Variant: Variant = .b

    @Flag(help: "Open archives without reading entries or parsing chunks.")
    var headersOnly = false

    @Option(help: "List at most this many failures; all of them are counted.")
    var maxFailures = 50

    @Option(help: """
        Without a folder: an install to check, game ($TSO_GAME_DIR), classic ($TSO_CLASSIC_DIR), \
        or beta ($TSO_BETA_DIR). Repeatable; without it, every one that's set.
        """)
    var install: [InstallKind] = []

    @Option(help: "Where to note how the installs differ, if it doesn't exist yet.")
    var differences = "docs/results/install-differences.md"

    @Argument(help: "The install folder. Defaults to the installs the environment names.")
    var directory: String?

    func validate() throws {
        guard maxFailures >= 0 else { throw ValidationError("--max-failures takes a number of 0 or more.") }
        guard directory == nil || install.isEmpty else {
            throw ValidationError("--install picks from the environment; give it or a folder, not both.")
        }
    }

    /// An install to check, and where it was named.
    struct Install: Equatable {
        /// The environment variable that named it, or `nil` for the command line.
        var source: String?
        var directory: URL
    }

    /// The installs to check: the argument, else each one the configuration names that
    /// `--install` picks, in ``InstallKind`` order. Two settings naming one folder check it once.
    func installs(in config: ConfigReader) throws(ValidationError) -> [Install] {
        if let directory {
            guard !directory.isEmpty else { throw ValidationError("The folder can't be empty.") }
            return [Install(source: nil, directory: URL(fileURLWithPath: directory, isDirectory: true))]
        }
        let kinds = install.isEmpty ? InstallKind.allCases : InstallKind.allCases.filter(install.contains)
        let found = InstallKind.installs(in: config).filter { kinds.contains($0.kind) }
            .map { Install(source: $0.kind.environmentVariable, directory: $0.directory) }
        guard !found.isEmpty else {
            let variables = kinds.map(\.environmentVariable)
            let list = variables.count < 3 ? variables.joined(separator: " and ")
                : variables.dropLast().joined(separator: ", ") + ", and " + (variables.last ?? "")
            throw ValidationError("No folder given and \(list) \(variables.count == 1 ? "is" : "are") not set.")
        }
        return found
    }

    /// The header line for an install: where it was named, its folder, and the version its
    /// `version` file records, if it has one.
    static func header(for install: Install) -> String {
        let version: String
        do {
            version = try GameVersion.read(install: install.directory).map { " (\($0))" } ?? ""
        } catch {
            version = " (version unknown: \(error))"
        }
        return "== \(install.source.map { "\($0): " } ?? "")\(install.directory.path)\(version)"
    }

    /// How the differences page names an install: its variable (or folder) and its version.
    static func label(for install: Install) -> String {
        let version = (try? GameVersion.read(install: install.directory)).flatMap { $0.map { " (\($0))" } } ?? ""
        return "`\(install.source ?? install.directory.path)`\(version)"
    }

    /// Compares each install with the next newer one and writes the differences file, unless it
    /// exists. `installs` is in ``InstallKind`` order, newest first. Returns false if a
    /// comparison or the write failed.
    func noteDifferences(between installs: [Install], date: Date = Date()) -> Bool {
        let file = URL(fileURLWithPath: differences)
        print("")
        guard !FileManager.default.fileExists(atPath: file.path) else {
            print("differences: already noted in \(differences); delete it to compare again")
            return true
        }
        guard FileManager.default.fileExists(atPath: file.deletingLastPathComponent().path) else {
            print("differences: not compared; \(file.deletingLastPathComponent().path) doesn't exist (run from the repository root, or pass --differences)")
            return true
        }
        let oldestFirst = Array(installs.reversed())
        do {
            var steps: [DifferencesReport.Step] = []
            for (older, newer) in zip(oldestFirst, oldestFirst.dropFirst()) {
                let result = try InstallComparison(far1Variant: far1Variant.layout).compare(older.directory, newer.directory)
                steps.append(DifferencesReport.Step(older: Self.label(for: older), newer: Self.label(for: newer), differences: result))
                print("differences: \(older.source ?? "the older") to \(newer.source ?? "the newer"): "
                      + "\(result.changedFiles.count) files differ, \(result.onlyInFirst.count) only in the older, "
                      + "\(result.onlyInSecond.count) only in the newer")
            }
            try Data(DifferencesReport.markdown(steps, date: date).utf8).write(to: file, options: .withoutOverwriting)
            print("differences: noted in \(differences)")
            return true
        } catch {
            fflush(nil)
            FileHandle.standardError.write(Data("tsofiles-check: can't compare the installs: \(error)\n".utf8))
            return false
        }
    }

    func run() throws {
        let installs = try installs(in: ConfigReader(provider: EnvironmentVariablesProvider()))
        let scanner = InstallScanner(far1Variant: far1Variant.layout, readsEntries: !headersOnly, parsesChunks: !headersOnly)
        var exitCode: Int32 = 0
        var scanned: [Install] = []
        for (index, install) in installs.enumerated() {
            if installs.count > 1 || install.source != nil {
                if index > 0 { print("") }
                print(Self.header(for: install))
            }
            fflush(nil) // keep the header ahead of any error on standard error
            guard GameLocator.isInstall(install.directory) else {
                FileHandle.standardError.write(Data("tsofiles-check: \(install.directory.path) isn't a TSO install (no objectdata folder)\n".utf8))
                exitCode = 2
                continue
            }
            let report: ScanReport
            do {
                report = try scanner.scan(directory: install.directory)
            } catch {
                FileHandle.standardError.write(Data("tsofiles-check: can't list \(install.directory.path): \(error)\n".utf8))
                exitCode = 2
                continue
            }
            for line in ScanReportText.lines(for: report, maxFailures: maxFailures) {
                print(line)
            }
            scanned.append(install)
            if !report.isClean && exitCode == 0 { exitCode = 1 }
        }
        if scanned.count >= 2, !noteDifferences(between: scanned) { exitCode = 2 }
        if exitCode != 0 { throw ExitCode(exitCode) }
    }
}

/// The report `tsofiles-check` prints, one string per line.
enum ScanReportText {
    static func lines(for report: ScanReport, maxFailures: Int) -> [String] {
        var lines = ContainerKind.allCases.map { "\($0.rawValue): \(report.containerCounts[$0, default: 0]) files" }
        lines.append("entries read: \(report.entriesRead) (IFFs inside archives: \(report.nestedIFFCount))")
        let chunkSummary = report.chunkCounts.sorted { $0.key < $1.key }.map { "\($0.key) \($0.value)" }
        lines.append("chunks parsed: \(report.chunkCounts.values.reduce(0, +))"
                     + (chunkSummary.isEmpty ? "" : " (\(chunkSummary.joined(separator: ", ")))"))
        lines.append("other files: \(report.otherFileCount)")
        lines.append("failures: \(report.failures.count)")
        for failure in report.failures.prefix(maxFailures) {
            let location = failure.entry.map { "\(failure.path): \($0)" } ?? failure.path
            lines.append("  \(location): \(failure.message)")
        }
        if report.failures.count > maxFailures {
            lines.append("  ... and \(report.failures.count - maxFailures) more")
        }
        if !report.unreferencedChunkFailures.isEmpty {
            lines.append("unreferenced chunks that don't parse (the game never loads them): \(report.unreferencedChunkFailures.count)")
            for failure in report.unreferencedChunkFailures.prefix(maxFailures) {
                lines.append("  \(failure.path): \(failure.entry ?? ""): \(failure.message)")
            }
        }
        return lines
    }
}

extension InstallKind: @retroactive ExpressibleByArgument {}
