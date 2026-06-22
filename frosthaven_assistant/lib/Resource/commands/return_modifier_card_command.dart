import '../state/game_state.dart';
import 'command_l10n.dart';

class ReturnModifierCardCommand extends Command {
  final String name;

  ReturnModifierCardCommand(this.name);

  @override
  void execute() {
    DeckMethods.returnModifierCard(stateAccess, name);
  }

  @override
  String describe() {
    return commandL10n.cmdReturnModifierCard;
  }
}
