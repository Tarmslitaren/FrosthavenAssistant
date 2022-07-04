
import '../../Layout/main_list.dart';
import '../../Model/scenario.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _scenario;
  final bool section;

  SetScenarioCommand(this._scenario, this.section);

  @override
  void execute() {
    //first reset state
    //List<ListItemData> newList = [];
    if (!section) {
      for (var item in _gameState.currentList) {
        if (item is Character) {
          //newList.add(item);
          item.characterState.initiative = 0;
          item.characterState.health.value =
          item.characterClass.healthByLevel[item.characterState.level.value -
              1];
          item.characterState.xp.value = 0;
          item.characterState.conditions.value.clear();
        }
        if (item is Monster) {
          item.monsterInstances.value.clear();
        }
      }
      GameMethods.shuffleDecks();
    }

    List<String> monsters;
    if (section) {
      monsters = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.sections[_scenario]!.monsters;
    }else{
      monsters = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.scenarios[_scenario]!.monsters;
    }

    for (String monster in monsters) {
      _gameState.currentList.add(GameMethods.createMonster(monster, _gameState.level.value)!);
    }

    //_gameState.currentList = newList;
    if (!section) {
      GameMethods.updateElements();
      GameMethods.updateElements(); //twice to make sure they are inert.
      GameMethods.setRoundState(RoundState.chooseInitiative);
      GameMethods.sortCharactersFirst();
      _gameState.scenario.value = _scenario;
    }

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