# Support

## Before opening an issue

1. Confirm ClipGrid is running and its grid icon is visible in the macOS menu bar.
2. Try opening history with `⌥⌘C`.
3. Confirm monitoring is not paused in the menu-bar menu.
4. Copy a new plain-text value with `⌘C` and wait briefly.
5. Relaunch ClipGrid.

## Reporting a problem

Open a GitHub issue and include:

- macOS version
- Mac model and processor architecture
- ClipGrid version
- Steps to reproduce
- Expected and actual behavior

Never paste private clipboard history, passwords, authentication tokens, private file paths, or personal conversations into a public issue.

## Common behavior

### The wrong source app is shown

Source attribution is best-effort. If you switch applications immediately after copying, macOS may report the newly foregrounded app.

### A password is not appearing

This can be intentional. ClipGrid skips concealed and transient pasteboards used by supporting password managers.

### The web page address is absent

When browsers copy selected text, they generally do not include the containing page URL. ClipGrid only displays a URL when the browser places it on the pasteboard.
