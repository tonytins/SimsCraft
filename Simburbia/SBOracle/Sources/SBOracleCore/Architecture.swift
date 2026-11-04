import Foundation
import TSOContent
import TSOFiles

extension Answers {
    /// `architecture`: which sprite chunks TSOContent's ``FloorProvider`` and ``WallProvider``
    /// find for each ID, as `fso-oracle architecture` prints FreeSO's (see its
    /// `ArchitectureDump.cs` for the lines). A sprite is `-` when there's none, else its chunk ID
    /// and frame count; an ID that fails prints `error` and the error's case. If the providers
    /// can't be made at all, the one line is `error` and why.
    public static func architecture(in gameDirectory: URL) -> [String] {
        let floors: FloorProvider, walls: WallProvider
        do {
            let files = try GameFileIndex(root: gameDirectory)
            floors = try FloorProvider(files: files)
            walls = try WallProvider(files: files)
        } catch {
            return ["error\t\(error)"]
        }
        var lines: [String] = []
        func line(_ key: String, _ record: () throws -> String) {
            do {
                lines.append("\(key)\t\(try record())")
            } catch {
                lines.append("\(key)\terror\t\(String(describing: error).prefix { $0 != "(" })")
            }
        }
        for entry in floors.entries {
            line("floor\t\(entry.id)") {
                guard let floor = try floors.floor(id: entry.id) else { return "\(entry.fileName)\t-\t-\t-" }
                return [entry.fileName, sprite(floor.far), sprite(floor.medium), sprite(floor.near)].joined(separator: "\t")
            }
        }
        // Only the sprites there are, as FreeSO lists them.
        for id in Array(UInt16(0x400)..<0x440) + Array(UInt16(0x800)..<0x810) {
            do {
                if let found = try floors.globalSprite(id: id) { lines.append("floor-sprite\t\(id)\t\(sprite(found))") }
            } catch {
                lines.append("floor-sprite\t\(id)\terror\t\(String(describing: error).prefix { $0 != "(" })")
            }
        }
        for id in Array(UInt16(0)...255) + walls.entries.map(\.id).filter({ $0 >= 256 }) {
            line("wall\t\(id)") {
                let file = id < 256 ? "global" : walls.entry(id: id)?.fileName ?? "-"
                guard let pattern = try walls.pattern(id: id) else { return "\(file)\t-\t-\t-" }
                return [file, sprite(pattern.far), sprite(pattern.medium), sprite(pattern.near)].joined(separator: "\t")
            }
        }
        for id in UInt16(1)...255 {
            line("style\t\(id)") {
                guard let style = try walls.style(id: id) else { return Array(repeating: "-", count: 6).joined(separator: "\t") }
                return [style.wallsUp.far, style.wallsUp.medium, style.wallsUp.near,
                        style.wallsDown.far, style.wallsDown.medium, style.wallsDown.near].map(sprite).joined(separator: "\t")
            }
        }
        line("junctions\t-") {
            let junctions = try walls.junctions()
            return [sprite(junctions.far), sprite(junctions.medium), sprite(junctions.near)].joined(separator: "\t")
        }
        return lines
    }

    private static func sprite(_ sprite: SPR2?) -> String {
        sprite.map { "\($0.id):\($0.frames.count)" } ?? "-"
    }

    private static func sprite(_ sprite: SPR?) -> String {
        sprite.map { "\($0.id):\($0.frames.count)" } ?? "-"
    }
}
