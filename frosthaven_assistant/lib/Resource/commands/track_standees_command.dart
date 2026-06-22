import '../settings.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

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
  String describe() {
    if (!track) {
      return commandL10n.cmdDontTrackStandees;
    }
    return commandL10n.cmdTrackStandees;
  }

  void _handleNoStandeesSettingChange() {
    if (_settings.noStandees.value) {
      for (final item in _gameState.currentList) {
        if (item is Monster) {
          item.clearMonsterInstances(stateAccess);
          item.notifyMonsterInstances(stateAccess);
        }
      }
    } else {
      for (final item in _gameState.currentList) {
        if (item is Monster && item.isActive) {
          item.setActive(stateAccess, false);
        }
      }
    }
    _gameState.updateList.notify();
  }
}
