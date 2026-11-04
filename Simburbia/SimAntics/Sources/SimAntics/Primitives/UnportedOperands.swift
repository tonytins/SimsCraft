// The operands of primitives this port doesn't run yet, decoded as FreeSO decodes them, so tools
// can show what an instruction asks for. Each ports a FreeSO operand class's `Read` and `Write`;
// when its primitive is ported, the operand moves into that primitive's own file.

/// An operand that lists its values under FreeSO's field names, for comparing a decoding with
/// FreeSO's (`fso-oracle operands`). Booleans are 0 or 1; scopes and enums are their raw values.
public protocol FSOCompatOperand: PrimitiveOperand {
    var fsoCompatFields: [(name: String, value: Int64)] { get }
}

extension PrimitiveTable {
    /// Operand types for primitives FreeSO registers in TSO mode that this port doesn't run yet,
    /// by opcode. Primitives with no operand (grab, drop, syslog, test sim interacting with, find
    /// best action) decode to ``Primitives/EmptyOperand``.
    public static let unportedOperands: [UInt8: any FSOCompatOperand.Type] = [
        1: Primitives.GenericTSOCall.Operand.self,
        4: Primitives.EmptyOperand.self,
        5: Primitives.EmptyOperand.self,
        6: Primitives.ChangeSuitOrAccessory.Operand.self,
        9: Primitives.Burn.Operand.self,
        13: Primitives.PushInteraction.Operand.self,
        14: Primitives.FindBestObjectForFunction.Operand.self,
        20: Primitives.RunFunctionalTree.Operand.self,
        22: Primitives.LookTowards.Operand.self,
        24: Primitives.OldRelationship.Operand.self,
        26: Primitives.Relationship.Operand.self,
        27: Primitives.GotoRelativePosition.Operand.self,
        29: Primitives.SetMotiveChange.Operand.self,
        30: Primitives.EmptyOperand.self,
        36: Primitives.Dialog.Operand.self,
        37: Primitives.EmptyOperand.self,
        38: Primitives.Dialog.Operand.self,
        39: Primitives.Dialog.Operand.self,
        40: Primitives.OnlineJobsCall.Operand.self,
        43: Primitives.DropOnto.Operand.self,
        44: Primitives.AnimateSim.Operand.self,
        45: Primitives.GotoRoutingSlot.Operand.self,
        46: Primitives.Snap.Operand.self,
        47: Primitives.Reach.Operand.self,
        50: Primitives.ChangeActionString.Operand.self,
        62: Primitives.InvokePlugin.Operand.self,
        65: Primitives.EmptyOperand.self,
        67: Primitives.InventoryOperations.Operand.self,
    ]

    /// An unported primitive's operand, decoded, or `nil` if this port doesn't know its layout.
    public static func unportedOperand(opcode: UInt16, bytes: [UInt8]) -> (any FSOCompatOperand)? {
        guard opcode < 256, let type = unportedOperands[UInt8(opcode)] else { return nil }
        return type.init(bytes: bytes)
    }
}

extension Primitives {
    /// The operand of a primitive that reads none, such as FreeSO's `VMGrabOperand`.
    public struct EmptyOperand: FSOCompatOperand, Equatable {
        public init() {}
        public init(bytes: [UInt8]) {}
        public func encoded() -> [UInt8] { OperandWriter.bytes { _ in } }
        public var fsoCompatFields: [(name: String, value: Int64)] { [] }
    }

