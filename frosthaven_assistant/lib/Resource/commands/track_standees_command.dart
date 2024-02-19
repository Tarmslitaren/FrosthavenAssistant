
import '../../services/service_locator.dart';
import '../settings.dart';
import '../state/game_state.dart';

class TrackStandeesCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final bool track;

  TrackStandeesCommand(this.track);

  @override
  void execute() {
    getIt<Settings>().noStandees.value = !track;
    _handleNoStandeesSettingChange();
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if (!track) {
      return "Don't track standees";
    }
    return "Track Standees";
  }

  void _handleNoStandeesSettingChange() {
    GameState gameState = getIt<GameState>();
    if (getIt<Settings>().noStandees.value) {
      for (var item in gameState.currentList) {
        if (item is Monster) {
          item.getMutableMonsterInstancesList(stateAccess).clear();
        }
      }
    } else {
      for (var item in gameState.currentList) {
        if (item is Monster && item.isActive) {
          item.setActive(stateAccess, false);
        }
      }
    }
    gameState.updateList.value++;
  }
}
