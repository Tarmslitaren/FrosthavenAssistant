import '../enums.dart';
import '../state/game_state.dart';

class UseElementCommand extends Command {
  final Elements element;
  final GameState? _gameState;

  UseElementCommand(this.element, {GameState? gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ElementMethods.useElement(stateAccess, element, gameState: _gameState);
  }

  @override
  String describe() {
    return "Use Element ${element.name}";
  }
}
