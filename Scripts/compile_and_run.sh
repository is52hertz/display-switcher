#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
APP_NAME=DisplaySwitcher

pkill -x "$APP_NAME" 2>/dev/null || true

swift test --package-path "$ROOT"
"$ROOT/Scripts/package_app.sh" release
open "$ROOT/${APP_NAME}.app"

for _ in {1..10}; do
    if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
        echo "OK: $APP_NAME is running."
        exit 0
    fi
    sleep 0.4
done

echo "ERROR: $APP_NAME exited immediately." >&2
exit 1
