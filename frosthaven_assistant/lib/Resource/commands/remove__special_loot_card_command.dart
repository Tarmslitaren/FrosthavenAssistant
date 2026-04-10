import '../state/game_state.dart';

class RemoveSpecialLootCardCommand extends Command {
  int nr;
  final GameState _gameState;

  RemoveSpecialLootCardCommand(this.nr, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (nr == 1418) {
      _gameState.lootDeck.removeSpecial1418(stateAccess);
    }
    if (nr == 1419) {
      _gameState.lootDeck.removeSpecial1419(stateAccess);
    }
  }

  @override
  String describe() {
    return "Remove Special loot card ${nr.toString()}";
  }
}
