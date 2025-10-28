import 'dart:convert';

import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class LoadCharacterSaveCommand extends Command {
  String saveName;
  String saveData;
  LoadCharacterSaveCommand(this.saveName, this.saveData);

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
    getIt<GameState>().updateList.value++;
    MutableGameMethods.unlockClass(stateAccess, character.characterClass.id);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Load saved character: $saveName";
  }
}
