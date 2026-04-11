import '../enums.dart';
import '../state/game_state.dart';

class UseElementCommand extends Command {
  late final Elements element;

  UseElementCommand(this.element);

  @override
  void execute() {
    ElementMethods.useElement(stateAccess, element);
  }

  @override
  String describe() {
    return "Use Element ${element.name}";
  }
}
