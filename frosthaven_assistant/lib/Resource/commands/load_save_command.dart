import '../state/game_state.dart';

class LoadSaveCommand extends Command {
  String saveName;
  String saveData;
  final GameState _gameState;

  LoadSaveCommand(this.saveName, this.saveData, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    _gameState.loadFromData(saveData);
    _gameState.save();
    _gameState.updateForUndo.value++;
  }

  @override
  String describe() {
    return "Load saved game: $saveName";
  }
}
