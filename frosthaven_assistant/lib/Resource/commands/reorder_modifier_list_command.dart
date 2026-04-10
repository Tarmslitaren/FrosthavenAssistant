import '../game_methods.dart';
import '../state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ReorderModifierListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  final String name;
  final GameState _gameState;

  ReorderModifierListCommand(this.newIndex, this.oldIndex, this.name,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.reorderCards(stateAccess, newIndex, oldIndex);
  }

  @override
  String describe() {
    return "Reorder Modifier Cards";
  }
}
