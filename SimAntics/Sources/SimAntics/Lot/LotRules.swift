/// Rules a running lot's state should always keep, checked on Simburbia alone.
///
/// The oracles compare Simburbia with FreeSO, which can't catch a mistake both make. These rules
/// need no second VM: each says something about the lot that should hold after any tick, whatever
/// the objects on it do. A broken rule is reported, never thrown, so a check never stops the lot.
/// The randomized study checks them as it runs (`sb-oracle study`), and so does
/// `simburbia --headless --check`.
///
/// Quirks Simburbia keeps on purpose aren't broken rules. A Sim left out of the world, as when
/// tile 3,3 is taken at join, is allowed, as is any object out of the world.
public enum LotRule: String, Sendable, Equatable, CaseIterable {
    /// A Sim's motives stay within −100 to 200. TSO let a motive go past 100 (the owner recalls up
    /// to 200); FreeSO, and Simburbia for now, keep them within −100 to 100.
    case motiveRange = "motive range"
    /// A Sim's online job ID stays at 4 or below, the most its setter takes.
    case onlineJobID = "online job ID"
    /// An object in the world is on the lot: its tile within the lot and its level 1 to 5.
    case onLot = "on the lot"
    /// The object ID index finds each entity, and finds nothing for a deleted one.
    case objectIndex = "object index"
    /// An object in the world is listed on the tile it's on.
    case tileIndex = "tile index"
    /// Containment points both ways: what a slot holds names that container and slot, and an
    /// object's container holds it there.
    case slots = "slots"
    /// An object in a slot is where its container is.
    case withContainer = "with its container"
    /// A multi-tile group lists each of its parts, and has a lead.
    case group = "multi-tile group"
}

/// A rule an entity broke, and how.
public struct BrokenRule: Sendable, Equatable, CustomStringConvertible {
    public var rule: LotRule
    /// The entity that broke it.
    public var objectID: Int16
    public var detail: String

    public init(rule: LotRule, objectID: Int16, detail: String) {
        self.rule = rule
        self.objectID = objectID
        self.detail = detail
    }

    public var description: String { "\(rule.rawValue): object \(objectID), \(detail)" }
}

extension VM {
    /// The lowest and highest motive values ``LotRule/motiveRange`` allows.
    public static let motiveRule: ClosedRange<Int16> = -100...200

    /// The rules the lot's state breaks now, in object ID order, or none.
    ///
    /// It reads the state and changes nothing, so checking doesn't change a run's digests.
    public func brokenRules() -> [BrokenRule] {
        var broken: [BrokenRule] = []
        for entity in entities.sorted(by: { $0.objectID < $1.objectID }) {
            check(entity, into: &broken)
        }
        return broken
    }

    private func check(_ entity: Entity, into broken: inout [BrokenRule]) {
        let id = entity.objectID
        func breaks(_ rule: LotRule, _ detail: String) {
            broken.append(BrokenRule(rule: rule, objectID: id, detail: detail))
        }

        if self.entity(id: id) !== entity { breaks(.objectIndex, "its ID finds another entity or none") }
        if entity.isDead { breaks(.objectIndex, "deleted, but still on the lot") }

        if entity.isAvatar {
            for (index, value) in entity.motiveData.enumerated() where !Self.motiveRule.contains(value) {
                breaks(.motiveRange, "motive \(index) is \(value)")
            }
            let job = entity.personData[PersonData.onlineJobID]
            if job > 4 { breaks(.onlineJobID, "online job ID is \(job)") }
        }

        let position = entity.position
        if !position.isOutOfWorld {
            let x = Int(position.tileX), y = Int(position.tileY), level = Int(position.level)
            if !(0..<lotSize.width).contains(x) || !(0..<lotSize.height).contains(y)
                || !(1...Architecture.stories).contains(level) {
                breaks(.onLot, "at tile \(x),\(y) on level \(level)")
            } else if objects(at: position)?.contains(where: { $0 === entity }) != true {
                breaks(.tileIndex, "not listed on tile \(x),\(y) on level \(level)")
            }
        }

        if let container = entity.container {
            let index = container.isAvatar ? 0 : Int(entity.containerSlot)
            if !container.contained.indices.contains(index) || container.contained[index] !== entity {
                breaks(.slots, "names slot \(entity.containerSlot) of object \(container.objectID), which doesn't hold it")
            }
            if self.entity(id: container.objectID) !== container {
                breaks(.slots, "its container, object \(container.objectID), is no longer on the lot")
            }
            if entity.position != container.position {
                breaks(.withContainer, "at \(entity.position), its container at \(container.position)")
            }
        }
        for (index, held) in entity.contained.enumerated() {
            guard let held else { continue }
            if held.container !== entity {
                breaks(.slots, "slot \(index) holds object \(held.objectID), which names another container")
            }
        }

        if !entity.group.objects.contains(where: { $0 === entity }) {
            breaks(.group, "its group doesn't list it")
        } else if entity.group.leadObject == nil {
            breaks(.group, "its group has no lead")
        }
    }
}
