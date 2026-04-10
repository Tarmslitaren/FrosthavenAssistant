import '../state/game_state.dart';

class AddLootCardCommand extends Command {
  AddLootCardCommand(this.resourceType, {required GameState gameState})
      : _gameState = gameState;
  final String resourceType;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.lootDeck.addExtraCard(stateAccess, resourceType);
  }

  @override
  String describe() {
    return "Add $resourceType Loot Card";
  }
}
