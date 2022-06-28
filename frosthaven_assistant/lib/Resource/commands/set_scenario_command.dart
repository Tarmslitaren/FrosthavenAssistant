
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_methods.dart';
import '../game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _scenario;

  SetScenarioCommand(this._scenario);

  @override
  void execute() {
    //first reset state
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Character) {
        newList.add(item);
        item.characterState.initiative = 0; //TODO: initiative values not
        item.characterState.health.value = item.characterClass.healthByLevel[item.characterState.level.value-1];
        item.characterState.xp.value = 0;
        item.characterState.conditions.value.clear();
      }
      if (item is Monster) {
        item.monsterInstances.value.clear();
      }
    }
    GameMethods.shuffleDecks();
    List<String> monsters =
        _gameState.modelData.value!.scenarios[_scenario]!.monsters;
    for (String monster in monsters) {
      newList.add(GameMethods.createMonster(monster, _gameState.level.value)!);
    }

    _gameState.currentList = newList;
    GameMethods.updateElements();
    GameMethods.updateElements(); //twice to make sure they are inert.
    GameMethods.setRoundState(RoundState.chooseInitiative);
    GameMethods.sortCharactersFirst();
    _gameState.scenario.value = _scenario;

    //Future.delayed(Duration(milliseconds: 10), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    //});
  }

  @override
  void undo() {
    //TODO: implement
  }
}