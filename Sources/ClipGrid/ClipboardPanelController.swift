import AppKit
import SwiftUI

final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class ClipboardPanelController: NSWindowController, NSWindowDelegate {
    private let store: ClipboardStore
    private var keyMonitor: Any?

    init(store: ClipboardStore) {
        self.store = store

        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 1080, height: 680),
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "ClipGrid"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.animationBehavior = .utilityWindow
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.closeButton)?.isHidden = true

        super.init(window: panel)
        panel.delegate = self

        panel.contentView = NSHostingView(
            rootView: ClipboardGridView(
                store: store,
                onChoose: { [weak self, weak store] item in
                    store?.copy(item)
                    self?.hide()
                },
                onClose: { [weak self] in self?.hide() }
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isVisible: Bool { window?.isVisible == true }

    func show() {
        guard let panel = window else { return }
        position(panel)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKey()
        installKeyMonitor()
    }

    func hide() {
        removeKeyMonitor()
        window?.orderOut(nil)
    }

    func windowDidResignKey(_ notification: Notification) {
        hide()
    }

    private func position(_ panel: NSWindow) {
        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let frame = screen?.visibleFrame else {
            panel.center()
            return
        }

        let width = min(1080, frame.width - 36)
        let height = min(680, frame.height - 70)
        panel.setContentSize(NSSize(width: width, height: height))
        let origin = NSPoint(
            x: frame.midX - width / 2,
            y: frame.maxY - height - 34
        )
        panel.setFrameOrigin(origin)
    }

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 {
                self.hide()
                return nil
            }

            guard event.modifierFlags.intersection([.command, .control, .option]).isEmpty,
                  let characters = event.charactersIgnoringModifiers,
                  let index = ShortcutMap.index(for: characters),
                  index < self.store.items.count else { return event }

            self.store.copy(self.store.items[index])
            self.hide()
            return nil
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
    }
}
