import Foundation
import TSOContent

extension Blueprint {
    /// The blueprint as XML in TSO's dialect, as `blueprint.dtd` lays it out (see
    /// `docs/nso/blueprints.md`).
    ///
    /// Elements come in the DTD's order, with a comment per level of floors and walls, as Maxis
    /// wrote them, and NewSO's marker (`<newso version>`) after the revision. Objects keep their
    /// order, which is the order they're created in. An attribute at its default (0, or not
    /// hidden) is left out, as Maxis left out an out-of-world object's tile, so reading the
    /// result gives the same blueprint. What reading kept without understanding is written back
    /// in the same parent: unknown attributes on their element, unknown elements after the
    /// section's own.
    ///
    /// Three choices of NewSO's own: UTF-8 rather than ISO-8859-1, so any object name can be
    /// written; line feeds rather than CRLF; and no `DOCTYPE`, which .NET since Core refuses to
    /// read, so FreeSO can still open the file.
    public func xml() -> Data {
        var writer = BlueprintXMLWriter(blueprint: self)
        return Data(writer.document().utf8)
    }

    /// The blueprint with each object that has no name given the one its `OBJD` has, as TSO's
    /// blueprints name every object; objects the content doesn't have stay unnamed.
    public func namingObjects(from content: GameContent) -> Blueprint {
        var named = self
        for index in named.objects.indices where named.objects[index].name == nil {
            named.objects[index].name = content.objects.reference(guid: named.objects[index].guid)?.name
        }
        return named
    }
}

/// Builds the text of ``Blueprint/xml()``.
private struct BlueprintXMLWriter {
    let blueprint: Blueprint
    private var lines: [String] = []

    init(blueprint: Blueprint) {
        self.blueprint = blueprint
    }

