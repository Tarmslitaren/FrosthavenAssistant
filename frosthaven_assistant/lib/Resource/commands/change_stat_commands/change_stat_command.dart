import '../../../services/service_locator.dart';
import '../../enums.dart';
import '../../state/game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String? ownerId;
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
        newList.addAll(item.monsterInstances);
        for (var instance in item.monsterInstances) {
          if (instance.health.value == 0) {
            newList.remove(instance);
            item.getMutableMonsterInstancesList(stateAccess).clear();
            item.getMutableMonsterInstancesList(stateAccess).addAll(newList);
            Future.delayed(const Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            final roundState = getIt<GameState>().roundState.value;
            if (item.monsterInstances.isEmpty) {
              item.setActive(stateAccess, false);
              if (roundState == RoundState.chooseInitiative) {
                GameMethods.sortCharactersFirst(stateAccess);
              }
              if (roundState == RoundState.playTurns) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              } else {
                getIt<GameState>().updateList.value++;
              }
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
        final summonList = item.characterState.summonList;
        for (var instance in summonList) {
          if (instance.health.value == 0) {
            if (!GameMethods.summonDoesNotDie(item.id, instance.name)) {
              item.characterState
                  .getMutableSummonList(stateAccess)
                  .remove(instance);
              Future.delayed(const Duration(milliseconds: 600), () {
                getIt<GameState>().killMonsterStandee.value++;
              });

              if (item.characterState.summonList.isEmpty) {
                if (getIt<GameState>().roundState.value ==
                    RoundState.playTurns) {
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
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "change stat";
  }
}
