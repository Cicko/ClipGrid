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
    let sourceAppName: String?
    let sourceBundleIdentifier: String?
    let sourceIconData: Data?
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        text: String,
        imageData: Data? = nil,
        filePaths: [String] = [],
        copiedAt: Date = Date(),
        colorIndex: Int,
        sourceAppName: String? = nil,
        sourceBundleIdentifier: String? = nil,
        sourceIconData: Data? = nil,
        isPinned: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.text = text
        self.imageData = imageData
        self.filePaths = filePaths
        self.copiedAt = copiedAt
        self.colorIndex = colorIndex
        self.sourceAppName = sourceAppName
        self.sourceBundleIdentifier = sourceBundleIdentifier
        self.sourceIconData = sourceIconData
        self.isPinned = isPinned
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

    private enum CodingKeys: String, CodingKey {
        case id, kind, text, imageData, filePaths, copiedAt, colorIndex
        case sourceAppName, sourceBundleIdentifier, sourceIconData, isPinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        kind = try container.decode(Kind.self, forKey: .kind)
        text = try container.decode(String.self, forKey: .text)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        filePaths = try container.decode([String].self, forKey: .filePaths)
        copiedAt = try container.decode(Date.self, forKey: .copiedAt)
        colorIndex = try container.decode(Int.self, forKey: .colorIndex)
        sourceAppName = try container.decodeIfPresent(String.self, forKey: .sourceAppName)
        sourceBundleIdentifier = try container.decodeIfPresent(String.self, forKey: .sourceBundleIdentifier)
        sourceIconData = try container.decodeIfPresent(Data.self, forKey: .sourceIconData)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind, forKey: .kind)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(filePaths, forKey: .filePaths)
        try container.encode(copiedAt, forKey: .copiedAt)
        try container.encode(colorIndex, forKey: .colorIndex)
        try container.encodeIfPresent(sourceAppName, forKey: .sourceAppName)
        try container.encodeIfPresent(sourceBundleIdentifier, forKey: .sourceBundleIdentifier)
        try container.encodeIfPresent(sourceIconData, forKey: .sourceIconData)
        try container.encode(isPinned, forKey: .isPinned)
    }
}
