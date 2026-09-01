import CryptoKit
import Foundation
import Testing
@testable import ClipGrid

@Test func shortcutMapContainsNumbersThenLetters() {
    #expect(ShortcutMap.labels.count == 35)
    #expect(ShortcutMap.labels.prefix(9) == ["1", "2", "3", "4", "5", "6", "7", "8", "9"])
    #expect(ShortcutMap.labels[9] == "A")
    #expect(ShortcutMap.labels.last == "Z")
    #expect(ShortcutMap.index(for: "c") == 11)
}

@Test func fingerprintsDeduplicateEqualPayloads() {
    let first = ClipboardItem(kind: .text, text: "same value", colorIndex: 0)
    let second = ClipboardItem(
        kind: .text,
        text: "same value",
        colorIndex: 8,
        sourceAppName: "Safari",
        sourceBundleIdentifier: "com.apple.Safari",
        isPinned: true
    )
    let different = ClipboardItem(kind: .link, text: "same value", colorIndex: 0)

    #expect(first.fingerprint == second.fingerprint)
    #expect(first.fingerprint != different.fingerprint)
}

@Test func sourceApplicationsReceiveStableBrandColors() {
    #expect(SourceApplication.colorIndex(for: "com.apple.Safari") == 3)
    #expect(SourceApplication.colorIndex(for: "com.google.Chrome") == 3)
    #expect(SourceApplication.colorIndex(for: "ru.keepcoder.Telegram") == 8)
    #expect(SourceApplication.colorIndex(for: "com.apple.Notes") == 4)
    #expect(
        SourceApplication.colorIndex(for: "com.example.Other") ==
        SourceApplication.colorIndex(for: "com.example.Other")
    )
}

@Test func legacyHistoryWithoutSourceMetadataStillDecodes() throws {
    let JSON = """
    {
      "id": "F54E1F3C-FB9D-4C44-A89B-2A135FE88906",
      "kind": "text",
      "text": "Older clip",
      "filePaths": [],
      "copiedAt": 809959108.0,
      "colorIndex": 0
    }
    """
    let item = try JSONDecoder().decode(ClipboardItem.self, from: Data(JSON.utf8))
    #expect(item.text == "Older clip")
    #expect(item.sourceAppName == nil)
    #expect(item.sourceBundleIdentifier == nil)
    #expect(item.sourceIconData == nil)
    #expect(!item.isPinned)
}

@Test func filtersMatchKindSourceAndFileExtension() {
    let safariLink = ClipboardItem(
        kind: .link,
        text: "https://example.com",
        colorIndex: 3,
        sourceAppName: "Safari",
        sourceBundleIdentifier: "com.apple.Safari"
    )
    let telegramText = ClipboardItem(
        kind: .text,
        text: "Message",
        colorIndex: 8,
        sourceAppName: "Telegram",
        sourceBundleIdentifier: "ru.keepcoder.Telegram"
    )
    let PDFAndFolder = ClipboardItem(
        kind: .files,
        text: "Score.pdf\nScores",
        filePaths: ["/tmp/Score.pdf", "/tmp/Scores"],
        colorIndex: 3,
        sourceAppName: "Finder",
        sourceBundleIdentifier: "com.apple.finder"
    )

    #expect(ClipboardFilter(kind: .link).matches(safariLink))
    #expect(!ClipboardFilter(kind: .text).matches(safariLink))
    #expect(ClipboardFilter(sourceKey: telegramText.sourceKey).matches(telegramText))
    #expect(!ClipboardFilter(sourceKey: telegramText.sourceKey).matches(safariLink))
    #expect(ClipboardFilter(kind: .files, fileExtension: "pdf").matches(PDFAndFolder))
    #expect(ClipboardFilter(kind: .files, fileExtension: ClipboardItem.noFileExtensionKey).matches(PDFAndFolder))
    #expect(!ClipboardFilter(kind: .files, fileExtension: "png").matches(PDFAndFolder))
}
