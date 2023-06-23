import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class AddSpecialLootCardCommand extends Command {
  int nr;
  AddSpecialLootCardCommand(this.nr);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    if (nr == 1418) {
      gameState.lootDeck.addSpecial1418();
    }
    if (nr == 1419) {
      gameState.lootDeck.addSpecial1419();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Add Special loot card ${nr.toString()}";
  }
}
