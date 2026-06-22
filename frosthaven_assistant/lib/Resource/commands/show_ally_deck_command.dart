import '../state/game_state.dart';
import 'command_l10n.dart';

class ShowAllyDeckCommand extends Command {
  ShowAllyDeckCommand();

  @override
  void execute() {
    MonsterMethods.showAllyDeck(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdShowAllyDeck;
  }
}
