import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../state/game_state.dart';

class ImbueElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final Elements element;
  final bool half;

  ImbueElementCommand(this.element, this.half);

  @override
  void execute() {
    GameMethods.imbueElement(element, half);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Imbue element ${element.name}";
  }
}
