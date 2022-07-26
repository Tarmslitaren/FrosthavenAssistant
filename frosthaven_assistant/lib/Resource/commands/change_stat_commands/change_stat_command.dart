
import '../../../services/service_locator.dart';
import '../../action_handler.dart';
import '../../enums.dart';
import '../../game_methods.dart';
import '../../game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String ownerId;
  int change;
  final String figureId; //need to generate this somehow (name for char, standeeNr for monsters, summons - name+something (standeeNr+gfx)
  ChangeStatCommand(this.change, this.figureId, this.ownerId);

  void setChange(int change) {
    this.change = change;
  }

  void handleDeath(){
    for(var item in getIt<GameState>().currentList){
      if(item is Monster){
        for (var instance in item.monsterInstances.value) {
          if(instance.health.value == 0) {
            item.monsterInstances.value.remove(instance);
            Future.delayed(const Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            if (item.monsterInstances.value.isEmpty) {
              if (getIt<GameState>().roundState.value ==
                  RoundState.chooseInitiative) {
                GameMethods.sortCharactersFirst();
              } else
              if (getIt<GameState>().roundState.value == RoundState.playTurns) {
                GameMethods.sortByInitiative();
              }
              if(getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              }else {
                getIt<GameState>().updateList.value++;
              }
            }else {
             // getIt<GameState>().updateList.value++; //check if this was needed for something (will block standee death anim)
            }
            break;
          }
        }
      } else if (item is Character) {
        //handle summon death
        for (var instance in item.characterState.summonList.value) {
          if(instance.health.value == 0) {
            item.characterState.summonList.value.remove(instance);
            Future.delayed(Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            if (item.characterState.summonList.value.isEmpty) {
              //TODO: unessessary?
              if(getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              }else {
                getIt<GameState>().updateList.value++;
              }
              ////
            }else {
              getIt<GameState>().updateList.value++;
            }
            //Navigator.pop(context);
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
  String toString() {
    return "change stat";
  }
}