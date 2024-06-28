import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';


void tests() {
  String oldState = gameState.toString();
  AddCharacterCommand command = AddCharacterCommand("Hatchet", "Arnold", 9);
  command.execute();

  test("added ok", (){
    assert(gameState.currentList.first is Character);
    assert((gameState.currentList.first as Character).characterState.display.value == "Arnold");
    assert(gameState.currentList.first.id == "Hatchet");
    assert((gameState.currentList.first as Character).characterClass.name == "Hatchet");
    assert(gameState.currentList.length == 1);
    Character brute = GameMethods.getCurrentCharacters().first;
    assert(brute.characterState.display.value == "Arnold");
    assert(brute.characterState.level.value == 9);
    assert(gameState.unlockedClasses.first == "Hatchet");
    checkNoSideEffects(
      ["currentList", "unlockedClasses"],
      oldState
    );
    checkSaveState();
  });

  test("description is ok", (){
    assert(command.describe() == "Add Hatchet");
    //assert(_gameState.commands.last?.describe() == "Add Hatchet");
  });

  //todo: test objective/escort/2-mini


}

main() async {
  await setUpGame();
  tests();
}