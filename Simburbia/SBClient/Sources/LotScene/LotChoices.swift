import Foundation

/// A lot the login window offers to play.
public struct LotChoice: Sendable, Equatable {
    /// The lot's file name without `.xml`.
    public var name: String
    public var url: URL
    /// Whether it's in the player's own folder rather than one Simburbia ships.
    public var isPlayers: Bool
}

/// The lots the login window's Start tab lists: Simburbia's own (`Lots`), the mock lots when the
/// client runs on MockInstall (`MockInstall/Lots`), then the player's (`Lots` in the user folder,
/// ``TSOContent/UserFolderLocator``). Each folder's lots are sorted by name, ignoring letter case.
/// A folder that doesn't exist or can't be listed adds none.
public enum LotChoices {
    public static func lots(simburbiaFolder: URL, includesMockLots: Bool, userFolder: URL?) -> [LotChoice] {
        var folders: [(URL, Bool)] = [(simburbiaFolder.appendingPathComponent("Lots", isDirectory: true), false)]
        if includesMockLots { folders.append((simburbiaFolder.appendingPathComponent("MockInstall/Lots", isDirectory: true), false)) }
        if let userFolder { folders.append((userFolder.appendingPathComponent("Lots", isDirectory: true), true)) }
        return folders.flatMap { folder, isPlayers -> [LotChoice] in
            let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
            return files.filter { $0.pathExtension.lowercased() == "xml" }
                .map { LotChoice(name: $0.deletingPathExtension().lastPathComponent, url: $0, isPlayers: isPlayers) }
                .sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
}
