import '../state/game_state.dart';

class RemoveSpecialLootCardCommand extends Command {
  static const int _kCard1418 = 1418;
  static const int _kCard1419 = 1419;

  int nr;
  final GameState _gameState;

  RemoveSpecialLootCardCommand(this.nr, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (nr == _kCard1418) {
      _gameState.lootDeck.removeSpecial1418(stateAccess);
    }
    if (nr == _kCard1419) {
      _gameState.lootDeck.removeSpecial1419(stateAccess);
    }
  }

  @override
  String describe() {
    return "Remove Special loot card ${nr.toString()}";
  }
}
