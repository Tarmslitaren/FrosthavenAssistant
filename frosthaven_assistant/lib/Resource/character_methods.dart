part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class CharacterMethods {
  static void addPerk(_StateModifier s, Character character, int index, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];
    for (final item in perk.remove) {
      final amount = deck.cardCount.value;
      deck.removeCard(s, item);
      if (deck.cardCount.value == amount) {
        //must be a perk card

        //find missing card from perk list
        //todo: maybe easier to find from card list? get all starting with a 'P' then go through and remove first fitting

        for (int i = 0; i < perks.length; i++) {
          //check if other perk added the card previously
          final adds = perks[i].add;
          if (adds.contains(item)) {
            //remove that perk card
            String second = "";
            if (adds.first != adds.last && item == adds.last) {
              second = "-2"; //in case perk adds 2 different cards
            }
            deck.removeCard(s, "P$i$second");
            if (deck.cardCount.value != amount) {
              //found and removed
              break;
            }
          }
        }
      }
    }
    for (final item in perk.add) {
      CardType type = CardType.add;
      if (item.endsWith("/ns2")) {
        //nightshroud hack
        type = CardType.multiply;
      }
      final id = GameMethods.perkGfxIdToCardId(item, perk, index);
      deck.addCard(s, id, type);
    }

    final className = character.characterClass.name;
    if (index == 17 && className == "Hail") {
      gs.modifierDeck.addHailSpecial(s);
    }
    if (index == 16 && className == "Pain Conduit") {
      final level = character.characterState.level.value;
      final healthByLevel = character.characterClass.healthByLevel;
      if (level >= 1 && level <= healthByLevel.length) {
        character.characterState._health.value =
            healthByLevel[level - 1] + 5;
        character.characterState
            .setMaxHealth(s, character.characterState._health.value);
      }
    }
  }

  static void removePerk(_StateModifier s, Character character, int index, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];
    for (final item in perk.remove) {
      if (item.startsWith("perks/")) {
        //find id of perk: bull: could be several...
        for (int i = 0; i < perks.length; i++) {
          if (character.characterState.perkList[i] &&
              perks[i].add.contains(item)) {
            final id = GameMethods.perkGfxIdToCardId(item, perks[i], i);
            deck.addCard(s, id, CardType.add);
            break;
          }
        }
      } else {
        deck.addCard(s, item, CardType.add);
      }
    }
    for (final item in perk.add) {
      final id = GameMethods.perkGfxIdToCardId(item, perk, index);
      deck.removeCard(s, id);
    }

    final className = character.characterClass.name;
    if (index == 17 && className == "Hail") {
      gs.modifierDeck.removeHailSpecial(s);
    }
    if (index == 16 && className == "Pain Conduit") {
      final state = character.characterState;
      final characterClass = character.characterClass;
      final level = state.level.value;
      if (level >= 1 && level <= characterClass.healthByLevel.length) {
        final int health = characterClass.healthByLevel[level - 1];
        state.setMaxHealth(s, health);
        state.setHealth(s, health);
      }
    }
  }

  static void setCharacterLevel(
      _StateModifier s, int level, String characterId,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    Character? character;
    for (var item in gs.currentList) {
      if (item.id == characterId && item is Character) {
        character = item;
        break;
      }
    }
    if (character != null) {
      var healthByLevel = character.characterClass.healthByLevel;
      if (healthByLevel.length < level) {
        level = healthByLevel.length;
      }
      character.characterState.setFigureLevel(s, level);
      character.characterState.setHealth(s, healthByLevel[level - 1]);

      if (character.id == "Pain Conduit" &&
          character.characterState.perkList[16]) {
        character.characterState.setHealth(s, healthByLevel[level - 1] + 5);
      }

      character.characterState
          .setMaxHealth(s, character.characterState.health.value);

      //handle special summons
      int health = 0;
      int multiplier = 1;
      String name = "";
      if (character.id == "Beast Tyrant" || character.id == "Wildfury") {
        //create the bear summon
        health = 8;
        multiplier = 2;
        name = "Beast";
      }
      if (character.id == "D.O.M.E.") {
        health = 3;
        name = "Barrier";
      }
      if (character.id == "Glacial Torrent") {
        health = 7;
        name = "Glacier";
      }
      if (character.id == "Jester Twins") {
        //create the barrier as a summon
        health = 5;
        name = "Jester Twin";
      }

      var list = character.characterState.summonList;
      if (list.isNotEmpty && list.first.name == name) {
        int hp = health + character.characterState.level.value * multiplier;
        list.first.setMaxHealth(s, hp);
        list.first.setHealth(s, hp);
      }
    }

    ScenarioMethods.applyDifficulty(s);
  }

  static void resetCharacter(_StateModifier s, Character item, {GameState? gameState}) {
    item.characterState._initiative.value = 0;
    final level = item.characterState.level.value;
    item.characterState._health.value =
        item.characterClass.healthByLevel[level - 1];

    if (item.characterClass.name == "Pain Conduit") {
      if (item.characterState.perkList[16]) {
        item.characterState._health.value += 5;
      }
    }

    item.characterState._maxHealth.value = item.characterState.health.value;
    item.characterState._xp.value = 0;
    item.characterState._conditions.value.clear();
    item.characterState._chill.value = 0;
    item.characterState._plague.value = 0;
    item.characterState.modifierDeck._initDeck();
    //reapply perks
    final perksSetList = item.characterState.perkList;
    final perks = item.characterState.useFHPerks.value
        ? item.characterClass.perksFH
        : item.characterClass.perks;
    for (int i = 0; i < perks.length; i++) {
      if (perksSetList[i]) {
        addPerk(s, item, i);
      }
    }
    //handle special summons
    final summonList = item.characterState._summonList;
    summonList.clear();
    int health = 0;
    int multiplier = 1;
    String gfx = "";
    String name = "";
    if (item.id == "Beast Tyrant" || item.id == "Wildfury") {
      //create the bear summon
      health = 8;
      multiplier = 2;
      gfx = item.id == "Beast Tyrant" ? "beast" : "Beast v2";
      name = "Beast";
    }
    if (item.id == "D.O.M.E.") {
      health = 3;
      gfx = "DOM barrier";
      name = "Barrier";
    }
    if (item.id == "Glacial Torrent") {
      health = 7;
      gfx = "GLA glacier";
      name = "Glacier";
    }
    if (item.id == "Jester Twins") {
      //create the barrier as a summon
      health = 5;
      gfx = "JES twin";
      name = "Jester Twin";
    }

    if (name.isNotEmpty) {
      MonsterInstance summon = MonsterInstance.summon(0, MonsterType.summon,
          name, health + level * multiplier, 3, 2, 0, gfx, -1);
      summonList.add(summon);
    }
    item.characterState._notifySummonList();
  }

  static void removeCharacters(_StateModifier s, List<Character> characters, {GameState? gameState}) {
    List<ListItemData> newList = [];
    final gs = gameState ?? getIt<GameState>();
    for (var item in gs.currentList) {
      if (item is Character) {
        bool remove = false;
        for (var name in characters) {
          if (item.characterState.display.value ==
              name.characterState.display.value) {
            remove = true;
            break;
          }
        }
        if (!remove) {
          newList.add(item);
        }
      } else {
        newList.add(item);
      }
    }
    gs._currentList = newList;
    RoundMethods.updateForSpecialRules(s);
    gs._notifyCurrentList();
  }

  static Character? createCharacter(_StateModifier _, String id,
      String? edition, String? display, int level, {GameData? gameData}) {
    Character? character;
    List<CharacterClass> characters = [];
    final gd = gameData ?? getIt<GameData>();
    final modelData = gd.modelData.value;
    for (String key in modelData.keys) {
      characters.addAll(modelData[key]!.characters);
    }
    for (CharacterClass characterClass in characters) {
      if (characterClass.id == id &&
          (edition == null || edition == characterClass.edition)) {
        var characterState = CharacterState(id);
        characterState._level.value = level;

        if (GameMethods.isObjectiveOrEscort(characterClass)) {
          characterState._initiative.value = 99;
        }
        characterState._health.value = characterClass.healthByLevel[level - 1];
        characterState._maxHealth.value = characterState.health.value;

        if (display != null) {
          characterState._display.value = display;
        } else {
          characterState._display.value = characterClass.name;
        }
        character = Character(characterState, characterClass);

        //handle special summons
        final summonList = character.characterState._summonList;
        summonList.clear();
        int health = 0;
        int multiplier = 1;
        String gfx = "";
        String name = "";
        if (character.id == "Beast Tyrant" || character.id == "Wildfury") {
          //create the bear summon
          health = 8;
          multiplier = 2;
          gfx = character.id == "Beast Tyrant" ? "beast" : "Beast v2";
          name = "Beast";
        }
        if (character.id == "D.O.M.E.") {
          health = 3;
          gfx = "DOM barrier";
          name = "Barrier";
        }
        if (character.id == "Glacial Torrent") {
          health = 7;
          gfx = "GLA glacier";
          name = "Glacier";
        }
        if (character.id == "Jester Twins") {
          //create the barrier as a summon
          health = 5;
          gfx = "JES twin";
          name = "Jester Twin";
        }

        if (name.isNotEmpty) {
          MonsterInstance summon = MonsterInstance.summon(0, MonsterType.summon,
              name, health + level * multiplier, 3, 2, 0, gfx, -1);
          summonList.add(summon);
        }

        break;
      }
    }
    return character;
  }
}
