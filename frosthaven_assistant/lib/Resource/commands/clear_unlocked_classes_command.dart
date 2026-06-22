import '../state/game_state.dart';
import 'command_l10n.dart';

class ClearUnlockedClassesCommand extends Command {
  ClearUnlockedClassesCommand();

  @override
  void execute() {
    ScenarioMethods.clearUnlockedClasses(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdClearUnlockedClasses;
  }
}
