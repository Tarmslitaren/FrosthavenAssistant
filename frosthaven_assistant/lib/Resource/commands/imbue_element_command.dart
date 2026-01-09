import '../enums.dart';
import '../state/game_state.dart';

class ImbueElementCommand extends Command {
  final Elements element;
  final bool half;

  ImbueElementCommand(this.element, this.half);

  @override
  void execute() {
    MutableGameMethods.imbueElement(stateAccess, element, half);
  }

  @override
  String describe() {
    return "Imbue element ${element.name}";
  }
}
