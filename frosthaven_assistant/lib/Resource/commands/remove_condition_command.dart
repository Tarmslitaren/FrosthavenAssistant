import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveConditionCommand extends Command {
  final Condition condition;
  final String figureId;
  final String? ownerId;

  RemoveConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure != null) {
      List<Condition> newList = [];
      newList.addAll(figure.conditions.value);
      newList.remove(condition);
      figure.conditions.value = newList;
      if (condition != Condition.chill ||
          !figure.conditions.value.contains(Condition.chill)) {
        figure.getMutableConditionsAddedThisTurn(stateAccess).remove(condition);
      }
      if (condition == Condition.chill) {
        figure.setChill(stateAccess, figure.chill.value - 1);
      }
      if (condition == Condition.plague) {
        figure.setPlague(stateAccess, figure.plague.value - 1);
      }

      figure
          .getMutableConditionsAddedPreviousTurn(stateAccess)
          .remove(condition);
      getIt<GameState>().updateList.value++;
    }
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Remove condition: ${condition.getName()}";
  }
}
