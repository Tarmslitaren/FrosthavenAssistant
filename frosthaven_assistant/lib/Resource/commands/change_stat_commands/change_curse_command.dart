import '../../../services/service_locator.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeCurseCommand extends ChangeStatCommand {
  ChangeCurseCommand(super.change, super.figureId, super.ownerId);
  ChangeCurseCommand.deck(this.deck) : super(0, '', '');

  ModifierDeck? deck;

  @override
  void execute() {
    if (deck == null) {
      deck = getIt<GameState>().modifierDeck;
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          if (item is Monster && item.isAlly) {
            deck = getIt<GameState>().modifierDeckAllies;
          }
        }
      }
    }
    deck!.setCurse(stateAccess, deck!.curses.value + change);
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    if (change > 0) {
      return "Add a Curse";
    }
    return "Remove a Curse";
  }
}
