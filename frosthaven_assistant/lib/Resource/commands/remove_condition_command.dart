
import 'package:frosthaven_assistant/Resource/action_handler.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_state.dart';

class RemoveConditionCommand extends Command {
  final Condition condition;
  final String figureId;
  final String ownerId;

  RemoveConditionCommand(this.condition, this.figureId, this.ownerId);
  @override
  void execute() {
    Figure figure = GameMethods.getFigure(ownerId, figureId)!;
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.remove(condition);
    figure.conditions.value = newList;
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
    return "Remove ${condition.name}";
  }
}