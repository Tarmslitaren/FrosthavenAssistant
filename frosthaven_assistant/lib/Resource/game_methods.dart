part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

GameState _gameState = getIt<GameState>();
GameData _gameData = getIt<GameData>();

class GameMethods {
  static void updateElements(_StateModifier _) {
    for (var key in _gameState.elementState.keys) {
      if (_gameState.elementState[key] == ElementState.full) {
        _gameState._elementState[key] = ElementState.half;
      } else if (_gameState.elementState[key] == ElementState.half) {
        _gameState._elementState[key] = ElementState.inert;
      }
    }
  }

  static int getTrapValue() {
    return 2 + _gameState.level.value;
  }

  static int getHazardValue() {
    if (isOgGloomEdition() &&
        !getIt<Settings>().fhHazTerrainCalcInOGGloom.value) {
      return (getTrapValue() / 2).floor();
    }

    return 1 + (_gameState.level.value / 3.0).ceil();
  }

  static int getXPValue() {
    return 4 + 2 * _gameState.level.value;
  }

  static int getCoinValue() {
    int level = _gameState.level.value;
    if (level == 7) {
      return 6;
    }

    return 2 + (level / 2.0).floor();
  }

  static int getRecommendedLevel() {
    double totalLevels = 0;
    double nrOfCharacters = 0;
    for (var item in _gameState.currentList) {
      if (item is Character &&
          !GameMethods.isObjectiveOrEscort(item.characterClass)) {
        totalLevels += item.characterState.level.value;
        nrOfCharacters++;
      }
    }
    if (nrOfCharacters == 0) {
      return 1;
    }
    if (_gameState.solo.value) {
      //Take the average level of all characters in the
      // scenario, then add 1 before dividing by 2 and rounding
      // up.
      return ((totalLevels / nrOfCharacters + 1.0) / 2.0).ceil();
    }
    //scenario level is equal to
    //the average level of the characters divided by 2
    //(rounded up)

    return (totalLevels / nrOfCharacters / 2.0).ceil();
  }

  static bool canDraw() {
    if (_gameState.currentList.isEmpty) {
      return false;
    }
    if (getIt<Settings>().noInit.value) {
      return true;
    }
    for (var item in _gameState.currentList) {
      if (item is Character) {
        if (item.characterState.initiative.value == 0) {
          if (item.characterState.health.value > 0) {
            return false;
          }
        }
      }
    }

    return true;
  }