    /// Animate Sim (opcode 44). FreeSO's `VMAnimateSimOperand`; its second padding byte is
    /// written back as zero, as FreeSO writes it.
    public enum AnimateSim {
        public struct Operand: FSOCompatOperand, Equatable {
            public var animationID: UInt16
            public var localEventNumber: UInt8
            /// Where the animation comes from (`VMAnimationScope`).
            public var source: UInt8
            public var flags: UInt8
            public var expectedEventCount: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                animationID = reader.uint16()
                localEventNumber = reader.uint8()
                _ = reader.uint8()
                source = reader.uint8()
                flags = reader.uint8()
                expectedEventCount = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(animationID)
                    writer.uint8(localEventNumber)
                    writer.uint8(0)
                    writer.uint8(source)
                    writer.uint8(flags)
                    writer.uint8(expectedEventCount)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("AnimationID", Int64(animationID)), ("LocalEventNumber", Int64(localEventNumber)),
                 ("Source", Int64(source)), ("Flags", Int64(flags)), ("ExpectedEventCount", Int64(expectedEventCount))]
            }
        }
    }

    /// Change Suit or Accessory (opcode 6). FreeSO's `VMChangeSuitOrAccessoryOperand`.
    public enum ChangeSuitOrAccessory {
        public struct Operand: FSOCompatOperand, Equatable {
            public var suitData: UInt8
            /// Where the suit comes from (`VMSuitScope`).
            public var suitScope: UInt8
            public var flags: UInt16

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                suitData = reader.uint8()
                suitScope = reader.uint8()
                flags = reader.uint16()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint8(suitData)
                    writer.uint8(suitScope)
                    writer.uint16(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("SuitData", Int64(suitData)), ("SuitScope", Int64(suitScope)), ("Flags", Int64(flags))]
            }
        }
    }

    /// Set Motive Deltas (opcode 29). FreeSO's `VMSetMotiveChangeOperand`; its owner and data
    /// pairs are ``Variable``s here.
    public enum SetMotiveChange {
        public struct Operand: FSOCompatOperand, Equatable {
            public var delta: Variable
            public var max: Variable
            /// The motive (`VMMotive`).
            public var motive: UInt8
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                let deltaOwner = reader.uint8(), maxOwner = reader.uint8()
                motive = reader.uint8()
                flags = reader.uint8()
                delta = Variable(rawScope: UInt16(deltaOwner), data: reader.int16())
                max = Variable(rawScope: UInt16(maxOwner), data: reader.int16())
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint8(UInt8(truncatingIfNeeded: delta.rawScope))
                    writer.uint8(UInt8(truncatingIfNeeded: max.rawScope))
                    writer.uint8(motive)
                    writer.uint8(flags)
                    writer.int16(delta.data)
                    writer.int16(max.data)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("DeltaOwner", Int64(delta.rawScope)), ("DeltaData", Int64(delta.data)), ("MaxOwner", Int64(max.rawScope)),
                 ("MaxData", Int64(max.data)), ("Motive", Int64(motive)), ("Flags", Int64(flags))]
            }
        }
    }

    /// Dialog (opcodes 36, 38, and 39: private, global, and semi-global strings). FreeSO's
    /// `VMDialogOperand`. The IDs index the strings of the dialog's string table.
    public enum Dialog {
        public struct Operand: FSOCompatOperand, Equatable {
            public var cancelStringID: UInt8
            public var iconNameStringID: UInt8
            public var messageStringID: UInt8
            public var yesStringID: UInt8
            public var noStringID: UInt8
            /// The kind of dialog (`VMDialogType`).
            public var type: UInt8
            public var titleStringID: UInt8
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                cancelStringID = reader.uint8()
                iconNameStringID = reader.uint8()
                messageStringID = reader.uint8()
                yesStringID = reader.uint8()
                noStringID = reader.uint8()
                type = reader.uint8()
                titleStringID = reader.uint8()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                [cancelStringID, iconNameStringID, messageStringID, yesStringID, noStringID, type, titleStringID, flags]
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("CancelStringID", Int64(cancelStringID)), ("IconNameStringID", Int64(iconNameStringID)),
                 ("MessageStringID", Int64(messageStringID)), ("YesStringID", Int64(yesStringID)),
                 ("NoStringID", Int64(noStringID)), ("Type", Int64(type)), ("TitleStringID", Int64(titleStringID)),
                 ("Flags", Int64(flags))]
            }
        }
    }

    /// Go to Routing Slot (opcode 45). FreeSO's `VMGotoRoutingSlotOperand`.
    public enum GotoRoutingSlot {
        public struct Operand: FSOCompatOperand, Equatable {
            public var data: UInt16
            /// How ``data`` picks the slot (`VMSlotScope`).
            public var type: UInt16
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                data = reader.uint16()
                type = reader.uint16()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(data)
                    writer.uint16(type)
                    writer.uint8(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Data", Int64(data)), ("Type", Int64(type)), ("Flags", Int64(flags))]
            }
        }
    }

    /// Push Interaction (opcode 13). FreeSO's `VMPushInteractionOperand`.
    public enum PushInteraction {
        public struct Operand: FSOCompatOperand, Equatable {
            public var interaction: UInt8
            /// The local or parameter that holds the object's ID.
            public var objectLocation: UInt8
            /// The interaction's priority (`VMPushPriority`).
            public var priority: UInt8
            public var flags: UInt8
            public var iconLocation: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                interaction = reader.uint8()
                objectLocation = reader.uint8()
                priority = reader.uint8()
                flags = reader.uint8()
                iconLocation = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    for byte in [interaction, objectLocation, priority, flags, iconLocation] { writer.uint8(byte) }
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Interaction", Int64(interaction)), ("ObjectLocation", Int64(objectLocation)), ("Priority", Int64(priority)),
                 ("Flags", Int64(flags)), ("IconLocation", Int64(iconLocation))]
            }
        }
    }

    /// Relationship (opcode 26). FreeSO's `VMRelationshipOperand`; its scope and data are a
    /// ``Variable`` here.
    public enum Relationship {
        public struct Operand: FSOCompatOperand, Equatable {
            public var relationshipVariable: UInt8
            public var mode: UInt8
            public var flags: UInt8
            public var local: UInt8
            public var variable: Variable

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                relationshipVariable = reader.uint8()
                mode = reader.uint8()
                flags = reader.uint8()
                local = reader.uint8()
                let scope = reader.uint16()
                variable = Variable(rawScope: scope, data: reader.int16())
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    for byte in [relationshipVariable, mode, flags, local] { writer.uint8(byte) }
                    writer.uint16(variable.rawScope)
                    writer.int16(variable.data)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("RelVar", Int64(relationshipVariable)), ("Mode", Int64(mode)), ("Flags", Int64(flags)),
                 ("Local", Int64(local)), ("VarScope", Int64(variable.rawScope)), ("VarData", Int64(variable.data))]
            }
        }
    }

    /// Old Relationship (opcode 24): the same primitive as ``Relationship`` with an older
    /// operand. FreeSO's `VMOldRelationshipOperand`, whose variable is always a parameter.
    public enum OldRelationship {
        public struct Operand: FSOCompatOperand, Equatable {
            /// Whether it gets or sets (FreeSO's private `GetSet`, public as `SetMode`).
            public var setMode: UInt8
            public var relationshipVariable: UInt8
            /// The parameter that holds the value.
            public var variable: Variable
            public var mode: UInt8
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                setMode = reader.uint8()
                relationshipVariable = reader.uint8()
                variable = Variable(.parameters, Int16(reader.uint8()))
                mode = reader.uint8()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint8(setMode)
                    writer.uint8(relationshipVariable)
                    writer.uint8(UInt8(truncatingIfNeeded: variable.data))
                    writer.uint8(mode)
                    writer.uint8(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("SetMode", Int64(setMode)), ("RelVar", Int64(relationshipVariable)), ("VarScope", Int64(variable.rawScope)),
                 ("VarData", Int64(variable.data)), ("Mode", Int64(mode)), ("Flags", Int64(flags))]
            }
        }
    }

    /// Go to Relative Position (opcode 27). FreeSO's `VMGotoRelativePositionOperand`; location
    /// and direction are signed bytes.
    public enum GotoRelativePosition {
        public struct Operand: FSOCompatOperand, Equatable {
            public var oldTrapCount: UInt16
            /// Where to go relative to the object (`VMGotoRelativeLocation`).
            public var location: Int8
            /// Which way to face (`VMGotoRelativeDirection`).
            public var direction: Int8
            public var routeCount: UInt16
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                oldTrapCount = reader.uint16()
                location = Int8(bitPattern: reader.uint8())
                direction = Int8(bitPattern: reader.uint8())
                routeCount = reader.uint16()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(oldTrapCount)
                    writer.uint8(UInt8(bitPattern: location))
                    writer.uint8(UInt8(bitPattern: direction))
                    writer.uint16(routeCount)
                    writer.uint8(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("OldTrapCount", Int64(oldTrapCount)), ("Location", Int64(location)), ("Direction", Int64(direction)),
                 ("RouteCount", Int64(routeCount)), ("Flags", Int64(flags))]
            }
        }
    }

    /// Change Action String (opcode 50). FreeSO's `VMChangeActionStringOperand`.
    public enum ChangeActionString {
        public struct Operand: FSOCompatOperand, Equatable {
            public var stringTable: UInt16
            public var scope: UInt16
            public var stringID: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                stringTable = reader.uint16()
                scope = reader.uint16()
                stringID = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(stringTable)
                    writer.uint16(scope)
                    writer.uint8(stringID)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("StringTable", Int64(stringTable)), ("Scope", Int64(scope)), ("StringID", Int64(stringID))]
            }
        }
    }

    /// Snap (opcode 46). FreeSO's `VMSnapOperand`.
    public enum Snap {
        public struct Operand: FSOCompatOperand, Equatable {
            public var index: UInt16
            /// How ``index`` picks the slot (`VMSnapSlotScope`).
            public var mode: UInt16
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                index = reader.uint16()
                mode = reader.uint16()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(index)
                    writer.uint16(mode)
                    writer.uint8(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Index", Int64(index)), ("Mode", Int64(mode)), ("Flags", Int64(flags))]
            }
        }
    }

    /// One-byte calls: Generic Sims Online Call (opcode 1, `VMGenericTSOCallOperand`), Look
    /// Towards (22, `VMLookTowardsOperand`), and Online Jobs Call (40, `VMOnlineJobsCallOperand`).
    public enum GenericTSOCall {
        public struct Operand: FSOCompatOperand, Equatable {
            /// The call (`VMGenericTSOCallMode`).
            public var call: UInt8
            public init(bytes: [UInt8]) { call = bytes.first ?? 0 }
            public func encoded() -> [UInt8] { OperandWriter.bytes { $0.uint8(call) } }
            public var fsoCompatFields: [(name: String, value: Int64)] { [("Call", Int64(call))] }
        }
    }

    public enum LookTowards {
        public struct Operand: FSOCompatOperand, Equatable {
            /// What to look at (`VMLookTowardsMode`).
            public var mode: UInt8
            public init(bytes: [UInt8]) { mode = bytes.first ?? 0 }
            public func encoded() -> [UInt8] { OperandWriter.bytes { $0.uint8(mode) } }
            public var fsoCompatFields: [(name: String, value: Int64)] { [("Mode", Int64(mode))] }
        }
    }

    public enum OnlineJobsCall {
        public struct Operand: FSOCompatOperand, Equatable {
            /// The call (`VMOnlineJobsCallMode`).
            public var call: UInt8
            public init(bytes: [UInt8]) { call = bytes.first ?? 0 }
            public func encoded() -> [UInt8] { OperandWriter.bytes { $0.uint8(call) } }
            public var fsoCompatFields: [(name: String, value: Int64)] { [("Call", Int64(call))] }
        }
    }

    /// Drop Onto (opcode 43). FreeSO's `VMDropOntoOperand`.
    public enum DropOnto {
        public struct Operand: FSOCompatOperand, Equatable {
            public var sourceSlotMode: UInt16
            public var sourceSlotNumber: UInt16
            public var destinationSlotMode: UInt16
            public var destinationSlotNumber: UInt16

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                sourceSlotMode = reader.uint16()
                sourceSlotNumber = reader.uint16()
                destinationSlotMode = reader.uint16()
                destinationSlotNumber = reader.uint16()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    for value in [sourceSlotMode, sourceSlotNumber, destinationSlotMode, destinationSlotNumber] { writer.uint16(value) }
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("SrcSlotMode", Int64(sourceSlotMode)), ("SrcSlotNum", Int64(sourceSlotNumber)),
                 ("DestSlotMode", Int64(destinationSlotMode)), ("DestSlotNum", Int64(destinationSlotNumber))]
            }
        }
    }

    /// Run Functional Tree (opcode 20, `VMRunFunctionalTreeOperand`) and Find Best Object for
    /// Function (14, `VMFindBestObjectForFunctionOperand`, which reads only the function).
    public enum RunFunctionalTree {
        public struct Operand: FSOCompatOperand, Equatable {
            public var function: UInt16
            public var flags: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                function = reader.uint16()
                flags = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint16(function)
                    writer.uint8(flags)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Function", Int64(function)), ("Flags", Int64(flags))]
            }
        }
    }

    public enum FindBestObjectForFunction {
        public struct Operand: FSOCompatOperand, Equatable {
            public var function: UInt16
            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                function = reader.uint16()
            }
            public func encoded() -> [UInt8] { OperandWriter.bytes { $0.uint16(function) } }
            public var fsoCompatFields: [(name: String, value: Int64)] { [("Function", Int64(function))] }
        }
    }

    /// Reach (opcode 47). FreeSO's `VMReachOperand`.
    public enum Reach {
        public struct Operand: FSOCompatOperand, Equatable {
            public var mode: UInt16
            public var grabOrDrop: UInt16
            public var slotParameter: UInt16

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                mode = reader.uint16()
                grabOrDrop = reader.uint16()
                slotParameter = reader.uint16()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    for value in [mode, grabOrDrop, slotParameter] { writer.uint16(value) }
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Mode", Int64(mode)), ("GrabOrDrop", Int64(grabOrDrop)), ("SlotParam", Int64(slotParameter))]
            }
        }
    }

    /// Burn (opcode 9). FreeSO's `VMBurnOperand`.
    public enum Burn {
        public struct Operand: FSOCompatOperand, Equatable {
            /// What burns (`VMBurnType`).
            public var type: UInt8
            public var burnsBusyObjects: Bool

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                type = reader.uint8()
                burnsBusyObjects = reader.uint8() > 0
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint8(type)
                    writer.uint8(burnsBusyObjects ? 1 : 0)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("Type", Int64(type)), ("BurnBusyObjects", burnsBusyObjects ? 1 : 0)]
            }
        }
    }

    /// Invoke Plugin (opcode 62). FreeSO's `VMInvokePluginOperand`.
    public enum InvokePlugin {
        public struct Operand: FSOCompatOperand, Equatable {
            public var personLocal: UInt8
            public var objectLocal: UInt8
            public var eventLocal: UInt8
            public var isJoinable: Bool
            public var pluginID: UInt32

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                personLocal = reader.uint8()
                objectLocal = reader.uint8()
                eventLocal = reader.uint8()
                isJoinable = reader.uint8() > 0
                pluginID = reader.uint32()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    for byte in [personLocal, objectLocal, eventLocal, isJoinable ? 1 : 0] { writer.uint8(byte) }
                    writer.uint32(pluginID)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("PersonLocal", Int64(personLocal)), ("ObjectLocal", Int64(objectLocal)), ("EventLocal", Int64(eventLocal)),
                 ("Joinable", isJoinable ? 1 : 0), ("PluginID", Int64(pluginID))]
            }
        }
    }

    /// Inventory Operations (opcode 67). FreeSO's `VMInventoryOperationsOperand`.
    public enum InventoryOperations {
        public struct Operand: FSOCompatOperand, Equatable {
            public var guid: UInt32
            /// The operation (`VMInventoryOpMode`).
            public var mode: UInt8

            public init(bytes: [UInt8]) {
                var reader = OperandReader(bytes)
                guid = reader.uint32()
                mode = reader.uint8()
            }

            public func encoded() -> [UInt8] {
                OperandWriter.bytes { writer in
                    writer.uint32(guid)
                    writer.uint8(mode)
                }
            }

            public var fsoCompatFields: [(name: String, value: Int64)] {
                [("GUID", Int64(guid)), ("Mode", Int64(mode))]
            }
        }
    }
}
