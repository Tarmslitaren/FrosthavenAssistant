// ignore_for_file: no-magic-number

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void _tests() {
  String oldState = gameState.toString();
  AddCharacterCommand command = AddCharacterCommand(
      "Hatchet", "Jaws of the Lion", "Arnold", 9,
      gameState: getIt<GameState>());
  command.execute();

  test("added ok", () {
    expect(gameState.currentList.first is Character, true);
    expect(
        (gameState.currentList.first as Character).characterState.display.value,
        "Arnold");
    expect(gameState.currentList.first.id, "Hatchet");
    expect((gameState.currentList.first as Character).characterClass.name,
        "Hatchet");
    expect(gameState.currentList.length, 1);
    Character brute = GameMethods.getCurrentCharacters().first;
    expect(brute.characterState.display.value, "Arnold");
    expect(brute.characterState.level.value, 9);
    expect(gameState.unlockedClasses.first, "Hatchet");
    checkNoSideEffects(["currentList", "unlockedClasses"], oldState);
    checkSaveState();
  });

  test("description is ok", () {
    expect(command.describe(), "Add Hatchet");
    //assert(_gameState.commands.last?.describe() == "Add Hatchet");
  });

  //todo: test objective/escort/2-mini
}

Future<void> main() async {
  await setUpGame();
  _tests();
}
