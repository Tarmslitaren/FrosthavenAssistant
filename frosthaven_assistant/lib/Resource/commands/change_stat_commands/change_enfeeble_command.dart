import '../../../services/service_locator.dart';
import '../../state/game_state.dart';
import '../../state/modifier_deck_state.dart';
import '../../state/monster.dart';
import 'change_stat_command.dart';

class ChangeEnfeebleCommand extends ChangeStatCommand {
  ChangeEnfeebleCommand(super.change, super.figureId, super.ownerId);
  ChangeEnfeebleCommand.deck(this.deck) : super(0, '', '');

  ModifierDeck? deck;

  @override
  void execute() {
    if (deck == null) {
      deck = getIt<GameState>().modifierDeck;
      //Figure figure = getFigure(ownerId, figureId)!;
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          if (item is Monster && item.isAlly) {
            deck = getIt<GameState>().modifierDeckAllies;
          }
        }
      }
    }
    deck!.enfeebles.value += change;
  }

  @override
  void undo() {
    //stat.value -= change;
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    if (change > 0) {
      return "Add Enfeeble";
    }
    return "Remove Enfeeble";
  }
}
