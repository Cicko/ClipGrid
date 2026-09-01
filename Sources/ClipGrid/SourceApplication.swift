import AppKit
import Foundation

struct SourceApplication {
    let name: String
    let bundleIdentifier: String?
    let iconData: Data?
    let colorIndex: Int

    @MainActor
    static func captureFrontmost() -> SourceApplication? {
        guard let application = NSWorkspace.shared.frontmostApplication else { return nil }
        let bundleIdentifier = application.bundleIdentifier
        guard bundleIdentifier != Bundle.main.bundleIdentifier,
              bundleIdentifier != "com.rudolfcicko.clipgrid" else { return nil }

        let name = application.localizedName ?? bundleIdentifier ?? "Unknown app"
        return SourceApplication(
            name: name,
            bundleIdentifier: bundleIdentifier,
            iconData: application.icon.flatMap(iconPNGData),
            colorIndex: colorIndex(for: bundleIdentifier, appName: name)
        )
    }

    static func colorIndex(for bundleIdentifier: String?, appName: String = "") -> Int {
        let identifier = (bundleIdentifier ?? appName).lowercased()
        let knownApps: [(fragments: [String], color: Int)] = [
            (["safari", "chrome", "chromium", "edge", "arc", "brave"], 3),
            (["firefox"], 7),
            (["telegram"], 8),
            (["slack", "discord"], 6),
            (["notes", "notion"], 4),
            (["messages", "whatsapp", "signal"], 1),
            (["mail", "outlook", "spark"], 3),
            (["finder", "files"], 3),
            (["xcode", "visualstudio", "vscode", "zed"], 8),
            (["terminal", "iterm", "warp"], 9),
            (["pages", "word", "textedit"], 0),
        ]

        if let match = knownApps.first(where: { entry in
            entry.fragments.contains(where: identifier.contains)
        }) {
            return match.color
        }

        let stableValue = identifier.utf8.reduce(UInt32(2_166_136_261)) {
            ($0 ^ UInt32($1)) &* 16_777_619
        }
        return Int(stableValue % 10)
    }

    @MainActor
    static func iconData(forBundleIdentifier bundleIdentifier: String) -> Data? {
        guard let applicationURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: bundleIdentifier
        ) else { return nil }
        return iconPNGData(NSWorkspace.shared.icon(forFile: applicationURL.path))
    }

    @MainActor
    private static func iconPNGData(_ image: NSImage) -> Data? {
        let pixelSize = 64
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }

        bitmap.size = NSSize(width: pixelSize, height: pixelSize)
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }
        NSGraphicsContext.current = context
        image.draw(
            in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
        context.flushGraphics()
        return bitmap.representation(using: .png, properties: [:])
    }
}
