import Foundation
import Testing
import SimAntics
import TSOContent
@testable import SBOracleCore

@Suite struct CensusTests {
    let install = repository.appendingPathComponent("MockInstall/TSOClient")
    let mockLot = repository.appendingPathComponent("MockInstall/Lots/mock-lot.xml")

    private func analyze(catalog: ObjectCatalog? = nil, columns: [Census.Column]? = nil) throws -> Census.Result {
        let content = try GameContent(.init(gameDirectory: install))
        let lot = try Blueprint(xml: try Data(contentsOf: mockLot))
        return try Census.analyze(content: content, catalog: try catalog ?? content.catalog(), columns: columns ?? [
            .init(name: "catalog"),
            .init(name: "mock-lot", guids: Set(lot.objects.map(\.guid))),
        ])
    }

    @Test func countsTheCatalogAndTheLotsObjects() throws {
        let result = try analyze()
        #expect(result.catalogEntries == 7)
        #expect(result.buyableEntries == 5)
        #expect(result.columns.map(\.name) == ["catalog", "mock-lot"])
        #expect(result.columns[0].counts.objects == 5)
        #expect(result.columns[0].counts.loaded == 5)
        // The lot also places 0x4D4F43FF, which the catalog doesn't list.
        #expect(result.columns[1].counts.objects == 4)
        #expect(result.columns[1].counts.loaded == 4)
        #expect(result.failures.isEmpty)
        #expect(result.columns[0].counts.routines == 11)
        #expect(result.columns[0].counts.primitives == 25)
    }

    @Test func countsPrimitivesAndShapes() throws {
        let counts = try analyze().columns[0].counts
        #expect(counts.primitiveUses[2] == 17)
        #expect(counts.shapes[.init(opcode: 2, variables: "myObject,literal")] == 10)
        #expect(counts.shapes[.init(opcode: 25, variables: "literal")] == 4)
        #expect(counts.shapes[.init(opcode: 28, variables: "-")] == 4)
        #expect(counts.shapes.values.reduce(0, +) == counts.primitives)
        #expect(counts.scopes["literal"] == 18)
        #expect(counts.scopes["myObjectAttributes"] == 5)
        #expect(counts.scopes.values.reduce(0, +) > 0)
    }

    @Test func reportsCatalogEntriesTheInstallDoesNotHave() throws {
        let catalog = try ObjectCatalog(bytes: Data(#"<Catalog><P g="0xDEADBEEF" s="1" p="1" n="Missing"></P></Catalog>"#.utf8))
        let result = try analyze(catalog: catalog, columns: [.init(name: "catalog")])
        #expect(result.columns[0].counts.objects == 1)
        #expect(result.columns[0].counts.missing == 1)
        #expect(result.columns[0].counts.errors == 0)
        #expect(result.failures == [.init(column: "catalog", guid: 0xDEAD_BEEF, reason: "not registered or has no OBJD")])
    }

    @Test func keepsTheFirstOfDuplicateCatalogEntries() throws {
        // A catalog that lists a GUID twice shouldn't crash the walk; the first entry wins.
        let catalog = try ObjectCatalog(bytes: Data("""
            <Catalog>
            <P g="0x4D4F4301" s="1" p="50" n="Chair"></P>
            <P g="0x4D4F4301" s="2" p="60" n="Chair again"></P>
            </Catalog>
            """.utf8))
        let result = try analyze(catalog: catalog, columns: [.init(name: "catalog")])
        #expect(result.columns[0].counts.objects == 1)
        #expect(result.columns[0].counts.loaded == 1)
        #expect(result.failures.isEmpty)
    }

    @Test func writesAHeaderAndOneRowPerCount() throws {
        let lines = try analyze().lines()
        #expect(lines[0] == "# sb-oracle census")
        #expect(lines.contains("# catalog: 5 buyable of 7 entries"))
        #expect(lines.contains("# column mock-lot: 4 objects"))
        #expect(lines.contains("kind\tkey\tcatalog\tmock-lot"))
        #expect(lines.contains("summary\tobjects\t5\t4"))
        #expect(lines.contains("primitive\t2 expression (ported)\t17\t14"))
        #expect(lines.contains("shape\t2 expression: myObject,literal\t10\t8"))
        #expect(lines.contains("scope\tliteral\t18\t15"))
    }

    /// Each object's reach matches what a lot run covers: the mock lot's objects run code from
    /// their own files, and each site a run reaches in them is one the reach lists.
    @Test func reachListsTheRoutinesARunReaches() throws {
        let content = try GameContent(.init(gameDirectory: install))
        let lot = try Blueprint(xml: try Data(contentsOf: mockLot))
        let guids = Array(Set(lot.objects.map(\.guid))).sorted()
        let reach = try Census.reach(content: content, guids: guids)
        let behaviorOnly = try Census.reach(content: content, guids: guids, interactions: false)
        #expect(!reach.byObject.isEmpty && reach.sizes.values.allSatisfy { $0 > 0 })
        for (guid, routines) in behaviorOnly.byObject { #expect(Set(routines).isSubset(of: Set(reach.byObject[guid] ?? []))) }

        let coverage = Coverage()
        _ = Answers(content: content).lotRun(lot, ticks: 300, every: 300, coverage: coverage)
        let reachable = Set(reach.byObject.values.joined())
        let ownFiles = coverage.sites.filter { $0.file.hasPrefix("object ") }
        #expect(!ownFiles.isEmpty)
        #expect(ownFiles.allSatisfy { reachable.contains(Census.RoutineSite(file: $0.file, id: $0.routine)) })

        // What's covered counts against each object's reach.
        let counts = Census.Reach.coveredCounts(coverage.sites)
        let guid = try #require(guids.first { reach.byObject[$0] != nil })
        let total = (reach.byObject[guid] ?? []).reduce(0) { $0 + (reach.sizes[$1] ?? 0) }
        #expect(reach.uncovered(guid, coveredCounts: [:]) == total)
        #expect(reach.uncovered(guid, coveredCounts: counts) <= total)
    }
}
