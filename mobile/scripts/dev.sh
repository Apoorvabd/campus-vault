#!/usr/bin/env bash
# Run the app against the backend on this Mac (port 5000).
#
#   ./scripts/dev.sh                 # runs on the connected device
#   ./scripts/dev.sh -d <device-id>  # any flutter run arguments work
#
# Before launching, every connected Android device/emulator gets
# `adb reverse tcp:5000 tcp:5000`, so the app's default base URL
# (http://localhost:5000/api/v1) reaches the backend whatever the Mac's IP is.
set -euo pipefail
cd "$(dirname "$0")/.."

PORT="${BACKEND_PORT:-5000}"

if command -v adb >/dev/null 2>&1; then
  for serial in $(adb devices | awk 'NR>1 && $2=="device" {print $1}'); do
    if adb -s "$serial" reverse "tcp:$PORT" "tcp:$PORT" >/dev/null 2>&1; then
      echo "adb reverse set for $serial (localhost:$PORT -> this Mac)"
    fi
  done
fi

exec flutter run --dart-define=API_BASE_URL="http://localhost:$PORT/api/v1" "$@"
