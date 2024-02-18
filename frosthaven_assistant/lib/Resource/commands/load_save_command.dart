import '../../services/service_locator.dart';
import '../state/game_state.dart';

class LoadSaveCommand extends Command {
  String saveName;
  String saveData;
  LoadSaveCommand(this.saveName, this.saveData);

  @override
  void execute() {
    getIt<GameState>().loadFromData(saveData);
    getIt<GameState>().save();
    getIt<GameState>().updateForUndo.value++;
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Load saved game: $saveName";
  }
}
