@echo off
cd /d "%~dp0"

if not exist dart_defines.json (
    echo Error: dart_defines.json not found. Create it with your SENTRY_DSN.
    exit /b 1
)

for /f "tokens=2" %%v in ('findstr /b "version:" pubspec.yaml') do set VERSION_FULL=%%v
for /f "tokens=1 delims=+" %%v in ("%VERSION_FULL%") do set VERSION=%%v

echo =^> Building Windows...
call flutter build windows --dart-define-from-file=dart_defines.json
if errorlevel 1 goto :error

echo =^> Building Android APK...
call flutter build apk --dart-define-from-file=dart_defines.json
if errorlevel 1 goto :error

echo =^> Zipping Windows release...
set WIN_ZIP=X-Haven Assistant %VERSION% Windows.zip
if exist "%WIN_ZIP%" del "%WIN_ZIP%"
powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release' -DestinationPath '%WIN_ZIP%'"
if errorlevel 1 goto :error

echo =^> Done.
echo     Windows: %WIN_ZIP%
exit /b 0

:error
echo Build failed.
exit /b 1
