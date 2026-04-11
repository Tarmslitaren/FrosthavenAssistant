part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class ElementMethods {
  static void resetElements(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (var key in gs.elementState.keys) {
      gs._elementState[key] = ElementState.inert;
    }
  }

  static void updateElements(_StateModifier _, {GameState? gameState}) {
    //elementalist special:
    bool elementalistPerk = false;
    Character? elementalist = GameMethods.getCharacterByName("Elementalist");
    if (elementalist != null && elementalist.characterState.perkList[15]) {
      if (elementalist.characterClass.edition == "Gloomhaven 2nd Edition") {
        elementalistPerk = true;
      }
    }

    final gs = gameState ?? getIt<GameState>();
    for (var key in gs.elementState.keys) {
      if (gs.elementState[key] == ElementState.full) {
        if (!elementalistPerk ||
            key == Elements.light ||
            key == Elements.dark) {
          gs._elementState[key] = ElementState.half;
        }
      } else if (gs.elementState[key] == ElementState.half) {
        if (!elementalistPerk ||
            key == Elements.light ||
            key == Elements.dark) {
          gs._elementState[key] = ElementState.inert;
        }
      }
    }
  }

  static void imbueElement(_StateModifier _, Elements element, bool half, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._elementState[element] = ElementState.full;
    if (half) {
      gs._elementState[element] = ElementState.half;
    }
  }

  static void useElement(_StateModifier _, Elements element, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._elementState[element] = ElementState.inert;
  }
}
