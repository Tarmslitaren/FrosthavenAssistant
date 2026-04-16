import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';

class ChangeEnfeebleCommand extends ChangeStatCommand {
  ModifierDeck? deck;
  final String gfx;
  ChangeEnfeebleCommand(super.change, this.gfx, super.figureId, super.ownerId,
      {required super.gameState});
  ChangeEnfeebleCommand.deck(this.deck, this.gfx,
      {required GameState gameState})
      : super(0, '', '', gameState: gameState);

  @override
  void execute() {
    if (deck == null) {
      deck = gameState.modifierDeck;
      for (var item in gameState.currentList) {
        if (item.id == ownerId) {
          if (item is Monster &&
              item.isAlly &&
              (gameState.allyDeckInOGGloom.value ||
                  !GameMethods.isOgGloomEdition())) {
            deck = gameState.modifierDeckAllies;
          }
          if (item is Character) {
            deck = item.characterState.modifierDeck;
          }
        }
      }
    }
    deck?.addRemovableValue(stateAccess, gfx, change);
  }

  @override
  String describe() {
    if (change > 0) {
      return "Add Enfeeble";
    }
    return "Remove Enfeeble";
  }
}
