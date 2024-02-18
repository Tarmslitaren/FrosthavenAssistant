
import 'dart:convert';
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

}
void checkSaveState() async {
  String state = gameState.toString();
  int nrStates = gameState.gameSaveStates.length;
  gameState.save();
  await gameState.load();
  String newState = gameState.toString();
  assert(gameState.gameSaveStates.length == nrStates + 2); //for some reason a null state is added on load.
  assert(newState == state);
}

void checkNoSideEffects(List<String> changedFields, String oldState, ) {

  final differ = JsonDiffer.fromJson(json.decode(oldState), json.decode(gameState.toString()));
  DiffNode diff = differ.diff();

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

}