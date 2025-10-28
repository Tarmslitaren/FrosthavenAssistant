import '../../../services/service_locator.dart';
import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeEnfeebleCommand extends ChangeStatCommand {
  ModifierDeck? deck;
  final String gfx;
  ChangeEnfeebleCommand(super.change, this.gfx, super.figureId, super.ownerId);
  ChangeEnfeebleCommand.deck(this.deck, this.gfx) : super(0, '', '');

  @override
  void execute() {
    if (deck == null) {
      deck = getIt<GameState>().modifierDeck;
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          if (item is Monster &&
              item.isAlly &&
              (getIt<GameState>().allyDeckInOGGloom.value ||
                  !GameMethods.isOgGloomEdition())) {
            deck = getIt<GameState>().modifierDeckAllies;
          }
          if (item is Character) {
            deck = item.characterState.modifierDeck;
          }
        }
      }
    }
    deck?.addRemovableValue(gfx, change);
  }

  @override
  void undo() {
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
