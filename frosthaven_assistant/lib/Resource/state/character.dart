part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Character extends ListItemData {
  late final CharacterState characterState;
  late final CharacterClass characterClass;

  Character(this.characterState, this.characterClass) {
    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : characterClass.id;
  }

  Character.fromSave(Map<String, dynamic> json) {
    final anId = json['characterClass'];
    String? edition = json['edition'];
    characterState = CharacterState.fromSave(anId, json['characterState']);
    characterClass = _getClass(anId, edition)!;
    id = characterClass.id;
  }

  Character.fromJson(Map<String, dynamic> json) {
    final anId = json['characterClass'];
    String? edition = json['edition'];
    _turnState.value = TurnsState.values[json['turnState']];
    characterState = CharacterState.fromJson(anId, json['characterState']);

    characterClass = _getClass(anId, edition)!;

    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : characterClass.id;
  }

  void nextRound(_StateModifier _) {
    if (!GameMethods.isObjectiveOrEscort(characterClass)) {
      characterState._initiative.value = 0;
    }
  }

  flipUseFHPerks(_StateModifier s) {
    //first clear all perks
    for (int i = 0; i < characterState._perkList.length; i++) {
      if (characterState._perkList[i]) {
        characterState.flipPerk(s, i);
        GameMethods.removePerk(s, this, i);
      }
    }

    characterState._useFHPerks.value = !characterState._useFHPerks.value;
  }

  void flipPerk(_StateModifier s, int index) {
    characterState.flipPerk(s, index);
    if (characterState.perkList[index]) {
      GameMethods.addPerk(s, this, index);
    } else {
      GameMethods.removePerk(s, this, index);
    }
  }

  String toSave() {
    return '{'
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.id}", '
        '"edition": "${characterClass.edition}" '
        '}';
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.value.index}, '
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.id}", '
        '"edition": "${characterClass.edition}" '
        '}';
  }

  CharacterClass? _getClass(String id, String? edition) {
    final modelData = getIt<GameData>().modelData.value;
    for (String key in modelData.keys) {
      final item = modelData[key]!.characters.firstWhereOrNull((item) {
        return item.id == id && (edition == null || edition == item.edition);
      });
      if (item != null) {
        return item;
        break;
      }
    }
    return null;
  }
}
