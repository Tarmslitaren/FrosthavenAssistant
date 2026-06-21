#!/bin/bash
set -e
cd "$(dirname "$0")"

SCRIPT_DIR="$(pwd)"

if [ ! -f dart_defines.json ]; then
    echo "Error: dart_defines.json not found. Create it with your SENTRY_DSN."
    exit 1
fi

VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)

echo "==> Building macOS..."
flutter build macos --dart-define-from-file=dart_defines.json

echo "==> Building iOS IPA..."
flutter build ipa --dart-define-from-file=dart_defines.json

echo "==> Zipping macOS app..."
MACOS_ZIP="X-Haven Assistant $VERSION macOS.zip"
rm -f "$MACOS_ZIP"
(cd "build/macos/Build/Products/Release" && zip -r "$SCRIPT_DIR/$MACOS_ZIP" "X-Haven Assistant.app")

echo "==> Done."
echo "    macOS: $MACOS_ZIP"
