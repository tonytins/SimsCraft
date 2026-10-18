import Foundation
import SimAntics
import TSOContent
import TSOFiles

public struct ScenarioContext {
    public let content: GameContent
    public let blueprint: Blueprint?
    public let ticks: Int
    public let every: Int
    public let dump: Bool
    public let seed: UInt64
    public let leaveOut: [UInt32]
    
    public init(content: GameContent, blueprint: Blueprint? = nil, ticks: Int = 1800, every: Int = 0, dump: Bool = false, seed: UInt64 = 1, leaveOut: [UInt32] = []) {
        self.content = content
        self.blueprint = blueprint
        self.ticks = ticks
        self.every = every
        self.dump = dump
        self.seed = seed
        self.leaveOut = leaveOut
    }
}
