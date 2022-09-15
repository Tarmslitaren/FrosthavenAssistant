
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_state.dart';

class UseElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  late final Elements element;

  UseElementCommand(this.element);

  @override
  void execute() {
    _gameState.elementState.value[element] = ElementState.inert;
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Use Element ${element.name}";
  }

}
