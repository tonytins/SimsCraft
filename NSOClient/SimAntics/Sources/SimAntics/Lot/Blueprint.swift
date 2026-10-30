import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// A lot saved as XML: a blueprint.
///
/// Reads both dialects (see `docs/nso/blueprints.md`). TSO's own, which `blueprint.dtd` in
/// 1.1097.1.0's `housedata/blueprints` defines, has a revision, object names and `hidden`, a flag
/// layer per level, puddles, and sounds. FreeSO's (`XmlHouseData`, which its `Content/Blueprints`
/// and saved lots use) has only the size, category, floors, pools, walls, sounds, and objects.
/// Everything either has is read, so that writing a blueprint keeps it; anything else, such as a
/// later NewSO's section, is kept as it came (``unknownElements`` and each part's
/// ``Attribute`` list).
public struct Blueprint: Sendable, Equatable {
    /// The newest NewSO blueprint version this reads: the major number of `<newso version>`.
    public static let newestVersion = 1

    /// An attribute this reader doesn't know, kept to be written back.
    public struct Attribute: Sendable, Equatable {
        public var name: String
        public var value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    /// An element this reader doesn't know, kept as XML to be written back where it was.
    public struct UnknownElement: Sendable, Equatable {
        /// Where it was, such as `house` or `house/world`.
        public var parent: String
        /// The element, as XML.
        public var xml: String
    }

    /// Who last changed the blueprint (TSO's `revision`, from Maxis' version control).
    public struct Revision: Sendable, Equatable {
        public var author: String
        public var date: String
        public var change: String
        public var otherAttributes: [Attribute] = []
    }

    /// A level's tile flags (TSO's `flags/layer`): one number a tile, row by row. What they mean
    /// isn't known yet; they're kept so a saved lot keeps them.
    public struct FlagLayer: Sendable, Equatable {
        /// 0 is the ground floor.
        public var level: Int
        public var values: [Int]
        public var otherAttributes: [Attribute] = []
    }

    public struct Floor: Sendable, Equatable {
        /// 0 is the ground floor.
        public var level: Int
        public var x: Int
        public var y: Int
        public var pattern: Int
        public var otherAttributes: [Attribute] = []
    }

    public struct Pool: Sendable, Equatable {
        public var x: Int
        public var y: Int
        /// The `value` attribute; FreeSO reads it and doesn't use it.
        public var value: Int = 0
        public var otherAttributes: [Attribute] = []
    }

    /// A puddle (TSO's `water/puddle`); FreeSO doesn't read them. What `value` means isn't known yet.
    public struct Puddle: Sendable, Equatable {
        public var x: Int
        public var y: Int
        public var value: Int
        public var otherAttributes: [Attribute] = []
    }

    public struct Wall: Sendable, Equatable {
        /// 0 is the ground floor.
        public var level: Int
        public var x: Int
        public var y: Int
        public var tile: WallTile
        /// The `placement` attribute, which FreeSO reads and doesn't use.
        public var placement: Int = 0
        public var otherAttributes: [Attribute] = []
    }

    /// An ambient sound the lot plays (`sound`).
    public struct Sound: Sendable, Equatable {
        public var id: UInt32
        public var isOn: Bool
        public var otherAttributes: [Attribute] = []
    }

    /// An object to create on the lot (`XmlHouseDataObject`).
    public struct Object: Sendable, Equatable {
        public var guid: UInt32
        /// 0 leaves the object out of the world; 1 is the ground floor.
        public var level: Int
        /// The tile.
        public var x: Int
        public var y: Int
        public var direction: Direction
        /// The `dir` attribute as written, which ``direction`` reads; kept so a saved lot keeps
        /// values FreeSO reads as west.
        public var dir: Int
        /// A value for every part's object data `groupID`, or 0 to leave it.
        public var group: Int
        /// The object's name, which TSO's dialect gives for people to read.
        public var name: String?
        /// Whether TSO's dialect marks the object as not meant to be seen (`hidden="1"`).
        public var isHidden: Bool
        /// FreeSO's `id` attribute, if the blueprint has one.
        public var id: Int?
        public var otherAttributes: [Attribute]

        public init(guid: UInt32, level: Int = 0, x: Int = 0, y: Int = 0, direction: Direction = .north, dir: Int? = nil,
                    group: Int = 0, name: String? = nil, isHidden: Bool = false, id: Int? = nil,
                    otherAttributes: [Attribute] = []) {
            self.guid = guid
            self.level = level
            self.x = x
            self.y = y
            self.direction = direction
            self.dir = dir ?? Self.dir(for: direction)
            self.group = group
            self.name = name
            self.isHidden = isHidden
            self.id = id
            self.otherAttributes = otherAttributes
        }

