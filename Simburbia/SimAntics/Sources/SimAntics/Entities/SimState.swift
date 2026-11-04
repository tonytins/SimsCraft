import TSOFiles

/// What a Sim carries besides its person data and motives (FreeSO's `VMAvatar` and its
/// `VMTSOAvatarState`): its kind, appearance, name, walk and swim animations, permissions on the
/// lot, and online jobs. Simburbia keeps no rendering state; outfits are their IDs.
public struct SimState: Sendable, Equatable {
    /// What a Sim is (`VMAvatarType`), from its body strings' first entry.
    public enum Kind: Sendable, Equatable {
        case adult, child, cat, dog
    }

    /// A Sim's skin tone (Vitaboy's `AppearanceType`).
    public enum SkinTone: UInt8, Sendable, Equatable {
        case light = 0, medium, dark
    }

    /// What a Sim may do on the lot (`VMTSOAvatarPermissions`).
    public enum Permissions: UInt8, Sendable, Equatable, Comparable {
        case visitor = 0, roommate, buildBuyRoommate, owner, admin

        public static func < (lhs: Permissions, rhs: Permissions) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    /// One online job's progress (`VMTSOJobInfo`).
    public struct Job: Sendable, Equatable {
        public var level: Int16 = 0
        public var sickDays: Int16 = 0
        public var statusFlags: Int16 = 0
        public var experience: Int16 = 0

        public init(level: Int16 = 0, sickDays: Int16 = 0, statusFlags: Int16 = 0, experience: Int16 = 0) {
            self.level = level
            self.sickDays = sickDays
            self.statusFlags = statusFlags
            self.experience = experience
        }
    }

    public var kind: Kind = .adult
    public var skinTone: SkinTone = .light
    /// The outfits a Sim changes into (`VMAvatarDefaultSuits`): FreeSO's defaults until the body
    /// strings or a player's state say otherwise.
    public var daywear: UInt64 = 0x24C_0000_000D
    public var swimwear: UInt64 = 0x547_0000_000D
    public var sleepwear: UInt64 = 0x544_0000_000D
    /// The outfits it's wearing (`BodyOutfit`, `HeadOutfit`); 0 is none.
    public var bodyOutfit: UInt64 = 0
    public var headOutfit: UInt64 = 0
    public var name = ""
    /// Walk and swim animation names by index (`WalkAnimations`, `SwimAnimations`): 50 each, `nil`
    /// where nothing names one.
    public var walkAnimations = [String?](repeating: nil, count: SimState.animationSlots)
    public var swimAnimations = [String?](repeating: nil, count: SimState.animationSlots)
    public var permissions: Permissions = .visitor
    /// Online jobs by job ID (`JobInfo`).
    public var jobs: [Int16: Job] = [:]
    /// This Sim's relationships to others by their persist ID (`MeToPersist`), each a list of values.
    public var relationships: [UInt32: [Int16]] = [:]

    /// How many walk and swim animations a Sim has room for.
    public static let animationSlots = 50

    public init() {}
}

/// A player's Sim as it arrives on a lot (FreeSO's `VMNetAvatarPersistState`): what the server
/// keeps of it between lots, applied when it joins (``VM/joinSim(template:identity:)``).
public struct SimIdentity: Sendable, Equatable {
    public var name: String
    public var persistID: UInt32
    public var daywear: UInt64 = 0x24C_0000_000D
    public var swimwear: UInt64 = 0x547_0000_000D
    public var sleepwear: UInt64 = 0x544_0000_000D
    public var permissions: SimState.Permissions = .visitor
    public var bodyOutfit: UInt64
    public var headOutfit: UInt64 = 0
    public var skinTone: UInt8 = 0
    public var isWorker = false
    /// All 16 motives.
    public var motives = [Int16](repeating: 0, count: 16)
    /// The person data that persists, in `VMNetAvatarPersistState`'s order (27 values; see
    /// ``SimIdentity/personDataMap``).
    public var personData = [Int16](repeating: 0, count: 27)
    public var relationships: [UInt32: [Int16]] = [:]
    public var jobs: [Int16: SimState.Job] = [:]

    /// Which person data index each of ``personData``'s first entries goes to
    /// (`VMNetAvatarPersistState.PersonDataMap`). It has 23 entries for 27 values, so the last
    /// entry, Badge Level (100), takes value 22, not 26, as in FreeSO.
    public static let personDataMap: [Int] = [10, 11, 12, 15, 17, 18, 65, 68, 99, 61,
                                              70, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 100]

    /// The skill-lock value (`SkillLock`, the persisted value 10).
    public var skillLock: Int16 { personData[10] }

    public init(name: String, persistID: UInt32, bodyOutfit: UInt64) {
        self.name = name
        self.persistID = persistID
        self.bodyOutfit = bodyOutfit
    }
}
