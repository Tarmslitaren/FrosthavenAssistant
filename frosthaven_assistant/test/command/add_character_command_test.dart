import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

late final GameState _gameState;

Future<void> setUpAll() async {
  setupGetIt();
  _gameState = getIt<GameState>();
  //initialize game
  _gameState.init();
  await getIt<GameData>().loadData("assets/data/");//todo: should use mock data
  await _gameState.load();

}

void tests() {
  AddCharacterCommand command = AddCharacterCommand("Brute", "Arnold", 9);

  command.execute();

  test("added ok", (){
    assert(_gameState.currentList.first is Character);
    assert(_gameState.currentList.first.id == "Arnold");
    assert((_gameState.currentList.first as Character).characterClass.name == "Brute");
  });

  test("description is ok", (){
    assert(command.describe() == "Add Brute");
  });
}

main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await setUpAll();
  tests();
  
}