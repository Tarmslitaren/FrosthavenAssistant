
import '../../Model/character_class.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  final String? _display;
  late Character character;

  AddCharacterCommand(this._name, this._display, this._level) {
    _createCharacter(_name,_display, _level);
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
  }

  @override
  void undo() {
    _gameState.currentList.remove(character);
  }

  void _createCharacter(String name, String? display, int level) {

    List<CharacterClass> characters = [];
    for (String key in _gameState.modelData.value.keys){
      characters.addAll(
          _gameState.modelData.value[key]!.characters
      );
    }
    for (CharacterClass characterClass in characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level - 1];
        characterState.maxHealth.value = characterState.health.value;
        if (name == "Escort" || name == "Objective") {
          characterState.initiative = 99;
        }
        characterState.display = name;
        if (display != null) {
          characterState.display = display;
        }
        character = Character(characterState, characterClass);
      }
    }
  }
}