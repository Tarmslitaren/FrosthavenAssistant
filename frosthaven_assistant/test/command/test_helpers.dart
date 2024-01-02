
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:json_diff/json_diff.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

late final GameState gameState;
Future<void> setUpGame() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupGetIt();
  gameState = getIt<GameState>();
  //initialize game
  gameState.init();
  await getIt<GameData>().loadData("assets/testData/");
  await gameState.load();

  //todo: test there is no side effects -> check that _gameState does not change aside from the changes
}
void checkSaveState() async {
  //var currentList = gameState.currentList.asList();
  String state = gameState.toString();
  int nrStates = gameState.gameSaveStates.length;
  await gameState.save();
  await gameState.load();
  //SetLevelCommand(4, "Zealot").execute();
  String newState = gameState.toString();
  assert(gameState.gameSaveStates.length == nrStates + 2); //for some reason a null state is added on load.
  assert(newState == state);
  //assert(gameState.currentList.asList().equals(currentList));
}

void checkNoSideEffects(List<String> changedFields, String oldState, ) {

  final differ = JsonDiffer.fromJson(json.decode(oldState), json.decode(gameState.toString()));
  DiffNode diff = differ.diff();
  //if (kDebugMode) {
    /*print(diff.node['level']?.changed);
    print(diff.node['solo']?.changed);
    print(diff.node['roundState']?.changed);
    print(diff.node['round']?.changed);

    print(diff.node['toastMessage']?.changed);
    print(diff.node['scenarioSpecialRules']?.changed);
    print(diff.node['scenarioSectionsAdded']?.changed);
    print(diff.node['currentCampaign']?.changed);*/
  /*print(diff.node['scenario']?.changed);
  print(diff.node['scenario']?.added);

    print(diff.node['currentList']?.changed);
  print(diff.node['currentList']?.added);
  print(diff.node['currentList']?.removed);

    print(diff.node['modifierDeck']?.changed);
    print(diff.node['modifierDeckAllies']?.changed);
    print(diff.node['lootDeck']?.changed);
    print(diff.node['unlockedClasses']?.changed);
    print(diff.node['showAllyDeck']?.changed);
    print(diff.node['elementState']?.changed);*/

  /*print(diff.changed);
  print(diff.added);
  print(diff.removed);
  print(diff.allAdded());*/
  print("for each");
  diff.forEach((s, dn) {
    print(s);
    assert(changedFields.contains(s));
    print(dn.added);
    print(dn.moved);
    print(dn.removed);
    print(dn.changed);
    print(dn.node);
    /*dn.node.forEach((s, dn) {
      print(s);
      print(dn.added);
      print(dn.moved);
      print(dn.path);
      print(dn.removed);
      print(dn.changed);
      print(dn.node);
    });*/
  });
  //}

  //print(diff.changed);
  /*
  level": , s": [], "modifierDeck
   */

  //todo: deal with currentList and card decks
  //todo: compare with previous value rather than initial value?
}