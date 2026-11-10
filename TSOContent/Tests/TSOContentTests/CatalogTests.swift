import Foundation
import Testing
@testable import TSOContent

@Suite struct ObjectCatalogTests {
    @Test func readsTheMockCatalog() throws {
        let catalog = try GameContent(.init(gameDirectory: mockInstall)).catalog()
        #expect(catalog.entries.map(\.guid) == [0x4D4F_4301, 0x4D4F_4302, 0x4D4F_4305, 0x4D4F_4306, 0x4D4F_4307])
        #expect(catalog.entries.map(\.category) == [1, 2, 3, 4, 5])
        #expect(catalog.entries.map(\.price) == [50, 80, 20, 60, 40])
        #expect(catalog.entries.map(\.name) == ["Mock Chair", "Mock Table", "Mock Lamp", "Mock Register", "Mock Sim"])
    }

    @Test func leavesOutEntriesWithANegativeCategory() throws {
        let catalog = try ObjectCatalog(bytes: Data("""
            <Catalog>
            <P g="0x10" s="-1" p="0" n="Part"></P>
            <P g="0x20" s="0" p="10" n="Free"></P>
            <P g="0X30" s="29" p="20" n="Cursor"></P>
            </Catalog>
            """.utf8))
        #expect(catalog.entries == [.init(guid: 0x20, category: 0, price: 10, name: "Free"),
                                    .init(guid: 0x30, category: 29, price: 20, name: "Cursor")])
    }

    @Test func acceptsAPlainHexadecimalGUID() throws {
        let catalog = try ObjectCatalog(bytes: Data(#"<Catalog><P g="4D4F4301" s="1" p="50" n="Chair"></P></Catalog>"#.utf8))
        #expect(catalog.entries.first?.guid == 0x4D4F_4301)
    }

    @Test(arguments: [
        #"<Catalog><P s="1" p="50" n="Chair"></P></Catalog>"#,
        #"<Catalog><P g="zz" s="1" p="50" n="Chair"></P></Catalog>"#,
        #"<Catalog><P g="0x10" p="50" n="Chair"></P></Catalog>"#,
        #"<Catalog><P g="0x10" s="many" p="50" n="Chair"></P></Catalog>"#,
        #"<Catalog><P g="0x10" s="1" p="-5" n="Chair"></P></Catalog>"#,
        #"<Catalog><P g="0x10" s="1" p="50"></P></Catalog>"#,
        "not XML",
    ])
    func rejectsMalformedEntries(_ xml: String) {
        #expect(throws: ContentError.self) { try ObjectCatalog(bytes: Data(xml.utf8)) }
    }
}
