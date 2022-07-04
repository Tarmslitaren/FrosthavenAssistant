
import 'package:frosthaven_assistant/Resource/action_handler.dart';

import '../../services/service_locator.dart';
import '../enums.dart';
import '../game_state.dart';

class RemoveConditionCommand extends Command {
  final Condition condition;
  final Figure figure;
  RemoveConditionCommand(this.condition, this.figure);
  @override
  void execute() {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.remove(condition);
    figure.conditions.value = newList;
    getIt<GameState>().updateList.value++;
  }

  @override
  void undo() {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
  }
}