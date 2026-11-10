import Foundation
import SimAntics
import TSOContent
import TSOFiles

/// The content census: what the buy-mode catalog's behavior reaches, without running a VM.
///
/// Starting from each object's `OBJD` behavior fields, `OBJf` entry points, and `TTAB`
/// interactions, it follows subroutine calls and `run_tree_by_name`, then counts the primitives,
/// operand shapes, and variable scopes in every routine it reaches. A routine shared by many
/// objects is counted once per column. Each lot column counts only the objects the lot places
/// that are also in the catalog, so a column says what that lot exercises.
///
/// This is a static walk, not a run: it follows every edge, including branches a run wouldn't
/// take. `run_tree_by_name` is resolved in the calling object's own file and semi-global, which is
/// where the VM looks for the stack object's routines when the object is its own stack object;
/// a routine that runs a different object's named tree may reach more.
public enum Census {
    /// One column: a lot's objects, or (`guids == nil`) every buyable catalog entry.
    public struct Column: Sendable, Equatable {
        public var name: String
        /// The object GUIDs to start from, or `nil` for the whole catalog. GUIDs the catalog
        /// doesn't list are ignored.
        public var guids: Set<UInt32>?

        public init(name: String, guids: Set<UInt32>? = nil) {
            self.name = name
            self.guids = guids
        }
    }

    /// An object the census couldn't load.
    public struct Failure: Sendable, Equatable {
        public var column: String
        public var guid: UInt32
        public var reason: String
    }

    /// What one column's walk counted.
    public struct Counts: Sendable, Equatable {
        /// Catalog entries considered.
        public var objects = 0
        public var loaded = 0
        /// Listed in the catalog but not registered by the install.
        public var missing = 0
        /// Registered but failed to load.
        public var errors = 0
        /// Distinct routines reached.
        public var routines = 0
        /// Instructions in those routines, each counted once.
        public var instructions = 0
        public var subroutineCalls = 0
        public var primitives = 0
        /// Instructions whose primitive the port doesn't run yet.
        public var unported = 0
        /// Instructions whose primitive neither FreeSO nor the port knows.
        public var unknown = 0
        /// Instructions by primitive opcode, below 256.
        public var primitiveUses: [UInt8: Int] = [:]
        /// Instructions by primitive opcode and the scopes of its variables.
        public var shapes: [Shape: Int] = [:]
        /// Variables by scope name.
        public var scopes: [String: Int] = [:]
    }

    /// A primitive's operand shape: its variables' scopes, in field order, or `-` for none.
    public struct Shape: Sendable, Hashable {
        public var opcode: UInt8
        public var variables: String
    }

    /// A column with its counts.
    public struct ResultColumn: Sendable, Equatable {
        public var name: String
        public var counts: Counts
    }

    /// The whole census.
    public struct Result: Sendable, Equatable {
        public var installDirectory: String
        public var installVersion: String?
        /// Every `P` entry in the catalog, including parts and cursors.
        public var catalogEntries: Int
        /// Entries with a category of 0 or more.
        public var buyableEntries: Int
        public var columns: [ResultColumn]
        public var failures: [Failure]

        /// The report, as tab-separated lines: comments, a header, and `kind`/`key`/column rows.
        public func lines() -> [String] {
            var lines = [
                "# sb-oracle census",
                "# install: \(installVersion ?? "unknown") (\(installDirectory))",
                "# catalog: \(buyableEntries) buyable of \(catalogEntries) entries",
            ]
            for column in columns {
                lines.append("# column \(column.name): \(column.counts.objects) objects")
            }
            lines.append((["kind", "key"] + columns.map(\.name)).joined(separator: "\t"))

            func row(_ kind: String, _ key: String, _ value: (Counts) -> Int) {
                lines.append(([kind, key] + columns.map { String(value($0.counts)) }).joined(separator: "\t"))
            }
            row("summary", "objects") { $0.objects }
            row("summary", "loaded") { $0.loaded }
            row("summary", "missing") { $0.missing }
            row("summary", "errors") { $0.errors }
            row("summary", "routines") { $0.routines }
            row("summary", "instructions") { $0.instructions }
            row("summary", "subroutine calls") { $0.subroutineCalls }
            row("summary", "primitives") { $0.primitives }
            row("summary", "unported") { $0.unported }
            row("summary", "unknown") { $0.unknown }

            let opcodes = Set(columns.flatMap { $0.counts.primitiveUses.keys }).sorted()
            for opcode in opcodes {
                let primitive = Census.primitive(opcode)
                row("primitive", "\(opcode) \(primitive.name) (\(primitive.state))") { $0.primitiveUses[opcode] ?? 0 }
            }

            var shapes: Set<Shape> = []
            for column in columns { shapes.formUnion(column.counts.shapes.keys) }
            for shape in shapes.sorted(by: { ($0.opcode, $0.variables) < ($1.opcode, $1.variables) }) {
                let primitive = Census.primitive(shape.opcode)
                row("shape", "\(shape.opcode) \(primitive.name): \(shape.variables)") { $0.shapes[shape] ?? 0 }
            }

            let scopes = Set(columns.flatMap { $0.counts.scopes.keys }).sorted()
            for scope in scopes {
                row("scope", scope) { $0.scopes[scope] ?? 0 }
            }

            for failure in failures {
                lines.append("# failure \(failure.column) \(String(format: "0x%08X", failure.guid)): \(failure.reason)")
            }
            return lines
        }
    }

