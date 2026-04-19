part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Character extends ListItemData {
  final CharacterState characterState;
  final CharacterClass characterClass;

  Character(this.characterState, this.characterClass) {
    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : characterClass.id;
  }

  static CharacterClass _requireClass(String anId, String? edition) {
    final cls = _getClassStatic(anId, edition);
    if (cls == null) {
      throw StateError('Character class not found: $anId (edition: $edition)');
    }
    return cls;
  }

  Character.fromSave(Map<String, dynamic> json)
      : characterState = CharacterState.fromSave(
            json['characterClass'] as String, json['characterState'] as Map<String, dynamic>),
        characterClass = _requireClass(
            json['characterClass'] as String, json['edition'] as String?) {
    id = characterClass.id;
  }

  Character.fromJson(Map<String, dynamic> json)
      : characterState = CharacterState.fromJson(
            json['characterClass'] as String, json['characterState'] as Map<String, dynamic>),
        characterClass = _requireClass(
            json['characterClass'] as String, json['edition'] as String?) {
    final turnStateIdx = json['turnState'] as int?;
    if (turnStateIdx != null &&
        turnStateIdx >= 0 &&
        turnStateIdx < TurnsState.values.length) {
      _turnState.value = TurnsState.values[turnStateIdx];
    }

    id = GameMethods.isObjectiveOrEscort(characterClass)
        ? characterState.display.value
        : characterClass.id;
  }

  /// Updates mutable fields in-place from [json]. [characterClass] and [id]
  /// never change; only [_turnState] and [characterState] need updating.
  void updateFromJson(Map<String, dynamic> json) {
    final turnStateIdx = json['turnState'] as int?;
    if (turnStateIdx != null &&
        turnStateIdx >= 0 &&
        turnStateIdx < TurnsState.values.length) {
      _turnState.value = TurnsState.values[turnStateIdx];
    }
    characterState.updateFromJson(json['characterClass'] as String,
        json['characterState'] as Map<String, dynamic>);
  }

  void nextRound(_StateModifier _) {
    if (!GameMethods.isObjectiveOrEscort(characterClass)) {
      characterState._initiative.value = 0;
    }
  }

  void flipUseFHPerks(_StateModifier s) {
    //first clear all perks
    for (int i = 0; i < characterState._perkList.length; i++) {
      if (characterState._perkList[i]) {
        characterState.flipPerk(s, i);
        CharacterMethods.removePerk(s, this, i);
      }
    }

    characterState._useFHPerks.value = !characterState._useFHPerks.value;
  }

  void flipPerk(_StateModifier s, int index) {
    characterState.flipPerk(s, index);
    if (characterState.perkList[index]) {
      CharacterMethods.addPerk(s, this, index);
    } else {
      CharacterMethods.removePerk(s, this, index);
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

  static CharacterClass? _getClassStatic(String id, String? edition, {GameData? gameData}) {
    final modelData = (gameData ?? getIt<GameData>()).modelData.value;
    for (String key in modelData.keys) {
      final item = modelData[key]!.characters.firstWhereOrNull((item) {
        return item.id == id && (edition == null || edition == item.edition);
      });
      if (item != null) {
        return item;
      }
    }
    return null;
  }
}
