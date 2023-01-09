
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class EnhanceLootCardCommand extends Command {
  EnhanceLootCardCommand(this.value, this.index, this.resourceType);
  final bool value;
  final int index;
  final String resourceType;

  @override
  void execute() {
    getIt<GameState>().lootDeck.flipEnhancement(value, index, resourceType);
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    if(value == false) {
      return "Remove Loot Enhancement";
    }
    return "Add Loot Enhancement";
  }
}