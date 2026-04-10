import '../state/game_state.dart';

class AddSpecialLootCardCommand extends Command {
  int nr;
  final GameState _gameState;

  AddSpecialLootCardCommand(this.nr, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (nr == 1418) {
      _gameState.lootDeck.addSpecial1418(stateAccess);
    }
    if (nr == 1419) {
      _gameState.lootDeck.addSpecial1419(stateAccess);
    }
  }

  @override
  String describe() {
    return "Add Special loot card ${nr.toString()}";
  }
}
