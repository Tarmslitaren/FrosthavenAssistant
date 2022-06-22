
import '../action_handler.dart';
import '../game_state.dart';

class AddConditionCommand extends Command {
  final Condition condition;
  final Figure figure;
  AddConditionCommand(this.condition, this.figure);
  @override
  void execute() {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
  }

  @override
  void undo() {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.remove(condition);
    figure.conditions.value = newList;
  }
}