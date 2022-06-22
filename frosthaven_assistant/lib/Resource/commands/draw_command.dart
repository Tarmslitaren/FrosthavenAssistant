
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_methods.dart';
import '../game_state.dart';

class DrawCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  DrawCommand();

  @override
  void execute() {
    GameMethods.drawAbilityCards();
    GameMethods.sortByInitiative();
    _gameState.round.value++;
    GameMethods.setRoundState(RoundState.playTurns);
    MainList.scrollToTop();

  }

  @override
  void undo() {
    GameMethods.unDrawAbilityCards();
    _gameState.round.value--;
    GameMethods.setRoundState(RoundState.chooseInitiative);
    //TODO: un draw the cards (need to save the random nr used. unsort the list
  }
}