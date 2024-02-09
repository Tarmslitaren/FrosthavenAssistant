import '../../services/service_locator.dart';
import '../state/game_state.dart';

class RemoveSpecialLootCardCommand extends Command {
  int nr;
  RemoveSpecialLootCardCommand(this.nr);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    if (nr == 1418) {
      gameState.lootDeck.removeSpecial1418(stateAccess);
    }
    if (nr == 1419) {
      gameState.lootDeck.removeSpecial1419(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove Special loot card ${nr.toString()}";
  }
}
