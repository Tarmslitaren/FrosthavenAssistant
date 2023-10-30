part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Character extends ListItemData {
  Character(this.characterState, this.characterClass) {
    id = characterState.display.value; //characterClass.name;
  }
  late final CharacterState characterState;
  late final CharacterClass characterClass;
  void nextRound(_StateModifier _) {
    if (characterClass.name != "Objective" && characterClass.name != "Escort") {
      characterState._initiative.value = 0;
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
    _turnState = TurnsState.values[json['turnState']];
    characterState = CharacterState.fromJson(json['characterState']);
    String className = json['characterClass'];
    GameData data = getIt<GameData>();
    List<CharacterClass> characters = [];
    for (String key in data.modelData.value.keys) {
      characters.addAll(data.modelData.value[key]!.characters);
    }
    for (var item in characters) {
      if (item.name == className) {
        characterClass = item;
        break;
      }
    }
  }
}
