import '../state/game_state.dart';
import 'command_l10n.dart';

class SetCharacterLevelCommand extends Command {
  final int level;
  final String characterId;

  SetCharacterLevelCommand(this.level, this.characterId);

  @override
  void execute() {
    CharacterMethods.setCharacterLevel(stateAccess, level, characterId);
  }

  @override
  String describe() {
    return commandL10n.cmdSetCharacterLevel(characterId);
  }
}
