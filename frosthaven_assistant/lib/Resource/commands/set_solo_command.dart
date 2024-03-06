import '../state/game_state.dart';

class SetSoloCommand extends Command {
  SetSoloCommand(this.solo);

  bool solo;

  @override
  void execute() {
    GameMethods.setSolo(stateAccess, solo);
    GameMethods.applyDifficulty(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    if(solo) {
      return "set solo level recommendation";
    }
    return "set regular level recommendation";
  }
}
