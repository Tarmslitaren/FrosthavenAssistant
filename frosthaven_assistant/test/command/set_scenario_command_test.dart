import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void tests() {
  String oldState = gameState.toString();
  SetScenarioCommand("#5 A Deeper Understanding", false).execute();
  test("basic scenario", (){
    assert(gameState.currentList.length == 3);
    assert(gameState.round.value == 1);
    assert(gameState.showAllyDeck.value == false);
    assert(gameState.scenario.value == "#5 A Deeper Understanding");
    assert(gameState.currentAbilityDecks.length == 3);
    assert(gameState.lootDeck.cardCount.value == 0);
    checkNoSideEffects([
      "scenario",
      "currentAbilityDecks",
      "currentList",
      "modifierDeck",
      "modifierDeckAllies"
    ], oldState);
    checkSaveState();
  });

  //todo: test, all kind of specials, sections, loot deck etc, set other scenario after.
}

main() async {
  await setUpGame();
  tests();
}