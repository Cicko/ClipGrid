import Foundation

extension ClipboardItem {
    static let unknownSourceKey = "__unknown_source__"
    static let noFileExtensionKey = "__no_extension__"

    var sourceKey: String {
        if let sourceBundleIdentifier, !sourceBundleIdentifier.isEmpty {
            return sourceBundleIdentifier
        }
        if let sourceAppName, !sourceAppName.isEmpty {
            return "name:\(sourceAppName.lowercased())"
        }
        return Self.unknownSourceKey
    }

    var fileExtensionKeys: Set<String> {
        guard kind == .files else { return [] }
        return Set(filePaths.map { path in
            let value = URL(fileURLWithPath: path).pathExtension.lowercased()
            return value.isEmpty ? Self.noFileExtensionKey : value
        })
    }
}

enum ClipKindFilter: String, CaseIterable, Identifiable {
    case all
    case text
    case link
    case image
    case files

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .text: "Text"
        case .link: "Links"
        case .image: "Images"
        case .files: "Files"
        }
    }

    var symbol: String {
        switch self {
        case .all: "square.grid.2x2"
        case .text: "text.alignleft"
        case .link: "link"
        case .image: "photo"
        case .files: "doc.on.doc"
        }
    }

    func matches(_ item: ClipboardItem) -> Bool {
        switch self {
        case .all: true
        case .text: item.kind == .text
        case .link: item.kind == .link
        case .image: item.kind == .image
        case .files: item.kind == .files
        }
    }
}

struct ClipboardFilter: Equatable {
    var kind: ClipKindFilter = .all
    var sourceKey: String?
    var fileExtension: String?
    var pinnedOnly = false

    var isActive: Bool {
        kind != .all || sourceKey != nil || fileExtension != nil || pinnedOnly
    }

    func matches(_ item: ClipboardItem) -> Bool {
        guard kind.matches(item) else { return false }
        if pinnedOnly, !item.isPinned { return false }
        if let sourceKey, item.sourceKey != sourceKey { return false }
        if let fileExtension, !item.fileExtensionKeys.contains(fileExtension) { return false }
        return true
    }
}

struct SourceFilterOption: Identifiable, Equatable {
    let id: String
    let name: String
    let iconData: Data?
}

struct FileExtensionFilterOption: Identifiable, Equatable {
    let id: String

    var title: String {
        id == ClipboardItem.noFileExtensionKey ? "Folders / no extension" : id.uppercased()
    }
}
