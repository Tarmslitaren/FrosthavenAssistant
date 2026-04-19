import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class HealthWheelControllerViewModel {
  HealthWheelControllerViewModel({GameState? gameState})
      : _gameState = gameState ?? getIt<GameState>();

  final GameState _gameState;

  void triggerListUpdate() {
    _gameState.updateList.notify();
  }
}