        /// The facing for a `dir` attribute, as `XmlHouseDataObject.Direction` reads it: 0, 2,
        /// 4, and 6 are north, east, south, and west, and anything else is west.
        public static func direction(dir: Int) -> Direction {
            switch dir {
            case 0: .north
            case 2: .east
            case 4: .south
            default: .west
            }
        }

        /// The `dir` attribute for a facing: 0, 2, 4, or 6, and 6 for any diagonal.
        public static func dir(for direction: Direction) -> Int {
            switch direction {
            case .north: 0
            case .east: 2
            case .south: 4
            default: 6
            }
        }
    }

    /// Maxis' format version (`house version`), "1.0" in TSO's blueprints; FreeSO's have none.
    public var formatVersion: String?
    public var revision: Revision?
    /// NewSO's blueprint version (`<newso version>`), or `nil` for a blueprint NewSO didn't write.
    public var newsoVersion: Int?
    /// The width and height in tiles.
    public var size: Int
    public var category: Int
    public var flags: [FlagLayer]
    public var floors: [Floor]
    public var pools: [Pool]
    public var puddles: [Puddle]
    public var walls: [Wall]
    public var sounds: [Sound]
    /// The lot's objects, in the order they're created.
    public var objects: [Object]
    /// Elements this reader doesn't know, in the order they came, kept to be written back.
    public var unknownElements: [UnknownElement]
    /// Attributes of `house`, `world`, and the other sections that this reader doesn't know,
    /// each named by its element's path, such as `house@flavor`.
    public var otherAttributes: [Attribute]
    /// Whether reading had to drop a `<` followed by whitespace, the one repair it makes.
    public private(set) var wasRepaired: Bool

