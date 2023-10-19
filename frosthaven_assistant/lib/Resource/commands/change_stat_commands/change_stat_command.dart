import '../../../services/service_locator.dart';
import '../../action_handler.dart';
import '../../enums.dart';
import '../../state/character.dart';
import '../../state/game_state.dart';
import '../../state/monster.dart';
import '../../state/monster_instance.dart';

abstract class ChangeStatCommand extends Command {
  final String ownerId;
  int change;
  final String figureId;
  ChangeStatCommand(this.change, this.figureId, this.ownerId);

  void setChange(int change) {
    this.change = change;
  }

  void handleDeath() {
    for (var item in getIt<GameState>().currentList) {
      if (item is Monster) {
        List<MonsterInstance> newList = [];
        newList.addAll(item.monsterInstances.value);
        for (var instance in item.monsterInstances.value) {
          if (instance.health.value == 0) {
            newList.remove(instance);
            item.monsterInstances.value = newList;
            //item.monsterInstances.value.remove(instance);
            Future.delayed(const Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            if (item.monsterInstances.value.isEmpty) {
              if (getIt<GameState>().roundState.value ==
                  RoundState.chooseInitiative) {
                GameMethods.sortCharactersFirst();
              } else if (getIt<GameState>().roundState.value ==
                  RoundState.playTurns) {
                //GameMethods.sortItemToPlace(item.id, 99); //TODO: don't? leave in place until end of round?
              }
              if (getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              } else {
                getIt<GameState>().updateList.value++;
              }
            } else {
              // getIt<GameState>().updateList.value++; //check if this was needed for something (will block standee death anim)
            }
            break;
          }
        }
      } else if (item is Character) {
        //handle character death
        if (item.characterState.health.value <= 0) {
          getIt<GameState>().updateList.value++;
        }

        //handle summon death
        for (var instance in item.characterState.summonList.value) {
          if (instance.health.value == 0) {
            item.characterState.summonList.value.remove(instance);
            Future.delayed(const Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            if (item.characterState.summonList.value.isEmpty) {
              if (getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              } else {
                getIt<GameState>().updateList.value++;
              }
            } else {
              getIt<GameState>().updateList.value++;
            }
            break;
          }
        }
      }
    }
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "change stat";
  }
}
