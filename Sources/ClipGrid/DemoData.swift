import AppKit
import Foundation

@MainActor
enum DemoData {
    static func makeItems() -> [ClipboardItem] {
        let now = Date()
        return [
            item(
                kind: .link,
                text: "https://developer.apple.com/design/human-interface-guidelines/",
                appName: "Safari",
                bundleIdentifier: "com.apple.Safari",
                isPinned: true,
                secondsAgo: 18,
                now: now
            ),
            item(
                kind: .image,
                text: "Image · 640 × 360",
                imageData: makePreviewImage(style: 0),
                appName: "Photos",
                bundleIdentifier: "com.apple.Photos",
                isPinned: true,
                secondsAgo: 42,
                now: now
            ),
            item(
                kind: .text,
                text: "Rehearsal moved to 18:30. Bring the Rachmaninoff score 🎹",
                appName: "Telegram",
                bundleIdentifier: "ru.keepcoder.Telegram",
                secondsAgo: 65,
                now: now
            ),
            item(
                kind: .text,
                text: "let shortcut = HotKey(modifiers: [.option, .command], key: .c)",
                appName: "Xcode",
                bundleIdentifier: "com.apple.dt.Xcode",
                secondsAgo: 130,
                now: now
            ),
            item(
                kind: .files,
                text: "Moonlight-Sonata.pdf\ncover-art.png",
                filePaths: ["/Demo/Moonlight-Sonata.pdf", "/Demo/cover-art.png"],
                appName: "Finder",
                bundleIdentifier: "com.apple.finder",
                secondsAgo: 190,
                now: now
            ),
            item(
                kind: .text,
                text: "Launch checklist\n• App Store screenshots\n• Privacy policy\n• Release notes",
                appName: "Notes",
                bundleIdentifier: "com.apple.Notes",
                isPinned: true,
                secondsAgo: 270,
                now: now
            ),
            item(
                kind: .image,
                text: "Image · 640 × 360",
                imageData: makePreviewImage(style: 1),
                appName: "Preview",
                bundleIdentifier: "com.apple.Preview",
                secondsAgo: 420,
                now: now
            ),
            item(
                kind: .text,
                text: "The first beta feels incredibly fast — keyboard selection is perfect.",
                appName: "Mail",
                bundleIdentifier: "com.apple.mail",
                secondsAgo: 620,
                now: now
            ),
            item(
                kind: .link,
                text: "https://github.com/Cicko/ClipGrid",
                appName: "Safari",
                bundleIdentifier: "com.apple.Safari",
                secondsAgo: 840,
                now: now
            ),
            item(
                kind: .files,
                text: "ClipGrid-Press-Kit.zip",
                filePaths: ["/Demo/ClipGrid-Press-Kit.zip"],
                appName: "Finder",
                bundleIdentifier: "com.apple.finder",
                secondsAgo: 1_020,
                now: now
            ),
            item(
                kind: .text,
                text: "Meet at Café Savoy after the recording session?",
                appName: "Messages",
                bundleIdentifier: "com.apple.MobileSMS",
                secondsAgo: 1_300,
                now: now
            ),
        ]
    }

    private static func item(
        kind: ClipboardItem.Kind,
        text: String,
        imageData: Data? = nil,
        filePaths: [String] = [],
        appName: String,
        bundleIdentifier: String,
        isPinned: Bool = false,
        secondsAgo: TimeInterval,
        now: Date
    ) -> ClipboardItem {
        ClipboardItem(
            kind: kind,
            text: text,
            imageData: imageData,
            filePaths: filePaths,
            copiedAt: now.addingTimeInterval(-secondsAgo),
            colorIndex: SourceApplication.colorIndex(
                for: bundleIdentifier,
                appName: appName
            ),
            sourceAppName: appName,
            sourceBundleIdentifier: bundleIdentifier,
            sourceIconData: SourceApplication.iconData(forBundleIdentifier: bundleIdentifier),
            isPinned: isPinned
        )
    }

    private static func makePreviewImage(style: Int) -> Data? {
        let width = 640
        let height = 360
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }

        bitmap.size = NSSize(width: width, height: height)
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        NSGraphicsContext.current = context

        let bounds = NSRect(x: 0, y: 0, width: width, height: height)
        let colors: [NSColor] = style == 0 ? [
            NSColor(calibratedRed: 0.11, green: 0.42, blue: 0.58, alpha: 1),
            NSColor(calibratedRed: 0.42, green: 0.80, blue: 0.74, alpha: 1),
        ] : [
            NSColor(calibratedRed: 0.42, green: 0.36, blue: 0.96, alpha: 1),
            NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.57, alpha: 1),
        ]
        NSGradient(colors: colors)?.draw(in: bounds, angle: 18)

        if style == 0 {
            NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.54, alpha: 0.95).setFill()
            NSBezierPath(ovalIn: NSRect(x: 460, y: 225, width: 82, height: 82)).fill()
            let mountains = NSBezierPath()
            mountains.move(to: NSPoint(x: 0, y: 55))
            mountains.line(to: NSPoint(x: 150, y: 240))
            mountains.line(to: NSPoint(x: 255, y: 125))
            mountains.line(to: NSPoint(x: 365, y: 285))
            mountains.line(to: NSPoint(x: 520, y: 95))
            mountains.line(to: NSPoint(x: 640, y: 205))
            mountains.line(to: NSPoint(x: 640, y: 0))
            mountains.line(to: NSPoint(x: 0, y: 0))
            mountains.close()
            NSColor.white.withAlphaComponent(0.72).setFill()
            mountains.fill()
        } else {
            NSColor.white.withAlphaComponent(0.2).setFill()
            NSBezierPath(ovalIn: NSRect(x: 405, y: 75, width: 185, height: 185)).fill()
            NSBezierPath(roundedRect: NSRect(x: 55, y: 80, width: 300, height: 200), xRadius: 35, yRadius: 35).fill()
        }
        context.flushGraphics()
        return bitmap.representation(using: .png, properties: [:])
    }
}
