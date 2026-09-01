import AppKit
import SwiftUI

@main
struct ClipGridApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: ClipboardStore!
    private var panelController: ClipboardPanelController!
    private var hotKeyManager: HotKeyManager!
    private var statusItem: NSStatusItem!
    private var pauseMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let arguments = ProcessInfo.processInfo.arguments
        let demoMode = arguments.contains("--demo")
        store = ClipboardStore(demoMode: demoMode)
        if demoMode {
            applyDemoFilters(from: arguments)
        }
        panelController = ClipboardPanelController(store: store)
        hotKeyManager = HotKeyManager { [weak self] in
            self?.togglePanel()
        }
        configureStatusItem()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.panelController.show()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager.unregister()
    }

    @objc private func showHistory() {
        panelController.show()
    }

    @objc private func toggleMonitoring() {
        store.togglePaused()
        updatePauseMenuItem()
    }

    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear clipboard history?"
        alert.informativeText = "This removes every saved clip from this Mac. The system clipboard is not changed."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear History")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        store.clear()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func togglePanel() {
        if panelController.isVisible {
            panelController.hide()
        } else {
            panelController.show()
        }
    }

    private func applyDemoFilters(from arguments: [String]) {
        if let value = argumentValue(named: "--demo-kind", in: arguments),
           let kind = ClipKindFilter(rawValue: value) {
            store.selectKind(kind)
        }
        if let source = argumentValue(named: "--demo-source", in: arguments) {
            store.selectSource(source)
        }
        if let fileExtension = argumentValue(named: "--demo-extension", in: arguments) {
            store.selectFileExtension(fileExtension)
        }
    }

    private func argumentValue(named name: String, in arguments: [String]) -> String? {
        let prefix = "\(name)="
        return arguments.first(where: { $0.hasPrefix(prefix) }).map {
            String($0.dropFirst(prefix.count))
        }
    }

    private func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "square.grid.3x3.fill",
                accessibilityDescription: "ClipGrid"
            )
            button.image?.isTemplate = true
            button.toolTip = "ClipGrid · ⌥⌘C"
        }

        let menu = NSMenu()
        let showItem = NSMenuItem(
            title: "Show ClipGrid",
            action: #selector(showHistory),
            keyEquivalent: ""
        )
        showItem.target = self
        menu.addItem(showItem)

        let shortcutItem = NSMenuItem(title: "Global shortcut: ⌥⌘C", action: nil, keyEquivalent: "")
        shortcutItem.isEnabled = false
        menu.addItem(shortcutItem)
        menu.addItem(.separator())

        pauseMenuItem = NSMenuItem(
            title: "Pause Monitoring",
            action: #selector(toggleMonitoring),
            keyEquivalent: ""
        )
        pauseMenuItem.target = self
        menu.addItem(pauseMenuItem)

        let clearItem = NSMenuItem(
            title: "Clear History…",
            action: #selector(clearHistory),
            keyEquivalent: ""
        )
        clearItem.target = self
        menu.addItem(clearItem)
        menu.addItem(.separator())

        let privacyItem = NSMenuItem(title: "Stored locally · No network access", action: nil, keyEquivalent: "")
        privacyItem.isEnabled = false
        menu.addItem(privacyItem)

        let quitItem = NSMenuItem(
            title: "Quit ClipGrid",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func updatePauseMenuItem() {
        pauseMenuItem.title = store.isPaused ? "Resume Monitoring" : "Pause Monitoring"
    }
}
