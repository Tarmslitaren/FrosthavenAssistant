import '../state/game_state.dart';

class SetLevelCommand extends Command {
  late final int level;
  late final String? monsterId;

  SetLevelCommand(this.level, this.monsterId);

  @override
  void execute() {
    GameMethods.setLevel(stateAccess, level, monsterId);
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (monsterId != null) {
      return "Set $monsterId's level";
    }
    return "Set Level";
  }
}
