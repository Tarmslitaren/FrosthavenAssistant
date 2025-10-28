import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import '../state/game_state.dart';

class DrawCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawCommand();

  @override
  void execute() {
    MutableGameMethods.drawAbilityCards(stateAccess);
    MutableGameMethods.sortByInitiative(stateAccess);
    MutableGameMethods.setRoundState(stateAccess, RoundState.playTurns);
    if (_gameState.currentList.isNotEmpty) {
      _gameState.currentList[0].setTurnState(stateAccess, TurnsState.current);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Draw";
  }
}
