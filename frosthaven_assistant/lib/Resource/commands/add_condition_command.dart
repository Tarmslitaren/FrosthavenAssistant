
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_state.dart';

class AddConditionCommand extends Command {
  final Condition condition;
  final String ownerId;
  final String figureId;
  AddConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    Figure figure = getFigure(ownerId, figureId)!;
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
    getIt<GameState>().updateList.value++;
  }

  Figure? getFigure(String ownerId, String figureId) {
    for(var item in getIt<GameState>().currentList) {
      if(item.id == figureId) {
        return (item as Character).characterState;
      }
      if(item.id == ownerId){
        if(item is Monster) {

          for (var instance in item.monsterInstances.value) {
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
            if(id == figureId){
              return instance;
            }
          }
        }else if(item is Character){
          for (var instance in item.characterState.summonList.value){
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        }
      }
    }
    return null;
  }

  @override
  void undo() {
    /*List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.remove(condition);
    figure.conditions.value = newList;*/
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Add ${condition.name}";
  }
}