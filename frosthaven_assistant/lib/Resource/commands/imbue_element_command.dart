
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class ImbueElementCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final Elements element;
  final bool half;
  ElementState? _previousState;

  ImbueElementCommand(this.element, this.half);

  @override
  void execute() {
    _previousState = _gameState.elementState.value[element];
    _gameState.elementState.value[element] = ElementState.full;
    if (half) {
      _gameState.elementState.value[element] = ElementState.half;
    }
  }

  @override
  void undo() {
    _gameState.elementState.value[element] = _previousState!;
  }
}