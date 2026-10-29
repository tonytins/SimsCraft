import Foundation
import Testing
import TSOContent
import TSOFiles
@testable import SimsScript

let gameDirectory: URL? = InstallKind.installs(in: ProcessInfo.processInfo.environment)
    .first { $0.kind == .game }?.directory

/// Every routine in the install converts to assembly and back unchanged.
@Suite(.enabled(if: gameDirectory != nil, "TSO_GAME_DIR is not set"))
struct RealAssemblyTests {
    @Test func everyRoutineRoundTrips() throws {
        let content = try GameContent(.init(gameDirectory: try #require(gameDirectory)))
        var files: [IFFFile] = [try content.global().mainFile]
        var seen = Set<String>()
        for reference in content.objects.references where seen.insert(reference.fileName).inserted {
            guard let object = try? content.objects.object(guid: reference.guid) else { continue }
            files.append(object.resource.mainFile)
            if let semiGlobal = object.resource.semiGlobal, seen.insert("semi " + semiGlobal.name).inserted {
                files.append(semiGlobal.mainFile)
            }
        }
        var checked = 0, problems: [String] = []
        for file in files {
            let routines = try file.chunks(BHAV.self)
            let reread = try Assembly.routines(from: Assembly.text(of: routines))
            for (original, copy) in zip(routines, reread) where !equal(original, copy) { problems.append("BHAV #\(original.id) \(original.label)") }
            if reread.count != routines.count { problems.append("routine count \(routines.count) became \(reread.count)") }
            checked += routines.count
        }
        print("Assembly round trip: \(checked) routines, \(problems.count) differ")
        #expect(checked > 10_000)
        #expect(problems.isEmpty, "\(problems.prefix(5))")
    }
}

/// Every object's routines list, with its names, one line per instruction.
@Suite(.enabled(if: gameDirectory != nil, "TSO_GAME_DIR is not set"))
struct RealListingTests {
    @Test func everyObjectsRoutinesList() throws {
        let content = try GameContent(.init(gameDirectory: try #require(gameDirectory)))
        let global = try content.global()
        var seen = Set<String>(), routines = 0, unported = 0, problems: [String] = []
        var byPrimitive: [String: Int] = [:]
        for reference in content.objects.references where seen.insert(reference.fileName).inserted {
            guard let object = try? content.objects.object(guid: reference.guid) else { continue }
            let names = RoutineNames(owner: object.resource, global: global)
            for routine in try object.resource.mainFile.chunks(BHAV.self) {
                let lines = Listing.text(of: routine, names: names).split(separator: "\n")
                if lines.count != routine.instructions.count + 1 { problems.append("\(reference.fileName) BHAV #\(routine.id)") }
                for line in lines where line.contains("(not ported yet)") || line.contains("(unknown)") {
                    unported += 1
                    let body = line.drop { $0 != ":" }.dropFirst().drop { $0 == " " }
                    byPrimitive[String(body.prefix { $0 != "(" }).trimmingCharacters(in: .whitespaces), default: 0] += 1
                }
                routines += 1
            }
        }
        print("Listing: \(routines) routines, \(unported) instructions with operands not yet spelled out")
        for (name, count) in byPrimitive.sorted(by: { ($1.value, $0.key) < ($0.value, $1.key) }) {
            print("  \(count)\t\(name)")
        }
        #expect(routines > 5_000)
        #expect(problems.isEmpty, "\(problems.prefix(5))")
    }
}
