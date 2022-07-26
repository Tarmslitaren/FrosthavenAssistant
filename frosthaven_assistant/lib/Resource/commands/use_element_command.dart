
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_state.dart';

class UseElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final Elements element;
  ElementState? _previousState;

  UseElementCommand(this.element);

  @override
  void execute() {
    _previousState = _gameState.elementState.value[element];
    _gameState.elementState.value[element] = ElementState.inert;
  }

  @override
  void undo() {
    //_gameState.elementState.value[element] = _previousState!;
  }

  @override
  String toString() {
    return "Use Element";
  }
}
