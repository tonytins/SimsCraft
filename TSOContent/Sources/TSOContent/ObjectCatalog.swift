import Foundation
import TSOFiles
#if canImport(FoundationXML)
import FoundationXML
#endif

/// `packingslips/catalog.xml`: the objects buy mode offers, by GUID.
///
/// Ports the table read in FreeSO's `WorldObjectCatalog.Init`. Each `P` element is a
/// catalog entry with a GUID (`g`, hexadecimal), a category (`s`), a price (`p`), and a
/// display name (`n`). A negative category means the entry isn't in the catalog (a
/// multi-tile part, a cursor, and so on), and is left out, as FreeSO leaves it out.
///
/// FreeSO also merges `Content/Objects/catalog_downloads.xml` when FreeSO's own content
/// folder has one. This type reads one file; a caller that wants the downloads too reads
/// a second catalog and joins them.
public struct ObjectCatalog: Sendable, Equatable {
    public struct Entry: Sendable, Equatable {
        public var guid: UInt32
        /// `s`, the buy-mode category; 0 and up.
        public var category: Int8
        public var price: UInt32
        public var name: String
    }

    /// The entries with a category of 0 or more, in document order.
    public let entries: [Entry]
    /// Every `P` entry read, including the ones with a negative category.
    public let totalEntries: Int

    /// Reads a catalog.
    ///
    /// - Throws: ``ContentError/invalidCatalog(_:)`` if the XML is malformed, or an entry lacks
    ///   a GUID, category, price, or name, or one doesn't parse.
    public init(bytes: Data) throws(ContentError) {
        if let problem = XMLWellFormedness.problem(in: bytes) {
            throw .invalidCatalog("malformed XML: \(problem)")
        }
        let elements: [XMLNode]
        do {
            elements = try XMLDocument(data: bytes).nodes(forXPath: "//P")
        } catch {
            throw .invalidCatalog("malformed XML: \(error)")
        }
        var entries: [Entry] = []
        for case let (index, element as XMLElement) in elements.enumerated() {
            if let entry = try Self.entry(element, index: index) { entries.append(entry) }
        }
        self.entries = entries
        self.totalEntries = elements.count
    }

    private static func entry(_ element: XMLElement, index: Int) throws(ContentError) -> Entry? {
        func text(_ name: String) throws(ContentError) -> String {
            guard let value = element.attribute(forName: name)?.stringValue else {
                throw .invalidCatalog("entry \(index) has no \"\(name)\"")
            }
            return value
        }
        // .NET's Convert.ToSByte(value) and Convert.ToUInt32(value, 16): an optional 0x prefix
        // for the GUID, an optional sign for the category, and decimal prices.
        let rawGUID = try text("g")
        let hexDigits = rawGUID.lowercased().hasPrefix("0x") ? String(rawGUID.dropFirst(2)) : rawGUID
        guard let guid = UInt32(hexDigits, radix: 16) else {
            throw .invalidCatalog("entry \(index) has an invalid GUID \"\(rawGUID)\"")
        }
        let rawCategory = try text("s"), rawPrice = try text("p")
        guard let category = Int8(rawCategory) else {
            throw .invalidCatalog("entry \(index) has an invalid category \"\(rawCategory)\"")
        }
        guard category >= 0 else { return nil }
        guard let price = UInt32(rawPrice) else {
            throw .invalidCatalog("entry \(index) has an invalid price \"\(rawPrice)\"")
        }
        return Entry(guid: guid, category: category, price: price, name: try text("n"))
    }
}
