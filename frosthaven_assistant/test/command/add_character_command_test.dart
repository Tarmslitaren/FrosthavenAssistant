import 'package:flutter/cupertino.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

late final GameState _gameState;

setUpAll() {
  setupGetIt();
  _gameState = getIt<GameState>();
  //todo: should use mock data

}

main() {

  setUpAll();


  AddCharacterCommand command = AddCharacterCommand("Brute", "Arnold", 9);

  test("description is empty", (){
    command.describe() == "";
  });
  command.execute();

  test("added ok", (){
    _gameState.currentList.first is Character;
    _gameState.currentList.first.id == "Brute";
    (_gameState.currentList.first as Character).characterState.display.value == "Arnold";
  });

  test("description is ok", (){
    command.describe() == "Added Brute";
  });
}