
import 'package:frosthaven_assistant/Resource/game_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';

class AddStandeeCommand extends Command {
  final int nr;
  final Monster monster;
  final MonsterType type;

  AddStandeeCommand(this.nr, this.monster, this.type);

  @override
  void execute() {
    MonsterInstance instance = MonsterInstance(nr, type, monster);
    List<MonsterInstance> newList = [];
    newList.addAll(monster.monsterInstances.value);
    newList.add(instance);
    GameMethods.sortMonsterInstances(newList);
    monster.monsterInstances.value = newList;
    if (monster.monsterInstances.value.length == 1) {
      //first added
      if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst();
      } else if (getIt<GameState>().roundState.value == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck();
        GameMethods.sortByInitiative();
      }
    }
    getIt<GameState>().updateList.value++;

  }

  @override
  void undo() {
    // TODO: implement undo
  }
}