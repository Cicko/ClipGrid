# Changelog

All notable changes to ClipGrid will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and ClipGrid uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Release preparation

- Added App Sandbox and privacy-manifest resources.
- Added reproducible Mac App Store screenshot generation.
- Added App Store metadata, review notes, privacy audit, pricing research, and release checklists.

## 1.0.0 - Unreleased

### Added

- Global `⌥⌘C` shortcut using the native macOS hotkey API.
- Keyboard-addressable clipboard history using `1–9`, then `A–Z`.
- Support for text, HTTP/HTTPS links, images, files, and folders.
- Filters by content type and source application, with file clips narrowed by contained extension.
- Best-effort source-application name, icon, and color attribution.
- Persistent pinned clips.
- Per-item deletion, complete-history clearing, and monitoring pause control.
- Local persistence across relaunches.
- Automatic payload deduplication.
- Exclusion of pasteboards marked concealed, transient, or auto-generated.
- Privacy-safe in-memory demo mode for repository and App Store screenshots.

### Privacy

- No account, analytics, advertising, tracking, cloud sync, or developer-operated network service.
- Clipboard history remains in ClipGrid's local Application Support directory.
- No Accessibility or Input Monitoring permission is required for the global shortcut.

[Unreleased]: https://github.com/Cicko/ClipGrid/commits/main
