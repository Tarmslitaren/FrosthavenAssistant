import '../state/game_state.dart';

class ClearUnlockedClassesCommand extends Command {
  ClearUnlockedClassesCommand();

  @override
  void execute() {
    ScenarioMethods.clearUnlockedClasses(stateAccess);
  }

  @override
  String describe() {
    return "clear unlocked classes";
  }
}
