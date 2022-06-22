
import '../../Model/character_class.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class AddCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _name;
  final int _level;
  late Character character;

  AddCharacterCommand(this._name, this._level) {
    _createCharacter(_name, _level);
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
  }

  @override
  void undo() {
    _gameState.currentList.remove(character);
  }

  void _createCharacter(String name, int level) {
    for (CharacterClass characterClass
    in _gameState.modelData.value!.characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;
        characterState.health.value = characterClass.healthByLevel[level - 1];
        characterState.maxHealth.value = characterState.health.value;
        character = Character(characterState, characterClass);
      }
    }
  }
}