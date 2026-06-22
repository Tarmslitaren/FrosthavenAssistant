import '../state/game_state.dart';
import 'command_l10n.dart';

class SetAutoLevelAdjustCommand extends Command {
  SetAutoLevelAdjustCommand(this.on, {required GameState gameState})
      : _gameState = gameState;

  bool on;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.setAutoScenarioLevel(stateAccess, on);
    ScenarioMethods.applyDifficulty(stateAccess);
  }

  @override
  String describe() {
    return on
        ? commandL10n.cmdAutoLevelOn
        : commandL10n.cmdAutoLevelOff;
  }
}
