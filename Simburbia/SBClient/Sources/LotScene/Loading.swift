/// The loading screen's lines, sliding in one after another as loading goes on, as FreeSO's
/// `LoadingScreen` slides them: each new line comes in from the right as the last goes out to the
/// left, both moving the screen's width in a second, at an even pace. A line comes in only when
/// the one before it has settled and loading has reached its share: with four lines, the second
/// at a quarter, the third at half, the last at three quarters. So the lines take at least a
/// second each however quickly the lot loads, which gives what's loaded time to settle.
public struct SlidingLines: Sendable, Equatable {
    /// How long a line takes to slide in, in seconds (FreeSO's tween of 1.0).
    public static let slideSeconds = 1.0

    public let lines: [String]
    /// The line sliding in, or settled, by its index.
    public private(set) var current = 0
    /// How far it has slid in, 0 (off the right) to 1 (settled).
    public private(set) var slid: Double = 0

    public init(lines: [String]) {
        self.lines = lines
    }

    /// Moves the slide on by `seconds`, and starts the next line once this one has settled and
    /// `progress` (0 to 1) has reached it.
    public mutating func advance(seconds: Double, progress: Double) {
        slid = min(1, slid + max(0, seconds) / Self.slideSeconds)
        guard slid >= 1, current + 1 < lines.count,
              progress >= Double(current + 1) / Double(lines.count) else { return }
        current += 1
        slid = 0
    }

    /// Whether every line has had its turn and loading is done, so the screen can give way (FreeSO
    /// moves on when the last line has settled and loading is complete).
    public func isFinished(progress: Double) -> Bool {
        progress >= 1 && slid >= 1 && current + 1 >= lines.count
    }

    /// Where the line sliding out and the one sliding in are, as fractions of the screen's width
    /// from its left: the old one from 0 to −1, the new one from 1 to 0.
    public var offsets: (outgoing: Double, incoming: Double) {
        (-slid, 1 - slid)
    }

    /// The line sliding out, if one is.
    public var outgoing: String? {
        current > 0 && slid < 1 ? lines[current - 1] : nil
    }

    /// The line sliding in or settled.
    public var incoming: String? {
        lines.indices.contains(current) ? lines[current] : nil
    }
}
