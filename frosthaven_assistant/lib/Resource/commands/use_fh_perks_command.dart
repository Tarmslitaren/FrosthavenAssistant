import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

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
  String describe() {
    Character? character = GameMethods.getCharacterByName(characterId);
    final charId = character?.id ?? characterId;
    final use = character?.characterState.useFHPerks.value ?? false;
    if (use) {
      return commandL10n.cmdUseFhPerks(charId);
    }
    return commandL10n.cmdDontUseFhPerks(charId);
  }
}
