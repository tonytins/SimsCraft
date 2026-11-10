import Foundation
import Testing
@testable import TSOFiles

@Suite struct TuningXMLTests {
    private func read(_ xml: String) throws(TuningXMLError) -> TuningXML {
        try TuningXML(bytes: Data(xml.utf8))
    }

    @Test func readsEntriesAndValuesInOrder() throws {
        let document = try read("""
            <?xml version="1.0"?>
            <!-- Simburbia's defaults -->
            <Tuning version="1">
              <Entry name="SimMotives">
                <Value key="WakeHours"> 16 </Value>
                <Value key="EnergySpan">100</Value>
              </Entry>
              <Entry name="Empty"/>
            </Tuning>
            """)
        #expect(document.tuning.entries.map(\.name) == ["SimMotives", "Empty"])
        let motives = try #require(document.tuning.entry(named: "simmotives"))
        #expect(motives.values.map(\.key) == ["WakeHours", "EnergySpan"] && motives.number(forKey: "WakeHours") == 16)
        #expect(document.ignored.isEmpty)
    }

    /// Newer data an older build can skip: unknown elements anywhere, with what's inside them,
    /// unknown attributes, and stray text.
    @Test func skipsAndListsWhatItDoesntKnow() throws {
        let document = try read("""
            <Tuning version="1" author="someone">
              <Notes><Entry name="NotReally"><Value key="x">1</Value></Entry></Notes>
              loose text
              <Entry name="SimMotives" since="2">
                <Range low="0" high="24"/>
                <Value key="WakeHours" unit="hours">1<Hint>hours</Hint>6</Value>
              </Entry>
            </Tuning>
            """)
        #expect(document.tuning.entries.map(\.name) == ["SimMotives"])
        #expect(document.tuning.entry(named: "SimMotives")?.value(forKey: "WakeHours") == "16")
        #expect(document.ignored == ["Tuning/Notes", "Tuning/Entry[SimMotives]/Range", "Tuning/Entry[SimMotives]/Value[WakeHours]/Hint"])
    }

    @Test func refusesNewerVersionsAndBadDocuments() {
        #expect(throws: TuningXMLError.unsupportedVersion(2)) { try read(#"<Tuning version="2"/>"#) }
        #expect(throws: TuningXMLError.invalidVersion("1.5")) { try read(#"<Tuning version="1.5"/>"#) }
        #expect(throws: TuningXMLError.invalidVersion("0")) { try read(#"<Tuning version="0"/>"#) }
        #expect(throws: TuningXMLError.missingAttribute(element: "Tuning", attribute: "version")) { try read("<Tuning/>") }
        #expect(throws: TuningXMLError.notATuningDocument(root: "Blueprint")) { try read("<Blueprint/>") }
        #expect(throws: TuningXMLError.missingAttribute(element: "Entry", attribute: "name")) {
            try read(#"<Tuning version="1"><Entry/></Tuning>"#)
        }
        #expect(throws: TuningXMLError.missingAttribute(element: "Value", attribute: "key")) {
            try read(#"<Tuning version="1"><Entry name="A"><Value>1</Value></Entry></Tuning>"#)
        }
        #expect(throws: TuningXMLError.repeatedEntry("a")) {
            try read(#"<Tuning version="1"><Entry name="A"/><Entry name="a"/></Tuning>"#)
        }
        #expect(throws: TuningXMLError.repeatedKey(entry: "A", key: "k")) {
            try read(#"<Tuning version="1"><Entry name="A"><Value key="k">1</Value><Value key="k">2</Value></Entry></Tuning>"#)
        }
    }

    @Test func refusesBrokenXML() {
        for broken in [#"<Tuning version="1"><Entry name="A">"#, "", #"<Tuning version="1"></Entry>"#] {
            #expect(throws: TuningXMLError.self, "\(broken)") { try read(broken) }
        }
    }

    @Test func mergesKeyByKey() {
        let defaults = TuningFile(entries: [
            .init(name: "SimMotives", values: [("WakeHours", "16"), ("EnergySpan", "100")]),
            .init(name: "LotMotives", values: [("None_HungerWeight", "1")]),
        ])
        let install = TuningFile(entries: [
            .init(name: "simmotives", values: [("EnergySpan", "180"), ("EnergyDrift", "0")]),
            .init(name: "Stores", values: [("Max", "3")]),
        ])
        let merged = defaults.merging(install)
        #expect(merged.entries.map(\.name) == ["SimMotives", "LotMotives", "Stores"])
        let motives = merged.entries[0].values.map { "\($0.key)=\($0.value)" }
        #expect(motives == ["WakeHours=16", "EnergySpan=180", "EnergyDrift=0"])
        #expect(merged.entry(named: "LotMotives")?.value(forKey: "None_HungerWeight") == "1")
    }
}
