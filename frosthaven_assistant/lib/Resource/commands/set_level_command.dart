
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';
import '../state/monster.dart';

class SetLevelCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  int _previousState = 0;
  late final int level;
  late final String? monsterId;

  SetLevelCommand(this.level, this.monsterId);

  @override
  void execute() {
    if (monsterId == null) {
      _previousState = _gameState.level.value;
      _gameState.level.value = level;
      for (var item in _gameState.currentList) {
        if(item is Monster) {
          item.setLevel(level);
        }
      }
      GameMethods.updateForSpecialRules();
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
  }

  @override
  String describe() {
    if (monsterId != null) {
      return "Set $monsterId's level";
    }
    return "Set Level";
  }

}