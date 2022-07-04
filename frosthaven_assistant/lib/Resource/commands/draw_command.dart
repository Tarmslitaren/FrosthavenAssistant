
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
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
    Future.delayed(Duration(milliseconds: 600), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    });

  }

  @override
  void undo() {
    GameMethods.unDrawAbilityCards();
    _gameState.round.value--;
    GameMethods.setRoundState(RoundState.chooseInitiative);
    //TODO: un draw the cards (need to save the random nr used. unsort the list
  }
}