import ArgumentParser
import Foundation
import SBOracleCore
import SimAntics

extension SBOracle {
    /// `census`: what the buy catalog's behavior reaches, counted without a VM.
    struct CensusCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "census",
            abstract: "Count the primitives, operand shapes, and variable scopes reachable from the buy-mode catalog and lots.",
            discussion: """
                Starts from every buyable object's OBJD behavior fields, OBJf entry points, and TTAB \
                interactions, follows subroutine calls and run_tree_by_name, and counts the primitives, \
                operand shapes, and variable scopes in the routines it reaches. No VM runs, and FreeSO \
                isn't needed. A routine shared by several objects is counted once per column. The \
                `catalog` column counts every buyable object; each lot column counts only the objects \
                the lot places that are also in the catalog.
                """)

        @OptionGroup var install: InstallOptions

        @Option(name: .customLong("lot"),
                help: "A lot to count as its own column (default: Lots/tonys-lot.xml and Lots/community-lot.xml in this repository). Repeatable.")
        var lots: [String] = []

        @Flag(help: "Only count the whole buy catalog, without the default lots.") var catalogOnly = false

        func run() async throws {
            let content = try await install.load()
            let catalog = try content.catalog()
            let paths = lots.isEmpty && !catalogOnly ? Self.defaultLots.map(\.path) : lots
            var columns = [Census.Column(name: "catalog")]
            var names: Set<String> = ["catalog"]
            for path in paths {
                let url = URL(fileURLWithPath: path)
                let lot = try Blueprint(xml: try Data(contentsOf: url))
                let base = url.deletingPathExtension().lastPathComponent
                var name = base
                var suffix = 2
                while !names.insert(name).inserted {
                    name = "\(base)-\(suffix)"
                    suffix += 1
                }
                columns.append(.init(name: name, guids: Set(lot.objects.map(\.guid))))
            }
            for line in try Census.analyze(content: content, catalog: catalog, columns: columns).lines() { print(line) }
        }

        /// The lots the census counts by default: the owner's lot and the group lot beside it.
        static var defaultLots: [URL] {
            let folder = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("../../../Lots").standardizedFileURL
            return [folder.appendingPathComponent("tonys-lot.xml"), folder.appendingPathComponent("community-lot.xml")]
        }
    }
}
