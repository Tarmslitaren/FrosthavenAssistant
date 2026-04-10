import 'dart:convert';

import '../game_methods.dart';
import '../state/game_state.dart';

class LoadCharacterSaveCommand extends Command {
  String saveName;
  String saveData;
  final GameState _gameState;

  LoadCharacterSaveCommand(this.saveName, this.saveData,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    var data = json.decode(saveData) as Map<String, dynamic>;
    Character character = Character.fromSave(data);

    //add new character on top of list, if not present.
    final Character? currentCharacter =
        GameMethods.getCharacterByName(character.id);
    if (currentCharacter != null) {
      MutableGameMethods.removeCharacters(stateAccess, [currentCharacter]);
    }

    MutableGameMethods.resetCharacter(stateAccess, character);
    MutableGameMethods.addToMainList(stateAccess, 0, character);
    MutableGameMethods.applyDifficulty(stateAccess);
    _gameState.updateList.value++;
    MutableGameMethods.unlockClass(stateAccess, character.characterClass.id);
  }

  @override
  String describe() {
    return "Load saved character: $saveName";
  }
}
