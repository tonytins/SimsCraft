import SimAntics

/// What the inspector says about an object: what it is, where it is, and what it's running.
public struct Inspection: Sendable, Equatable {
    /// The object's name, from its definition's label.
    public var title: String
    /// Lines of detail, in order.
    public var lines: [String]

    /// The most stack frames listed.
    public static let mostFrames = 6

    public init(_ entity: Entity) {
        let definition = entity.object.definition
        title = definition.label.isEmpty ? "Object \(entity.objectID)" : definition.label
        var lines: [String] = []
        lines.append("GUID 0x" + String(entity.object.guid, radix: 16, uppercase: true) + "   ID \(entity.objectID)")
        let position = entity.leadObject.container == nil ? entity.position : entity.leadObject.position
        if position == .outOfWorld {
            lines.append("Not on the lot")
        } else {
            let tileX = Int(position.x) / 16, tileY = Int(position.y) / 16
            lines.append("Tile \(tileX), \(tileY) on floor \(position.level), facing \(entity.direction)")
        }
        if let container = entity.container {
            lines.append("In slot \(entity.containerSlot) of object \(container.objectID)")
        }
        let thread = entity.thread
        if thread.stack.isEmpty {
            lines.append("Idle")
        } else {
            lines.append("Running (most recent first):")
            for frame in thread.stack.reversed().prefix(Self.mostFrames) {
                lines.append("  \(frame.routine.name)  [\(frame.instructionPointer)]")
            }
            if thread.stack.count > Self.mostFrames { lines.append("  and \(thread.stack.count - Self.mostFrames) more") }
        }
        if let error = thread.lastError {
            lines.append("Last error: \(error)")
        }
        self.lines = lines
    }
}
