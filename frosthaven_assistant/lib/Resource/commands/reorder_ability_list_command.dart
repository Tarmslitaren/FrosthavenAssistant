import '../state/game_state.dart';

class ReorderAbilityListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  late final String deck;
  final GameState _gameState;

  ReorderAbilityListCommand(this.deck, this.newIndex, this.oldIndex,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    for (var item in _gameState.currentAbilityDecks) {
      if (item.name == deck) {
        item.reorderDrawPile(stateAccess, oldIndex, newIndex);
        break;
      }
    }
  }

  @override
  String describe() {
    return "Reorder Ability Cards";
  }
}
