import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../state/figure_state.dart';
import '../state/game_state.dart';

class AddConditionCommand extends Command {
  final Condition condition;
  final String ownerId;
  final String figureId;
  AddConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;

    //only added this turn if is current or done
    for (var item in getIt<GameState>().currentList) {
      if (item.id == ownerId) {
        if (item.turnState != TurnsState.notDone &&
            getIt<GameState>().roundState.value == RoundState.playTurns) {
          figure.conditionsAddedThisTurn.value.add(condition);
        }
      }
    }
    getIt<GameState>().updateList.value++;
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
    return "Add condition: ${condition.getName()}";
  }
}
