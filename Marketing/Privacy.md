# Privacy Policy

**Last updated: 1 September 2026**

ClipGrid is designed to operate locally on your Mac.

## Data processed

ClipGrid processes clipboard values that macOS places on the system pasteboard while monitoring is enabled. Supported values include text, links, images, and file references. For best-effort source attribution, ClipGrid may also store the foreground application's localized name, bundle identifier, and a small local copy of its application icon.

## Storage

Clipboard history is stored only on the user's Mac in ClipGrid's Application Support directory. A sandboxed Mac App Store build stores this directory inside ClipGrid's macOS app container. ClipGrid does not operate a server and does not transmit clipboard history to the developer or any third party.

## Data not collected

ClipGrid does not include:

- User accounts
- Analytics or telemetry
- Advertising SDKs
- Tracking
- Cloud synchronization
- Developer-operated network services

Pasteboards marked by their originating application as concealed, transient, or auto-generated are excluded from history.

## User control

Users can pause monitoring, delete individual clips, clear all history, or quit ClipGrid at any time. Uninstalling the application does not automatically delete its Application Support history. The exact storage path depends on whether ClipGrid is installed as a sandboxed App Store build or built directly from source.

## Contact

For privacy questions, use the [ClipGrid GitHub repository](https://github.com/Cicko/ClipGrid) without including private clipboard content. Security-sensitive reports should follow [`SECURITY.md`](https://github.com/Cicko/ClipGrid/blob/main/SECURITY.md) rather than a public issue.
