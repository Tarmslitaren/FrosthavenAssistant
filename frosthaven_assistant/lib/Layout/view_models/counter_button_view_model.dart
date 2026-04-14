import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_stat_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class CounterButtonViewModel {
  CounterButtonViewModel({GameState? gameState})
      : _gameState = gameState ?? getIt<GameState>();

  final GameState _gameState;

  void executeCommand(ChangeStatCommand command) {
    _gameState.action(command);
  }
}
