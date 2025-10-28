import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AddCSPartyCardCommand extends Command {
  final String characterId;
  final int type;
  AddCSPartyCardCommand(this.characterId, this.type);

  @override
  void execute() {
    ModifierDeck? deck =
        GameMethods.getModifierDeck(characterId, getIt<GameState>());
    deck.addCSPartyCard(stateAccess, type);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "$characterId add party card $type";
  }
}
