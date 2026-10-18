import Foundation
import SimAntics
import SimsScript
import TSOContent
import TSOFiles

public struct Answers {
    public static let defaultSeed: UInt64 = 1
    let content: GameContent

    public init(content: GameContent) {
        self.content = content
    }
}
