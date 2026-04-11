import '../../enums.dart';
import '../../game_methods.dart';
import '../../state/game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String? ownerId;
  int change;
  final String figureId;
  // Public so subclasses in other files can access it
  final GameState gameState;

  ChangeStatCommand(this.change, this.figureId, this.ownerId,
      {required this.gameState});

  void setChange(int change) {
    this.change = change;
  }

  void handleDeath() {
    for (var item in gameState.currentList) {
      if (item is Monster) {
        List<MonsterInstance> newList = [];
        newList.addAll(item.monsterInstances);
        for (var instance in item.monsterInstances) {
          if (instance.health.value == 0) {
            newList.remove(instance);
            item.setMonsterInstances(stateAccess, newList);
            Future.delayed(const Duration(milliseconds: 600), () {
              gameState.killMonsterStandee.value++;
            });

            final roundState = gameState.roundState.value;
            if (item.monsterInstances.isEmpty) {
              item.setActive(stateAccess, false);
              if (roundState == RoundState.chooseInitiative) {
                RoundMethods.sortCharactersFirst(stateAccess);
              }
              if (roundState == RoundState.playTurns) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  gameState.updateList.value++;
                });
              } else {
                gameState.updateList.value++;
              }
            }
            break;
          }
        }
      } else if (item is Character) {
        //handle character death
        if (item.characterState.health.value <= 0) {
          gameState.updateList.value++;
        }

        //handle summon death
        final summonList = item.characterState.summonList;
        for (var instance in summonList) {
          if (instance.health.value == 0) {
            if (!GameMethods.summonDoesNotDie(item.id, instance.name)) {
              item.characterState.removeSummon(stateAccess, instance);
              Future.delayed(const Duration(milliseconds: 600), () {
                gameState.killMonsterStandee.value++;
              });

              if (item.characterState.summonList.isEmpty) {
                if (gameState.roundState.value == RoundState.playTurns) {
                  Future.delayed(const Duration(milliseconds: 600), () {
                    gameState.updateList.value++;
                  });
                } else {
                  gameState.updateList.value++;
                }
              } else {
                gameState.updateList.value++;
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
    gameState.updateList.value++;
  }

  @override
  String describe() {
    return "change stat";
  }
}
