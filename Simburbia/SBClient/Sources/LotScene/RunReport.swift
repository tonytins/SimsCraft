import SimAntics

/// The lines a headless or verbose run logs, worked out here without logging, so they're tested
/// without a window and the libraries stay free of logging.
public enum RunReport {
    /// The tick and the game time, which stamp every line: wall-clock time would differ between
    /// two runs of the same lot.
    public static func stamp(_ vm: VM) -> String {
        "tick \(vm.clock.ticks), \(vm.clock.hours):" + (vm.clock.minutes < 10 ? "0" : "") + "\(vm.clock.minutes)"
    }

    /// The ticks in a game day at the lot's clock rate: 216,000 at TSO's 150 a game minute.
    public static func ticksPerGameDay(_ vm: VM) -> Int {
        Int(vm.clock.ticksPerMinute) * 60 * 24
    }

    /// How long a game day lasts in real time at normal speed, such as "2 h 0 min".
    public static func gameDayLength(_ vm: VM) -> String {
        let seconds = Double(ticksPerGameDay(vm)) / LotSession.ticksPerSecond
        let minutes = Int((seconds / 60).rounded())
        return "\(minutes / 60) h \(minutes % 60) min"
    }

    /// What a run starts with: the lot, the install, and what the lot holds.
    public static func start(_ session: LotSession, install: String) -> [String] {
        let vm = session.vm
        var lines = ["\(stamp(vm)): lot \(session.lotName), install \(install)",
                     "\(stamp(vm)): \(vm.entities.count) entities; a game minute is \(vm.clock.ticksPerMinute) ticks, "
                         + "so a game day is \(ticksPerGameDay(vm)) ticks, \(gameDayLength(vm)) at normal speed"]
        for missing in session.leftOut {
            lines.append("\(stamp(vm)): left out object 0x\(String(missing.object.guid, radix: 16)): \(missing.reason)")
        }
        return lines
    }

    /// The line logged each game hour.
    public static func hour(_ vm: VM) -> String {
        "\(stamp(vm)): \(vm.entities.count) entities, \(vm.reportedErrors.count) errors so far"
    }

    /// What a run ends with: how far it went, and how fast it ran on this machine.
    ///
    /// - Parameter seconds: the real time the ticks took, or `nil` if the run wasn't timed.
    public static func summary(_ vm: VM, ticks: Int, seconds: Double?) -> [String] {
        let gameMinutes = Double(ticks) / Double(vm.clock.ticksPerMinute)
        var lines = ["\(stamp(vm)): ran \(ticks) ticks, \(gameDuration(minutes: gameMinutes)) of game time; "
                         + "\(vm.entities.count) entities, \(vm.reportedErrors.count) errors"]
        if let seconds, seconds > 0 {
            let rate = Double(ticks) / seconds
            lines.append("\(stamp(vm)): took \(String(format: "%.1f", seconds)) s, \(Int(rate)) ticks a second, "
                         + "\(String(format: "%.0f", rate / LotSession.ticksPerSecond))x normal speed")
        }
        return lines
    }

    /// Game minutes as "1 day 2 h 30 min", leaving out what's zero.
    public static func gameDuration(minutes: Double) -> String {
        let total = Int(minutes.rounded())
        let parts = [(total / 1440, "day"), (total / 60 % 24, "h"), (total % 60, "min")]
            .filter { $0.0 > 0 }
            .map { $0.1 == "day" ? "\($0.0) day\($0.0 == 1 ? "" : "s")" : "\($0.0) \($0.1)" }
        return parts.isEmpty ? "0 min" : parts.joined(separator: " ")
    }
}
