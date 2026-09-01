# ClipGrid 1.0 Release Readiness

This checklist separates repository-complete work from tasks that require macOS, Apple credentials, commercial approval, or App Store Connect.

## Repository evidence

- [x] Public source is available at `Cicko/ClipGrid`.
- [x] No third-party Swift package dependencies.
- [x] No network client, analytics, advertising, account, or cloud-sync implementation in the source tree.
- [x] Concealed, transient, and auto-generated pasteboard types are excluded.
- [x] Global shortcut uses Carbon `RegisterEventHotKey`; no Accessibility/Input Monitoring API is used.
- [x] History is bounded to 35 addressable items.
- [x] Users can pause monitoring, delete one item, clear history, and quit.
- [x] Public privacy, support, security, metadata, pricing, and review-note drafts exist.
- [x] Current GitHub macOS CI is green.

## Repository release package

- [x] Bundle identifier: `com.rudolfcicko.clipgrid`.
- [x] Marketing version: `1.0.0`.
- [x] Build number starts at `1`.
- [x] Minimum macOS version: 14.0.
- [x] App Sandbox entitlement file exists.
- [x] Privacy manifest declares no tracking or collection.
- [x] Reproducible App Store screenshot generator exists.
- [x] Four synthetic-data screenshots exist at `2880 × 1800`.

## Must be completed on Rudolf's Mac

- [ ] Pull the release branch into `/Users/rudolfcicko/Projects/ClipGrid`.
- [ ] Create or validate the Xcode App Store application target and archive scheme.
- [ ] Select Rudolf's Apple Developer team and production signing identity.
- [ ] Confirm the final bundle identifier is registered and available.
- [ ] Run `swift test` and a Release archive with the installed Xcode toolchain.
- [ ] Inspect the signed archive's entitlements.
- [ ] Test first run, clipboard capture, filters, pins, deletion, clearing, pause, relaunch, and shortcut on a clean macOS account.
- [ ] Test permission denial/revocation behavior; ClipGrid should request no invasive permission.
- [ ] Verify sandboxed storage location and deletion behavior.
- [ ] Upload through Xcode Organizer and run the same smoke test through macOS TestFlight.

## Must be completed by Rudolf in Apple systems

- [ ] Confirm active Apple Developer Program membership.
- [ ] Accept current Apple agreements.
- [ ] Complete banking and tax setup for a paid app.
- [ ] Approve price and territories.
- [ ] Create the App Store Connect app record.
- [ ] Enter monitored App Review contact details.
- [ ] Complete age-rating and export-compliance questionnaires.
- [ ] Revalidate App Privacy answers against the uploaded build.
- [ ] Approve final metadata and screenshots.
- [ ] Submit for review.
- [ ] Release manually after approval.

## Release gate

Do not submit until the exact Apple-processed TestFlight build has passed the clean-account checklist and Rudolf has approved pricing, territories, metadata, privacy answers, and review notes.
