import '../enums.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class ImbueElementCommand extends Command {
  final Elements element;
  final bool half;
  final GameState? _gameState;

  ImbueElementCommand(this.element, this.half, {GameState? gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ElementMethods.imbueElement(stateAccess, element, half,
        gameState: _gameState);
  }

  @override
  String describe() {
    return commandL10n.cmdImbueElement(element.name);
  }
}
