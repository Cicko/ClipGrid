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
    let second = ClipboardItem(kind: .text, text: "same value", colorIndex: 8)
    let different = ClipboardItem(kind: .link, text: "same value", colorIndex: 0)

    #expect(first.fingerprint == second.fingerprint)
    #expect(first.fingerprint != different.fingerprint)
}
