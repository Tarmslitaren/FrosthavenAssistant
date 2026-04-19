// ignore_for_file: no-magic-number

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void _tests() {
  String oldState = gameState.toString();
  AddCharacterCommand("Hatchet", "Jaws of the Lion", "Arnold", 9,
          gameState: getIt<GameState>())
      .execute();
  RemoveCharacterCommand(List.of([gameState.currentList.last as Character]),
          gameState: getIt<GameState>())
      .execute();
  test("removed ok", () {
    expect(gameState.currentList.isEmpty, true);
    expect(gameState.unlockedClasses.first, "Hatchet");

    checkNoSideEffects(["unlockedClasses"], oldState);
    checkSaveState();
  });
}

Future<void> main() async {
  await setUpGame();
  _tests();
}
