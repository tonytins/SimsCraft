import Foundation
import LotScene
import Logging
import SimAntics

/// The log of a headless or verbose run: the start, each system message as it arrives, a line
/// each game hour, and the summary. The lines come from ``RunReport``; this decides when.
final class RunLog {
    private var logger = Logger(label: "simburbia")
    private let session: LotSession
    private var messagesLogged = 0
    private var lastHour: Int32
    /// Each rule broken so far, by rule and object, so a rule that stays broken is logged once.
    private var brokenSoFar: Set<String> = []
    var brokenCount: Int { brokenSoFar.count }

    /// Sends logging to standard error, each line its level and its message, without the wall
    /// clock: every message carries the tick and game time instead.
    static func bootstrap() {
        LoggingSystem.bootstrap { label in GameLogHandler(label: label) }
    }

    init(session: LotSession, install: String) {
        self.session = session
        lastHour = session.vm.clock.hours
        for line in RunReport.start(session, version: GitVersion.version, install: install) { logger.info("\(line)") }
        for problem in session.contentProblems { logger.warning("\(RunReport.stamp(session.vm)): \(problem)") }
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

    /// Checks the lot's rules and logs each newly broken one.
    func checkRules() {
        let vm = session.vm
        for broken in vm.brokenRules() where brokenSoFar.insert("\(broken.rule.rawValue) \(broken.objectID)").inserted {
            logger.error("\(RunReport.broken(broken, in: vm))")
        }
    }

    func finish(ticks: Int, seconds: Double?, checkedRules: Bool = false) {
        update()
        for line in RunReport.summary(session.vm, ticks: ticks, seconds: seconds) { logger.info("\(line)") }
        if checkedRules { logger.info("\(RunReport.rulesSummary(session.vm, broken: brokenCount))") }
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
///
/// With `checksRules`, the lot's rules are checked after loading and every game minute, and the
/// run returns how many rules objects broke.
enum HeadlessRun {
    @discardableResult
    static func run(_ session: LotSession, ticks: Int, install: String, checksRules: Bool = false) -> Int {
        let log = RunLog(session: session, install: install)
        let every = max(1, Int(session.vm.clock.ticksPerMinute))
        if checksRules { log.checkRules() }
        let start = Date()
        for tick in stride(from: 1, through: ticks, by: 1) {
            session.vm.tick()
            log.update()
            if checksRules, tick % every == 0 || tick == ticks { log.checkRules() }
        }
        log.finish(ticks: ticks, seconds: Date().timeIntervalSince(start), checkedRules: checksRules)
        return log.brokenCount
    }
}
