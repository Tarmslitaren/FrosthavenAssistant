#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f dart_defines.json ]; then
    echo "Error: dart_defines.json not found. Create it with your SENTRY_DSN."
    exit 1
fi

echo "==> Building macOS..."
flutter build macos --dart-define-from-file=dart_defines.json

echo "==> Building iOS IPA..."
flutter build ipa --dart-define-from-file=dart_defines.json

echo "==> Done."
