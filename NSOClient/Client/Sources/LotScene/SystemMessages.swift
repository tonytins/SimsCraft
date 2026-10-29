import Foundation
import SimAntics
import TSOContent

/// The system messages the client's MOMI window shows: for now, each error a thread reported.
///
/// MOMI was TSO's in-universe name for its game masters, who sent players messages. NewSO uses
/// the name for its own messages, as the owner's prototype interface lays out.
public enum SystemMessages {
    /// What went wrong loading the content, from files nobody controls: a custom object or
    /// patch that couldn't be read, or a custom object whose GUID another object already has.
    public static func contentProblems(of content: GameContent) -> [String] {
        let failures = content.objects.standaloneFailures.map { failure in
            "Couldn't read the custom object \((failure.path as NSString).lastPathComponent): \(failure.reason)"
        }
        let conflicts = content.objects.duplicates.filter { $0.ignored.source == .standalone }.map { duplicate in
            "Left out the custom object \(duplicate.ignored.name ?? "?") (\((duplicate.ignored.fileName as NSString).lastPathComponent)): "
                + "its GUID \(String(format: "%08x", duplicate.ignored.guid)) belongs to \(duplicate.kept.name ?? duplicate.kept.fileName)"
        }
        let patches = content.patches.failures.map { "Couldn't read the patch \($0.path): \($0.message)" }
        return failures + conflicts + patches
    }

    /// One message per error the VM has reported, oldest first, naming the object when it's
    /// still on the lot.
    ///
    /// - Parameter includingTick: whether each starts with its tick, as MOMI shows them; a log
    ///   that stamps its lines itself leaves it out.
    public static func messages(of vm: VM, includingTick: Bool = true) -> [String] {
        vm.reportedErrors.map { report in
            let text = text(tick: report.tick, objectID: report.objectID,
                            objectName: vm.entity(id: report.objectID).map { Inspection($0).title }, error: report.error)
            return includingTick ? text : String(text.drop { $0 != ":" }.dropFirst(2))
        }
    }

    /// A message about an error, such as "Tick 30: Lamp (#12) reached behavior NewSO doesn't run
    /// yet: animate".
    public static func text(tick: UInt32, objectID: Int16, objectName: String?, error: SimAnticsError) -> String {
        let object = objectName.map { "\($0) (#\(objectID))" } ?? "Object #\(objectID)"
        return "Tick \(tick): \(object) \(sentence(for: error))"
    }

    static func sentence(for error: SimAnticsError) -> String {
        switch error {
        case .unsupported(let what): "reached behavior NewSO doesn't run yet: \(what)"
        case .infiniteLoop: "ran too many instructions in one tick and was reset"
        case .simantics(let what): "hit a SimAntics error and was reset: \(what)"
        case .indexOutOfRange(let what): "read past the end of something and was reset: \(what)"
        case .nullReference(let what): "used something that isn't there and was reset: \(what)"
        case .invalidCast(let what): "used the wrong kind of object and was reset: \(what)"
        case .overflow(let what): "overflowed a calculation and was reset: \(what)"
        case .content(let error): "needed content that couldn't load and was reset: \(error)"
        }
    }
}
