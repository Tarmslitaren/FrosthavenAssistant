import '../enums.dart';
import '../state/game_state.dart';

class UseElementCommand extends Command {
  late final Elements element;

  UseElementCommand(this.element);

  @override
  void execute() {
    MutableGameMethods.useElement(stateAccess, element);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Use Element ${element.name}";
  }
}
