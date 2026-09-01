<p align="center">
  <img src="docs/images/clipgrid-icon.png" width="128" height="128" alt="ClipGrid icon">
</p>

<h1 align="center">ClipGrid</h1>

<p align="center">
  A fast, colorful, keyboard-first clipboard manager built natively for macOS.
</p>

<p align="center">
  <strong>Copy with ⌘C · Open with ⌥⌘C · Choose with 1–9 or A–Z</strong>
</p>

---

## Why ClipGrid?

Clipboard history should be immediate, visually understandable, and private. ClipGrid turns recent copied values into a colorful grid where every card has a stable keyboard shortcut. There is no account, cloud service, analytics SDK, or background network connection.

## Features

- **Native global shortcut** — press `⌥⌘C` from any application
- **Keyboard-first selection** — `1–9`, followed by `A–Z`
- **35 addressable clips** — every retained item always has a key
- **Multiple clipboard types** — text, links, images, files, and folders
- **Source application identity** — displays the originating app name and native icon on a best-effort basis
- **App-aware color families** — browsers, Telegram, messaging, notes, developer tools, and other apps receive consistent visual treatment
- **Instant filters** — narrow history by text, link, image, file, or originating application
- **Dynamic file types** — when viewing files, filter by extensions such as PDF, PNG, ZIP, or folders without an extension
- **URL presentation** — copied links show their host and complete URL
- **Automatic deduplication** — repeated values move to the front
- **Per-card deletion** — every card includes a trash control
- **Pause and clear controls** — available from the menu-bar icon
- **Local persistence** — history survives relaunches
- **Sensitive-type protection** — concealed, transient, and auto-generated password-manager pasteboards are ignored
- **No accessibility permission** — the global shortcut uses the native Carbon hotkey API
- **No network access** — ClipGrid operates entirely on the Mac

## Interaction

| Action | Result |
|---|---|
| Copy normally with `⌘C` | The changed pasteboard value is saved |
| Press `⌥⌘C` | Open or close the ClipGrid panel |
| Press `1–9` or `A–Z` | Copy the assigned card back to the system clipboard |
| Click a card | Copy that card |
| Click its trash icon | Remove only that clip |
| Choose a type or app filter | Reassign keys to only the visible matching cards |
| Choose a file extension | Show copied files containing that type |
| Press `Esc` | Close the panel |
| Click the menu-bar grid | Show, pause, clear, or quit |

## Source application attribution

ClipGrid reads `NSWorkspace.frontmostApplication` immediately after a pasteboard change. It stores:

- Localized application name
- Bundle identifier
- A compact 64×64 PNG representation of the application icon
- A deterministic application color family

This is best-effort attribution. If someone switches applications within the short detection window, macOS may report the newly active application instead. ClipGrid does not inspect another application's private state.

When a browser places a URL on the pasteboard, ClipGrid displays that URL and its host. When only selected page text is copied, browsers generally do not expose the containing page URL; obtaining that context would require browser-specific extensions or automation permissions, which ClipGrid deliberately avoids.

## Privacy

Clipboard contents can be sensitive, so ClipGrid follows a deliberately narrow model:

- History is written only to `~/Library/Application Support/ClipGrid/history.json`
- No telemetry or analytics
- No cloud synchronization
- No account
- No network requests
- Password-manager pasteboards marked concealed, transient, or auto-generated are not retained
- Monitoring can be paused at any time
- History can be cleared from the menu bar

See the future App Store privacy policy in `Marketing/Privacy.md` as release preparation progresses.

## Requirements

- macOS 14 Sonoma or later
- Apple Silicon or Intel Mac when compiled for the corresponding architecture
- Xcode 26 or a compatible Swift 6 toolchain for development

## Build from source

```bash
git clone https://github.com/Cicko/ClipGrid.git
cd ClipGrid
swift test
./scripts/build-app.sh
open dist/ClipGrid.app
```

The packaging script:

1. Builds an optimized Swift executable
2. Constructs a native `.app` bundle
3. Adds the application icon and metadata
4. Applies an ad-hoc local signature

For Mac App Store distribution, the project will also provide a sandboxed Xcode archive target signed with an Apple Developer team.

## Architecture

- **SwiftUI** — visual grid and cards
- **AppKit** — menu-bar integration, floating panel, pasteboard, source application icons, and keyboard event routing
- **Carbon `RegisterEventHotKey`** — global `⌥⌘C` shortcut
- **CryptoKit** — deterministic clipboard payload fingerprints
- **Swift Testing** — shortcut mapping, migration, deduplication, and app-color behavior

Important source files:

```text
Sources/ClipGrid/
├── ClipGridApp.swift
├── ClipboardGridView.swift
├── ClipboardItem.swift
├── ClipboardPanelController.swift
├── ClipboardStore.swift
├── HotKeyManager.swift
├── ShortcutMap.swift
└── SourceApplication.swift
```

## Test

```bash
swift test
```

Tests currently cover:

- Number/letter shortcut ordering
- Payload deduplication independent of source application
- Stable source application color mapping
- Migration of history written before source metadata existed

## Roadmap

- [ ] Sandboxed Xcode project and App Store archive workflow
- [ ] Launch at login
- [ ] Search and filtering
- [ ] Pin important clips
- [ ] User-configurable history length
- [ ] Optional automatic expiration
- [ ] App exclusions
- [ ] App Store screenshots and localization

## Status

ClipGrid is functional and installed as a local development release. Mac App Store preparation is the next milestone.

## Copyright

Copyright © 2026 Rudolf Cicko. All rights reserved.

The repository is public for product transparency and development visibility. No license to redistribute, rebrand, or commercially resell ClipGrid is granted unless a separate license is added or written permission is provided.
