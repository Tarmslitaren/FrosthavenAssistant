import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveAMDCardCommand extends Command {
  final int index;
  final String name;
  final GameState _gameState = getIt<GameState>();
  RemoveAMDCardCommand(this.index, this.name);
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.removeCardFromDiscard(stateAccess, index);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove amd card";
  }
}
