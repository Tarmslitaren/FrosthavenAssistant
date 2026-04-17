import '../state/game_state.dart';

class AddSpecialLootCardCommand extends Command {
  static const int _kCard1418 = 1418;
  static const int _kCard1419 = 1419;

  int nr;
  final GameState _gameState;

  AddSpecialLootCardCommand(this.nr, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (nr == _kCard1418) {
      _gameState.lootDeck.addSpecial1418(stateAccess);
    }
    if (nr == _kCard1419) {
      _gameState.lootDeck.addSpecial1419(stateAccess);
    }
  }

  @override
  String describe() {
    return "Add Special loot card ${nr.toString()}";
  }
}
