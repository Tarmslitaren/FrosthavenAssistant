part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Character extends ListItemData {
  Character(this.characterState, this.characterClass) {
    if (GameMethods.isObjectiveOrEscort(characterClass)) {
      id = characterState.display.value;
    } else {
      id = characterClass.id;
    }
  }

  late final CharacterState characterState;
  late final CharacterClass characterClass;

  void nextRound(_StateModifier _) {
    if (!GameMethods.isObjectiveOrEscort(characterClass)) {
      characterState._initiative.value = 0;
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.index}, '
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.id}" '
        '}';
  }

  Character.fromJson(Map<String, dynamic> json) {
    var anId = json['characterClass'];
    _turnState = TurnsState.values[json['turnState']];
    characterState = CharacterState.fromJson(json['characterState']);
    GameData data = getIt<GameData>();
    List<CharacterClass> characters = [];
    for (String key in data.modelData.value.keys) {
      characters.addAll(data.modelData.value[key]!.characters);
    }
    for (var item in characters) {
      if (item.id == anId) {
        characterClass = item;
        break;
      }
    }

    if (!GameMethods.isObjectiveOrEscort(characterClass)) {
      id = characterClass.id;
    } else {
      id = characterState.display.value;
    }
  }
}
