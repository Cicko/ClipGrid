# ClipGrid App Review Notes

## Summary

ClipGrid is a local-only macOS clipboard-history utility. It monitors changes to the system pasteboard while monitoring is enabled and stores up to 35 recent supported items in its sandboxed local Application Support container.

No account or demo credentials are required.

## Review steps

1. Launch ClipGrid. A grid icon appears in the macOS menu bar.
2. Copy a plain-text value in another application with `⌘C`.
3. Press `⌥⌘C` to open ClipGrid.
4. Confirm the copied value appears in the grid.
5. Press the card's displayed key (`1–9`, then `A–Z`) or click the card to copy it back to the pasteboard.
6. Use the type and source-app filters near the top of the panel.
7. Pin or delete an item using the controls on its card.
8. Open the menu-bar menu to pause monitoring or clear all history.

## Permissions

ClipGrid does **not** request Accessibility, Input Monitoring, Automation, Full Disk Access, Contacts, Calendar, Photos, Camera, Microphone, or Location permission.

The global shortcut uses Carbon `RegisterEventHotKey`, a native macOS hotkey API. ClipGrid does not inspect, log, or retain unrelated keystrokes.

## Privacy and networking

- Clipboard history is processed and stored locally.
- There is no account, analytics, advertising, tracking, cloud sync, or developer-operated service.
- The application declares no outbound or inbound network entitlement.
- Pasteboards marked as concealed, transient, or auto-generated are skipped on a best-effort basis.
- Users can pause monitoring, delete individual items, clear all history, or quit at any time.

## Supported data

ClipGrid supports text, HTTP/HTTPS links, images, and local file/folder references. Source-application name, bundle identifier, and a small icon representation are stored locally for best-effort attribution.

## Reviewer contact

**User action before submission:** Enter a monitored name, telephone number, and email address in App Store Connect. Do not publish credentials in this repository.

## Final verification

Replace any statement above that differs from the exact uploaded build. Build number, macOS version, signing, sandbox entitlements, and network behavior must be rechecked after Apple processes the upload.
