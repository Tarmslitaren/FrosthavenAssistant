import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetAutoLevelAdjustCommand extends Command {
  SetAutoLevelAdjustCommand(this.on);

  bool on;

  @override
  void execute() {
    getIt<GameState>().setAutoScenarioLevel(stateAccess, on);
    GameMethods.applyDifficulty(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    if(on) {
      return "turn automatic level updated on";
    } else {
      return "turn automatic level updated off";
    }
  }
}
