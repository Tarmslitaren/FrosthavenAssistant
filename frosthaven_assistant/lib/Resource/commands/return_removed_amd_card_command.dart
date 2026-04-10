import '../game_methods.dart';
import '../state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ReturnRemovedAMDCardCommand extends Command {
  final int index;
  final String name;
  final GameState _gameState;

  ReturnRemovedAMDCardCommand(this.index, this.name,
      {required GameState gameState})
      : _gameState = gameState;
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.returnCardToDiscard(stateAccess, index);
  }

  @override
  String describe() {
    return "Return removed amd card";
  }
}
