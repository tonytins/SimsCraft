import Foundation
import TSOFiles

extension Answers {
    /// `sprites`: every object sprite in the install as `fso-oracle sprites` prints it.
    ///
    /// The same archives (each `objspf*.far` under the install, as FAR 1b), entries in name
    /// order, and for each IFF a line per `SPR2` and `SPR#` frame and per `DGRP`, with FNV-1a
    /// 64 hashes of the decoded pixels. A frame or file that fails prints `error` and the
    /// error's case.
    ///
    /// - Parameter every: decode only every this many IFFs across the archives, from the first,
    ///   for a quicker sample (the tests use it; the review decodes them all).
    public static func sprites(in gameDirectory: URL, every: Int = 1) -> [String] {
        var lines: [String] = []
        var counter = 0
        let root = gameDirectory.standardizedFileURL.path
        let files = FileManager.default.enumerator(atPath: root)?.compactMap { $0 as? String } ?? []
        let archives = files.filter { path in
            let name = (path as NSString).lastPathComponent.lowercased()
            return name.hasPrefix("objspf") && name.hasSuffix(".far")
        }.sorted { $0.lowercased() < $1.lowercased() }

        for archivePath in archives {
            guard let archive = try? FAR1Archive(contentsOf: URL(fileURLWithPath: root).appendingPathComponent(archivePath), variant: .b) else {
                lines.append("\(archivePath.lowercased())\tFAR\t-\t-\terror\tunreadable")
                continue
            }
            for entry in archive.entries.sorted(by: { $0.fileName.lowercased() < $1.fileName.lowercased() }) {
                let name = "\(archivePath.lowercased())/\(entry.fileName.lowercased())"
                counter += 1
                guard (counter - 1) % max(every, 1) == 0 else { continue }
                let iff: IFFFile
                do {
                    iff = try IFFFile(bytes: try archive.data(for: entry))
                } catch {
                    lines.append("\(name)\tIFF\t-\t-\terror\t\(errorCase(error))")
                    continue
                }
                lines += spriteLines(iff, name)
                lines += olderSpriteLines(iff, name)
                lines += drawGroupLines(iff, name)
            }
        }
        return lines
    }

    private static func spriteLines(_ iff: IFFFile, _ name: String) -> [String] {
        var lines: [String] = []
        for record in iff.chunks(ofType: SPR2.typeCode).sorted(by: { $0.id < $1.id }) {
            guard let sprite = try? SPR2(record: record) else {
                lines.append("\(name)\tSPR2\t\(record.id)\t0\terror\tunreadable")
                continue
            }
            for (index, frame) in sprite.frames.enumerated() {
                let key = "\(name)\tSPR2\t\(sprite.id)\t\(index)"
                do {
                    let palette = (try? iff.chunk(PALT.self, id: frame.paletteID)) ?? nil
                    let image = try sprite.decode(frameAt: index, palette: palette)
                    lines.append([key, "\(image.width)", "\(image.height)", "\(image.position.x)", "\(image.position.y)",
                                  "\(frame.paletteID)", "\(frame.flags.rawValue)",
                                  image.rgba.map(hash) ?? "-", image.depth.map(hash) ?? "-"].joined(separator: "\t"))
                } catch {
                    lines.append("\(key)\terror\t\(errorCase(error))")
                }
            }
        }
        return lines
    }

    private static func olderSpriteLines(_ iff: IFFFile, _ name: String) -> [String] {
        var lines: [String] = []
        for record in iff.chunks(ofType: SPR.typeCode).sorted(by: { $0.id < $1.id }) {
            guard let sprite = try? SPR(record: record) else {
                lines.append("\(name)\tSPR#\t\(record.id)\t0\terror\tunreadable")
                continue
            }
            let palette = (try? iff.chunk(PALT.self, id: sprite.paletteID)) ?? nil
            for index in sprite.frames.indices {
                let key = "\(name)\tSPR#\t\(sprite.id)\t\(index)"
                do {
                    let image = try sprite.decode(frameAt: index, palette: palette)
                    lines.append([key, "\(image.width)", "\(image.height)", "\(sprite.paletteID)",
                                  image.rgba.map(hash) ?? "-"].joined(separator: "\t"))
                } catch {
                    lines.append("\(key)\terror\t\(errorCase(error))")
                }
            }
        }
        return lines
    }

    private static func drawGroupLines(_ iff: IFFFile, _ name: String) -> [String] {
        iff.chunks(ofType: DGRP.typeCode).sorted(by: { $0.id < $1.id }).map { record in
            let key = "\(name)\tDGRP\t\(record.id)\t-"
            do {
                let group = try DGRP(record: record)
                return [key, "\(group.images.count)", hash(Array(listing(group).utf8))].joined(separator: "\t")
            } catch {
                return "\(key)\terror\t\(errorCase(error))"
            }
        }
    }

    /// A drawing group's images as text, as `fso-oracle`'s `DrawGroupListing` writes them.
    static func listing(_ group: DGRP) -> String {
        func bits(_ value: Float) -> String {
            let text = String(value.bitPattern, radix: 16)
            return String(repeating: "0", count: 8 - text.count) + text
        }
        return group.images.map { image in
            "\(image.direction),\(image.zoom):" + image.sprites.map { sprite in
                ["\(sprite.spriteID)", "\(sprite.frameIndex)", "\(sprite.flags.rawValue)",
                 "\(sprite.spriteOffset.x)", "\(sprite.spriteOffset.y)",
                 bits(sprite.objectOffset.x), bits(sprite.objectOffset.y), bits(sprite.objectOffset.z)].joined(separator: ",")
            }.joined(separator: ";")
        }.joined(separator: "|")
    }

    /// FNV-1a, 64 bits, as 16 hex digits.
    static func hash(_ bytes: [UInt8]) -> String {
        var value: UInt64 = 14_695_981_039_346_656_037
        for byte in bytes {
            value ^= UInt64(byte)
            value = value &* 1_099_511_628_211
        }
        let text = String(value, radix: 16)
        return String(repeating: "0", count: 16 - text.count) + text
    }

    private static func errorCase(_ error: Error) -> String {
        String(describing: error).prefix { $0 != "(" }.description
    }
}
