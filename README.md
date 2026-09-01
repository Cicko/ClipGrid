# ClipGrid

A native, private clipboard manager for macOS.

## Interaction

- Copy normally with **⌘C**. ClipGrid monitors macOS's system pasteboard and saves changed text, links, images, and file references.
- Each new clip records the foreground source app on a best-effort basis and shows its native app icon. Known browsers, Telegram, messaging, notes, and developer apps also receive a consistent color family.
- Press **⌥⌘C** from any application to open the colorful clipboard grid.
- Press **1–9**, followed by **A–Z**, to copy the assigned card back to the system clipboard.
- Click a card to copy it, or use its trash button to delete it.
- Press **Esc** or click outside the panel to close it.

Clip history is stored locally at `~/Library/Application Support/ClipGrid/history.json`. The app makes no network requests.

Source attribution uses `NSWorkspace.frontmostApplication` immediately after a pasteboard change. It does not inspect another app's private state. A copied URL displays its host, but ClipGrid cannot determine the containing web page when the browser does not place that context on the pasteboard.

## Build and run

```bash
swift test
./scripts/build-app.sh
open dist/ClipGrid.app
```

ClipGrid is a menu-bar app. Use its grid icon to show history, pause monitoring, clear history, or quit.
