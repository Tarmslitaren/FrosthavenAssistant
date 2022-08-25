
import '../../Model/character_class.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_methods.dart';
import '../game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  final String? _display;
  late Character character;

  AddCharacterCommand(this._name, this._display, this._level) {
    character = GameMethods.createCharacter(_name,_display, _level)!;
  }

  @override
  void execute() {
    //add new character on top of list
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      newList.add(item);
    }
    newList.insert(0, character);
    _gameState.currentList = newList;
    _gameState.updateList.value++;
    _gameState.unlockedClasses.add(character.characterClass.name);
  }

  @override
  void undo() {
    //_gameState.currentList.remove(character);
    _gameState.updateList.value++;
  }

  @override
  String toString() {
    return "Add $_name";
  }
}