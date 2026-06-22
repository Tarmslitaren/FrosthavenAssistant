import '../state/game_state.dart';
import 'command_l10n.dart';

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
      return commandL10n.cmdSetMonsterLevel(monsterId!);
    }
    return commandL10n.cmdSetLevel;
  }
}
