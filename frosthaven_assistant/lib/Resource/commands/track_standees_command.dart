import '../settings.dart';
import '../state/game_state.dart';

class TrackStandeesCommand extends Command {
  final GameState _gameState;
  final Settings _settings;
  final bool track;

  TrackStandeesCommand(this.track,
      {required GameState gameState, required Settings settings})
      : _gameState = gameState,
        _settings = settings;

  @override
  void execute() {
    _settings.noStandees.value = !track;
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
    if (_settings.noStandees.value) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          item.clearMonsterInstances(stateAccess);
        }
      }
    } else {
      for (var item in _gameState.currentList) {
        if (item is Monster && item.isActive) {
          item.setActive(stateAccess, false);
        }
      }
    }
    _gameState.updateList.value++;
  }
}
