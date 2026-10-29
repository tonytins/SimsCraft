import ArgumentParser
import Foundation
import SimsScript
import TSOContent
import TSOFiles

/// `simsscript`: SimsScript's view of an install's objects.
@main
struct SimsScriptCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simsscript",
        abstract: "Read what TSO's objects do, as SimsScript writes it.",
        subcommands: [List.self])
}

/// The NSOClient folder, which holds MockInstall, next to FreeSO's content in the snapshot.
private let nsoclient = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

extension SimsScriptCommand {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print an object's routines with their names, one line per instruction.",
            discussion: """
                OBJECT is a GUID in hexadecimal (such as 0x4D4F4301) or a name: the object's file \
                name (such as mockchair) or its catalog name. With a name several objects share, \
                each is listed. Calls, parameters, locals, attributes, and constants are named \
                from the object's own files, its semi-global, and the global file.
                """)

        @Argument(help: "The object: a GUID in hexadecimal, or a name.")
        var object: String

        @Option(help: "Only this routine (a BHAV ID).")
        var routine: UInt16?

        @Option(help: "The TSO install (default: $TSO_GAME_DIR, else NSOClient's MockInstall).")
        var game: String?

        @Flag(help: "Also list the semi-global's routines.")
        var semiGlobal = false

        func run() throws {
            let directory = game.map { URL(fileURLWithPath: $0, isDirectory: true) }
                ?? InstallKind.installs(in: ProcessInfo.processInfo.environment).first { $0.kind == .game }?.directory
                ?? nsoclient.appendingPathComponent("MockInstall/TSOClient", isDirectory: true)
            let freeSO = nsoclient.appendingPathComponent("../TSOClient/tso.content/Content", isDirectory: true).standardizedFileURL
            let content = try GameContent(.init(gameDirectory: directory, freeSOContentDirectory: freeSO))
            let global = try content.global()

            let wanted = object.lowercased()
            let digits = wanted.hasPrefix("0x") ? String(wanted.dropFirst(2)) : wanted
            let matches = content.objects.references.filter { reference in
                UInt32(digits, radix: 16) == reference.guid
                    || reference.fileName.lowercased() == wanted || reference.name?.lowercased() == wanted
            }
            guard !matches.isEmpty else { throw ValidationError("no object named or numbered \(object)") }

            for reference in matches {
                guard let object = try content.objects.object(guid: reference.guid) else {
                    print("# \(String(format: "%08x", reference.guid)): the install doesn't have its file\n")
                    continue
                }
                let resource = object.resource
                print("# \(reference.name ?? resource.name) (\(String(format: "%08x", reference.guid)), \(resource.name))\n")
                let names = RoutineNames(owner: resource, global: global)
                var routines = try resource.mainFile.chunks(BHAV.self)
                if semiGlobal, let shared = resource.semiGlobal { routines += try shared.mainFile.chunks(BHAV.self) }
                if let routine { routines = routines.filter { $0.id == routine } }
                print(Listing.text(of: routines.sorted { $0.id < $1.id }, names: names))
            }
        }
    }
}
