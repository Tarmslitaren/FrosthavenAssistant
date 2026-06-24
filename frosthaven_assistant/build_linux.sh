#!/bin/bash
set -e
cd "$(dirname "$0")"

SCRIPT_DIR="$(pwd)"

if [ ! -f dart_defines.json ]; then
    echo "Error: dart_defines.json not found. Create it with your SENTRY_DSN."
    exit 1
fi

VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)

echo "==> Building Linux..."
flutter build linux --dart-define-from-file=dart_defines.json

echo "==> Copying Linux fonts..."
cp -r linux_fonts/. "build/linux/x64/release/bundle/data/fonts/"

echo "==> Zipping Linux bundle..."
LINUX_ZIP="X-Haven Assistant $VERSION Linux.zip"
rm -f "$LINUX_ZIP"
(cd "build/linux/x64/release" && zip -r "$SCRIPT_DIR/$LINUX_ZIP" "bundle")

echo "==> Done."
echo "    Linux: $LINUX_ZIP"
