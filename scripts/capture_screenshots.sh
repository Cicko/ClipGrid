#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/ClipGrid.app"
INSTALLED_APP="$HOME/Applications/ClipGrid.app"
OUTPUT="$ROOT/docs/screenshots"
SETTLE_SECONDS="${CLIPGRID_SCREENSHOT_DELAY:-8}"

restore_normal_app() {
  pkill -f '/ClipGrid.app/Contents/MacOS/ClipGrid' 2>/dev/null || true
  if [ -d "$INSTALLED_APP" ]; then
    open "$INSTALLED_APP"
  fi
}
trap restore_normal_app EXIT

stop_clipgrid() {
  pkill -f '/ClipGrid.app/Contents/MacOS/ClipGrid' 2>/dev/null || true
  for _ in {1..30}; do
    if ! pgrep -f '/ClipGrid.app/Contents/MacOS/ClipGrid' >/dev/null; then
      return
    fi
    sleep 0.1
  done
}

mkdir -p "$OUTPUT"
"$ROOT/scripts/build-app.sh" >/dev/null

capture() {
  local filename="$1"
  shift

  stop_clipgrid
  open -n "$APP" --args --demo "$@"
  sleep 2

  local app_pid
  app_pid="$(pgrep -n -f "$APP/Contents/MacOS/ClipGrid")"

  osascript -e 'tell application "System Events"' \
    -e 'tell process "ClipGrid"' \
    -e 'if (count of windows) is 0 then' \
    -e 'keystroke "c" using {command down, option down}' \
    -e 'delay 0.5' \
    -e 'end if' \
    -e 'set frontmost to true' \
    -e 'if (count of windows) > 0 then set position of window 1 to {100, 100}' \
    -e 'end tell' \
    -e 'end tell'

  # Wait for the panel, gradients, app icons, and image previews to finish drawing.
  sleep "$SETTLE_SECONDS"

  rm -f "$OUTPUT/$filename"
  local captured=false
  local window_id=''
  for _ in {1..3}; do
    window_id="$(CLIPGRID_PID="$app_pid" swift "$ROOT/scripts/window_id.swift")"
    if [ -n "$window_id" ] && screencapture -x -l "$window_id" "$OUTPUT/$filename"; then
      captured=true
      break
    fi
    sleep 2
  done
  if [ "$captured" != true ]; then
    echo "Could not capture ClipGrid window $window_id" >&2
    return 1
  fi
  "$ROOT/scripts/optimize_screenshots.py" "$OUTPUT/$filename"
}

capture '01-overview.png'
capture '02-safari-links-filter.png' '--demo-kind=link' '--demo-source=com.apple.Safari'
capture '03-finder-pdf-filter.png' '--demo-kind=files' '--demo-source=com.apple.finder' '--demo-extension=pdf'
capture '04-images-filter.png' '--demo-kind=image'

echo "Screenshots written to $OUTPUT"
