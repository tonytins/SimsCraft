import Foundation

/// The client's interface, as UIScript documents in an `Interface` folder (Hudini's XML; see
/// `docs/sb/client.md`): each document's file name, and the controls the client fills, reads, or
/// draws into, so a document missing one is refused when the client starts, not found blank.
///
/// The folder sits beside `Lots` and `MockInstall`, wherever ``ClientOptions/simburbiaFolder(executableFolder:sourceFolder:)``
/// finds them.
public enum InterfaceDocuments {
    public static let folderName = "Interface"

    /// The documents, by file name without `.xml`, with the controls each must have.
    public static let required: [(document: String, controls: [String])] = [
        ("topbar", ["bar", "lotName", "speed0", "speed1", "speed2", "clock", "floor", "errors", "objects", "help"]),
        ("help", []),
        ("momi", ["log", "empty", "input"]),
        ("inspector", ["lines"]),
        ("login-start", ["preview", "selectLot", "lots", "delete", "new", "play"]),
        ("login-join", ["servers", "address", "port", "name", "password", "delete", "new"]),
    ]

    /// Where a document is, in a Simburbia folder.
    public static func url(of document: String, in simburbiaFolder: URL) -> URL {
        simburbiaFolder.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent("\(document).xml")
    }
}
