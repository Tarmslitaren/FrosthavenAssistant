import '../../Layout/main_list.dart';
import '../enums.dart';
import '../state/game_state.dart';

class DrawCommand extends Command {
  final GameState _gameState;

  DrawCommand({required GameState gameState}) : _gameState = gameState;

  @override
  void execute() {
    DeckMethods.drawAbilityCards(stateAccess);
    RoundMethods.sortByInitiative(stateAccess);
    RoundMethods.setRoundState(stateAccess, RoundState.playTurns);
    if (_gameState.currentList.isNotEmpty) {
      _gameState.currentList[0].setTurnState(stateAccess, TurnsState.current);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });
  }

  @override
  void onUndo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Draw";
  }
}
