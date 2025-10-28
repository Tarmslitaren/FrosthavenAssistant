import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AddConditionCommand extends Command {
  final Condition condition;
  final String? ownerId;
  final String figureId;
  AddConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure != null) {
      List<Condition> newList = [];
      newList.addAll(figure.conditions.value);
      newList.add(condition);
      figure.conditions.value = newList;

      if (condition == Condition.chill) {
        figure.setChill(stateAccess, figure.chill.value + 1);
      }
      if (condition == Condition.plague) {
        figure.setPlague(stateAccess, figure.plague.value + 1);
      }

      //only added this turn if is current or done
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          if (item.turnState.value != TurnsState.notDone &&
              getIt<GameState>().roundState.value == RoundState.playTurns) {
            figure
                .getMutableConditionsAddedThisTurn(stateAccess)
                .add(condition);
          }
        }
      }
      getIt<GameState>().updateList.value++;
    }
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Add condition: ${condition.getName()}";
  }
}
