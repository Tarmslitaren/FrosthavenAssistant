import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetLevelCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  late final int level;
  late final String? monsterId;

  SetLevelCommand(this.level, this.monsterId);

  @override
  void execute() {
    if (monsterId == null) {
      GameMethods.setLevel(level);
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          item.setLevel(level);
        }
      }
      GameMethods.updateForSpecialRules();
    } else {
      Monster? monster;
      for (var item in _gameState.currentList) {
        if (item.id == monsterId) {
          monster = item as Monster;
        }
      }
      monster!.setLevel(level);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (monsterId != null) {
      return "Set $monsterId's level";
    }
    return "Set Level";
  }
}