    mutating func document() -> String {
        let blueprint = self.blueprint
        lines = [#"<?xml version="1.0" encoding="utf-8"?>"#]
        let rootAttributes = [("version", blueprint.formatVersion ?? "1.0")] + kept("house")
        lines.append("<house\(attributes(rootAttributes))>")
        if let revision = blueprint.revision {
            element(1, "revision", [("author", revision.author), ("date", revision.date), ("change", revision.change)],
                    revision.otherAttributes)
        }
        section(1, "newso", path: "house/newso", attributes: [("version", "\(Blueprint.newestVersion)")]) { _ in }
        lines.append(indent(1) + "<size>\(blueprint.size)</size>")
        lines.append(indent(1) + "<category>\(blueprint.category)</category>")
        world()
        section(1, "sounds", path: "house/sounds") { writer in
            for sound in blueprint.sounds {
                writer.element(2, "sound", [("id", "\(sound.id)")] + (sound.isOn ? [("on", "1")] : []), sound.otherAttributes)
            }
        }
        section(1, "objects", path: "house/objects") { writer in
            for object in blueprint.objects { writer.object(object) }
        }
        unknown(in: "house", depth: 1)
        lines.append("</house>")
        return lines.joined(separator: "\n") + "\n"
    }

    private mutating func world() {
        let blueprint = self.blueprint
        section(1, "world", path: "house/world") { writer in
            writer.section(2, "flags", path: "house/world/flags") { writer in
                for layer in blueprint.flags {
                    writer.lines.append(writer.indent(3) + "<layer\(writer.attributes([("level", "\(layer.level)")] + layer.otherAttributes.map { ($0.name, $0.value) }))>"
                                        + layer.values.map(String.init).joined(separator: ",") + "</layer>")
                }
            }
            writer.section(2, "floors", path: "house/world/floors") { writer in
                var level: Int?
                for floor in blueprint.floors {
                    if floor.level != level {
                        writer.lines.append(writer.indent(3) + "<!-- Level \(floor.level) Floors -->")
                        level = floor.level
                    }
                    writer.element(3, "floor", [("level", "\(floor.level)"), ("x", "\(floor.x)"), ("y", "\(floor.y)"),
                                                ("value", "\(floor.pattern)")], floor.otherAttributes)
                }
            }
            writer.section(2, "walls", path: "house/world/walls") { writer in
                var level: Int?
                for wall in blueprint.walls {
                    if wall.level != level {
                        writer.lines.append(writer.indent(3) + "<!-- Level \(wall.level) Walls -->")
                        level = wall.level
                    }
                    let tile = wall.tile
                    writer.element(3, "wall", [
                        ("level", "\(wall.level)"), ("x", "\(wall.x)"), ("y", "\(wall.y)"), ("segments", "\(tile.segments.rawValue)"),
                        ("placement", "\(wall.placement)"), ("tls", "\(tile.topLeftStyle)"), ("trs", "\(tile.topRightStyle)"),
                        ("tlp", "\(tile.topLeftPattern)"), ("trp", "\(tile.topRightPattern)"), ("blp", "\(tile.bottomLeftPattern)"),
                        ("brp", "\(tile.bottomRightPattern)"),
                    ], wall.otherAttributes)
                }
            }
            writer.section(2, "pools", path: "house/world/pools") { writer in
                for pool in blueprint.pools {
                    writer.element(3, "pool", [("x", "\(pool.x)"), ("y", "\(pool.y)"), ("value", "\(pool.value)")], pool.otherAttributes)
                }
            }
            writer.section(2, "water", path: "house/world/water") { writer in
                for puddle in blueprint.puddles {
                    writer.element(3, "puddle", [("x", "\(puddle.x)"), ("y", "\(puddle.y)"), ("value", "\(puddle.value)")],
                                   puddle.otherAttributes)
                }
            }
        }
    }

    private mutating func object(_ object: Blueprint.Object) {
        var list: [(String, String)] = [("guid", String(format: "0x%08X", object.guid))]
        if let name = object.name { list.append(("name", name)) }
        list.append(("group", "\(object.group)"))
        // An object out of the world has no tile, as Maxis wrote its controllers.
        if object.x != 0 || object.y != 0 || object.level != 0 {
            list += [("x", "\(object.x)"), ("y", "\(object.y)"), ("level", "\(object.level)")]
        }
        if object.dir != 0 { list.append(("dir", "\(object.dir)")) }
        if object.isHidden { list.append(("hidden", "1")) }
        if let id = object.id { list.append(("id", "\(id)")) }
        element(2, "object", list, object.otherAttributes)
    }

    // MARK: Pieces

    /// A section with its contents, or closing itself when it has none.
    private mutating func section(_ depth: Int, _ name: String, path: String, attributes own: [(String, String)] = [],
                                  _ body: (inout BlueprintXMLWriter) -> Void) {
        let opening = indent(depth) + "<\(name)\(attributes(own + kept(path)))"
        lines.append(opening + ">")
        let start = lines.count
        body(&self)
        unknown(in: path, depth: depth + 1)
        if lines.count == start {
            lines[start - 1] = opening + " />"
        } else {
            lines.append(indent(depth) + "</\(name)>")
        }
    }

    private mutating func element(_ depth: Int, _ name: String, _ list: [(String, String)], _ others: [Blueprint.Attribute]) {
        lines.append(indent(depth) + "<\(name)\(attributes(list + others.map { ($0.name, $0.value) })) />")
    }

    /// The unknown elements reading kept in `path`, as they came.
    private mutating func unknown(in path: String, depth: Int) {
        for element in blueprint.unknownElements where element.parent == path {
            lines.append(indent(depth) + element.xml)
        }
    }

    /// The unknown attributes reading kept on the section at `path` (named `path@name`).
    private func kept(_ path: String) -> [(String, String)] {
        let prefix = path + "@"
        return blueprint.otherAttributes.filter { $0.name.hasPrefix(prefix) }.map { (String($0.name.dropFirst(prefix.count)), $0.value) }
    }

    private func attributes(_ list: [(String, String)]) -> String {
        list.map { " \($0.0)=\"\(Self.escaped($0.1))\"" }.joined()
    }

    private func indent(_ depth: Int) -> String {
        String(repeating: "  ", count: depth)
    }

    static func escaped(_ text: String) -> String {
        var result = ""
        for character in text {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "\n": result += "&#10;"
            case "\r": result += "&#13;"
            case "\t": result += "&#9;"
            default: result.append(character)
            }
        }
        return result
    }
}
