
import 'package:frosthaven_assistant/Resource/action_handler.dart';

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
  }

  @override
  void undo() {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
  }
}