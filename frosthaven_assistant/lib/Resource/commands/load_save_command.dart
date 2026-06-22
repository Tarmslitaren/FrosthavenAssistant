import '../state/game_state.dart';
import 'command_l10n.dart';

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
  }

  @override
  String describe() {
    return commandL10n.cmdLoadGame(saveName);
  }
}
