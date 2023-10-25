# frosthaven_assistant

README for developers contributing to frosthaven_assistant.

## Getting Started

For first time flutter developers, follow the [Flutter Installation Steps](https://docs.flutter.dev/get-started/install).

To see if there are any dependencies you need to install to complete setup, run `flutter doctor` from the terminal.

Run the app with `flutter run`.

## Running Unit Tests

frosthaven_assistant's unit tests rely on [mockito](https://github.com/dart-lang/mockito).

Before running unit tests, run `dart run build_runner build` to generate mockito's `.mocks.dart` files that the unit tests rely on. If encountering errors upon executing build_runner, try running `dart pub upgrade` and rerunning.

Once `.mocks.dart` files are generated, run unit tests with `flutter test`.
