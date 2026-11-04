extension VM {
    /// The person template every player's Sim is made from (`VMAvatar.TEMPLATE_PERSON`).
    public static let templatePerson: UInt32 = 0x7FD9_6B54

    /// The mailbox GUIDs a joining Sim is placed by (`VMNetSimJoinCmd`): the mailbox's part that
    /// stands on the lot (which TSO's mailbox objects create), and the job lots' vacation mailbox.
    public static let mailboxGUIDs: Set<UInt32> = [0xEF12_1974, 0x1D95_C9B0]

    /// The tile a joining Sim is put on when the lot has no mailbox (`VMNetSimJoinCmd`'s fallback):
    /// 3,3 on the ground floor, facing north.
    public static let arrivalFallback = LotPosition.center(ofTileX: 3, y: 3, level: 1)

    /// A Sim arrives on the lot as a player joins one (`VMNetSimJoinCmd` outside TS1 mode): the
    /// template is created out of the world, then placed by the first mailbox part in object ID
    /// order (``findLocation(for:near:flags:)``), or without one on ``arrivalFallback``.
    ///
    /// Kept from FreeSO: if the fallback tile is taken, nothing else is tried, and the Sim stays
    /// out of the world. FreeSO then applies the player's saved state (name, outfits, motives,
    /// permissions); that's part of the Sim setup Simburbia doesn't run yet, which ``createObject(guid:at:facing:mainStackObjectID:mainParameter:)``
    /// reports as unsupported.
    ///
    /// - Returns: the Sim, or `nil` if the content has no such object.
    /// - Throws: Any error an entry point throws.
    @discardableResult
    public func joinSim(template: UInt32 = VM.templatePerson) throws(SimAnticsError) -> Entity? {
        guard let group = try createObject(guid: template), let sim = group.objects.first else { return nil }
        if let mailbox = entities.first(where: { Self.mailboxGUIDs.contains($0.object.guid) }) {
            _ = try findLocation(for: sim, near: mailbox, flags: [])
        } else {
            try place(group, at: Self.arrivalFallback, facing: .north)
        }
        return sim
    }
}
