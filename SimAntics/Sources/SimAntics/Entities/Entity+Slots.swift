extension Entity {
    /// The number of container slots (`TotalSlots`): the definition's slots of type 0, once
    /// initialized. A Sim has one, its hand (`VMAvatar.TotalSlots`).
    public var totalSlots: Int { contained.count }

    /// The object in a container slot, or `nil` for an empty or unknown slot (`GetSlot`). A Sim's
    /// hand answers for every index (`VMAvatar.GetSlot`).
    public func slot(_ index: Int) -> Entity? {
        if isAvatar { return contained.first ?? nil }
        return contained.indices.contains(index) ? contained[index] : nil
    }

    /// The height of the first container slot, whatever the index, or -1 past the last
    /// (`GetSlotHeight`). A Sim's hand is at height 5, whatever the index (`VMAvatar.GetSlotHeight`).
    func slotHeight(_ index: Int) -> Int {
        if isAvatar { return 5 }
        return index < totalSlots ? Int(containerSlots[0].height) : -1
    }

    /// Whether putting `object` in one of this entity's slots would contain it in itself (`WillLoopSlot`).
    func willLoopSlot(_ object: Entity) -> Bool {
        if object === self { return true }
        return container?.willLoopSlot(object) ?? false
    }

    /// Puts an object in a container slot (`PlaceInSlot`), and returns whether it's there.
    ///
    /// It's true at once if the object is already in that slot, and false if the slot holds
    /// something else, doesn't exist, or would hold its own container. With `cleanOld`, the object
    /// first leaves its place and afterwards takes its new one (room, tile, placement entry point);
    /// either way it moves to this entity's position.
    ///
    /// A Sim holds it in its hand whatever the index, which the object keeps as its slot number,
    /// and doesn't check for loops (`VMAvatar.PlaceInSlot`). FreeSO also starts the carry animation
    /// (`a2o-rarm-carry-loop`), which comes with animation.
    ///
    /// - Throws: any error the object's placement or dynamic multi-tile entry point throws.
    @discardableResult
    public func placeInSlot(_ object: Entity, slot index: Int, cleanOld: Bool) throws(SimAnticsError) -> Bool {
        if slot(index) === object { return true }
        if isAvatar {
            if slot(index) != nil { return false }
            if cleanOld { vm.leavePosition(object) }
            guard !contained.isEmpty else { return false }
            contained[0] = object
            object.container = self
            object.containerSlot = Int16(truncatingIfNeeded: index)
            object.position = position
            if cleanOld { try vm.takePosition(object, runsPlacementEntryPoint: true) }
            return true
        }
        if slot(index) != nil || willLoopSlot(object) { return false }
        if cleanOld { vm.leavePosition(object) }
        guard contained.indices.contains(index) else { return false }
        contained[index] = object
        object.container = self
        object.containerSlot = Int16(index)
        object.position = position
        if cleanOld { try vm.takePosition(object, runsPlacementEntryPoint: true) }
        return true
    }

    /// Empties a container slot (`ClearSlot`). A Sim empties its hand whatever the index
    /// (`VMAvatar.ClearSlot`); FreeSO fails clearing an empty hand, which does nothing here.
    func clearSlot(_ index: Int) {
        let index = isAvatar ? 0 : index
        guard contained.indices.contains(index), let object = contained[index] else { return }
        object.container = nil
        object.containerSlot = -1
        contained[index] = nil
    }
}
