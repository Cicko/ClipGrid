import AppKit
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published private(set) var isPaused = false
    @Published private(set) var filter = ClipboardFilter()

    private let pasteboard = NSPasteboard.general
    private let maximumItemCount = ShortcutMap.labels.count
    private var lastChangeCount: Int
    private var monitorTask: Task<Void, Never>?
    private let historyURL: URL
    private let isDemoMode: Bool

    init(demoMode: Bool = false) {
        isDemoMode = demoMode
        lastChangeCount = pasteboard.changeCount
        historyURL = Self.makeHistoryURL()
        if demoMode {
            items = Self.ordered(DemoData.makeItems())
            isPaused = true
        } else {
            load()
            startMonitoring()
        }
    }

    func togglePaused() {
        isPaused.toggle()
    }

    var filteredItems: [ClipboardItem] {
        items.filter(filter.matches)
    }

    var isPresentingDemoData: Bool { isDemoMode }

    var sourceFilterOptions: [SourceFilterOption] {
        var options: [String: SourceFilterOption] = [:]
        for item in items {
            let key = item.sourceKey
            guard options[key] == nil else { continue }
            options[key] = SourceFilterOption(
                id: key,
                name: item.sourceAppName ?? "Unknown source",
                iconData: item.sourceIconData
            )
        }
        return options.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var fileExtensionFilterOptions: [FileExtensionFilterOption] {
        let extensions = items
            .filter { item in
                item.kind == .files && (filter.sourceKey == nil || item.sourceKey == filter.sourceKey)
            }
            .reduce(into: Set<String>()) { result, item in
                result.formUnion(item.fileExtensionKeys)
            }
        return extensions
            .map(FileExtensionFilterOption.init(id:))
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func selectKind(_ kind: ClipKindFilter) {
        filter.kind = kind
        if kind != .files {
            filter.fileExtension = nil
        }
    }

    func selectSource(_ sourceKey: String?) {
        filter.sourceKey = sourceKey
        normalizeFilter()
    }

    func selectFileExtension(_ fileExtension: String?) {
        filter.fileExtension = fileExtension
        if fileExtension != nil {
            filter.kind = .files
        }
    }

    func togglePinnedOnly() {
        filter.pinnedOnly.toggle()
    }

    func resetFilter() {
        filter = ClipboardFilter()
    }

    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        normalizeFilter()
        persist()
    }

    func togglePinned(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = items.remove(at: index)
        updated.isPinned.toggle()
        insertAtFrontOfSection(updated)
        normalizeFilter()
        persist()
    }

    func clear() {
        items.removeAll()
        resetFilter()
        persist()
    }

    func copy(_ item: ClipboardItem) {
        pasteboard.clearContents()

        switch item.kind {
        case .text, .link:
            pasteboard.setString(item.text, forType: .string)
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        case .files:
            let URLs = item.filePaths.map { URL(fileURLWithPath: $0) as NSURL }
            pasteboard.writeObjects(URLs)
        }

        lastChangeCount = pasteboard.changeCount
        moveToFront(item)
    }

    private func startMonitoring() {
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(150))
                guard let self, !self.isPaused else { continue }
                self.capturePasteboardIfChanged()
            }
        }
    }

    private func capturePasteboardIfChanged() {
        let currentChangeCount = pasteboard.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        guard var item = makeClipboardItem() else { return }
        if let existingIndex = items.firstIndex(where: { $0.fingerprint == item.fingerprint }) {
            item.isPinned = items[existingIndex].isPinned
            items.remove(at: existingIndex)
        }
        insertAtFrontOfSection(item)
        while items.count > maximumItemCount {
            if let unpinnedIndex = items.lastIndex(where: { !$0.isPinned }) {
                items.remove(at: unpinnedIndex)
            } else {
                items.removeLast()
            }
        }
        persist()
    }

    private func makeClipboardItem() -> ClipboardItem? {
        let protectedTypes = [
            "org.nspasteboard.ConcealedType",
            "org.nspasteboard.TransientType",
            "org.nspasteboard.AutoGeneratedType",
        ]
        let currentTypes = Set((pasteboard.types ?? []).map(\.rawValue))
        guard currentTypes.isDisjoint(with: protectedTypes) else { return nil }

        let sourceApplication = SourceApplication.captureFrontmost()
        let colorIndex = sourceApplication?.colorIndex ?? items.count % 10

        if let URLs = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL], !URLs.isEmpty {
            let paths = URLs.map(\.path)
            let names = URLs.map(\.lastPathComponent).joined(separator: "\n")
            return ClipboardItem(
                kind: .files,
                text: names,
                filePaths: paths,
                colorIndex: colorIndex,
                sourceAppName: sourceApplication?.name,
                sourceBundleIdentifier: sourceApplication?.bundleIdentifier,
                sourceIconData: sourceApplication?.iconData
            )
        }

        if pasteboard.availableType(from: [.png, .tiff]) != nil,
           let imageData = pngData(from: pasteboard) {
            let dimensions = NSImage(data: imageData)?.size
            let description = dimensions.map {
                "Image · \(Int($0.width)) × \(Int($0.height))"
            } ?? "Copied image"
            return ClipboardItem(
                kind: .image,
                text: description,
                imageData: imageData,
                colorIndex: colorIndex,
                sourceAppName: sourceApplication?.name,
                sourceBundleIdentifier: sourceApplication?.bundleIdentifier,
                sourceIconData: sourceApplication?.iconData
            )
        }

        guard let string = (pasteboard.string(forType: .URL) ?? pasteboard.string(forType: .string))?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !string.isEmpty else { return nil }

        let kind: ClipboardItem.Kind
        if let URL = URL(string: string), let scheme = URL.scheme?.lowercased(), ["http", "https"].contains(scheme) {
            kind = .link
        } else {
            kind = .text
        }

        return ClipboardItem(
            kind: kind,
            text: string,
            colorIndex: colorIndex,
            sourceAppName: sourceApplication?.name,
            sourceBundleIdentifier: sourceApplication?.bundleIdentifier,
            sourceIconData: sourceApplication?.iconData
        )
    }

    private func pngData(from pasteboard: NSPasteboard) -> Data? {
        if let PNGData = pasteboard.data(forType: .png) {
            return PNGData
        }
        guard let TIFFData = pasteboard.data(forType: .tiff),
              let bitmap = NSBitmapImageRep(data: TIFFData) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }

    private func moveToFront(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }), index != 0 else { return }
        let existing = items.remove(at: index)
        insertAtFrontOfSection(existing)
        persist()
    }

    private func insertAtFrontOfSection(_ item: ClipboardItem) {
        if item.isPinned {
            items.insert(item, at: 0)
        } else {
            let firstUnpinnedIndex = items.firstIndex(where: { !$0.isPinned }) ?? items.endIndex
            items.insert(item, at: firstUnpinnedIndex)
        }
    }

    private func normalizeFilter() {
        if let sourceKey = filter.sourceKey,
           !items.contains(where: { $0.sourceKey == sourceKey }) {
            filter.sourceKey = nil
        }
        if let fileExtension = filter.fileExtension,
           !items.contains(where: { $0.fileExtensionKeys.contains(fileExtension) }) {
            filter.fileExtension = nil
        }
        if filter.pinnedOnly, !items.contains(where: \.isPinned) {
            filter.pinnedOnly = false
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: historyURL),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = Array(Self.ordered(decoded).prefix(maximumItemCount))
    }

    private func persist() {
        guard !isDemoMode else { return }
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? FileManager.default.createDirectory(
            at: historyURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: historyURL, options: .atomic)
    }

    private static func makeHistoryURL() -> URL {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return applicationSupport
            .appendingPathComponent("ClipGrid", isDirectory: true)
            .appendingPathComponent("history.json")
    }

    private static func ordered(_ values: [ClipboardItem]) -> [ClipboardItem] {
        values.sorted { first, second in
            if first.isPinned != second.isPinned { return first.isPinned }
            return first.copiedAt > second.copiedAt
        }
    }
}
