#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/ClipGrid.app"
CODESIGN_IDENTITY="${CLIPGRID_CODESIGN_IDENTITY:--}"

cd "$ROOT"
swift build -c release
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/.build/release/ClipGrid" "$APP/Contents/MacOS/ClipGrid"
cp "$ROOT/Support/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/Support/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/Support/PrivacyInfo.xcprivacy" "$APP/Contents/Resources/PrivacyInfo.xcprivacy"
chmod +x "$APP/Contents/MacOS/ClipGrid"
codesign \
    --force \
    --options runtime \
    --sign "$CODESIGN_IDENTITY" \
    --entitlements "$ROOT/Support/ClipGrid.entitlements" \
    "$APP"

codesign --verify --deep --strict "$APP"

echo "$APP"
