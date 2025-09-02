import '../state/game_state.dart';

class UseFHPerksCommand extends Command {
  final String characterId;

  UseFHPerksCommand(this.characterId);

  @override
  void execute() {
    Character? character = GameMethods.getCharacterByName(characterId);
    if (character != null) {
      character.flipUseFHPerks(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    Character? character = GameMethods.getCharacterByName(characterId);
    bool use =
        character != null ? character.characterState.useFHPerks.value : false;
    String add = "don't use";
    if (use) {
      add = "use";
    }
    return "${character?.id} $add Frosthaven Perks";
  }
}
