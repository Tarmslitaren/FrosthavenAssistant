// ignore_for_file: avoid-top-level-members-in-tests

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/network/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialises the Flutter test binding and stubs SharedPreferences.
/// Call once from setUpAll in test files that pump widgets or touch platform
/// channels (e.g. SharedPreferences.saveToDisk inside GameState.action).
void initTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
}

/// Creates a fresh [GameState] and [Settings] backed by no-op network stubs.
/// No JSON is loaded; all state is constructed in memory.
/// Call from setUp() so each test starts from a clean slate.
(GameState, Settings) makeGameAndSettings() {
  final settings = Settings();
  final gameState = GameState(
    communication: Communication(connection: Connection()),
    settings: settings,
  );
  gameState.init();
  return (gameState, settings);
}
