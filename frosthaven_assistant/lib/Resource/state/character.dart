import '../../Model/character_class.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import 'character_state.dart';
import 'game_state.dart';
import 'list_item_data.dart';

class Character extends ListItemData {
  Character(this.characterState, this.characterClass) {
    id = characterState.display.value; //characterClass.name;
  }
  late final CharacterState characterState;
  late final CharacterClass characterClass;
  void nextRound() {
    if (characterClass.name != "Objective" && characterClass.name != "Escort") {
      characterState.initiative.value = 0;
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.index}, '
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.name}" '
        '}';
  }

  Character.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    turnState = TurnsState.values[json['turnState']];
    characterState = CharacterState.fromJson(json['characterState']);
    String className = json['characterClass'];
    GameState gameState = getIt<GameState>();
    List<CharacterClass> characters = [];
    for (String key in gameState.modelData.value.keys) {
      characters.addAll(gameState.modelData.value[key]!.characters);
    }
    for (var item in characters) {
      if (item.name == className) {
        characterClass = item;
        break;
      }
    }
  }
}
