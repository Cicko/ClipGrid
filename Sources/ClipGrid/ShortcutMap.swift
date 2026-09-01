import Foundation

struct ShortcutMap {
    static let labels: [String] = (1...9).map(String.init) + (65...90).compactMap { UnicodeScalar($0).map(String.init) }

    static func index(for characters: String) -> Int? {
        let key = characters.uppercased()
        return labels.firstIndex(of: key)
    }
}