    /// Walks the buy-mode catalog and the given columns, never running a VM.
    ///
    /// - Throws: ``ContentError`` if the install's global can't load, which every walk needs;
    ///   an object that can't load is counted and reported instead.
    public static func analyze(content: GameContent, catalog: ObjectCatalog, columns: [Column]) throws(ContentError) -> Result {
        let global = try content.global()
        // A catalog with a GUID twice keeps the first, rather than crashing the walk.
        let entries = Dictionary(catalog.entries.map { ($0.guid, $0) }, uniquingKeysWith: { first, _ in first })
        let catalogGUIDs = entries.keys.sorted()
        var results: [ResultColumn] = []
        var failures: [Failure] = []
        for column in columns {
            var walker = Walker(content: content, global: global, column: column.name, catalog: entries)
            let guids = column.guids.map { $0.sorted() } ?? catalogGUIDs
            walker.walk(guids)
            results.append(ResultColumn(name: column.name, counts: walker.counts))
            failures += walker.failures
        }
        let version = try? GameVersion.read(install: content.files.root)
        return Result(installDirectory: content.files.root.path, installVersion: version.map { String(describing: $0) },
                      catalogEntries: catalog.totalEntries, buyableEntries: catalog.entries.count,
                      columns: results, failures: failures)
    }

    private static func primitive(_ opcode: UInt8) -> (name: String, state: String) {
        if let name = PrimitiveTable.standard.name(of: opcode) { return (name, "ported") }
        if let name = PrimitiveTable.fsoCompat[opcode] { return (name, "unported") }
        return ("unknown", "unknown")
    }
}

// MARK: - Walking

private struct RoutineKey: Hashable {
    enum Owner: Hashable {
        case global
        case semiGlobal(String)
        case object(String)
    }

    var owner: Owner
    var id: UInt16

    var description: String {
        switch owner {
        case .global: "global BHAV \(id)"
        case .semiGlobal(let name): "semi-global \(name) BHAV \(id)"
        case .object(let name): "object \(name) BHAV \(id)"
        }
    }
}

private struct ScanKey: Hashable {
    var routine: RoutineKey
    var object: UInt32
}

private struct Walker {
    typealias Shape = Census.Shape

    let content: GameContent
    let global: GlobalResource
    let column: String
    /// The catalog's entries by GUID; a GUID it doesn't list is skipped.
    let catalog: [UInt32: ObjectCatalog.Entry]

    var counts = Census.Counts()
    var failures: [Census.Failure] = []

    private var routines: [RoutineKey: BHAV] = [:]
    private var missingRoutines: Set<RoutineKey> = []
    private var counted: Set<RoutineKey> = []
    private var scanned: Set<ScanKey> = []

    enum Root {
        case id(UInt16)
        case routine(RoutineKey, BHAV)
    }

    init(content: GameContent, global: GlobalResource, column: String, catalog: [UInt32: ObjectCatalog.Entry]) {
        self.content = content
        self.global = global
        self.column = column
        self.catalog = catalog
    }

    mutating func walk(_ guids: [UInt32]) {
        for guid in guids where catalog[guid] != nil {
            counts.objects += 1
            let object: GameObject
            do {
                guard let loaded = try content.objects.object(guid: guid) else {
                    counts.missing += 1
                    failures.append(.init(column: column, guid: guid, reason: "not registered or has no OBJD"))
                    continue
                }
                object = loaded
            } catch {
                counts.errors += 1
                failures.append(.init(column: column, guid: guid, reason: String(describing: error)))
                continue
            }
            counts.loaded += 1
            walk(object: object)
        }
    }

    private mutating func walk(object: GameObject) {
        var stack = roots(of: object).map { Root.id($0) }
        while let root = stack.popLast() {
            let key: RoutineKey, bhav: BHAV
            switch root {
            case .routine(let rootKey, let rootBHAV):
                (key, bhav) = (rootKey, rootBHAV)
            case .id(let id):
                guard let resolved = resolve(id, in: object) else { continue }
                (key, bhav) = resolved
            }
            guard scanned.insert(ScanKey(routine: key, object: object.guid)).inserted else { continue }
            let isNew = counted.insert(key).inserted
            if isNew { counts.routines += 1 }
            for instruction in bhav.instructions {
                if isNew {
                    counts.instructions += 1
                    if instruction.opcode >= 256 {
                        counts.subroutineCalls += 1
                    } else {
                        countPrimitive(instruction)
                    }
                }
                if instruction.opcode >= 256 {
                    stack.append(.id(instruction.opcode))
                } else if instruction.opcode == UInt16(Primitives.RunTreeByName.opcode),
                          let target = treeByName(Primitives.RunTreeByName.Operand(bytes: Array(instruction.operand)),
                                                  in: object, routine: key.id) {
                    stack.append(.routine(target.0, target.1))
                }
            }
        }
    }

