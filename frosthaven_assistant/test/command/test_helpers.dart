
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
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
  String? state = gameState.toString();
  int nrStates = gameState.gameSaveStates.length;
  await gameState.save();
  await gameState.load();
  String? newState = gameState.toString();
  assert(gameState.gameSaveStates.length == nrStates + 2); //for some reason a null state is added on load.
  assert(newState == state);
}