    /// Reads blueprint XML in either dialect.
    ///
    /// Missing attributes read as 0, as .NET's `XmlSerializer` reads them. A `DOCTYPE` is
    /// ignored, never fetched.
    ///
    /// One TSO quirk is tolerated: a `<` followed by whitespace, which is never valid XML, is
    /// dropped when the file doesn't parse otherwise. 1.1097.1.0's `nightclub00_01.xml` has one
    /// before its level 1 flag layer. TSO's launcher patched the game first, so players likely
    /// never had that copy, but it's what the install holds. FreeSO's reader fails on it.
    ///
    /// - Throws: ``BlueprintError/malformed(_:)`` if the XML doesn't parse even so, has no size,
    ///   or has a value that isn't a number; ``BlueprintError/newerVersion(_:newest:)`` if NewSO
    ///   wrote it in a newer major version than this reads.
    public init(xml: Data) throws(BlueprintError) {
        // XMLDocument recovers from broken XML on Linux, so XMLParser, which doesn't, checks it first.
        var source = xml
        var repaired = false
        if let problem = Self.wellFormednessError(xml) {
            guard let fixed = Self.droppingStrayAngleBrackets(xml), Self.wellFormednessError(fixed) == nil else {
                throw .malformed("XML doesn't parse: \(problem)")
            }
            source = fixed
            repaired = true
        }
        let document: XMLDocument
        do {
            document = try XMLDocument(data: source)
        } catch {
            throw .malformed("XML doesn't parse: \(error)")
        }
        wasRepaired = repaired
        guard let house = document.rootElement(), house.name == "house" else { throw .malformed("no house element") }

        func number(_ text: String?, _ what: String) throws(BlueprintError) -> Int {
            guard let text else { return 0 }
            guard let value = Int32(text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                throw .malformed("\(what) \"\(text)\" isn't a 32-bit number")
            }
            return Int(value)
        }
        func value(_ element: XMLElement, _ name: String) throws(BlueprintError) -> Int {
            try number(element.attribute(forName: name)?.stringValue, "\(element.name ?? "element") \(name)")
        }
        func others(_ element: XMLElement, known: Set<String>) -> [Attribute] {
            (element.attributes ?? []).compactMap { node in
                guard let name = node.name, !known.contains(name), !name.hasPrefix("xmlns") else { return nil }
                return Attribute(name: name, value: node.stringValue ?? "")
            }
        }
        var unknown: [UnknownElement] = []
        var otherAttributes: [Attribute] = []
        /// The child elements of a section, with any it doesn't expect kept as unknown, and its
        /// own attributes it doesn't expect kept too, named by path (`house/world@flavor`).
        func children(_ element: XMLElement, path: String, known: Set<String>,
                      knownAttributes: Set<String> = []) -> [XMLElement] {
            otherAttributes += others(element, known: knownAttributes).map { Attribute(name: "\(path)@\($0.name)", value: $0.value) }
            return (element.children ?? []).compactMap { node in
                guard let child = node as? XMLElement else { return nil }
                guard let name = child.name, known.contains(name) else {
                    unknown.append(UnknownElement(parent: path, xml: child.xmlString))
                    return nil
                }
                return child
            }
        }

        formatVersion = house.attribute(forName: "version")?.stringValue
        var revision: Revision?, newsoVersion: Int?, size: Int?, category = 0
        var flags: [FlagLayer] = [], floors: [Floor] = [], pools: [Pool] = [], puddles: [Puddle] = []
        var walls: [Wall] = [], sounds: [Sound] = [], objects: [Object] = []
        let top = children(house, path: "house", known: ["revision", "newso", "size", "category", "world", "sounds", "objects"],
                           knownAttributes: ["version"])
        for section in top {
            switch section.name {
            case "revision":
                revision = Revision(author: section.attribute(forName: "author")?.stringValue ?? "",
                                    date: section.attribute(forName: "date")?.stringValue ?? "",
                                    change: section.attribute(forName: "change")?.stringValue ?? "",
                                    otherAttributes: others(section, known: ["author", "date", "change"]))
            case "newso":
                let version = try value(section, "version")
                guard version <= Self.newestVersion else { throw .newerVersion(version, newest: Self.newestVersion) }
                newsoVersion = version
                // NewSO's sections live inside it; none are defined yet, so all are kept.
                _ = children(section, path: "house/newso", known: [], knownAttributes: ["version"])
            case "size":
                size = try number(section.stringValue, "size")
            case "category":
                category = try number(section.stringValue, "category")
            case "world":
                for part in children(section, path: "house/world", known: ["flags", "floors", "walls", "pools", "water"]) {
                    switch part.name {
                    case "flags":
                        for layer in children(part, path: "house/world/flags", known: ["layer"]) {
                            let values = try (layer.stringValue ?? "").split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                                .map { (text) throws(BlueprintError) -> Int in try number(text, "flag") }
                            flags.append(FlagLayer(level: try value(layer, "level"), values: values,
                                                   otherAttributes: others(layer, known: ["level"])))
                        }
                    case "floors":
                        for floor in children(part, path: "house/world/floors", known: ["floor"]) {
                            floors.append(Floor(level: try value(floor, "level"), x: try value(floor, "x"), y: try value(floor, "y"),
                                                pattern: try value(floor, "value"),
                                                otherAttributes: others(floor, known: ["level", "x", "y", "value"])))
                        }
                    case "pools":
                        for pool in children(part, path: "house/world/pools", known: ["pool"]) {
                            pools.append(Pool(x: try value(pool, "x"), y: try value(pool, "y"), value: try value(pool, "value"),
                                              otherAttributes: others(pool, known: ["x", "y", "value"])))
                        }
                    case "water":
                        for puddle in children(part, path: "house/world/water", known: ["puddle"]) {
                            puddles.append(Puddle(x: try value(puddle, "x"), y: try value(puddle, "y"), value: try value(puddle, "value"),
                                                  otherAttributes: others(puddle, known: ["x", "y", "value"])))
                        }
                    default:
                        for wall in children(part, path: "house/world/walls", known: ["wall"]) {
                            let tile = WallTile(
                                segments: WallSegments(rawValue: Int32(try value(wall, "segments"))),
                                topLeftPattern: UInt16(truncatingIfNeeded: try value(wall, "tlp")),
                                topRightPattern: UInt16(truncatingIfNeeded: try value(wall, "trp")),
                                bottomLeftPattern: UInt16(truncatingIfNeeded: try value(wall, "blp")),
                                bottomRightPattern: UInt16(truncatingIfNeeded: try value(wall, "brp")),
                                topLeftStyle: UInt16(truncatingIfNeeded: try value(wall, "tls")),
                                topRightStyle: UInt16(truncatingIfNeeded: try value(wall, "trs")))
                            walls.append(Wall(level: try value(wall, "level"), x: try value(wall, "x"), y: try value(wall, "y"),
                                              tile: tile, placement: try value(wall, "placement"),
                                              otherAttributes: others(wall, known: ["level", "x", "y", "segments", "placement",
                                                                                    "tls", "trs", "tlp", "trp", "blp", "brp"])))
                        }
                    }
                }
            case "sounds":
                for sound in children(section, path: "house/sounds", known: ["sound"]) {
                    // Unsigned, as FreeSO's `XmlHouseDataSound.ID` is: TSO's go past 2^31.
                    let text = sound.attribute(forName: "id")?.stringValue ?? "0"
                    guard let id = UInt32(text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        throw .malformed("sound id \"\(text)\" isn't an unsigned 32-bit number")
                    }
                    sounds.append(Sound(id: id, isOn: try value(sound, "on") != 0,
                                        otherAttributes: others(sound, known: ["id", "on"])))
                }
            default:
                for object in children(section, path: "house/objects", known: ["object"]) {
                    // `Convert.ToUInt32(text, 16)`: an optional 0x prefix; a missing GUID reads as 0.
                    var text = object.attribute(forName: "guid")?.stringValue ?? "0"
                    if text.lowercased().hasPrefix("0x") { text.removeFirst(2) }
                    guard let guid = UInt32(text, radix: 16) else { throw .malformed("object guid \"\(text)\" isn't a 32-bit hex number") }
                    let dir = try value(object, "dir")
                    objects.append(Object(
                        guid: guid, level: try value(object, "level"), x: try value(object, "x"), y: try value(object, "y"),
                        direction: Object.direction(dir: dir), dir: dir, group: try value(object, "group"),
                        name: object.attribute(forName: "name")?.stringValue, isHidden: try value(object, "hidden") != 0,
                        id: try object.attribute(forName: "id").map { (attribute) throws(BlueprintError) in try number(attribute.stringValue, "object id") },
                        otherAttributes: others(object, known: ["guid", "name", "group", "x", "y", "level", "dir", "hidden", "id"])))
                }
            }
        }
        guard let size else { throw .malformed("no size") }
        self.revision = revision
        self.newsoVersion = newsoVersion
        self.size = size
        self.category = category
        self.flags = flags
        self.floors = floors
        self.pools = pools
        self.puddles = puddles
        self.walls = walls
        self.sounds = sounds
        self.objects = objects
        self.unknownElements = unknown
        self.otherAttributes = otherAttributes
    }

