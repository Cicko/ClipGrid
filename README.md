# ClipGrid

A native, private clipboard manager for macOS.

## Interaction

- Copy normally with **⌘C**. ClipGrid monitors macOS's system pasteboard and saves changed text, links, images, and file references.
- Press **⌥⌘C** from any application to open the colorful clipboard grid.
- Press **1–9**, followed by **A–Z**, to copy the assigned card back to the system clipboard.
- Click a card to copy it, or use its trash button to delete it.
- Press **Esc** or click outside the panel to close it.

Clip history is stored locally at `~/Library/Application Support/ClipGrid/history.json`. The app makes no network requests.

## Build and run

```bash
swift test
./scripts/build-app.sh
open dist/ClipGrid.app
```

ClipGrid is a menu-bar app. Use its grid icon to show history, pause monitoring, clear history, or quit.
