import '../game_methods.dart';
import '../state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ShuffleAMDCardCommand extends Command {
  final String name;
  final GameState _gameState;

  ShuffleAMDCardCommand(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.shuffleUnDrawn(stateAccess);
  }

  @override
  String describe() {
    return "Extra AMD deck shuffle";
  }
}
