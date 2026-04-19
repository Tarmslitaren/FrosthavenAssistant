import '../state/game_state.dart';

class SetLevelCommand extends Command {
  final int level;
  final String? monsterId;

  SetLevelCommand(this.level, this.monsterId);

  @override
  void execute() {
    ScenarioMethods.setLevel(stateAccess, level, monsterId);
  }

  @override
  String describe() {
    if (monsterId != null) {
      return "Set $monsterId's level";
    }
    return "Set Level";
  }
}
