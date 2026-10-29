import Foundation
import Testing
import TSOFiles
@testable import SimsScript

@Suite struct ObjectFileTests {
    let compiled: CompiledObject

    init() throws {
        compiled = try ScriptCompiler.compile("""
            integer a;
            integer b;
            bump() { a += 1; }
            default {
                initialize() { a = 0; b = 2; }
                main() { bump(); }
            }
            """)
    }

    @Test func writesTheDefinitionTheFunctionTableAndTheRoutines() throws {
        let file = try IFFFile(bytes: try compiled.objectFile(guid: 0x5C00_0001, name: "bumper"))
        #expect(file.chunks.map(\.typeCode) == ["OBJD", "OBJf"] + compiled.routines.map { _ in "BHAV" })
        let definition = try #require(try file.chunks(OBJD.self).first)
        #expect(definition.id == 128 && definition.label == "bumper" && definition.version == 142)
        #expect(definition.guid == 0x5C00_0001)
        #expect(definition.knownObjectType == .normal)
        #expect(definition.usesFnTable == 1)
        #expect(definition.numAttributes == 2)
        let table = try #require(try file.chunk(OBJf.self, id: 128))
        #expect(table.functions.map(\.actionFunction) == compiled.entryPoints)
        for routine in compiled.routines {
            let written = try #require(try file.chunk(BHAV.self, id: routine.id))
            #expect(written.instructions == routine.instructions && written.label == routine.label)
        }
    }

    @Test func reportsANameThatCantBeALabel() {
        #expect(throws: IFFWriteError.self) {
            try compiled.objectFile(guid: 1, name: String(repeating: "n", count: 65))
        }
    }
}
