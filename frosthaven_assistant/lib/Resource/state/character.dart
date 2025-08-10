part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Character extends ListItemData {
  late final CharacterState characterState;
  late final CharacterClass characterClass;

  Character(this.characterState, this.characterClass) {
    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : id = characterClass.id;
  }

  Character.fromJson(Map<String, dynamic> json) {
    var anId = json['characterClass'];
    _turnState.value = TurnsState.values[json['turnState']];
    characterState = CharacterState.fromJson(json['characterState']);
    GameData data = getIt<GameData>();
    List<CharacterClass> characters = [];
    final modelData = data.modelData.value;
    for (String key in modelData.keys) {
      characters.addAll(modelData[key]!.characters);
    }
    for (var item in characters) {
      if (item.id == anId) {
        characterClass = item;
        break;
      }
    }

    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : id = characterClass.id;
  }

  void nextRound(_StateModifier _) {
    if (!GameMethods.isObjectiveOrEscort(characterClass)) {
      characterState._initiative.value = 0;
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.value.index}, '
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.id}" '
        '}';
  }
}
