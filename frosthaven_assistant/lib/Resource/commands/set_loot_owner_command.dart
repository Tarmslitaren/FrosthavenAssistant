import '../state/game_state.dart';
import 'command_l10n.dart';

class SetLootOwnerCommand extends Command {
  final String ownerId;
  final LootCard card;

  SetLootOwnerCommand(this.ownerId, this.card);

  @override
  void execute() {
    card.owner = ownerId;
  }

  @override
  String describe() {
    return commandL10n.cmdSetLootOwner;
  }
}
