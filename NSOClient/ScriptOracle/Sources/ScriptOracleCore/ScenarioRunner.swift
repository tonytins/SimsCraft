import Foundation
import SimAntics
import SimsScript
import TSOContent
import TSOFiles

/// What one scenario left: its object variables after the run, the errors its threads hit, and
/// the expectations they missed.
public struct ScenarioResult: Sendable, Equatable {
    /// An expectation the run didn't meet.
    public struct Miss: Sendable, Equatable {
        public var attribute: String
        public var expected: Int16
        public var actual: Int16

        public init(attribute: String, expected: Int16, actual: Int16) {
            self.attribute = attribute
            self.expected = expected
            self.actual = actual
        }
    }

    public var name: String
    public var guid: UInt32
    /// Each object variable and its value, in declaration order; empty if the run didn't happen.
    public var attributes: [(name: String, value: Int16)]
    /// Errors the VM reported, or why the object couldn't be created.
    public var errors: [String]
    public var misses: [Miss]

    public init(name: String, guid: UInt32, attributes: [(name: String, value: Int16)], errors: [String], misses: [Miss]) {
        self.name = name
        self.guid = guid
        self.attributes = attributes
        self.errors = errors
        self.misses = misses
    }

    /// Whether the run met every expectation without an error.
    public var passed: Bool { errors.isEmpty && misses.isEmpty }

    /// One line for the record: `name guid ticks attributes a=1 b=2`, then `errors` and each
    /// error if there were any. Both VMs' records use this form, so they can be compared line
    /// for line.
    public var recordLine: String {
        let values = attributes.map { "\($0.name)=\($0.value)" }.joined(separator: " ")
        return "\(name) \(String(format: "%08x", guid)) attributes \(values)"
            + (errors.isEmpty ? "" : " errors " + errors.joined(separator: "; "))
    }

    public static func == (lhs: ScenarioResult, rhs: ScenarioResult) -> Bool {
        lhs.name == rhs.name && lhs.guid == rhs.guid && lhs.errors == rhs.errors && lhs.misses == rhs.misses
            && lhs.attributes.map(\.name) == rhs.attributes.map(\.name)
            && lhs.attributes.map(\.value) == rhs.attributes.map(\.value)
    }
}

/// Compiles scenarios into standalone objects and runs each on NSOClient's VM.
///
/// Each object is run as `fso-oracle run-objects` runs one, so the other VM can run the same
/// bytes the same way: the lot is loaded with its objects taken out, ticked once, and reseeded;
/// then the object is created out of the world (which runs its initialize) and the lot is
/// ticked the scenario's `@ticks` times.
public struct ScenarioRunner: Sendable {
    /// The first GUID scenarios get, in name order. TSO's GUIDs use the whole 32-bit range
    /// (seven objects in each of the owner's installs start with `0x5C`), so no range is safe
    /// by itself: ``run(gameDirectory:lot:objectFolder:seed:)`` refuses a GUID the content
    /// already has.
    public static let firstGUID: UInt32 = 0x5C00_0001

    public let scenarios: [Scenario]

    public init(scenarios: [Scenario]) {
        self.scenarios = scenarios
    }

    /// Each scenario's GUID, in the order given.
    public var guids: [UInt32] { scenarios.indices.map { Self.firstGUID + UInt32($0) } }

    /// Writes each scenario's object into a folder as `NAME.iff`, a standalone object folder like
    /// FreeSO's `Content/Objects`, and a `scenarios.tsv`: each object's GUID, its scenario's name,
    /// its ticks, and its variables' names, comma-separated, in attribute order.
    ///
    /// - Throws: ``ScenarioError`` if a scenario doesn't compile or a file can't be written.
    public func writeObjects(to folder: URL) throws(ScenarioError) {
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            throw .unwritable(path: folder.path, reason: error.localizedDescription)
        }
        var table = ""
        for (scenario, guid) in zip(scenarios, guids) {
            let object = try scenario.compiled()
            let bytes: Data
            do {
                bytes = try object.objectFile(guid: guid, name: scenario.name)
            } catch {
                throw .objectFile(scenario: scenario.name, "\(error)")
            }
            let file = folder.appendingPathComponent("\(scenario.name).iff")
            do {
                try bytes.write(to: file)
            } catch {
                throw .unwritable(path: file.path, reason: error.localizedDescription)
            }
            table += "\(String(format: "%08x", guid))\t\(scenario.name)\t\(scenario.ticks)\t"
                + object.attributes.joined(separator: ",") + "\n"
        }
        let file = folder.appendingPathComponent("scenarios.tsv")
        do {
            try Data(table.utf8).write(to: file)
        } catch {
            throw .unwritable(path: file.path, reason: error.localizedDescription)
        }
    }

    /// Runs every scenario on NSOClient's VM, each on its own fresh lot.
    ///
    /// - Parameters:
    ///   - gameDirectory: the install whose content the VM loads (MockInstall will do; the
    ///     scenarios use none of it).
    ///   - lot: the lot to run on; its objects are taken out.
    ///   - objectFolder: a folder to write the scenarios' objects into, which the content loads
    ///     as standalone objects.
    /// - Throws: ``ScenarioError`` if the objects can't be written, the content can't load, or
    ///   a scenario's GUID belongs to another object. A scenario that fails to run is reported in
    ///   its result instead.
    public func run(gameDirectory: URL, lot: Blueprint, objectFolder: URL,
                    seed: UInt64 = Self.defaultSeed) throws(ScenarioError) -> [ScenarioResult] {
        try writeObjects(to: objectFolder)
        let content: GameContent
        do {
            content = try GameContent(.init(gameDirectory: gameDirectory, standaloneObjectDirectory: objectFolder))
        } catch {
            throw .content("\(error)")
        }
        for (scenario, guid) in zip(scenarios, guids) where content.objects.reference(guid: guid)?.source != .standalone {
            throw .guidTaken(scenario: scenario.name, guid: guid)
        }
        var empty = lot
        empty.objects = []
        return zip(scenarios, guids).map { scenario, guid in
            run(scenario, guid: guid, content: content, lot: empty, seed: seed)
        }
    }

    /// The seed `fso-oracle` and `nso-oracle` use unless told otherwise.
    public static let defaultSeed: UInt64 = 0x0F50_D0C5_EED0_0001

    private func run(_ scenario: Scenario, guid: UInt32, content: GameContent, lot: Blueprint,
                     seed: UInt64) -> ScenarioResult {
        var result = ScenarioResult(name: scenario.name, guid: guid, attributes: [], errors: [], misses: [])
        let names: [String]
        let entity: Entity
        let vm: VM
        do {
            names = try scenario.compiled().attributes
            vm = try VM(content: content, seed: seed)
            _ = try vm.load(lot)
            vm.tick()
            vm.random = VMRandom(seed: seed)
            guard let created = try vm.createObject(guid: guid)?.objects.first else {
                result.errors = ["missing: the content has no object \(String(format: "%08x", guid))"]
                return result
            }
            entity = created
        } catch {
            result.errors = ["while creating: \(error)"]
            return result
        }
        for _ in 0..<scenario.ticks { vm.tick() }
        result.errors = vm.reportedErrors.map { "tick \($0.tick): \($0.error)" }
        result.attributes = names.enumerated().map { (name: $1, value: entity.attribute(at: UInt16($0))) }
        for expectation in scenario.expectations {
            guard let actual = result.attributes.first(where: { $0.name == expectation.attribute })?.value,
                  actual != expectation.value else { continue }
            result.misses.append(.init(attribute: expectation.attribute, expected: expectation.value, actual: actual))
        }
        return result
    }
}
