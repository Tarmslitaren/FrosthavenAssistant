
import '../../../services/service_locator.dart';
import '../../game_state.dart';
import '../../modifier_deck_state.dart';
import 'change_stat_command.dart';

class ChangeCurseCommand extends ChangeStatCommand {
  ChangeCurseCommand(super.change, super.figureId, super.ownerId);

  @override
  void execute() {

    ModifierDeck deck = getIt<GameState>().modifierDeck;
    //Figure figure = getFigure(ownerId, figureId)!;
    for (var item in getIt<GameState>().currentList) {
      if (item.id == ownerId) {
        if(item is Monster && item.isAlly) {
          deck = getIt<GameState>().modifierDeckAllies;
        }
      }
    }


    //figure.chill.value += change;
    deck.curses.value += change;

  }

  @override
  void undo() {
    //stat.value -= change;
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