    /// The object's entry points: every `OBJD` behavior field, `OBJf`, and `TTAB`.
    private mutating func roots(of object: GameObject) -> [UInt16] {
        var roots = object.definition.behaviorFields.map(\.id)
        let definition = object.definition
        do {
            if let table = try object.resource.chunk(OBJf.self, id: definition.id) {
                for function in table.functions { roots += [function.conditionFunction, function.actionFunction] }
            }
        } catch {
            failures.append(.init(column: column, guid: object.guid, reason: "OBJf \(definition.id): \(error)"))
        }
        do {
            var table = try object.resource.chunk(TTAB.self, id: definition.treeTableID)
            if table == nil, let semiGlobal = object.resource.semiGlobal {
                table = try semiGlobal.chunk(TTAB.self, id: definition.treeTableID)
            }
            for interaction in table?.interactions ?? [] {
                roots += [interaction.actionFunction, interaction.testFunction]
            }
        } catch {
            failures.append(.init(column: column, guid: object.guid, reason: "TTAB \(definition.treeTableID): \(error)"))
        }
        return roots.filter { $0 != 0 }
    }

    private mutating func resolve(_ id: UInt16, in object: GameObject) -> (RoutineKey, BHAV)? {
        guard id != 0 else { return nil }
        let owner: RoutineKey.Owner
        let resource: any IFFResource
        if id >= 8192 {
            guard let semiGlobal = object.resource.semiGlobal else { return nil }
            owner = .semiGlobal(semiGlobal.name)
            resource = semiGlobal
        } else if id >= 4096 {
            owner = .object(object.resource.name)
            resource = object.resource
        } else {
            owner = .global
            resource = global
        }
        let key = RoutineKey(owner: owner, id: id)
        if let cached = routines[key] { return (key, cached) }
        if missingRoutines.contains(key) { return nil }
        do {
            guard let bhav = try resource.chunk(BHAV.self, id: id) else {
                missingRoutines.insert(key)
                return nil
            }
            routines[key] = bhav
            return (key, bhav)
        } catch {
            missingRoutines.insert(key)
            failures.append(.init(column: column, guid: object.guid, reason: "\(key.description): \(error)"))
            return nil
        }
    }

    private mutating func treeByName(_ operand: Primitives.RunTreeByName.Operand, in object: GameObject,
                                     routine id: UInt16) -> (RoutineKey, BHAV)? {
        let table: STR?
        if operand.stringScope == 1 {
            table = try? global.chunk(STR.self, id: operand.stringTable)
        } else if id >= 8192, let semiGlobal = object.resource.semiGlobal,
                  let shared = try? semiGlobal.chunk(STR.self, id: operand.stringTable) {
            table = shared
        } else {
            table = try? object.resource.chunk(STR.self, id: operand.stringTable)
        }
        guard let table else { return nil }
        let index = Int(operand.stringID) - 1
        guard index >= 0, let name = table.table.string(at: index),
              let bhav = object.resource.treesByName[name],
              let source = object.resource.treeSourcesByName[name] else { return nil }
        switch source {
        case .mainFile:
            return (RoutineKey(owner: .object(object.resource.name), id: bhav.id), bhav)
        case .semiGlobal(let name):
            return (RoutineKey(owner: .semiGlobal(name), id: bhav.id), bhav)
        }
    }

    private mutating func countPrimitive(_ instruction: BHAV.Instruction) {
        let opcode = UInt8(truncatingIfNeeded: instruction.opcode)
        let bytes = Array(instruction.operand)
        counts.primitives += 1
        counts.primitiveUses[opcode, default: 0] += 1
        var variables: [Variable] = []
        switch PrimitiveTable.standard.decode(opcode: instruction.opcode, operand: bytes) {
        case .primitive(let prepared):
            variables = (prepared.operand as? any VariableOperand)?.variables ?? []
        case .unportedPrimitive:
            counts.unported += 1
            if let operand = PrimitiveTable.unportedOperand(opcode: instruction.opcode, bytes: bytes) {
                variables = (operand as? any VariableOperand)?.variables ?? []
            }
        case .missingPrimitive:
            counts.unknown += 1
        case .subroutine:
            break
        }
        let shape = variables.isEmpty ? "-" : variables.map(scopeName).joined(separator: ",")
        counts.shapes[Shape(opcode: opcode, variables: shape), default: 0] += 1
        for variable in variables { counts.scopes[scopeName(variable), default: 0] += 1 }
    }

    private func scopeName(_ variable: Variable) -> String {
        variable.scope.map { String(describing: $0) } ?? "scope\(variable.rawScope)"
    }
}
