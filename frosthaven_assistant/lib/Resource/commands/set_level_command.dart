
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class SetLevelCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  int _previousState = 0;
  final int level;
  final String? monsterId;

  SetLevelCommand(this.level, this.monsterId);

  @override
  void execute() {
    if (monsterId == null) {
      _previousState = _gameState.level.value;
      _gameState.level.value = level;
      for (var item in _gameState.currentList) {
        if(item is Monster) {
          item.setLevel(level);
          //will overwrite specific level settings, but that is probably ok
        }
      }
    } else {
      Monster? monster;
      for(var item in _gameState.currentList) {
        if (item.id == monsterId) {
          monster = item as Monster;
        }
      }
      _previousState = monster!.level.value;
      monster.level.value = level;
      for(var item in monster.monsterInstances.value){
        item.setLevel(monster);
      }

    }
  }

  @override
  void undo() {
    /*if(monster != null) {
      monster!.level.value = _previousState;
      for(var item in monster!.monsterInstances.value){
        item.level.value = _previousState;
      }
    } else {
      _gameState.level.value = _previousState;
      for (var item in _gameState.currentList) {
        if(item is Monster) {
          item.level.value = level;
          //will overwrite specific level settings, but that is probably ok
        }
      }
    }*/
  }

  @override
  String toString() {
    return "Set Level";
  }
}