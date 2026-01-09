import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDRevealCommand extends Command {
  final int amount;
  final String name;

  AMDRevealCommand({required this.amount, required this.name});

  @override
  void execute() {
    ModifierDeck deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    deck.revealCards(stateAccess, amount);
  }

  @override
  String describe() {
    return "Reveal $amount modifier cards";
  }
}
