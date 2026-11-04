// The loading screen, as FreeSO's LoadingScreen paces it.

import Foundation
import Hudini
import LotScene
import Testing

private let simburbiaFolder = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

@Test func eachLineSlidesInOverASecondWhenLoadingHasReachedIt() {
    var lines = SlidingLines(lines: ["one", "two", "three", "four"])
    #expect(lines.incoming == "one" && lines.outgoing == nil && lines.offsets.incoming == 1)
    lines.advance(seconds: 0.5, progress: 0)
    #expect(lines.offsets.incoming == 0.5)
    // Settled, but loading hasn't reached a quarter, so the next line waits.
    lines.advance(seconds: 0.5, progress: 0.2)
    #expect(lines.current == 0 && lines.offsets.incoming == 0)
    lines.advance(seconds: 0.1, progress: 0.25)
    #expect(lines.current == 1 && lines.incoming == "two" && lines.outgoing == "one")
    // A slide is never cut short, however far loading has got.
    lines.advance(seconds: 0.5, progress: 1)
    #expect(lines.current == 1 && lines.offsets == (outgoing: -0.5, incoming: 0.5))
    #expect(!lines.isFinished(progress: 1))
}

@Test func theScreenGivesWayOnlyWhenEveryLineHasShownAndLoadingIsDone() {
    var lines = SlidingLines(lines: ["one", "two", "three", "four"])
    for _ in 0..<8 { lines.advance(seconds: 0.5, progress: 0.75) }
    // Three quarters loaded: all four lines have come in, but the last quarter is still loading.
    #expect(lines.current == 3 && !lines.isFinished(progress: 0.75))
    #expect(lines.isFinished(progress: 1))
    // So with everything loaded at once, the lines still take a second each.
    var quick = SlidingLines(lines: ["one", "two", "three", "four"])
    var seconds = 0.0
    while !quick.isFinished(progress: 1) {
        quick.advance(seconds: 0.25, progress: 1)
        seconds += 0.25
    }
    #expect(seconds == 4)
}

@Test func aSessionReportsHowFarItHasLoaded() throws {
    let reports = Reports()
    _ = try LotSession(ClientOptions(installs: [], simburbiaFolder: simburbiaFolder)) { reports.add($0) }
    #expect(reports.values == [0.25, 0.5, 0.75])
}

@Test func simburbiasOwnLoadingTextReadsCleanly() throws {
    let catalog = try CSTCatalog(directory: simburbiaFolder.appendingPathComponent("Interface/uitext", isDirectory: true))
    let table = try #require(catalog.table(1))
    #expect(table.problems.isEmpty)
    #expect(catalog.text(table: 1, key: "Caption") != nil)
    #expect((1...4).allSatisfy { catalog.text(table: 1, key: "\($0)") != nil })
}

private final class Reports: @unchecked Sendable {
    private(set) var values: [Double] = []
    func add(_ value: Double) { values.append(value) }
}
