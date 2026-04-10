import '../../game_methods.dart';
import '../../state/game_state.dart';
import 'change_stat_command.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ChangeCurseCommand extends ChangeStatCommand {
  ChangeCurseCommand(super.change, super.figureId, super.ownerId,
      {required super.gameState});
  ChangeCurseCommand.deck(this.deck, {required GameState gameState})
      : super(0, '', '', gameState: gameState);

  ModifierDeck? deck;

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
    deck?.addRemovableValue("curse", change);
  }

  @override
  String describe() {
    if (change > 0) {
      return "Add a Curse";
    }
    return "Remove a Curse";
  }
}
