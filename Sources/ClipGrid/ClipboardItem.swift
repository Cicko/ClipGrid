import CryptoKit
import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case text
        case link
        case image
        case files

        var label: String {
            switch self {
            case .text: "TEXT"
            case .link: "LINK"
            case .image: "IMAGE"
            case .files: "FILES"
            }
        }

        var symbol: String {
            switch self {
            case .text: "text.alignleft"
            case .link: "link"
            case .image: "photo"
            case .files: "doc.on.doc"
            }
        }
    }

    let id: UUID
    let kind: Kind
    let text: String
    let imageData: Data?
    let filePaths: [String]
    let copiedAt: Date
    let colorIndex: Int

    init(
        id: UUID = UUID(),
        kind: Kind,
        text: String,
        imageData: Data? = nil,
        filePaths: [String] = [],
        copiedAt: Date = Date(),
        colorIndex: Int
    ) {
        self.id = id
        self.kind = kind
        self.text = text
        self.imageData = imageData
        self.filePaths = filePaths
        self.copiedAt = copiedAt
        self.colorIndex = colorIndex
    }

    var fingerprint: String {
        var payload = Data(kind.rawValue.utf8)
        payload.append(Data(text.utf8))
        payload.append(imageData ?? Data())
        payload.append(Data(filePaths.joined(separator: "\u{0}").utf8))
        return SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()
    }

    var accessibilitySummary: String {
        switch kind {
        case .image: "Copied image"
        case .files: "\(filePaths.count) copied file\(filePaths.count == 1 ? "" : "s")"
        case .link, .text: text
        }
    }
}
