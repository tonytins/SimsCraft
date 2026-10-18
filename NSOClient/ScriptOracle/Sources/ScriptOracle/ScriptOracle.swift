import ArgumentParser
import Foundation
import ScriptOracleCore
import SimAntics
import TSOContent

@main
struct ScriptOracle: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sso-oracle",
        abstract: "Run oracle experiments using SimsScript where possible.",
        discussion: """
            Hybrid oracle: uses SimsScript for scenario logic and Swift for orchestration.
            """,
        subcommands: [])
}
