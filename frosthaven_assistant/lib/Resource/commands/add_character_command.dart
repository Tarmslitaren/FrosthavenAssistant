import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/list_item_data.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  final String? _display;
  late Character character;

  AddCharacterCommand(this._name, this._display, this._level) {
    character = GameMethods.createCharacter(_name, _display, _level)!;
  }

  @override
  void execute() {
    //add new character on top of list
    GameMethods.addToMainList(0, character);

    GameMethods.updateForSpecialRules();
    _gameState.updateList.value++;
    GameMethods.unlockClass(character.characterClass.name);
  }

  @override
  void undo() {
    //_gameState.currentList.remove(character);
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Add $_name";
  }
}
