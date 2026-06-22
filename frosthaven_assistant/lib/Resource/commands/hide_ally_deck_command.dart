import '../state/game_state.dart';
import 'command_l10n.dart';

class HideAllyDeckCommand extends Command {
  HideAllyDeckCommand();

  @override
  void execute() {
    MonsterMethods.hideAllyDeck(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdHideAllyDeck;
  }
}
