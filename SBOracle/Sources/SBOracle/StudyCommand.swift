import ArgumentParser
import Foundation
import SBOracleCore
import SimAntics
import TSOContent
import TSOFiles

/// `sb-oracle study`: the randomized study (`Study`), run on both VMs for a time budget.
struct StudyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "study",
        abstract: "Sample objects onto lots, run each lot a game day on both VMs, and compare.",
        discussion: """
            Until --minutes have passed, each lot takes --objects of the install's objects that both \
            sides can load (no Sims, no multi-tile parts but their lead), picked by its seed with the \
            ones the ledger hasn't seen first, and lays them on a grid of an emptied lot. Simburbia runs \
            it first: an object that reaches something Simburbia doesn't support yet is recorded and \
            set aside, and the lot runs again without it. Then fso-oracle runs it, and the digests are \
            compared every game hour. A lot that disagrees is halved until the fewest objects that \
            still disagree are found. Each lot's blueprint is kept in --out/lots, so any of them can be \
            run again, and the records go to --out/study.tsv, which compare --study reads.
            """)

    @OptionGroup var install: InstallOptions

    @Option(help: "fso-oracle list-objects' records for this install (objects.tsv): only objects FreeSO loads are sampled.")
    var fsoObjects: String

    @Option(help: "The folder for the study's records and its lots' blueprints.")
    var out: String

    @Option(help: "The ledger of each object's latest result, read and updated (such as docs/results/sb-study-ledger.tsv).")
    var ledger: String?

    @Option(help: "How long to sample lots for, in minutes; the lot under way when it runs out is finished.")
    var minutes: Double = 5

    @Option(help: "The first lot's seed, in decimal; each lot after adds one (default: the time now, recorded).")
    var seed: UInt64?

    @Option(help: "Objects on each lot.")
    var objects = Study.objectsPerLot

    @Option(name: .customLong("floor-plan"), help: """
        A lot whose walls and floors a sample may go on, its own objects taken out; each lot's seed \
        picks one. Repeatable (default: Blueprints/empty_lot_fso.xml in the content folder).
        """)
    var floorPlans: [String] = []

    @Option(help: "fso-oracle's executable, already built (dotnet build FSO.Oracle -c Release).")
    var fsoOracle = fsoOracleExecutable.path

    @Option(help: "Ticks each lot runs (a game day by default).") var ticks = 216_000
    @Option(help: "A digest every this many ticks (a game hour by default).") var every = 9_000

    /// The most lots a disagreement's halving runs on both sides.
    static let shrinkRuns = 6
    /// The most objects one lot sets aside before it's counted inconclusive.
    static let mostSetAside = 16

    func validate() throws {
        guard minutes > 0, minutes.isFinite else { throw ValidationError("--minutes takes a positive number") }
        guard objects > 0 else { throw ValidationError("--objects takes a positive number") }
        guard ticks > 0, every > 0 else { throw ValidationError("--ticks and --every take positive numbers") }
    }

    func run() async throws {
        let game = try await install.gameDirectory()
        let content = try await install.load()
        let answers = Answers(content: content)
        let outFolder = URL(fileURLWithPath: out, isDirectory: true)
        let lotsFolder = outFolder.appendingPathComponent("lots", isDirectory: true)
        try FileManager.default.createDirectory(at: lotsFolder, withIntermediateDirectories: true)

        let candidates = try Self.candidates(content, fsoObjects: URL(fileURLWithPath: fsoObjects))
        let leads = Self.leadParts(content)
        let planFiles = floorPlans.isEmpty ? [install.contentDirectory.appendingPathComponent("Blueprints/empty_lot_fso.xml")]
            : floorPlans.map { URL(fileURLWithPath: $0) }
        let plans = try planFiles.map { file in (name: file.lastPathComponent, lot: try Blueprint(xml: try Data(contentsOf: file))) }
        // Plans FreeSO couldn't run a lot on (TSO's nightclub00_01.xml, say), set aside for the rest of the run.
        var unusable: Set<Int> = []
        var book = (ledger.flatMap { try? String(contentsOfFile: $0, encoding: .utf8) }).map(StudyLedger.init(tsv:)) ?? StudyLedger()
        let firstSeed = seed ?? UInt64(Date().timeIntervalSince1970)
        guard FileManager.default.isExecutableFile(atPath: fsoOracle) else {
            throw ValidationError("no fso-oracle at \(fsoOracle); build it with dotnet build FSO.Oracle -c Release")
        }
        let runner = Runner(answers: answers, fsoOracle: fsoOracle, game: game, content: install.contentDirectory,
                            lotsFolder: lotsFolder, ticks: ticks, every: every)

        print("study: \(candidates.count) objects to sample from, \(objects) a lot, first seed \(firstSeed), \(minutes) minutes")
        var records: [String] = []
        let deadline = Date().addingTimeInterval(minutes * 60)
        var lotSeed = firstSeed
        while Date() < deadline {
            defer { lotSeed &+= 1 }
            var sample = Study.sample(candidates, count: objects, seed: lotSeed, tested: book.tested)
            guard !sample.isEmpty else { break }
            let usable = plans.indices.filter { !unusable.contains($0) }
            guard !usable.isEmpty else { break }
            let planIndex = usable[Study.floorPlan(of: usable.count, seed: lotSeed)]
            let base = plans[planIndex].lot

            // Simburbia first, since it's quick: set aside each object that reaches something it
            // doesn't support yet, and run the lot again without it.
            var lot = Study.lot(sample, on: base, seed: lotSeed)
            var ours = answers.lotRun(lot, ticks: ticks, every: every)
            var inconclusive: String?
            var setAside = 0
            while let last = ours.last, last.hasPrefix("unsupported") {
                // The object that reached it may be a part of a sampled multi-tile object, or one a
                // sampled object made; then halving the lot, on Simburbia alone, finds which.
                guard setAside < Self.mostSetAside, let (reached, reason) = Self.unsupported(last),
                      let guid = sample.contains(reached) ? reached
                        : leads[reached].flatMap({ sample.contains($0) ? $0 : nil })
                        ?? Self.culprit(of: reason, in: lot, answers: answers, ticks: ticks, every: every) else {
                    inconclusive = "Simburbia reached something unsupported in an object it can't set aside: \(Self.reason(of: last))"
                    break
                }
                records.append("object\t\(String(format: "0x%08X", guid))\tunsupported\t\(reason)")
                book.record(guid, name: nameOf(guid, content), result: "unsupported: \(reason)", seed: lotSeed)
                sample.removeAll { $0 == guid }
                setAside += 1
                lot.objects.removeAll { $0.guid == guid }
                ours = answers.lotRun(lot, ticks: ticks, every: every)
            }
            if inconclusive == nil, lot.objects.isEmpty { inconclusive = "every object was set aside" }
            if let inconclusive {
                records.append("lot\t\(lotSeed)\t\(lot.objects.count)\tinconclusive\t\(inconclusive)")
                print("lot \(lotSeed): inconclusive, \(inconclusive)")
                continue
            }

            // Then FreeSO, on the same lot.
            let file = "seed-\(lotSeed).xml"
            let theirs = try runner.fso(lot, file: file)
            if !theirs.leftOut.isEmpty {
                for guid in theirs.leftOut {
                    records.append("object\t\(String(format: "0x%08X", guid))\tleft out\tFreeSO couldn't place it")
                    book.record(guid, name: nameOf(guid, content), result: "left out: FreeSO couldn't place it", seed: lotSeed)
                }
                records.append("lot\t\(lotSeed)\t\(lot.objects.count)\tinconclusive\tFreeSO left objects out")
                print("lot \(lotSeed): inconclusive, FreeSO left \(theirs.leftOut.count) objects out")
                continue
            }
            guard theirs.lines.first?.hasPrefix("tick") == true else {
                records.append("lot\t\(lotSeed)\t\(lot.objects.count)\tinconclusive\tFreeSO couldn't run it on \(plans[planIndex].name)")
                print("lot \(lotSeed): inconclusive, FreeSO couldn't run it on \(plans[planIndex].name); not using that floor plan again")
                if plans.count > 1 { unusable.insert(planIndex) }
                continue
            }
            let comparison = Comparison.lotRuns(fso: theirs.lines.map { "\(file) \($0)" }, nso: ours.map { "\(file) \($0)" })
            if comparison.mismatches.isEmpty, comparison.matched == 1 {
                records.append("lot\t\(lotSeed)\t\(lot.objects.count)\tagree")
                for object in lot.objects {
                    records.append("object\t\(String(format: "0x%08X", object.guid))\tagree")
                    book.record(object.guid, name: nameOf(object.guid, content), result: "agree", seed: lotSeed)
                }
                print("lot \(lotSeed): \(lot.objects.count) objects agree on \(plans[planIndex].name)")
                continue
            }

            // A disagreement: halve the lot, keeping each object's tile and facing, to the fewest
            // objects that still disagree.
            let first = comparison.mismatches.first ?? "differs"
            records.append("lot\t\(lotSeed)\t\(lot.objects.count)\tdisagree\t\(first)")
            print("lot \(lotSeed): disagrees, \(first); narrowing it down")
            let whole = lot
            let (culprits, _) = Study.shrink(whole.objects.map(\.guid), maxRuns: Self.shrinkRuns) { subset in
                var part = whole
                part.objects.removeAll { !subset.contains($0.guid) }
                let mine = answers.lotRun(part, ticks: ticks, every: every)
                guard mine.last?.hasPrefix("unsupported") != true,
                      let fso = try? runner.fso(part, file: "seed-\(lotSeed)-\(subset.count).xml"), fso.leftOut.isEmpty,
                      fso.lines.first?.hasPrefix("tick") == true else { return false }
                return !Comparison.lotRuns(fso: fso.lines.map { "x \($0)" }, nso: mine.map { "x \($0)" }).mismatches.isEmpty
            }
            let guids = culprits.map { String(format: "0x%08X", $0) }
            records.append("shrunk\t\(lotSeed)\t\(guids.joined(separator: ","))\t\(first)")
            for guid in culprits {
                records.append("object\t\(String(format: "0x%08X", guid))\tdisagree\ton lot \(lotSeed): \(first)")
                book.record(guid, name: nameOf(guid, content), result: "disagree: \(first)", seed: lotSeed)
            }
            print("lot \(lotSeed): narrowed to \(guids.joined(separator: ", "))")
        }

        let recordsFile = outFolder.appendingPathComponent("study.tsv")
        try Data((records.joined(separator: "\n") + "\n").utf8).write(to: recordsFile)
        if let ledger { try Data(book.tsv.utf8).write(to: URL(fileURLWithPath: ledger)) }
        for comparison in Comparison.study(records) { print(comparison.summary) }
    }

    private func nameOf(_ guid: UInt32, _ content: GameContent) -> String {
        content.objects.reference(guid: guid)?.name ?? String(format: "0x%08X", guid)
    }

    /// The objects a lot may hold: those FreeSO's list says it loads and Simburbia does too, but
    /// no Sims (not ported yet) and no multi-tile part but the lead, which places the rest.
    static func candidates(_ content: GameContent, fsoObjects: URL) throws -> [UInt32] {
        let loads = Set(try String(contentsOf: fsoObjects, encoding: .utf8).split(separator: "\n").compactMap { line -> UInt32? in
            let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard fields.count >= 2, fields[1] != "error", fields[1] != "missing" else { return nil }
            return UInt32(fields[0], radix: 16)
        })
        return content.objects.references.map(\.guid).filter { guid in
            guard loads.contains(guid), let object = try? content.objects.object(guid: guid) else { return false }
            let definition = object.definition
            return definition.knownObjectType != .person && (definition.masterID == 0 || definition.subIndex == -1)
        }
    }

    /// Each multi-tile part's lead part, which a lot names: parts share the lead's IFF and group.
    static func leadParts(_ content: GameContent) -> [UInt32: UInt32] {
        let references = content.objects.references
        var leads: [String: UInt32] = [:]
        for reference in references where reference.group != 0 && reference.subIndex == -1 {
            leads["\(reference.fileName)/\(reference.group)"] = reference.guid
        }
        var result: [UInt32: UInt32] = [:]
        for reference in references where reference.group != 0 && reference.subIndex >= 0 {
            if let lead = leads["\(reference.fileName)/\(reference.group)"] { result[reference.guid] = lead }
        }
        return result
    }

    /// The one object of a lot that leads Simburbia to `reason`, found by halving the lot and
    /// running the halves on Simburbia alone, or `nil` if it takes more than one.
    static func culprit(of reason: String, in lot: Blueprint, answers: Answers, ticks: Int, every: Int) -> UInt32? {
        let (found, _) = Study.shrink(lot.objects.map(\.guid), maxRuns: 12) { subset in
            var part = lot
            part.objects.removeAll { !subset.contains($0.guid) }
            guard let last = answers.lotRun(part, ticks: ticks, every: every).last, last.hasPrefix("unsupported") else { return false }
            return Self.reason(of: last) == reason
        }
        return found.count == 1 ? found.first : nil
    }

    /// The object and what it reached, from `unsupported at tick N by 0xGUID: what`.
    static func unsupported(_ line: String) -> (UInt32, String)? {
        guard let by = line.range(of: " by 0x"), let colon = line.range(of: ": ", range: by.upperBound..<line.endIndex),
              let guid = UInt32(line[by.upperBound..<colon.lowerBound], radix: 16) else { return nil }
        return (guid, String(line[colon.upperBound...]))
    }

    static func reason(of line: String) -> String {
        line.range(of: ": ").map { String(line[$0.upperBound...]) } ?? line
    }

    /// Runs lots on FreeSO through `fso-oracle run-lot`, keeping each lot's blueprint.
    struct Runner {
        let answers: Answers
        let fsoOracle: String
        let game: URL
        let content: URL
        let lotsFolder: URL
        let ticks: Int
        let every: Int

        /// FreeSO's digests for a lot, and the objects it left out of it.
        func fso(_ lot: Blueprint, file: String) throws -> (lines: [String], leftOut: [UInt32]) {
            let blueprint = lotsFolder.appendingPathComponent(file)
            try lot.xml().write(to: blueprint)
            let output = lotsFolder.appendingPathComponent(file + ".fso.txt")
            let messages = lotsFolder.appendingPathComponent(file + ".fso.log")
            guard FileManager.default.createFile(atPath: output.path, contents: nil),
                  FileManager.default.createFile(atPath: messages.path, contents: nil) else {
                throw ValidationError("can't write fso-oracle's output in \(lotsFolder.path)")
            }
            let process = Process()
            // The built executable rather than dotnet run, whose wrapper can outlive the oracle.
            process.executableURL = URL(fileURLWithPath: fsoOracle)
            process.arguments = ["run-lot", "--game", game.path, "--content", content.path, "--blueprint", blueprint.path,
                                 "--ticks", "\(ticks)", "--every", "\(every)"]
            process.standardOutput = try FileHandle(forWritingTo: output)
            process.standardError = try FileHandle(forWritingTo: messages)
            process.standardInput = FileHandle.nullDevice
            try process.run()
            process.waitUntilExit()
            let lines = (try String(contentsOf: output, encoding: .utf8)).split(separator: "\n").map(String.init)
            let log = (try? String(contentsOf: messages, encoding: .utf8)) ?? ""
            // fso-oracle's "...object 0x1A2B3C4D; left out of the lot".
            let leftOut = log.split(separator: "\n").compactMap { line -> UInt32? in
                guard let end = line.range(of: "; left out"), let start = line[..<end.lowerBound].range(of: "0x", options: .backwards)
                else { return nil }
                return UInt32(line[start.upperBound..<end.lowerBound], radix: 16)
            }
            return (lines, leftOut)
        }
    }
}

/// fso-oracle as `dotnet build FSO.Oracle -c Release` builds it in this repository.
private let fsoOracleExecutable = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("../../../FSO.Oracle/bin/Release/net10.0/fso-oracle").standardizedFileURL
