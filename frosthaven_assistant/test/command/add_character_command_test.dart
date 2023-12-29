import 'dart:ffi';

import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

late final GameState _gameState;

Future<void> setUpAll() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupGetIt();
  _gameState = getIt<GameState>();
  //initialize game
  _gameState.init();
  await getIt<GameData>().loadData("assets/testData/");//todo: should use mock data
  await _gameState.load();

  //todo: test there is no side effects -> check that _gameState does not change aside from the changes
  //todo: also test savestate: after each change test save+restore and that the state is equal
}

void checkSaveState() {
  String state = _gameState.gameSaveStates.last.toString();
  _gameState.save();
  _gameState.load();
  String newState = _gameState.gameSaveStates.last.toString();
  assert(newState == state);
}

void tests() {
  AddCharacterCommand command = AddCharacterCommand("Hatchet", "Arnold", 9);

  command.execute();
  checkSaveState();

  test("added ok", (){
    assert(_gameState.currentList.first is Character);
    assert(_gameState.currentList.first.id == "Arnold");
    assert((_gameState.currentList.first as Character).characterClass.name == "Hatchet");
    assert(_gameState.currentList.length == 1);
    Character brute = GameMethods.getCurrentCharacters().first;
    assert(brute.characterState.display.value == "Arnold");
    assert(brute.characterState.level.value == 9);

  });

  test("description is ok", (){
    assert(command.describe() == "Add Hatchet");
    assert(_gameState.commands.last?.describe() == "Add Hatchet");
  });
}

main() async {

  await setUpAll();
  tests();
  
}