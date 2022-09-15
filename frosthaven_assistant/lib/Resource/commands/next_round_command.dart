
import '../../Layout/main_list.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../game_state.dart';

class NextRoundCommand extends Command {
  final GameState _gameState = getIt<GameState>();

  @override
  void execute() {
    for (var item in _gameState.currentList) {
      if (item is Character) {
        item.nextRound();
      }
      if (item is Monster) {
        //item.nextRound();
      }
    }
    GameMethods.shuffleDecksIfNeeded();
    GameMethods.updateElements();
    GameMethods.setRoundState(RoundState.chooseInitiative);
    GameMethods.sortCharactersFirst();
    GameMethods.clearTurnState();

    _gameState.round.value++;

    Future.delayed(const Duration(milliseconds: 600), () {
        _gameState.updateList.value++;
        MainList.scrollToTop();
    });

    if(_gameState.modifierDeck.needsShuffle) {
      _gameState.modifierDeck.shuffle();
    }
  }

  @override
  void undo() {
    //GameMethods.setRoundState(RoundState.playTurns);
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Next Round";
  }
}