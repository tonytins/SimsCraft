import Foundation
import SimAntics
import TSOFiles

extension Answers {
    /// `operands`: the operands of primitives NSOClient decodes but doesn't run yet, as
    /// `fso-oracle operands` prints them.
    ///
    /// The same files (each entry of `objectdata/objects/objiff.far`, then each `.iff` in
    /// `objectdata/globals`, in name order) and, for each `BHAV` and each instruction with an
    /// opcode in ``PrimitiveTable/unportedOperands``, the entry, BHAV ID, instruction index,
    /// opcode, and the operand's ``FSOCompatOperand/fsoCompatFields`` as `Name=value` pairs in
    /// name order. A file or BHAV that can't be read prints `error` with `-` for what's missing.
    public static func operands(in gameDirectory: URL) -> [String] {
        var lines: [String] = []
        for (name, file) in operandFiles(in: gameDirectory, into: &lines) {
            for record in file.chunks(ofType: BHAV.typeCode).sorted(by: { $0.id < $1.id }) {
                guard let routine = try? BHAV(record: record) else {
                    lines.append("\(name)\t\(record.id)\t-\t-\terror\tunreadable")
                    continue
                }
                for (index, instruction) in routine.instructions.enumerated() {
                    let bytes = [UInt8](instruction.operand)
                    guard let operand = PrimitiveTable.unportedOperand(opcode: instruction.opcode, bytes: bytes) else { continue }
                    let fields = operand.fsoCompatFields.sorted { $0.name < $1.name }.map { "\($0.name)=\($0.value)" }
                    lines.append("\(name)\t\(routine.id)\t\(index)\t\(instruction.opcode)\t\(fields.joined(separator: ";"))")
                }
            }
        }
        return lines
    }

    /// The IFFs `operands` reads, by the names it prints them under.
    private static func operandFiles(in gameDirectory: URL, into lines: inout [String]) -> [(String, IFFFile)] {
        let root = gameDirectory.standardizedFileURL.path
        let paths = FileManager.default.enumerator(atPath: root)?.compactMap { $0 as? String } ?? []
        var files: [(String, IFFFile)] = []
        if let archivePath = paths.first(where: { $0.lowercased() == "objectdata/objects/objiff.far" }) {
            if let archive = try? FAR1Archive(contentsOf: URL(fileURLWithPath: root).appendingPathComponent(archivePath), variant: .b) {
                for entry in archive.entries.sorted(by: { $0.fileName.lowercased() < $1.fileName.lowercased() }) {
                    let name = "objiff.far/\(entry.fileName.lowercased())"
                    guard let data = try? archive.data(for: entry), let file = try? IFFFile(bytes: data) else {
                        lines.append("\(name)\t-\t-\t-\terror\tunreadable")
                        continue
                    }
                    files.append((name, file))
                }
            } else {
                lines.append("objiff.far\t-\t-\t-\terror\tunreadable")
            }
        }
        let globals = paths.filter { path in
            let lower = path.lowercased()
            return lower.hasPrefix("objectdata/globals/") && lower.hasSuffix(".iff") && !lower.dropFirst(19).contains("/")
        }.sorted { ($0 as NSString).lastPathComponent.lowercased() < ($1 as NSString).lastPathComponent.lowercased() }
        for path in globals {
            let name = "globals/" + (path as NSString).lastPathComponent.lowercased()
            guard let file = try? IFFFile(contentsOf: URL(fileURLWithPath: root).appendingPathComponent(path)) else {
                lines.append("\(name)\t-\t-\t-\terror\tunreadable")
                continue
            }
            files.append((name, file))
        }
        return files
    }
}

extension Comparison {
    /// `operands`: each instruction's operand, field by field. Every field NSOClient decodes must
    /// be in FreeSO's record with the same value; FreeSO's other fields (properties it derives,
    /// such as flags read as booleans) aren't compared. An instruction FreeSO can't read counts as
    /// recovered when NSOClient reads it.
    public static func operands(fso: [String], nso: [String]) -> Comparison {
        var result = Comparison(name: "Operands")
        func keyed(_ lines: [String]) -> [String: String] {
            var records: [String: String] = [:]
            for line in lines {
                let fields = line.split(separator: "\t", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
                guard fields.count == 5 else { continue }
                records[fields.prefix(4).joined(separator: "\t")] = fields[4]
            }
            return records
        }
        func values(_ record: String) -> [String: String] {
            var values: [String: String] = [:]
            for pair in record.split(separator: ";") {
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                if parts.count == 2 { values[parts[0]] = parts[1] }
            }
            return values
        }
        let theirs = keyed(fso), ours = keyed(nso)
        for (key, mine) in ours.sorted(by: { $0.key < $1.key }) {
            guard let record = theirs[key] else {
                result.skip("FreeSO has no record")
                continue
            }
            if record.hasPrefix("error") {
                if mine.hasPrefix("error") { result.matched += 1 } else { result.recovered += 1 }
                continue
            }
            if mine.hasPrefix("error") {
                result.skip("NSOClient couldn't read it")
                continue
            }
            let freeSO = values(record)
            let differing = values(mine).sorted { $0.key < $1.key }.filter { freeSO[$0.key] != $0.value }
            if differing.isEmpty {
                result.matched += 1
            } else {
                let fields = differing.map { "\($0.key) FreeSO \(freeSO[$0.key] ?? "absent") NSOClient \($0.value)" }
                result.mismatches.append("\(key.replacingOccurrences(of: "\t", with: " ")): \(fields.joined(separator: ", "))")
            }
        }
        for key in theirs.keys.sorted() where ours[key] == nil {
            result.skip("NSOClient has no record")
        }
        return result
    }
}
