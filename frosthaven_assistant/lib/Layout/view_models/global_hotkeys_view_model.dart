import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_actions.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class GlobalHotkeysViewModel {
  GlobalHotkeysViewModel({GameState? gameState})
      : _gameState = gameState ?? getIt<GameState>();

  final GameState _gameState;

  void undo() => _gameState.undo();
  void redo() => _gameState.redo();

  /// Returns a blocked message if the action was blocked, null if it succeeded.
  String? invokeDrawOrNextRound() {
    final result = runDrawOrNextRoundAction(_gameState);
    return result.blockedMessage;
  }

  void toggleElement(Elements element) {
    final elementState = _gameState.elementState[element];
    if (elementState == ElementState.half ||
        elementState == ElementState.full) {
      _gameState.action(UseElementCommand(element));
      return;
    }
    _gameState.action(ImbueElementCommand(element, false));
  }

  void advanceActivation() {
    if (_gameState.roundState.value != RoundState.playTurns) return;
    for (final item in _gameState.currentList) {
      if (item.turnState.value == TurnsState.current) {
        _gameState.action(TurnDoneCommand(item.id, gameState: _gameState));
        return;
      }
    }
  }

  void undoActivation() {
    final currentCommandIndex = _gameState.commandIndex.value;
    if (currentCommandIndex < 0 ||
        currentCommandIndex >= _gameState.commands.length) {
      return;
    }
    if (_gameState.commands[currentCommandIndex] is TurnDoneCommand) {
      _gameState.undo();
    }
  }
}
