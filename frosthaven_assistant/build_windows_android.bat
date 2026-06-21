@echo off
cd /d "%~dp0"

if not exist dart_defines.json (
    echo Error: dart_defines.json not found. Create it with your SENTRY_DSN.
    exit /b 1
)

echo =^> Building Windows...
flutter build windows --dart-define-from-file=dart_defines.json
if errorlevel 1 goto :error

echo =^> Building Android APK...
flutter build apk --dart-define-from-file=dart_defines.json
if errorlevel 1 goto :error

echo =^> Done.
exit /b 0

:error
echo Build failed.
exit /b 1
