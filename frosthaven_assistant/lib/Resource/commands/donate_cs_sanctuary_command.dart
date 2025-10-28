import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class DonateCSSanctuaryCommand extends Command {
  final String characterId;
  DonateCSSanctuaryCommand(this.characterId);

  @override
  void execute() {
    ModifierDeck? deck =
        GameMethods.getModifierDeck(characterId, getIt<GameState>());
    deck.addCSSanctuary(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "$characterId donate to sanctuary";
  }
}