    /// Why the XML isn't well-formed, or `nil` if it is. External entities aren't resolved.
    static func wellFormednessError(_ xml: Data) -> String? {
        let parser = XMLParser(data: xml)
        parser.shouldResolveExternalEntities = false
        if parser.parse() { return nil }
        return parser.parserError.map { "\($0.localizedDescription) at line \(parser.lineNumber)" } ?? "not well-formed"
    }

    /// The XML with each `<` that's followed by whitespace dropped, or `nil` if it has none.
    static func droppingStrayAngleBrackets(_ xml: Data) -> Data? {
        let bytes = [UInt8](xml)
        var kept: [UInt8] = []
        kept.reserveCapacity(bytes.count)
        var dropped = false
        for (index, byte) in bytes.enumerated() {
            if byte == UInt8(ascii: "<"), index + 1 < bytes.count,
               [UInt8(ascii: " "), UInt8(ascii: "\t"), UInt8(ascii: "\r"), UInt8(ascii: "\n")].contains(bytes[index + 1]) {
                dropped = true
                continue
            }
            kept.append(byte)
        }
        return dropped ? Data(kept) : nil
    }

    /// What this reader kept without understanding, in words, for reporting.
    public var unknownParts: [String] {
        unknownElements.map { "element in \($0.parent): \($0.xml.prefix(60))" }
            + otherAttributes.map { "attribute \($0.name)" }
    }

    /// The lot's walls and floors, with rooms generated, as `VMWorldActivator.LoadFromXML`
    /// builds them: floors, then pools (on the ground floor), then walls.
    ///
    /// - Throws: ``BlueprintError/offLot(_:)`` if the size is outside 1...255 or a tile is off
    ///   the lot or above the top level, where FreeSO fails with an index out of range.
    public func architecture() throws(BlueprintError) -> Architecture {
        do {
            var architecture = try Architecture(width: size, height: size)
            for floor in floors {
                try architecture.setFloor(UInt16(truncatingIfNeeded: floor.pattern), atX: floor.x, y: floor.y,
                                          level: floor.level + 1)
            }
            for pool in pools {
                try architecture.setFloor(Architecture.poolPattern, atX: pool.x, y: pool.y, level: 1)
            }
            for wall in walls {
                try architecture.setWall(wall.tile, atX: wall.x, y: wall.y, level: wall.level + 1)
            }
            architecture.regenerateRooms()
            return architecture
        } catch {
            throw .offLot("\(error)")
        }
    }
}

public enum BlueprintError: Error, Equatable, Sendable {
    /// The XML doesn't parse or doesn't describe a lot.
    case malformed(String)
    /// NewSO wrote it in a newer major version (the first value) than this reads (`newest`).
    case newerVersion(Int, newest: Int)
    /// The lot is too big or small, or a tile is outside it.
    case offLot(String)
}
