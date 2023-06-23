import 'package:get_it/get_it.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';
import '../settings.dart';

class TrackStandeesCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final bool track;

  TrackStandeesCommand(this.track) {}

  @override
  void execute() {
    getIt<Settings>().noStandees.value = !track;
    getIt<Settings>().handleNoStandeesSettingChange();
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
}
