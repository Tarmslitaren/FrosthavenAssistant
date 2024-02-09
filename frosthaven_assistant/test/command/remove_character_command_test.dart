import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';


void tests() {
  AddCharacterCommand("Hatchet", "Arnold", 9).execute();
  RemoveCharacterCommand(List.of([gameState.currentList.last as Character])).execute();
  test("removed ok", (){
    assert(gameState.currentList.isEmpty);
  });
  checkSaveState();
}

main() async {
  await setUpGame();
  tests();
}