  static void drawAbilityCardFromInactiveDeck(_StateModifier stateModifier) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.isNotEmpty || item.isActive) {
              if (deck.lastRoundDrawn != _gameState.totalRounds.value) {
                //do not draw new card in case drawn already this round
                deck.draw(stateModifier);
                break;
              }
            }
          }
        }
      }
    }
  }

  static void drawAbilityCards(_StateModifier stateModifier) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.isNotEmpty || item.isActive) {
              deck.draw(stateModifier);
              //only draw once from each deck
              break;
            }
          }
        }
      }
    }
  }

  static MonsterAbilityState? getDeck(String name) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      if (deck.name == name) {
        return deck;
      }
    }

    return null;
  }

  static void sortCharactersFirst(_StateModifier _) {
    _gameState._currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }

      bool aIsChar = false;
      bool bIsChar = false;
      if (a is Character) {
        aIsChar = true;
      }
      if (b is Character) {
        bIsChar = true;
      }
      if (aIsChar && bIsChar) {
        return 0;
      }
      if (bIsChar) {
        return 1;
      }

      //inactive at bottom
      if (a is Monster) {
        if (b is Monster) {
          if (b.monsterInstances.isEmpty && !b.isActive) {
            return -1;
          }
        }
        if (a.monsterInstances.isEmpty && !a.isActive) {
          return 1;
        }
      }
      if (b is Monster) {
        if (b.monsterInstances.isEmpty && !b.isActive) {
          return -1;
        }
        if (a is Monster) {
          if (a.monsterInstances.isEmpty && !a.isActive) {
            return 1;
          }
        }
      }

      return -1;
    });
  }

  static int getInitiative(ListItemData item) {
    if (item is Character) {
      return item.characterState.initiative.value;
    } else if (item is Monster) {
      if (item.monsterInstances.isEmpty && !item.isActive) {
        return 99; //sorted last
      }
      for (var deck in _gameState.currentAbilityDecks) {
        if (deck.name == item.type.deck) {
          if (deck.discardPile.isNotEmpty) {
            return deck.discardPile.peek.initiative;
          }
        }
      }
    }
    return 0;
  }

  static void sortItemToPlace(_StateModifier _, String id, int initiative) {
    var newList = _gameState.currentList.toList();
    ListItemData? item;
    int currentTurnItemIndex = 0;
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].turnState.value == TurnsState.current) {
        currentTurnItemIndex = i;
      }
      if (newList[i].id == id) {
        item = newList.removeAt(i);
      }
    }
    if (item == null) {
      return;
    }

    int init = 0;
    for (int i = 0; i < newList.length; i++) {
      ListItemData currentItem = newList[i];
      int currentItemInitiative = getInitiative(currentItem);
      if (currentItemInitiative > initiative && currentItemInitiative > init) {
        if (i > currentTurnItemIndex) {
          newList.insert(i, item);
          _gameState._currentList = newList;
          return;
        } else {
          //in case initiative is earlier than current turn, ignore anything current turn, and earlier and place later
          int insertIndex = currentTurnItemIndex + 1;
          for (int j = currentTurnItemIndex + 1; j < newList.length; j++) {
            if (getInitiative(newList[j]) >= initiative) {
              insertIndex = j;
              break;
            }
          }
          newList.insert(insertIndex, item);
          _gameState._currentList = newList;
          return;
        }
      }
      init =
          currentItemInitiative; //this check is for the case user has moved items around the order may be off
    }

    newList.add(item);
    _gameState._currentList = newList;
  }

  static void sortByInitiative(_StateModifier _) {
    _gameState._currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }
      int aInitiative = 0;
      int bInitiative = 0;
      if (a is Character) {
        aInitiative = a.characterState.initiative.value;
      } else if (a is Monster) {
        if (a.monsterInstances.isEmpty && !a.isActive) {
          if (b is Monster && b.monsterInstances.isEmpty && !b.isActive) {
            return -1;
          }
          return 1; //inactive at bottom
        }

        //find the deck
        for (var item in _gameState.currentAbilityDecks) {
          if (item.name == a.type.deck) {
            aInitiative = item.discardPile.peek.initiative;
          }
        }
      }
      if (b is Character) {
        bInitiative = b.characterState.initiative.value;
      } else if (b is Monster) {
        if (b.monsterInstances.isEmpty && !b.isActive) {
          if (a is Monster && a.monsterInstances.isEmpty && !a.isActive) {
            return 1;
          }
          return -1; //inactive at bottom
        }
        //find the deck
        for (var item in _gameState.currentAbilityDecks) {
          if (item.name == b.type.deck) {
            bInitiative = item.discardPile.peek.initiative;
          }
        }
      }
      return aInitiative.compareTo(bInitiative);
    });
  }

  static void sortMonsterInstances(
      _StateModifier _, List<MonsterInstance> instances) {
    instances.sort((a, b) {
      if (a.type == MonsterType.elite && b.type != MonsterType.elite) {
        return -1;
      }
      if (b.type == MonsterType.elite && a.type != MonsterType.elite) {
        return 1;
      }
      return a.standeeNr.compareTo(b.standeeNr);
    });
  }

  static Character? getCharacterByName(String name) {
    for (ListItemData data in _gameState.currentList) {
      if (data is Character) {
        if (data.id == name) {
          return data;
        }
      }
    }
    return null;
  }

  static List<Character> getCurrentCharacters() {
    return getCurrentCharactersForState(_gameState);
  }

  static List<Character> getCurrentCharactersForState(GameState state) {
    List<Character> characters = [];
    for (ListItemData data in state.currentList) {
      if (data is Character &&
          !GameMethods.isObjectiveOrEscort(data.characterClass)) {
        characters.add(data);
      }
    }

    return characters;
  }

  static Character? getCurrentCharacter() {
    for (var item in _gameState.currentList) {
      if (item.turnState.value == TurnsState.current) {
        if (item is Character) {
          if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
            return item;
          }
        }
      }
    }
    return null;
  }

  static ModifierDeck getModifierDeck(final String id, GameState state) {
    if (id == "allies") {
      return state.modifierDeckAllies;
    }
    if (id.isNotEmpty) {
      final characters = GameMethods.getCurrentCharactersForState(state);
      for (final character in characters) {
        if (character.id == id) {
          return character.characterState.modifierDeck;
        }
      }
    }

    return state.modifierDeck;
  }

  static bool canAddPerk(Character character, int index) {
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];
    for (final item in perk.remove) {
      if (!deck.hasCard(item)) {
        //check for perk cards in the deck with same id

        int otherPerkCardAdded = 0;
        //find missing card from perk list
        for (int i = 0; i < perks.length; i++) {
          //check if other perk added the card previously
          if (character.characterState.perkList[i]) {
            for (final card in perks[i].add) {
              if (card == item) {
                otherPerkCardAdded++;
              }
            }
            //this only for specific perk cards
            if (item.startsWith("perks/")) {
              for (final card in perks[i].remove) {
                if (card == item) {
                  otherPerkCardAdded--;
                }
              }
            }
          }
        }
        return otherPerkCardAdded > 0;
      }
    }
    return true;
  }

  static bool canRemovePerk(Character character, int index) {
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];

    for (final item in perk.add) {
      if (item.startsWith("perks/")) {
        String id = "P$index";
        if (perk.add.last != perk.add.first && item == perk.add.last) {
          id += "-2";
        }
        if (deck.hasCard(id)) {
          return true;
        }
      }
      if (!deck.hasCard(item)) {
        return false;
      }
    }
    return true;
  }

  static addPerk(_StateModifier s, Character character, int index) {
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
      final id = perkGfxIdToCardId(item, perk, index);
      deck.addCard(s, id, type);
    }

    if (index == 17 && character.characterClass.name == "Hail") {
      getIt<GameState>().modifierDeck.addHailSpecial(s);
    }
    //todo: add other perk specials: elementalist gh2e, painconduit
  }

  static String perkGfxIdToCardId(String gfx, PerkModel perk, int index) {
    if (gfx.startsWith("perks/")) {
      String id = "P$index";
      final last = perk.add.last;
      if (perk.add.first != last) {
        if (gfx == last) {
          id += "-2";
        }
      }
      return id;
    }
    return gfx;
  }

  static removePerk(_StateModifier s, Character character, int index) {
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
            final id = perkGfxIdToCardId(item, perks[i], i);
            deck.addCard(s, id, CardType.add);
            break;
          }
        }
      } else {
        deck.addCard(s, item, CardType.add);
      }
    }
    for (final item in perk.add) {
      final id = perkGfxIdToCardId(item, perk, index);
      deck.removeCard(s, id);
    }

    if (index == 17 && character.characterClass.name == "Hail") {
      getIt<GameState>().modifierDeck.removeHailSpecial(s);
    }
    //todo: remove other perk specials: elementalist gh2e, painconduit
  }

  static int getCurrentCharacterAmount() {
    int res = 0;
    for (ListItemData data in _gameState.currentList) {
      if (data is Character) {
        if (!GameMethods.isObjectiveOrEscort(data.characterClass)) {
          res++;
        }
      }
    }

    return res;
  }

  static List<Monster> getCurrentMonsters() {
    List<Monster> monsters = [];
    for (ListItemData data in _gameState.currentList) {
      if (data is Monster) {
        monsters.add(data);
      }
    }

    return monsters;
  }

  static void setRoundState(_StateModifier _, RoundState state) {
    _gameState._roundState.value = state;
  }

  static void setLevel(_StateModifier s, int level, String? monsterId) {
    if (monsterId == null) {
      _gameState._level.value = level;
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          item.setLevel(s, level);
        }
      }
      GameMethods.updateForSpecialRules(s);
    } else {
      Monster? monster;
      for (var item in _gameState.currentList) {
        if (item.id == monsterId) {
          monster = item as Monster;
        }
      }
      monster?.setLevel(s, level);
    }
  }

  static void applyDifficulty(_StateModifier s) {
    if (_gameState.autoScenarioLevel.value) {
      //adjust difficulty
      int newLevel =
          GameMethods.getRecommendedLevel() + _gameState.difficulty.value;
      if (newLevel > 7) {
        newLevel = 7;
      }
      GameMethods.setLevel(s, newLevel, null);
    }
  }

  static void setCharacterLevel(
      _StateModifier s, int level, String characterId) {
    Character? character;
    for (var item in _gameState.currentList) {
      if (item.id == characterId) {
        character = item as Character;
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
      character.characterState
          .setMaxHealth(s, character.characterState.health.value);

      if (character.id == "Beast Tyrant" || character.id == "Wildfury") {
        var list = character.characterState.summonList;
        if (list.isNotEmpty) {
          //create the bear summon
          final int bearHp = 8 + character.characterState.level.value * 2;
          list[0].setMaxHealth(s, bearHp);
          list[0].setHealth(s, bearHp);
        }
      }
    }

    GameMethods.applyDifficulty(s);
  }

  static void resetCharacter(_StateModifier s, Character item) {
    item.characterState._initiative.value = 0;
    final level = item.characterState.level.value;
    item.characterState._health.value =
        item.characterClass.healthByLevel[level - 1];
    item.characterState._maxHealth.value = item.characterState.health.value;
    item.characterState._xp.value = 0;
    item.characterState.conditions.value.clear();
    item.characterState._chill.value = 0;
    item.characterState.modifierDeck._initDeck(item.id);
    //reapply perks
    final perksSetList = item.characterState.perkList;
    final perks = item.characterClass.perks;
    for (int i = 0; i < perks.length; i++) {
      if (perksSetList[i]) {
        GameMethods.addPerk(s, item, i);
      }
    }

    final summonList = item.characterState._summonList;
    summonList.clear();
    if (item.id == "Beast Tyrant" || item.id == "Wildfury") {
      //create the bear summon
      final int bearHp = 8 + level * 2;
      final String gfx = item.id == "Beast Tyrant" ? "beast" : "Beast v2";
      MonsterInstance bear = MonsterInstance.summon(
          0, MonsterType.summon, "Bear", bearHp, 3, 2, 0, gfx, -1);
      summonList.add(bear);
    }
  }

  //todo: too long method - split
  static void setScenario(_StateModifier s, String scenario, bool section) {
    if (!section) {
      //first reset state
      GameMethods.resetRound(s, 1, true);
      _gameState._showAllyDeck.value = false;
      _gameState._currentAbilityDecks.clear();
      _gameState._scenarioSpecialRules.clear();
      GameMethods.applyDifficulty(s);

      _gameState.modifierDeck._initDeck("");
      _gameState.modifierDeckAllies._initDeck("allies");
      _gameState._sanctuaryDeck._initDeck();

      List<ListItemData> newList = [];
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
            resetCharacter(s, item);
            newList.add(item);
          }
        }
      }

      _gameState._currentList = newList;

      //loot deck init
      if (scenario != "custom") {
        LootDeckModel? lootDeckModel = _gameData
            .modelData
            .value[_gameState.currentCampaign.value]!
            .scenarios[scenario]!
            .lootDeck;
        lootDeckModel != null
            ? _gameState._lootDeck =
                LootDeck(lootDeckModel, _gameState.lootDeck)
            : _gameState._lootDeck = LootDeck.from(_gameState.lootDeck);
      } else {
        if (_gameState.currentCampaign.value == "Frosthaven") {
          //add loot deck for random scenarios
          LootDeckModel? lootDeckModel =
              const LootDeckModel(2, 2, 2, 12, 1, 1, 1, 1, 1, 1, 0);
          _gameState._lootDeck = LootDeck(lootDeckModel, _gameState.lootDeck);
        } else {
          _gameState._lootDeck = LootDeck.from(_gameState.lootDeck);
        }
      }

      GameMethods.clearTurnState(s, true);
      _gameState._toastMessage.value = "";
    }

    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];
    List<String> subSections = [];

    String initMessage = "";
    if (section) {
      var sectionData = _gameData
          .modelData
          .value[_gameState.currentCampaign.value]
          ?.scenarios[_gameState.scenario.value]
          ?.sections
          .firstWhere((element) => element.name == scenario);
      if (sectionData != null) {
        monsters = sectionData.monsters;
        specialRules = sectionData.specialRules.toList();
        initMessage = sectionData.initMessage;
        final monsterStandees = sectionData.monsterStandees;
        roomMonsterData =
            monsterStandees != null ? monsterStandees.toList() : [];
      }
    } else {
      if (getIt<Settings>().showBattleGoalReminder.value &&
          _gameState.currentCampaign.value != "Buttons and Bugs") {
        initMessage += "Remember to choose your Battle Goals.";
      }
      if (scenario != "custom") {
        var scenarioData = _gameData.modelData
            .value[_gameState.currentCampaign.value]?.scenarios[scenario];
        if (scenarioData != null) {
          monsters = scenarioData.monsters;
          specialRules = scenarioData.specialRules.toList();
          if (initMessage.isNotEmpty && scenarioData.initMessage.isNotEmpty) {
            initMessage += "\n\n${scenarioData.initMessage}";
          } else {
            initMessage += scenarioData.initMessage;
          }
          final monsterStandees = scenarioData.monsterStandees;
          roomMonsterData =
              monsterStandees != null ? monsterStandees.toList() : [];
          for (var item in scenarioData.sections) {
            subSections.add(item.name);
          }
        }
      }
    }

    //handle special rules
    for (String monster in monsters) {
      GameMethods.addMonster(s, monster, specialRules);
    }

    if (!section) {
      GameMethods.shuffleDecks(s);
    }

    //hack for banner spear solo special rule
    if (scenario.contains("Banner Spear: Scouting Ambush")) {
      MonsterAbilityState deck = _gameState.currentAbilityDecks
          .firstWhere((element) => element.name.contains("Scout"));
      final drawPileList = deck.drawPile.getList();
      for (int i = 0; i < drawPileList.length; i++) {
        if (drawPileList[i].title == "Rancid Arrow") {
          deck.drawPile.add(deck.drawPile.removeAt(i));
          break;
        }
      }
    }

    //add objectives and escorts
    for (var item in specialRules) {
      if (item.type == "AllyDeck") {
        _gameState._showAllyDeck.value = true;
      }
      if (item.type == "Objective") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition)) {
          Character? objective = GameMethods.createCharacter(
              s, "Objective", null, item.name, _gameState.level.value + 1);
          final health =
              StatCalculator.calculateFormula(item.health.toString());
          if (health != null) {
            objective?.characterState._maxHealth.value = health;
          }
          objective?.characterState._health.value =
              objective.characterState.maxHealth.value;
          objective?.characterState._initiative.value = item.init;
          bool add = true;
          for (var item2 in _gameState.currentList) {
            //don't add duplicates
            if (item2 is Character &&
                (item2).characterState.display.value == item.name) {
              add = false;
              break;
            }
          }
          if (add && objective != null) {
            _gameState._currentList.add(objective);
          }
        }
      }
      if (item.type == "Escort") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition)) {
          final objective = GameMethods.createCharacter(
              s, "Escort", null, item.name, _gameState.level.value + 1);
          if (objective != null) {
            final maxHealth =
                StatCalculator.calculateFormula(item.health.toString());
            if (maxHealth != null) {
              objective.characterState._maxHealth.value = maxHealth;
            }
            objective.characterState._health.value =
                objective.characterState.maxHealth.value;
            objective.characterState._initiative.value = item.init;
            bool add = true;
            for (var item2 in _gameState.currentList) {
              //don't add duplicates
              if (item2 is Character &&
                  (item2).characterState.display.value == item.name) {
                add = false;
                break;
              }
            }
            if (add) {
              _gameState._currentList.add(objective);
            }
          }
        }
      }

      //special case for start of round and round is 1
      if (!section) {
        if (item.type == "Timer" && item.startOfRound) {
          for (int round in item.list) {
            //minus 1 means always
            if (round == 1 || round == -1) {
              if (initMessage.isNotEmpty) {
                initMessage += "\n\n${item.note}";
              } else {
                initMessage += item.note;
              }
            }
          }
        }
      }

      if (item.type == "ResetRound") {
        GameMethods.resetRound(s, 1, false);
      }
    }

    //in case of spawns at round 1 start of round, add to roomMonsterData
    for (var rule in specialRules) {
      if (rule.type == "Timer" && rule.startOfRound) {
        for (int round in rule.list) {
          //minus 1 means always
          if (round == 1 || round == -1) {
            if (getIt<Settings>().autoAddSpawns.value) {
              if (rule.name.isNotEmpty) {
                //get room data and deal with spawns
                ScenarioModel? scenarioModel = _gameData
                    .modelData
                    .value[_gameState.currentCampaign.value]
                    ?.scenarios[scenario];
                if (scenarioModel != null) {
                  ScenarioModel? spawnSection = scenarioModel.sections
                      .firstWhereOrNull(
                          (element) => element.name.substring(1) == rule.name);
                  if (spawnSection != null &&
                      spawnSection.monsterStandees != null) {
                    final monsterStandees = spawnSection.monsterStandees;
                    if (monsterStandees != null) {
                      for (var spawnItem in monsterStandees) {
                        var item = roomMonsterData.firstWhereOrNull(
                            (element) => element.name == spawnItem.name);
                        if (item != null) {
                          //merge
                          List<int> normal = [
                            item.normal[0] + spawnItem.normal[0],
                            item.normal[1] + spawnItem.normal[1],
                            item.normal[2] + spawnItem.normal[2]
                          ];
                          List<int> elite = [
                            item.elite[0] + spawnItem.elite[0],
                            item.elite[1] + spawnItem.elite[1],
                            item.elite[2] + spawnItem.elite[2]
                          ];
                          RoomMonsterData mergedItem =
                              RoomMonsterData(item.name, normal, elite);
                          for (int i = 0; i < roomMonsterData.length; i++) {
                            if (roomMonsterData[i].name == item.name) {
                              roomMonsterData[i] = mergedItem;
                              break;
                            }
                          }
                        } else {
                          roomMonsterData.add(spawnItem);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    initMessage = GameMethods.autoAddStandees(s, roomMonsterData, initMessage);

    if (!section) {
      _gameState._scenarioSpecialRules = specialRules;

      //todo: create a game state set scenario method to handle all these
      GameMethods.updateElements(s);
      GameMethods.updateElements(s); //twice to make sure they are inert.
      GameMethods.setRoundState(s, RoundState.chooseInitiative);
      GameMethods.sortCharactersFirst(s);
      _gameState._scenario.value = scenario;
      _gameState._scenarioSectionsAdded = [];
    } else {
      //remove earlier times if has "ResetRound"
      if (specialRules
              .firstWhereOrNull((element) => element.type == "ResetRound") !=
          null) {
        _gameState._scenarioSpecialRules.removeWhere((oldItem) {
          if (oldItem.type == "Timer") {
            return true;
          }
          return false;
        });
      }

      //overwrite earlier timers with same time.
      for (var item in specialRules) {
        if (item.type == "Timer") {
          _gameState._scenarioSpecialRules.removeWhere((oldItem) {
            if (oldItem.type == "Timer" &&
                item.startOfRound == oldItem.startOfRound) {
              if (item.list.contains(-1) || oldItem.list.contains(-1)) {
                return true;
              }
              var set2 = oldItem.list.toSet();
              return item.list.any(set2.contains);
            }
            return false;
          });
        }
      }
      _gameState._scenarioSpecialRules.addAll(specialRules);
      _gameState._scenarioSectionsAdded.add(scenario);
    }

    //handle random sections
    var rule = specialRules
        .firstWhereOrNull((element) => element.type == "RandomSections");
    if (rule != null) {
      subSections.shuffle();
      //add the random selected to rule.list
      SpecialRule newRule = SpecialRule("RandomSections", "", 0, 0, 0, "",
          subSections.sublist(0, 3), false, "");
      specialRules.remove(rule);
      specialRules.add(newRule);
    }

    _gameState.updateList.value++;

    if (!section) {
      MainList.scrollToTop();
    }

    //show init message if exists:
    if (initMessage.isNotEmpty && getIt<Settings>().showReminders.value) {
      _gameState._toastMessage.value += initMessage;
    } else {
      if (getIt.isRegistered<BuildContext>()) {
        ScaffoldMessenger.of(getIt<BuildContext>()).hideCurrentSnackBar();
      }
    }
  }

  static void returnLootCard(bool top) {
    var card = _gameState._lootDeck._discardPile.pop();
    card.owner = "";
    if (top) {
      _gameState._lootDeck._drawPile.push(card);
    } else {
      _gameState._lootDeck._drawPile.insert(0, card);
    }
  }

  static void returnModifierCard(String name) {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    var card = deck._discardPile.pop();
    deck._drawPile.push(card);
  }

  static void removeCharacters(_StateModifier s, List<Character> characters) {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
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
    _gameState._currentList = newList;
    GameMethods.updateForSpecialRules(s);
    _gameState.updateList.value++;
  }

  static void removeMonsters(_StateModifier _, List<Monster> items) {
    List<String> deckIds = [];
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        bool remove = false;
        for (var name in items) {
          if (item.id == name.id) {
            remove = true;
            deckIds.add(item.type.deck);
          }
        }
        if (!remove) {
          newList.add(item);
        }
      } else {
        newList.add(item);
      }
    }

    _gameState._currentList = newList;

    for (var deck in deckIds) {
      bool removeDeck = true;
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck) {
            removeDeck = false;
          }
        }
      }

      if (removeDeck) {
        for (var item in _gameState.currentAbilityDecks) {
          if (item.name == deck) {
            _gameState._currentAbilityDecks.remove(item);
            break;
          }
        }
      }
    }

    _gameState.updateList.value++;
  }

  static void reorderMainList(_StateModifier _, int newIndex, int oldIndex) {
    _gameState._currentList
        .insert(newIndex, _gameState._currentList.removeAt(oldIndex));
  }

  static void addToMainList(_StateModifier _, int? index, ListItemData item) {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      newList.add(item);
    }
    if (index != null) {
      newList.insert(index, item);
    } else {
      newList.add(item);
    }
    _gameState._currentList = newList;
  }

  //note: while this changes the game state, it is a state used also by non game related instances.
  static void setToastMessage(String message) {
    _gameState._toastMessage.value = message;
  }

  static void setSolo(_StateModifier _, bool solo) {
    _gameState._solo.value = solo;
  }

  static void shuffleDecksIfNeeded(_StateModifier _) {
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle ||
          deck.drawPile.isEmpty) {
        deck._shuffle();
      }
    }
  }

  static void shuffleDecks(_StateModifier _) {
    for (var deck in _gameState.currentAbilityDecks) {
      deck._shuffle();
    }
  }

  static int getNextAvailableBnBStandee(Monster data) {
    int nrOfStandees = data.type.count;
    for (int i = 0; i < nrOfStandees; i++) {
      bool isAvailable = true;
      for (var item in data.monsterInstances) {
        if (item.standeeNr == i + 1) {
          isAvailable = false;
          break;
        }
      }

      if (isAvailable) {
        //check for other monsters with same standees
        for (var item in _gameState.currentList) {
          if (item is Monster) {
            if (item.id != data.id) {
              for (var standee in item.monsterInstances) {
                if (standee.standeeNr == i + 1) {
                  isAvailable = false;
                  break;
                }
              }
            }
          }
          if (!isAvailable) {
            break;
          }
        }
      }
      if (isAvailable) {
        return i + 1;
      }
    }
    return 0;
  }

  static int getRandomStandee(Monster data) {
    int nrOfStandees = data.type.count;
    if (data.type.name == "Polar Bear") {
      nrOfStandees =
          4; //for the special case where there are only 4 standees in first printing
    }
    List<int> available = [];
    for (int i = 0; i < nrOfStandees; i++) {
      bool isAvailable = true;
      for (var item in data.monsterInstances) {
        if (item.standeeNr == i + 1) {
          isAvailable = false;
          break;
        }
      }
      if (isAvailable) {
        //check for special monsters with same standees
        for (var item in _gameState.currentList) {
          if (item is Monster) {
            if (item.id != data.id) {
              if (item.type.gfx == data.type.gfx) {
                for (var standee in item.monsterInstances) {
                  if (standee.standeeNr == i + 1) {
                    isAvailable = false;
                    break;
                  }
                }
              }
            }
          }
          if (!isAvailable) {
            break;
          }
        }
      }
      if (isAvailable) {
        available.add(i + 1);
      }
    }

    //in case we run out of standees...
    if (available.isEmpty) {
      return 0;
    }
    return available[Random().nextInt(available.length)];
  }

  static void executeAddStandee(
      _StateModifier s,
      final int nr,
      final SummonData? summon,
      final MonsterType type,
      final String ownerId,
      final bool addAsSummon) {
    MonsterInstance instance;
    Monster? monster;
    if (summon == null) {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId && item is Monster) {
          monster = item;
          break;
        }
      }
      instance = MonsterInstance(nr, type, addAsSummon, monster!);
    } else {
      instance = MonsterInstance.summon(
          summon.standeeNr,
          type,
          summon.name,
          summon.health,
          summon.move,
          summon.attack,
          summon.range,
          summon.gfx,
          getIt<GameState>().round.value);
    }

    List<MonsterInstance> monsterList = [];
    //find list
    if (monster != null) {
      monsterList = monster._monsterInstances;
    } else {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          monsterList = (item as Character).characterState._summonList;
          break;
        }
      }
    }

    //make sure summons can not have same gfx and nr:
    if (instance.standeeNr != 0 && summon != null) {
      bool ok = false;
      while (!ok) {
        ok = true;
        for (var item in monsterList) {
          if (item.standeeNr == instance.standeeNr) {
            if (item.gfx == instance.gfx) {
              //can not have same gfx and nr
              instance = MonsterInstance.summon(
                  instance.standeeNr + 1,
                  type,
                  summon.name,
                  summon.health,
                  summon.move,
                  summon.attack,
                  summon.range,
                  summon.gfx,
                  getIt<GameState>().round.value);
              ok = false;
            }
          }
        }
      }
    }

    monsterList.add(instance);
    if (monster != null) {
      GameMethods.sortMonsterInstances(s, monsterList);
    }
    if (monsterList.length == 1 && monster != null) {
      //first added
      final roundState = getIt<GameState>().roundState.value;
      if (roundState == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst(s);
      } else if (roundState == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck(s);
        GameMethods.sortItemToPlace(
            s,
            monster.id,
            GameMethods.getInitiative(
                monster)); //need to only sort this one item to place
      }
    }
  }

  static void addStandee(
      int? nr, Monster data, MonsterType type, bool addAsSummon) {
    if (nr != null) {
      _gameState
          .action(AddStandeeCommand(nr, null, data.id, type, addAsSummon));
    } else {
      //add first un added nr
      for (int i = 1; i <= data.type.count; i++) {
        bool added = false;
        for (var item in data.monsterInstances) {
          if (item.standeeNr == i) {
            added = true;
            break;
          }
        }
        if (!added) {
          _gameState
              .action(AddStandeeCommand(i, null, data.id, type, addAsSummon));
          return;
        }
      }
    }
  }

  static void addMonster(
      _StateModifier s, String monster, List<SpecialRule> specialRules) {
    int levelAdjust = 0;
    Set<String> alliedMonsters = {};
    for (var rule in specialRules) {
      if (rule.name == monster || rule.name == "Enemies") {
        if (rule.type == "LevelAdjust") {
          levelAdjust = rule.level;
        }
      }
      if (rule.type == "Allies") {
        for (String item in rule.list) {
          alliedMonsters.add(item);
        }
      }
    }

    bool add = true;
    for (var item in _gameState.currentList) {
      //don't add duplicates
      if (item.id == monster) {
        add = false;
        break;
      }
    }
    if (add) {
      bool isAlly = false;
      if (alliedMonsters.contains(monster)) {
        isAlly = true;
      }

      final munster = GameMethods.createMonster(s, monster,
          (_gameState.level.value + levelAdjust).clamp(0, 7), isAlly);
      if (munster != null) {
        _gameState._currentList.add(munster);
      }
    }
  }

  static String autoAddStandees(_StateModifier stateModifier,
      List<RoomMonsterData> roomMonsterData, String initMessage) {
    //handle room data
    int characterIndex =
        GameMethods.getCurrentCharacterAmount().clamp(2, 4) - 2;
    for (int i = 0; i < roomMonsterData.length; i++) {
      var roomMonsters = roomMonsterData[i];
      addMonster(
          stateModifier, roomMonsters.name, _gameState._scenarioSpecialRules);
    }
    bool addSorted = _gameState.currentCampaign.value == "Buttons and Bugs";
    if (!getIt<Settings>().noStandees.value &&
        getIt<Settings>().autoAddStandees.value) {
      if (getIt<Settings>().randomStandees.value || addSorted) {
        if (initMessage.isNotEmpty && !addSorted) {
          initMessage += "\n";
        }
        for (int i = 0; i < roomMonsterData.length; i++) {
          List<int> normals = [];
          List<int> elites = [];
          var roomMonsters = roomMonsterData[i];
          Monster data = _gameState.currentList.firstWhereOrNull(
              (element) => element.id == roomMonsters.name) as Monster;

          int eliteAmount = roomMonsters.elite[characterIndex];
          int normalAmount = roomMonsters.normal[characterIndex];

          bool isBoss = false;
          if (data.type.levels[0].boss != null) {
            isBoss = true;
          }

          for (int i = 0; i < eliteAmount; i++) {
            int randomNr = GameMethods.getRandomStandee(data);
            if (randomNr != 0) {
              elites.add(randomNr);
              GameMethods.executeAddStandee(stateModifier, randomNr, null,
                  MonsterType.elite, data.id, false);
            }
          }

          for (int i = 0; i < normalAmount; i++) {
            int randomNr = GameMethods.getRandomStandee(data);
            if (addSorted) {
              randomNr = GameMethods.getNextAvailableBnBStandee(data);
            }
            if (randomNr != 0) {
              normals.add(randomNr);
              GameMethods.executeAddStandee(
                  stateModifier,
                  randomNr,
                  null,
                  isBoss ? MonsterType.boss : MonsterType.normal,
                  data.id,
                  false);
            }
          }

          if (!addSorted && (elites.isNotEmpty || normals.isNotEmpty)) {
            elites.sort();
            normals.sort();
            if (i != 0) {
              initMessage += "\n";
            }
            initMessage += "${data.type.display} added - ";

            if (elites.isNotEmpty) {
              initMessage += "Elite: ";
              for (int i = 0; i < elites.length; i++) {
                initMessage += "${elites[i]}, ";
                if (i == elites.length - 1) {
                  initMessage =
                      initMessage.substring(0, initMessage.length - 2);
                }
              }
            }
            if (normals.isNotEmpty) {
              if (!isBoss) {
                if (elites.isNotEmpty) {
                  initMessage += ", ";
                }
                initMessage += "Normal: ";
              }
              for (int i = 0; i < normals.length; i++) {
                initMessage += "${normals[i]}, ";
                if (i == normals.length - 1) {
                  initMessage =
                      initMessage.substring(0, initMessage.length - 2);
                }
              }
            }
          }
        }
      } else {
        if (roomMonsterData.isNotEmpty) {
          if (getIt.isRegistered<BuildContext>()) {
            openDialogWithDismissOption(
                getIt<BuildContext>(),
                AutoAddStandeeMenu(
                  monsterData: roomMonsterData,
                ),
                false);
          }
        }
      }
    }
    return initMessage;
  }

  static FigureState? getFigure(String? ownerId, String figureId) {
    for (var item in getIt<GameState>().currentList) {
      if (item.id == figureId) {
        return (item as Character).characterState;
      }
      if (item.id == ownerId) {
        if (item is Monster) {
          for (var instance in item.monsterInstances) {
            String id =
                instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        } else if (item is Character) {
          for (var instance in item.characterState.summonList) {
            String id =
                instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        }
      }
    }
    return null;
  }

  static String getFigureIdFromNr(String ownerId, int nr) {
    for (var item in getIt<GameState>().currentList) {
      if (item.id == ownerId) {
        if (item is Monster) {
          for (var instance in item.monsterInstances) {
            if (instance.standeeNr == nr) {
              return instance.name +
                  instance.gfx +
                  instance.standeeNr.toString();
            }
          }
        }
      }
    }
    return "";
  }

  static bool isObjectiveOrEscort(CharacterClass character) {
    return character.id == "Escort" || character.id == "Objective";
  }

  static Character? createCharacter(_StateModifier _, String id,
      String? edition, String? display, int level) {
    Character? character;
    List<CharacterClass> characters = [];
    final modelData = _gameData.modelData.value;
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

        if (characterClass.id == "Beast Tyrant" ||
            characterClass.id == "Wildfury") {
          //create the bear summon
          final int bearHp = 8 + characterState.level.value * 2;

          final String gfx =
              characterClass.id == "Beast Tyrant" ? "beast" : "Beast v2";

          MonsterInstance bear = MonsterInstance.summon(
              0, MonsterType.summon, "Bear", bearHp, 3, 2, 0, gfx, -1);

          character.characterState._summonList.add(bear);
        }
        break;
      }
    }
    return character;
  }

  static Monster? createMonster(
      _StateModifier _, String name, int? level, bool isAlly) {
    Map<String, MonsterModel> monsters = {};
    final modelData = _gameData.modelData.value;
    for (String key in modelData.keys) {
      monsters.addAll(modelData[key]!.monsters);
    }
    level ??= getIt<GameState>().level.value;
    return Monster(name, level, isAlly);
  }

  static void showAllyDeck(_StateModifier _) {
    _gameState._showAllyDeck.value = true;
  }

  static void hideAllyDeck(_StateModifier _) {
    _gameState._showAllyDeck.value = false;
  }

  static bool shouldShowAlliesDeck() {
    if (!getIt<Settings>().showAmdDeck.value) {
      return false;
    }
    if (_gameState.showAllyDeck.value) {
      return true;
    }
    if (!_gameState.allyDeckInOGGloom.value && isOgGloomEdition()) {
      return false;
    }
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        if (item.isAlly) {
          return true;
        }
      }
    }
    return false;
  }

  static void clearTurnStateConditions(
      _StateModifier _, FigureState figure, bool clearLastTurnToo) {
    if (!clearLastTurnToo) {
      figure._conditionsAddedPreviousTurn.clear();
      figure._conditionsAddedPreviousTurn
          .addAll(figure.conditionsAddedThisTurn.toSet());
    } else {
      figure._conditionsAddedPreviousTurn.clear();
    }
    if (!clearLastTurnToo) {
      if (figure.conditionsAddedThisTurn.contains(Condition.chill)) {
        figure._chill.value--;
        if (figure.chill.value > 0) {
          figure._conditionsAddedPreviousTurn.clear();
          figure._conditionsAddedThisTurn.add(Condition.chill);
        } else {
          figure._conditionsAddedThisTurn.clear();
        }
      } else {
        figure._conditionsAddedThisTurn.clear();
      }
    } else {
      figure._conditionsAddedThisTurn.clear();
    }
  }

  static void clearTurnState(
      _StateModifier stateModifier, bool clearLastTurnToo) {
    for (var item in _gameState._currentList) {
      item._turnState.value = TurnsState.notDone;
      if (item is Character) {
        clearTurnStateConditions(
            stateModifier, item.characterState, clearLastTurnToo);
        for (var instance in item.characterState._summonList) {
          clearTurnStateConditions(stateModifier, instance, clearLastTurnToo);
        }
      } else if (item is Monster) {
        for (var instance in item._monsterInstances) {
          clearTurnStateConditions(stateModifier, instance, clearLastTurnToo);
        }
      }
    }
  }

  static bool canExpire(Condition condition) {
    if (
        //don't remove bane because user need to remember to remove 10hp as well
        condition == Condition.strengthen ||
            condition == Condition.stun ||
            condition == Condition.immobilize ||
            condition == Condition.muddle ||
            condition == Condition.invisible ||
            condition == Condition.disarm ||
            condition == Condition.chill ||
            condition == Condition.impair) {
      return true;
    }
    return false;
  }

  static void removeExpiringConditions(_StateModifier _, FigureState figure) {
    if (getIt<Settings>().expireConditions.value) {
      bool chillRemoved = false;
      final conditions = figure.conditions.value;
      for (int i = conditions.length - 1; i >= 0; i--) {
        Condition item = conditions[i];
        if (canExpire(item)) {
          if (item != Condition.chill || chillRemoved) {
            if (!figure.conditionsAddedThisTurn.contains(item)) {
              conditions.removeAt(i);
              figure._conditionsAddedPreviousTurn.add(item);
            }
            if (item == Condition.chill) {
              figure._chill.value--;
              chillRemoved = true;
            }
          }
        }
      }
    }
  }

  static void removeExpiringConditionsFromListItem(
      _StateModifier s, ListItemData item) {
    if (item is Character) {
      removeExpiringConditions(s, item.characterState);
      for (var summon in item.characterState._summonList) {
        removeExpiringConditions(s, summon);
      }
    } else if (item is Monster) {
      for (var instance in item._monsterInstances) {
        removeExpiringConditions(s, instance);
      }
    }
  }

  static void reapplyConditions(_StateModifier _, FigureState figure) {
    for (var condition in figure.conditionsAddedPreviousTurn) {
      final conditions = figure.conditions.value;
      if (!conditions.contains(condition) || condition == Condition.chill) {
        conditions.add(condition);
        figure._conditionsAddedThisTurn.remove(condition);
      }
      if (condition == Condition.chill) {
        figure._chill.value++;
      }
    }
  }

  static void reapplyConditionsFromListItem(
      _StateModifier s, ListItemData item) {
    if (item is Character) {
      reapplyConditions(s, item.characterState);
      for (var summon in item.characterState.summonList) {
        reapplyConditions(s, summon);
      }
    } else if (item is Monster) {
      for (var instance in item._monsterInstances) {
        reapplyConditions(s, instance);
      }
    }
  }

  //1 if item WAS done OR not done, then set it to current, all before to done, and all after to not done
  //2 if item was current: set item to done, all before to done, next to current and rest to not done
  static void setTurnDone(_StateModifier s, int index) {
    //set all before to done.
    for (int i = 0; i < index; i++) {
      if (_gameState.currentList[i].turnState.value != TurnsState.done) {
        _gameState.currentList[i]._turnState.value = TurnsState.done;
        removeExpiringConditionsFromListItem(s, _gameState.currentList[i]);
      }
    }
    //if on index is NOT current then set to current else set to done
    int newIndex = index + 1;
    if (_gameState.currentList[index].turnState.value == TurnsState.current) {
      _gameState.currentList[index]._turnState.value = TurnsState.done;
      removeExpiringConditionsFromListItem(s, _gameState.currentList[index]);
      //remove expiring conditions
    } else {
      newIndex = index;
    }

    //get next active item and set to current
    for (; newIndex < _gameState.currentList.length; newIndex++) {
      ListItemData data = _gameState.currentList[newIndex];
      if (data is Monster) {
        if (data.monsterInstances.isNotEmpty || data.isActive) {
          if (data.turnState.value == TurnsState.done) {
            reapplyConditionsFromListItem(s, data);
          }
          data._turnState.value = TurnsState.current;
          break;
        }
      } else if (data is Character) {
        if (data.characterState.health.value > 0) {
          if (data.turnState.value == TurnsState.done) {
            reapplyConditionsFromListItem(s, data);
          }
          data._turnState.value = TurnsState.current;
          break;
        }
      }
    }
    //set rest to not done
    for (int i = newIndex + 1; i < _gameState.currentList.length; i++) {
      if (_gameState.currentList[i].turnState.value == TurnsState.done) {
        reapplyConditionsFromListItem(s, _gameState.currentList[i]);
      }
      _gameState.currentList[i]._turnState.value = TurnsState.notDone;
    }
  }

  static bool isFrosthavenStyledEdition(String edition) {
    return edition == "Frosthaven" ||
        edition == "Buttons and Bugs" ||
        edition == "Gloomhaven 2nd Edition" ||
        edition == "Mercenary Packs";
  }

  static bool isFrosthavenStyle(MonsterModel? monster) {
    //frosthaven monster
    if (monster != null && isFrosthavenStyledEdition(monster.edition)) {
      return true;
    }
    //frosthaven monsters in other campaigns
    final style = getIt<Settings>().style.value;
    if (style != Style.frosthaven &&
        monster != null &&
        !isFrosthavenStyledEdition(monster.edition)) {
      return false;
    }
    //frosthaven style settings
    return style == Style.frosthaven ||
        style == Style.original &&
            isFrosthavenStyledEdition(getIt<GameState>().currentCampaign.value);
  }

  static bool isCustomCampaign(String campaign) {
    if (campaign == "Crimson Scales") {
      return true;
    }
    if (campaign == "Trail of Ashes") {
      return true;
    }
    if (campaign == "CCUG") {
      return true;
    }
    return false;
  }

  static void updateForSpecialRules(_StateModifier _) {
    List<SpecialRule>? rules = _gameData
        .modelData
        .value[_gameState.currentCampaign.value]
        ?.scenarios[_gameState.scenario.value]
        ?.specialRules;
    if (rules != null) {
      for (SpecialRule rule in rules) {
        if (rule.type == "Objective" || rule.type == "Escort") {
          Character? character = _gameState.currentList
                  .firstWhereOrNull((element) => element.id == rule.name)
              as Character?;
          if (character != null) {
            int? newHealth =
                StatCalculator.calculateFormula(rule.health.toString());
            if (newHealth != character.characterState.maxHealth.value &&
                newHealth != null) {
              character.characterState._maxHealth.value = newHealth;
              character.characterState._health.value = newHealth;
            }
          }
        } else if (rule.type == "LevelAdjust") {
          Monster? monster = _gameState.currentList
                  .firstWhereOrNull((element) => element.id == rule.name)
              as Monster?;
          if (monster != null) {
            if (_gameState.level.value == monster.level.value) {
              int newLevel = (monster.level.value + rule.level).clamp(0, 7);
              monster._level.value = newLevel;
              for (MonsterInstance instance in monster._monsterInstances) {
                instance._setLevel(monster);
              }
            }
          }
        }
      }
    }
  }

  static int? findNrFromScenarioName(String scenario) {
    String nr = scenario.substring(1);
    for (int i = 0; i < nr.length; i++) {
      if (nr[i] == ' ' || nr[i] == ".") {
        nr = nr.substring(0, i);
        return int.tryParse(nr);
      }
    }

    return null;
  }

  static void resetRound(_StateModifier _, int round, bool resetTotal) {
    _gameState._round.value = round;
    if (resetTotal) {
      _gameState._totalRounds.value = round;
    }
  }

  static void setRound(_StateModifier _, int round) {
    _gameState._round.value = round;
    _gameState._totalRounds.value++;
  }

  static void setCampaign(_StateModifier _, String campaign) {
    _gameState._currentCampaign.value = campaign;
  }

  static void imbueElement(_StateModifier _, Elements element, bool half) {
    _gameState._elementState[element] = ElementState.full;
    if (half) {
      _gameState._elementState[element] = ElementState.half;
    }
  }

  static void useElement(_StateModifier _, Elements element) {
    _gameState._elementState[element] = ElementState.inert;
  }

  static void unlockClass(_StateModifier _, String name) {
    _gameState._unlockedClasses.add(name);
  }

  static void clearUnlockedClasses(_StateModifier _) {
    getIt<GameState>()._unlockedClasses = {};
  }

  static bool isOgGloomEdition() {
    String edition = _gameState.currentCampaign.value;
    String scenario = _gameState.scenario.value;
    if (edition == "Solo") {
      //#1-19, #37-56 are og solo scenarios
      for (int i = 1; i <= 19; i++) {
        if (scenario.contains("${"#$i"} ")) {
          return true;
        }
      }
      for (int i = 37; i <= 56; i++) {
        if (scenario.contains("${"#$i"} ")) {
          return true;
        }
      }
      return false;
    }
    return edition != "Frosthaven" && edition != "Gloomhaven 2nd Edition";
  }

  static bool hasLootDeck() {
    GameState gameState = getIt<GameState>();
    bool hasLootDeck = !getIt<Settings>().hideLootDeck.value;
    if (gameState.lootDeck.discardPile.isEmpty &&
        gameState.lootDeck.drawPile.isEmpty) {
      hasLootDeck = false;
    }
    return hasLootDeck;
  }

  static bool hasRetaliate(Monster monster, MonsterInstance figure) {
    return _monsterHasConditionOnCards(monster, figure, "%retaliate%");
  }

  static bool hasShield(Monster monster, MonsterInstance figure) {
    return _monsterHasConditionOnCards(monster, figure, "%shield%");
  }

  static bool _monsterHasConditionOnCards(
      Monster monster, MonsterInstance figure, String condition) {
    bool hasCondition = false;
    //check innate value

    final level = monster.type.levels[monster.level.value];
    if (figure.type == MonsterType.normal) {
      hasCondition =
          level.normal?.attributes.indexWhere((i) => i.contains(condition)) !=
              -1;
    } else if (figure.type == MonsterType.elite) {
      hasCondition =
          level.elite?.attributes.indexWhere((i) => i.contains(condition)) !=
              -1;
    } else if (figure.type == MonsterType.boss) {
      hasCondition =
          level.boss?.attributes.indexWhere((i) => i.contains(condition)) != -1;
    }
    //check ability card
    var deck = GameMethods.getDeck(monster.type.deck);
    if (deck != null &&
        deck.discardPile.isNotEmpty &&
        monster.turnState.value != TurnsState.notDone) {
      if (deck.discardPile.peek.lines
              .firstWhereOrNull((item) => item.contains(condition)) !=
          null) {
        return true;
      }
    }
    return hasCondition;
  }
}
