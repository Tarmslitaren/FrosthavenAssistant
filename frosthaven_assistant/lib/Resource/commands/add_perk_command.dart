import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AddPerkCommand extends Command {
  final String characterId;
  final int index;

  AddPerkCommand(this.characterId, this.index);

  @override
  void execute() {
    Character? character = GameMethods.getCharacterByName(characterId);
    if (character != null) {
      character.flipPerk(stateAccess, index);

      if (index == 17 && character.characterClass.name == "Hail") {
        if (character.characterState.perkList[index]) {
          getIt<GameState>().modifierDeck.addHailSpecial(stateAccess);
        } else {
          getIt<GameState>().modifierDeck.removeHailSpecial(stateAccess);
        }
      }
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    Character? character = GameMethods.getCharacterByName(characterId);
    String add = "Add";
    if (character != null) {
      if (!character.characterState.perkList[index]) {
        add = "Remove";
      }
    }
    return "$add '${character?.characterClass.perks[index].text}' Perk";
  }
}
