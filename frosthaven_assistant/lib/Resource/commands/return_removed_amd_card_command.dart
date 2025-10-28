import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class ReturnRemovedAMDCardCommand extends Command {
  final int index;
  final String name;
  final GameState _gameState = getIt<GameState>();
  ReturnRemovedAMDCardCommand(this.index, this.name);
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.returnCardToDiscard(stateAccess, index);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Return removed amd card";
  }
}
