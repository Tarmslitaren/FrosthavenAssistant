import '../state/game_state.dart';

class ClearUnlockedClassesCommand extends Command {
  ClearUnlockedClassesCommand();

  @override
  void execute() {
    GameMethods.clearUnlockedClasses(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "clear unlocked classes";
  }
}
