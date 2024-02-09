import '../../services/service_locator.dart';
import '../state/game_state.dart';

class RemoveAMDCardCommand extends Command {
  final int index;
  final bool allyDeck;
  final GameState _gameState = getIt<GameState>();
  RemoveAMDCardCommand(this.index, this.allyDeck);
  @override
  void execute() {
    if (allyDeck) {
      _gameState.modifierDeckAllies.discardPile.removeAt(index);
    } else {
      _gameState.modifierDeck.discardPile.removeAt(index);
    }
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Remove amd card";
  }
}
