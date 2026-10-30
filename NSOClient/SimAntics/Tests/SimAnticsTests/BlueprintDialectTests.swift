import Foundation
import Testing
@testable import SimAntics

/// TSO's blueprint dialect, as `blueprint.dtd` defines it and 1.1097.1.0's job lots use it, with
/// made-up values.
@Suite struct BlueprintDialectTests {
    /// A made-up lot in TSO's dialect: ISO-8859-1, CRLF line ends, a DOCTYPE, and every section.
    static let tsoLot = Data(("""
        <?xml version="1.0" encoding="ISO-8859-1" ?>
        <!DOCTYPE house SYSTEM "blueprint.dtd">
        <house version="1.0">
        \t<revision author="$Author: someone $" date="$Date: 2004/01/28 $" change="$Change: 1 $" />
        \t<size>4</size>
        \t<category>101</category>
        \t<world>
        \t\t<flags>
        \t\t\t<layer level="0">6,6,7,
        39,1,1,1,1,1,1,1,1,1,1,1,38</layer>
        \t\t\t<layer level="1">6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6</layer>
        \t\t</flags>
        \t\t<floors>
        \t\t\t<!-- Level 0 Floors -->
        \t\t\t<floor level="0" x="1" y="2" value="9" />
        \t\t</floors>
        \t\t<walls>
        \t\t\t<wall level="0" x="1" y="1" segments="4" placement="2" tls="1" trs="0" tlp="0" trp="0" blp="0" brp="314" />
        \t\t</walls>
        \t\t<pools><pool x="2" y="2" value="5" /></pools>
        \t\t<water><puddle x="3" y="1" value="12" /></water>
        \t</world>
        \t<sounds><sound id="504086947" on="1" /><sound id="7" /></sounds>
        \t<objects>
        \t\t<!-- 0-parent objects -->
        \t\t<object guid="0x38E2E75B" name="Death - Controller" group="0" />
        \t\t<object guid="0x81E6BEF9" name="Portal - Caf\u{E9}" group="0" x="2" y="3" level="1" dir="4" hidden="1" />
        \t</objects>
        </house>
        """.replacingOccurrences(of: "\n", with: "\r\n")).data(using: .isoLatin1) ?? Data())

