
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';
class AddMonsterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int? _level;
  late Monster monster;

  AddMonsterCommand(this._name, this._level) {
    monster = GameMethods.createMonster(_name, _level, null)!;
  }

  @override
  void execute() {
    //add new character on bottom of list
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      newList.add(item);
    }
    newList.add(monster);
    _gameState.currentList = newList;
    _gameState.updateList.value++;
  }

  @override
  void undo() {
    _gameState.currentList.remove(monster);
  }
}