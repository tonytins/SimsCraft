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
                guard let floor = try floors.floor(id: entry.id) else { return "\(entry.fileName)\t-\t-\t-\t-" }
                return [entry.fileName, sprite(floor.far), sprite(floor.medium), sprite(floor.near),
                        pixels([floor.far, floor.medium, floor.near], in: floor.file)].joined(separator: "\t")
            }
        }
        // Only the sprites there are, as FreeSO lists them.
        for id in Array(UInt16(0x400)..<0x440) + Array(UInt16(0x800)..<0x810) {
            do {
                if let found = try floors.globalSprite(id: id) {
                    let alpha = FloorProvider.globalSpriteTakesDepthAsAlpha(id)
                    lines.append("floor-sprite\t\(id)\t\(sprite(found))\t\(pixels([found], in: floors.globals, depthAsAlpha: alpha))")
                }
            } catch {
                lines.append("floor-sprite\t\(id)\terror\t\(String(describing: error).prefix { $0 != "(" })")
            }
        }
        for id in Array(UInt16(0)...255) + walls.entries.map(\.id).filter({ $0 >= 256 }) {
            line("wall\t\(id)") {
                let file = id < 256 ? "global" : walls.entry(id: id)?.fileName ?? "-"
                guard let pattern = try walls.pattern(id: id) else { return "\(file)\t-\t-\t-\t-" }
                return [file, sprite(pattern.far), sprite(pattern.medium), sprite(pattern.near),
                        pixels([pattern.far, pattern.medium, pattern.near], in: pattern.file)].joined(separator: "\t")
            }
        }
        for id in UInt16(1)...255 {
            line("style\t\(id)") {
                guard let style = try walls.style(id: id) else { return Array(repeating: "-", count: 7).joined(separator: "\t") }
                let masks = [style.wallsUp.far, style.wallsUp.medium, style.wallsUp.near,
                             style.wallsDown.far, style.wallsDown.medium, style.wallsDown.near]
                return (masks.map(sprite) + [pixels(masks, in: walls.globals)]).joined(separator: "\t")
            }
        }
        line("junctions\t-") {
            let junctions = try walls.junctions()
            return [sprite(junctions.far), sprite(junctions.medium), sprite(junctions.near),
                    pixels([junctions.far, junctions.medium, junctions.near], in: walls.globals)].joined(separator: "\t")
        }
        return lines
    }

    /// Each frame of the sprites as the client draws it (``FloorProvider/texture(of:frameAt:in:depthAsAlpha:)``):
    /// its size and the hash of its RGBA, comma-separated, or `-` with no frames.
    private static func pixels(_ sprites: [SPR2?], in file: IFFFile, depthAsAlpha: Bool = false) -> String {
        let frames = sprites.compactMap { $0 }.flatMap { sprite in
            sprite.frames.indices.map { index in
                do {
                    let image = try FloorProvider.texture(of: sprite, frameAt: index, in: file, depthAsAlpha: depthAsAlpha)
                    return "\(image.width)x\(image.height):" + (image.rgba.map(hash) ?? "-")
                } catch {
                    return "error:\(String(describing: error).prefix { $0 != "(" })"
                }
            }
        }
        return frames.isEmpty ? "-" : frames.joined(separator: ",")
    }

    /// Each frame of wall sprites as the client draws them: decoded with their palette from
    /// `file` (none is opaque black, FreeSO's default), as `pixels` for floors writes them.
    private static func pixels(_ sprites: [SPR?], in file: IFFFile) -> String {
        let frames = sprites.compactMap { $0 }.flatMap { sprite in
            sprite.frames.indices.map { index in
                do {
                    let image = try sprite.decode(frameAt: index, palette: try file.chunk(PALT.self, id: sprite.paletteID))
                    return "\(image.width)x\(image.height):" + (image.rgba.map(hash) ?? "-")
                } catch {
                    return "error:\(String(describing: error).prefix { $0 != "(" })"
                }
            }
        }
        return frames.isEmpty ? "-" : frames.joined(separator: ",")
    }

    private static func sprite(_ sprite: SPR2?) -> String {
        sprite.map { "\($0.id):\($0.frames.count)" } ?? "-"
    }

    private static func sprite(_ sprite: SPR?) -> String {
        sprite.map { "\($0.id):\($0.frames.count)" } ?? "-"
    }
}
