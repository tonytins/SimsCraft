import Foundation
import TSOFiles

/// The Markdown `tsofiles-check` writes, once, when it checks two or more installs: how they
/// differ, one step at a time from the oldest to the newest.
///
/// Files holding objects (IFFs, and archives of them) get one row per IFF listing the chunks
/// that differ; other archives get counts.
enum DifferencesReport {
    /// One comparison: an install against the next newer one, each named for the page, such as
    /// "`TSO_BETA_DIR` (1.3.2.121)".
    struct Step {
        var older: String
        var newer: String
        var differences: InstallDifferences
    }

    static func markdown(_ steps: [Step], date: Date) -> String {
        let day = ISO8601DateFormatter.string(from: date, timeZone: .gmt, formatOptions: [.withFullDate])
        var lines = [
            "# Install differences",
            "",
            "How the installed copies of *The Sims Online* differ, file by file, from the oldest to the newest.",
            "Each section compares one copy with the next newer one, so it shows what the patches between them",
            "changed. The copies are named by the environment variables that pointed `tsofiles-check` at them:",
            "`TSO_BETA_DIR` is a beta, `TSO_CLASSIC_DIR` an older production copy, and `TSO_GAME_DIR` the copy",
            "closest to the one FreeSO was built against. `tsofiles-check` wrote this on \(day). It names files,",
            "archive entries, IFF chunks (the resources inside the game's object files), and object IDs (GUIDs);",
            "it holds none of the game's own data.",
            "",
            "When NSOClient, or FreeSO (which NSOClient is checked against), behaves differently on two copies,",
            "this shows what changed in the game's files, before anyone looks for a bug in the code. It's",
            "written once: delete it and run `tsofiles-check` with the variables set to write it again. What the",
            "differences mean for NewSO is noted by hand beside it, in `install-notes.md`.",
            "",
            "## Summary",
            "",
            "| Step | Identical | Only in the older | Only in the newer | Different |",
            "| --- | ---: | ---: | ---: | ---: |",
        ]
        for step in steps {
            let d = step.differences
            lines.append("| \(step.older) to \(step.newer) | \(d.identicalFileCount) | \(d.onlyInFirst.count) | "
                         + "\(d.onlyInSecond.count) | \(d.changedFiles.count) |")
        }
        for step in steps {
            lines += ["", "## \(step.older) to \(step.newer)"]
            lines += section(step.differences, first: step.older, second: step.newer)
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// One step's lists and tables, under its heading.
    private static func section(_ differences: InstallDifferences, first: String, second: String) -> [String] {
        var lines: [String] = []
        if differences.isEmpty { lines += ["", "The installs are identical."] }
        for (title, paths) in [(first, differences.onlyInFirst), (second, differences.onlyInSecond)] where !paths.isEmpty {
            lines += ["", "### Only in \(title)", ""]
            lines += paths.map { "- `\($0)`" }
        }
        if !differences.changedFiles.isEmpty {
            lines += ["", "### Different files"]
            for file in differences.changedFiles {
                let kind = file.kind.map { "\($0.rawValue), " } ?? ""
                lines += ["", "#### `\(file.path)`", "", "\(kind)\(file.firstSize) bytes in the older, \(file.secondSize) in the newer."]
                guard file.kind != nil else {
                    lines.append("Not compared entry by entry: it isn't a container in both, or doesn't open.")
                    continue
                }
                guard !file.entries.isEmpty else {
                    lines.append("Every entry is the same; the container's layout differs.")
                    continue
                }
                lines.append("")
                if file.kind == .iff || file.entries.contains(where: { $0.name.contains(": ") }) {
                    lines += objectTable(file)
                } else {
                    // Archives of other assets: counts only; the names alone run to thousands of lines.
                    let counts = Dictionary(grouping: file.entries, by: \.change).mapValues(\.count)
                    lines.append("Entries only in the older: \(counts[.onlyInFirst, default: 0]), only in the newer: "
                                 + "\(counts[.onlyInSecond, default: 0]), changed: \(counts[.changed, default: 0]).")
                }
            }
        }
        return lines
    }

    /// One row per IFF (or per entry that isn't one), with the chunks that differ by type.
    private static func objectTable(_ file: FileDifference) -> [String] {
        struct Row {
            var onlyInFirst: [String] = []
            var onlyInSecond: [String] = []
            var changed: [String] = []
            var guids: [String] = []
        }
        var rows: [String: Row] = [:]
        for entry in file.entries {
            // "chair.iff: BHAV #4096" inside an archive, "BHAV #4096" in an IFF, or a whole entry.
            let parts = entry.name.components(separatedBy: ": ")
            let (iff, chunk): (String, String) = file.kind == .iff
                ? ("(this file)", entry.name)
                : parts.count > 1 ? (parts[0], parts.dropFirst().joined(separator: ": ")) : (entry.name, "whole entry")
            var row = rows[iff] ?? Row()
            switch entry.change {
            case .onlyInFirst: row.onlyInFirst.append(chunk)
            case .onlyInSecond: row.onlyInSecond.append(chunk)
            case .changed: row.changed.append(chunk)
            }
            if let guid = entry.guid, !row.guids.contains(guid) { row.guids.append(guid) }
            rows[iff] = row
        }
        var lines = ["| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |", "| --- | --- | --- | --- | --- |"]
        for name in rows.keys.sorted() {
            guard let row = rows[name] else { continue }
            let cells = [row.onlyInFirst, row.onlyInSecond, row.changed].map(chunkList)
            lines.append("| `\(escaped(name))` | \(cells[0]) | \(cells[1]) | \(cells[2]) | \(row.guids.joined(separator: ", ")) |")
        }
        return lines
    }

    /// Chunks grouped by type, in order: `BHAV 4096, 4097; STR# 128`.
    private static func chunkList(_ chunks: [String]) -> String {
        var order: [String] = [], ids: [String: [String]] = [:]
        for chunk in chunks {
            let parts = chunk.components(separatedBy: " #")
            let type = parts.count == 2 ? parts[0] : chunk
            if ids[type] == nil { order.append(type) }
            if parts.count == 2 { ids[type, default: []].append(parts[1]) } else { ids[type] = ids[type] ?? [] }
        }
        return order.map { type in
            let list = ids[type] ?? []
            return escaped(list.isEmpty ? type : "\(type) \(list.joined(separator: ", "))")
        }.joined(separator: "; ")
    }

    private static func escaped(_ text: String) -> String {
        text.replacingOccurrences(of: "|", with: "\\|")
    }
}
