import Foundation
import Testing
import TSOContent
@testable import SimAntics

/// Coverage: which instructions a lot's threads run, recorded without changing the run.
@Suite struct CoverageTests {
    private func mockLot(recording: Bool) throws -> VM {
        let vm = try VM(content: try GameContent(.init(gameDirectory: mockInstall)), seed: 1)
        vm.recordsCoverage = recording
        let file = mockInstall.deletingLastPathComponent().appendingPathComponent("Lots/mock-lot.xml")
        try vm.load(try Blueprint(xml: try Data(contentsOf: file)))
        return vm
    }

    @Test func recordsTheInstructionsThreadsRun() throws {
        let vm = try mockLot(recording: true)
        for _ in 0..<300 { vm.tick() }
        let covered = vm.coveredInstructions()
        #expect(!covered.isEmpty)
        #expect(covered == covered.sorted() && Set(covered).count == covered.count)
        #expect(covered.allSatisfy { $0.file == "global" || $0.file.hasPrefix("object ") || $0.file.hasPrefix("semi-global ") })
        // The mock chair's main counts its runs from its own file.
        #expect(covered.contains { $0.file.hasPrefix("object ") })
    }

    @Test func recordsNothingUnlessAskedAndChangesNoResult() throws {
        let off = try mockLot(recording: false), on = try mockLot(recording: true)
        for _ in 0..<300 {
            off.tick()
            on.tick()
        }
        #expect(off.coveredInstructions().isEmpty)
        #expect(StateDigest.hex(of: off) == StateDigest.hex(of: on))
    }

    @Test func aSiteReadsBackFromItsLine() {
        let site = InstructionSite(file: "semi-global mock", routine: 8192, index: 3)
        #expect(InstructionSite(line: site.description) == site)
        #expect(InstructionSite(line: "global\t256") == nil && InstructionSite(line: "global\tx\t1") == nil)
    }
}
