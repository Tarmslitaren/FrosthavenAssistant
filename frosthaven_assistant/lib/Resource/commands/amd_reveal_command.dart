import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../state/game_state.dart';

class AMDRevealCommand extends Command {
  final int amount;
  final String name;
  final GameState _gameState;

  AMDRevealCommand(
      {required this.amount, required this.name, required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = GameMethods.getModifierDeck(name, _gameState);
    deck.revealCards(stateAccess, amount);
  }

  @override
  String describe() {
    return "Reveal $amount modifier cards";
  }
}
