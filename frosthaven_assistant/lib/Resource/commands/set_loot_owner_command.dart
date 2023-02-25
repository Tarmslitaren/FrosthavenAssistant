import '../action_handler.dart';
import '../state/loot_deck_state.dart';

class SetLootOwnerCommand extends Command {
  final String ownerId;
  final LootCard card;

  SetLootOwnerCommand(this.ownerId, this.card);

  @override
  void execute() {
    card.owner = ownerId;
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Set loot card owner";
  }
}
