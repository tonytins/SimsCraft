import Foundation
import LotScene
import Logging
import SimAntics

/// The log of a headless or verbose run: the start, each system message as it arrives, a line
/// each game hour, and the summary. The lines come from ``RunReport``; this decides when.
final class RunLog {
    private var logger = Logger(label: "newso")
    private let session: LotSession
    private var messagesLogged = 0
    private var lastHour: Int32

    /// Sends logging to standard error, each line its level and its message, without the wall
    /// clock: every message carries the tick and game time instead.
    static func bootstrap() {
        LoggingSystem.bootstrap { label in GameLogHandler(label: label) }
    }

    init(session: LotSession, install: String) {
        self.session = session
        lastHour = session.vm.clock.hours
        for line in RunReport.start(session, install: install) { logger.info("\(line)") }
        // Errors from loading the lot, before the first tick of the run.
        update()
    }

    /// Logs what's new since the last call: messages, and the hour if it turned.
    func update() {
        let vm = session.vm
        if vm.reportedErrors.count > messagesLogged {
            let messages = SystemMessages.messages(of: vm, includingTick: false)
            for message in messages[messagesLogged...] { logger.warning("\(RunReport.stamp(vm)): \(message)") }
            messagesLogged = messages.count
        }
        if vm.clock.hours != lastHour {
            lastHour = vm.clock.hours
            logger.info("\(RunReport.hour(vm))")
        }
    }

    func finish(ticks: Int, seconds: Double?) {
        update()
        for line in RunReport.summary(session.vm, ticks: ticks, seconds: seconds) { logger.info("\(line)") }
    }
}

/// Writes each log line as its level and message to standard error.
struct GameLogHandler: LogHandler {
    let label: String
    var logLevel: Logger.Level = .info
    var metadata: Logger.Metadata = [:]

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(event: LogEvent) {
        FileHandle.standardError.write(Data("\(event.level): \(event.message)\n".utf8))
    }
}

/// A run with no window: the lot ticks as fast as the machine allows, back to back, for a set
/// number of ticks, then the run logs its summary and ends. Like CityLimits' `HeadlessRun`, it
/// never touches raylib, so it needs no display.
enum HeadlessRun {
    static func run(_ session: LotSession, ticks: Int, install: String) {
        let log = RunLog(session: session, install: install)
        let start = Date()
        for _ in 0..<ticks {
            session.vm.tick()
            log.update()
        }
        log.finish(ticks: ticks, seconds: Date().timeIntervalSince(start))
    }
}
