
import 'package:frosthaven_assistant/Resource/action_handler.dart';

import '../../services/service_locator.dart';
import '../enums.dart';
import '../state/figure_state.dart';
import '../state/game_state.dart';

class RemoveConditionCommand extends Command {
  final Condition condition;
  final String figureId;
  final String ownerId;

  RemoveConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    FigureState figure = GameMethods.getFigure(ownerId, figureId)!;
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.remove(condition);
    figure.conditions.value = newList;
    if(condition != Condition.chill || !figure.conditions.value.contains(Condition.chill)) {
      figure.conditionsAddedThisTurn.value.remove(condition);
    }
    figure.conditionsAddedPreviousTurn.value.remove(condition);
    getIt<GameState>().updateList.value++;
  }

  @override
  void undo() {
    /*List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;*/
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Remove condition: ${condition.getName()}";
  }
}