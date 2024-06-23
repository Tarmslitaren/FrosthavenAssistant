import '../state/game_state.dart';

class SetCharacterLevelCommand extends Command {
  late final int level;
  late final String characterId;

  SetCharacterLevelCommand(this.level, this.characterId);

  @override
  void execute() {
    GameMethods.setCharacterLevel(stateAccess, level, characterId);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Set $characterId's Level";
  }
}
