import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetDifficultyCommand extends Command {
  SetDifficultyCommand(this.difficulty);

  int difficulty;

  @override
  void execute() {
    getIt<GameState>().setDifficulty(stateAccess, difficulty);
    GameMethods.applyDifficulty(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "set difficulty level to $difficulty";
  }
}
