import '../state/game_state.dart';

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
    return "Set $characterId's Level";
  }
}
