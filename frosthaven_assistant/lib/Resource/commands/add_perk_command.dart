import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

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
  String describe() {
    Character? character = GameMethods.getCharacterByName(characterId);
    final charId = character?.id ?? characterId;
    if (character != null && !character.characterState.perkList[index]) {
      return commandL10n.cmdRemovePerk(charId, index);
    }
    return commandL10n.cmdAddPerk(charId, index);
  }
}
