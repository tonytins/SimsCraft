import Configuration
import Foundation
import Testing
import TSOConfig
import TSOContent

// swift-configuration needs macOS 15; the library declares no platforms, so its tests say so here.
@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
@Test func eachKindsKeyIsItsEnvironmentVariable() {
    let environment = Dictionary(uniqueKeysWithValues: InstallKind.allCases.map { ($0.environmentVariable, "/games/\($0)") })
    let config = ConfigReader(provider: EnvironmentVariablesProvider(environmentVariables: environment))
    let installs = InstallKind.installs(in: config)
    #expect(installs.map(\.kind) == [.game, .classic, .beta])
    #expect(installs.map(\.directory.path) == ["/games/game", "/games/classic", "/games/beta"])
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
@Test func anEarlierProviderWinsAndAnEmptyValueIsLeftOut() {
    let first = InMemoryProvider(values: [["tso", "beta", "dir"]: "/elsewhere/beta", ["tso", "classic", "dir"]: ""])
    let environment = EnvironmentVariablesProvider(environmentVariables: ["TSO_BETA_DIR": "/games/beta",
                                                                           "TSO_GAME_DIR": "/games/tso"])
    let installs = InstallKind.installs(in: ConfigReader(providers: [first, environment]))
    #expect(installs == [NamedInstall(kind: .game, directory: URL(fileURLWithPath: "/games/tso", isDirectory: true)),
                         NamedInstall(kind: .beta, directory: URL(fileURLWithPath: "/elsewhere/beta", isDirectory: true))])
}
