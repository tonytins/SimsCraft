import Foundation
import SimAntics
import TSOContent

/// Stub PrimitiveRunner for ScriptOracle; delegates to Answers-style behavior where appropriate.
public struct PrimitiveRunner {
    public static let protocolVersion = 1
    let answers: Answers
    let lot: Blueprint
    
    public init(answers: Answers, lot: Blueprint) {
        self.answers = answers
        self.lot = lot
    }
    
    public func answerLine(_ line: String) -> String? {
        let text = line.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !text.hasPrefix("#") else { return nil }
        return #"{"protocol":1,"requestError":"sso-oracle primitive execution not yet fully implemented"}"#
    }
}
