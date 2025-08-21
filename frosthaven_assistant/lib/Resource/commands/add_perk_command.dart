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
