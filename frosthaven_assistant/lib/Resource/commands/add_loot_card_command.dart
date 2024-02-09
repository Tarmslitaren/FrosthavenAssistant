import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AddLootCardCommand extends Command {
  AddLootCardCommand(this.resourceType);
  final String resourceType;

  @override
  void execute() {
    getIt<GameState>().lootDeck.addExtraCard(stateAccess, resourceType);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Add $resourceType Loot Card";
  }
}
