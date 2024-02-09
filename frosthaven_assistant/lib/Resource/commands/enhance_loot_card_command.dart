import '../../services/service_locator.dart';
import '../state/game_state.dart';

class EnhanceLootCardCommand extends Command {
  EnhanceLootCardCommand(this.id, this.value, this.resourceType);
  final int value;
  final int id;
  final String resourceType;

  @override
  void execute() {
    getIt<GameState>().lootDeck.addEnhancement(stateAccess, id, value, resourceType);
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (value <= 0) {
      return "Remove Loot Enhancement";
    }
    return "Add Loot Enhancement";
  }
}