    @Test func readsEverySectionOfTSOsDialect() throws {
        let lot = try Blueprint(xml: Self.tsoLot)
        #expect(lot.formatVersion == "1.0" && lot.newsoVersion == nil && !lot.wasRepaired)
        #expect(lot.revision == Blueprint.Revision(author: "$Author: someone $", date: "$Date: 2004/01/28 $", change: "$Change: 1 $"))
        #expect(lot.size == 4 && lot.category == 101)
        #expect(lot.flags.map(\.level) == [0, 1])
        #expect(lot.flags[0].values == [6, 6, 7, 39, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 38])
        #expect(lot.floors == [Blueprint.Floor(level: 0, x: 1, y: 2, pattern: 9)])
        #expect(lot.walls.first?.placement == 2 && lot.walls.first?.tile.bottomRightPattern == 314)
        #expect(lot.pools == [Blueprint.Pool(x: 2, y: 2, value: 5)])
        #expect(lot.puddles == [Blueprint.Puddle(x: 3, y: 1, value: 12)])
        #expect(lot.sounds == [Blueprint.Sound(id: 504_086_947, isOn: true), Blueprint.Sound(id: 7, isOn: false)])
        #expect(lot.objects == [
            Blueprint.Object(guid: 0x38E2_E75B, name: "Death - Controller"),
            Blueprint.Object(guid: 0x81E6_BEF9, level: 1, x: 2, y: 3, direction: .south, name: "Portal - Caf\u{E9}", isHidden: true),
        ])
        #expect(lot.unknownParts.isEmpty)
    }

    @Test func keepsWhatItDoesntKnow() throws {
        let xml = """
            <house version="1.0" flavor="sweet">
              <size>4</size>
              <weather kind="rain"><drop/></weather>
              <world><floors flavor="salty"><floor level="0" x="1" y="1" value="2" shine="3"/><rug/></floors></world>
              <objects><object guid="0x1" mood="happy"/></objects>
            </house>
            """
        let lot = try Blueprint(xml: Data(xml.utf8))
        #expect(lot.unknownElements.map(\.parent) == ["house", "house/world/floors"])
        #expect(lot.unknownElements.first?.xml.contains("<drop") == true)
        #expect(lot.otherAttributes == [Blueprint.Attribute(name: "house@flavor", value: "sweet"),
                                        Blueprint.Attribute(name: "house/world/floors@flavor", value: "salty")])
        #expect(lot.floors.first?.otherAttributes == [Blueprint.Attribute(name: "shine", value: "3")])
        #expect(lot.objects.first?.otherAttributes == [Blueprint.Attribute(name: "mood", value: "happy")])
        #expect(lot.unknownParts.count == 4)
    }

    @Test func readsFreeSOsDialectAsBefore() throws {
        let xml = """
            <?xml version="1.0" encoding="utf-8"?>
            <house xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
              <size>64</size><category>0</category>
              <world><floors><floor level="0" x="1" y="58" value="9" /></floors></world>
              <objects><object id="3" guid="0x39CCF441" level="1" x="30" y="52" dir="4" group="0" /></objects>
            </house>
            """
        let lot = try Blueprint(xml: Data(xml.utf8))
        #expect(lot.formatVersion == nil && lot.revision == nil && lot.flags.isEmpty && lot.sounds.isEmpty)
        #expect(lot.objects == [Blueprint.Object(guid: 0x39CC_F441, level: 1, x: 30, y: 52, direction: .south, id: 3)])
        #expect(lot.unknownParts.isEmpty)
    }

    @Test func toleratesAStrayAngleBracketAsInTSOsNightclub() throws {
        // nightclub00_01.xml has "<" and spaces before its level 1 layer.
        let xml = "<house><size>4</size><world><flags><layer level=\"0\">1</layer>\n<  \t<layer level=\"1\">2</layer></flags></world></house>"
        let lot = try Blueprint(xml: Data(xml.utf8))
        #expect(lot.wasRepaired && lot.flags.map(\.values) == [[1], [2]])
        // Only that: other broken XML still fails.
        #expect(throws: BlueprintError.self) { try Blueprint(xml: Data("<house><size>4</size><world>".utf8)) }
        #expect(throws: BlueprintError.self) { try Blueprint(xml: Data("<house><size>4</size>&</house>".utf8)) }
    }

    @Test func refusesANewerNewSOVersion() throws {
        let current = try Blueprint(xml: Data(#"<house><newso version="1"><later/></newso><size>4</size></house>"#.utf8))
        #expect(current.newsoVersion == 1)
        #expect(current.unknownElements.map(\.parent) == ["house/newso"])
        #expect(throws: BlueprintError.newerVersion(2, newest: 1)) {
            try Blueprint(xml: Data(#"<house><newso version="2"/><size>4</size></house>"#.utf8))
        }
    }

    @Test func neverReachesOutsideTheFile() throws {
        // A DTD that doesn't exist is ignored, and an external entity isn't expanded.
        let xml = """
            <?xml version="1.0"?>
            <!DOCTYPE house SYSTEM "file:///no/such/blueprint.dtd" [<!ENTITY secret SYSTEM "file:///etc/hostname">]>
            <house><size>4</size><objects><object guid="0x1" name="&secret;"/></objects></house>
            """
        let name = (try? Blueprint(xml: Data(xml.utf8)))?.objects.first?.name ?? ""
        let hostname = (try? String(contentsOfFile: "/etc/hostname", encoding: .utf8))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        #expect(hostname.isEmpty || !name.contains(hostname))
    }
}

/// Writing TSO's dialect: what's read back is the same lot.
@Suite struct BlueprintWriterTests {
    /// The blueprint as written and read back. Writing adds NewSO's marker, and Maxis' format
    /// version for a blueprint that had none; everything else must come back as it was.
    static func roundTrip(_ blueprint: Blueprint) throws -> Blueprint {
        var back = try Blueprint(xml: blueprint.xml())
        #expect(back.newsoVersion == Blueprint.newestVersion && back.formatVersion == (blueprint.formatVersion ?? "1.0"))
        #expect(!back.wasRepaired)
        back.newsoVersion = blueprint.newsoVersion
        back.formatVersion = blueprint.formatVersion
        return back
    }

    static func sameLot(_ a: Blueprint, _ b: Blueprint) -> Bool {
        a.formatVersion == b.formatVersion && a.revision == b.revision && a.newsoVersion == b.newsoVersion
            && a.size == b.size && a.category == b.category && a.flags == b.flags && a.floors == b.floors
            && a.pools == b.pools && a.puddles == b.puddles && a.walls == b.walls && a.sounds == b.sounds
            && a.objects == b.objects && a.unknownElements == b.unknownElements && a.otherAttributes == b.otherAttributes
    }

    @Test func writesTSOsDialectBackAsItWas() throws {
        let lot = try Blueprint(xml: BlueprintDialectTests.tsoLot)
        #expect(Self.sameLot(try Self.roundTrip(lot), lot))
        let text = String(decoding: lot.xml(), as: UTF8.self)
        // Maxis' layout: the DTD's order, names, hidden, comments per level, and no tile for a controller.
        #expect(text.contains(#"<object guid="0x38E2E75B" name="Death - Controller" group="0" />"#))
        #expect(text.contains("name=\"Portal - Caf\u{E9}\" group=\"0\" x=\"2\" y=\"3\" level=\"1\" dir=\"4\" hidden=\"1\" />"))
        #expect(text.contains("<!-- Level 0 Floors -->"))
        #expect(text.contains(#"<newso version="1" />"#) && !text.contains("DOCTYPE"))
        let order = ["<revision", "<newso", "<size>", "<category>", "<world>", "<flags>", "<floors>", "<walls>", "<pools>",
                     "<water>", "<sounds>", "<objects>"].compactMap { text.range(of: $0)?.lowerBound }
        #expect(order.count == 12 && order == order.sorted())
    }

    @Test func keepsWhatItDoesntKnowThroughAWrite() throws {
        let xml = """
            <house version="1.0" flavor="sweet">
              <newso version="1"><later kind="x"/></newso>
              <size>4</size>
              <weather kind="rain"><drop/></weather>
              <world><floors flavor="salty"><floor level="0" x="1" y="1" value="2" shine="3"/><rug/></floors></world>
              <objects><object guid="0x1" mood="happy"/></objects>
            </house>
            """
        let lot = try Blueprint(xml: Data(xml.utf8))
        let back = try Self.roundTrip(lot)
        #expect(Self.sameLot(back, lot))
        #expect(Set(back.unknownElements.map(\.parent)) == ["house/newso", "house", "house/world/floors"])
    }

    @Test func writesFreeSOsDialectAsTSOs() throws {
        let xml = """
            <house xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><size>64</size><category>0</category>
              <objects><object id="3" guid="0x39CCF441" level="1" x="30" y="52" dir="3" group="0" /></objects></house>
            """
        let lot = try Blueprint(xml: Data(xml.utf8))
        #expect(Self.sameLot(try Self.roundTrip(lot), lot))
        #expect(!String(decoding: lot.xml(), as: UTF8.self).contains("xmlns"))
    }

    @Test func escapesWhatItWrites() throws {
        var lot = try Blueprint(xml: Data("<house><size>4</size></house>".utf8))
        lot.objects = [Blueprint.Object(guid: 1, name: #"Tom & "Jerry" <3"#, otherAttributes: [.init(name: "note", value: "a\nb\tc")])]
        #expect(Self.sameLot(try Self.roundTrip(lot), lot))
    }

    @Test func roundTripsEveryBlueprintTheProjectHas() throws {
        let nsoclient = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("../../..").standardizedFileURL
        let folders = ["Lots", "MockInstall/Lots", "../TSOClient/tso.content/Content/Blueprints"].map { nsoclient.appendingPathComponent($0) }
        var count = 0
        for folder in folders {
            for file in (try? FileManager.default.contentsOfDirectory(atPath: folder.path))?.filter({ $0.hasSuffix(".xml") }) ?? [] {
                let lot = try Blueprint(xml: try Data(contentsOf: folder.appendingPathComponent(file)))
                #expect(Self.sameLot(try Self.roundTrip(lot), lot), "\(file)")
                count += 1
            }
        }
        #expect(count >= 4)
    }
}

/// TSO's own blueprints, the 23 job lots 1.1097.1.0 ships.
@Suite(.enabled(if: gameDirectory != nil, "TSO_GAME_DIR is not set"))
struct TSOBlueprintTests {
    @Test func readsEveryJobLot() throws {
        let folder = try #require(gameDirectory).appendingPathComponent("housedata/blueprints")
        let files = (try? FileManager.default.contentsOfDirectory(atPath: folder.path))?.filter { $0.hasSuffix(".xml") }.sorted() ?? []
        try #require(!files.isEmpty, "this install has no housedata/blueprints (only 1.1097.1.0 does)")
        var repaired: [String] = []
        for file in files {
            let lot = try Blueprint(xml: try Data(contentsOf: folder.appendingPathComponent(file)))
            if lot.wasRepaired { repaired.append(file) }
            #expect(BlueprintWriterTests.sameLot(try BlueprintWriterTests.roundTrip(lot), lot), "\(file) changes when written")
            #expect(lot.formatVersion == "1.0" && lot.revision != nil, "\(file)")
            #expect(lot.flags.count == 2 && lot.flags.allSatisfy { $0.values.count == lot.size * lot.size }, "\(file)")
            #expect(lot.objects.allSatisfy { $0.name != nil }, "\(file)")
            #expect(lot.unknownParts.isEmpty, "\(file): \(lot.unknownParts.prefix(3))")
            _ = try lot.architecture()
        }
        #expect(files.count == 23)
        #expect(repaired == ["nightclub00_01.xml"])
    }
}
