part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class MutableGameMethods {
  static void resetElements(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    for (var key in gameState.elementState.keys) {
      gameState._elementState[key] = ElementState.inert;
    }
  }

  static void updateElements(_StateModifier _) {
    //elementalist special:
    bool elementalistPerk = false;
    Character? elementalist = GameMethods.getCharacterByName("Elementalist");
    if (elementalist != null && elementalist.characterState.perkList[15]) {
      if (elementalist.characterClass.edition == "Gloomhaven 2nd Edition") {
        elementalistPerk = true;
      }
    }

    final GameState gameState = getIt<GameState>();
    for (var key in gameState.elementState.keys) {
      if (gameState.elementState[key] == ElementState.full) {
        if (!elementalistPerk ||
            key == Elements.light ||
            key == Elements.dark) {
          gameState._elementState[key] = ElementState.half;
        }
      } else if (gameState.elementState[key] == ElementState.half) {
        if (!elementalistPerk ||
            key == Elements.light ||
            key == Elements.dark) {
          gameState._elementState[key] = ElementState.inert;
        }
      }
    }
  }

  static void drawAbilityCardFromInactiveDeck(_StateModifier stateModifier) {
    final GameState gameState = getIt<GameState>();
    for (MonsterAbilityState deck in gameState.currentAbilityDecks) {
      for (var item in gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.isActive &&
                !GameMethods.isInactiveForRule(item.type.name)) {
              if (deck.lastRoundDrawn != gameState.totalRounds.value) {
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
    final GameState gameState = getIt<GameState>();
    for (MonsterAbilityState deck in gameState.currentAbilityDecks) {
      for (var item in gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            bool specialInactive =
                GameMethods.isInactiveForRule(item.type.name);
            if ((item.monsterInstances.isNotEmpty && !specialInactive) ||
                (item.isActive && !specialInactive)) {
              deck.draw(stateModifier);
              //only draw once from each deck
              break;
            }
          }
        }
      }
    }
  }

  static void sortCharactersFirst(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    gameState._currentList.sort((a, b) {
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
          if (!b.isActive) {
            return -1;
          }
        }
        if (!a.isActive) {
          return 1;
        }
      }
      if (b is Monster) {
        if (!b.isActive) {
          return -1;
        }
        if (a is Monster) {
          if (!a.isActive) {
            return 1;
          }
        }
      }

      return -1;
    });
  }

  static void sortItemToPlace(_StateModifier _, String id, int initiative) {
    final GameState gameState = getIt<GameState>();
    var newList = gameState.currentList.toList();
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
      int currentItemInitiative = GameMethods.getInitiative(currentItem);
      if (currentItemInitiative > initiative && currentItemInitiative > init) {
        if (i > currentTurnItemIndex) {
          newList.insert(i, item);
          gameState._currentList = newList;
          return;
        } else {
          //in case initiative is earlier than current turn, ignore anything current turn, and earlier and place later
          int insertIndex = currentTurnItemIndex + 1;
          for (int j = currentTurnItemIndex + 1; j < newList.length; j++) {
            if (GameMethods.getInitiative(newList[j]) >= initiative) {
              insertIndex = j;
              break;
            }
          }
          newList.insert(insertIndex, item);
          gameState._currentList = newList;
          return;
        }
      }
      init =
          currentItemInitiative; //this check is for the case user has moved items around the order may be off
    }

    newList.add(item);
    gameState._currentList = newList;
  }

  static void sortByInitiative(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    gameState._currentList.sort((a, b) {
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
        if (!a.isActive) {
          if (b is Monster && !b.isActive) {
            return -1;
          }
          return 1; //inactive at bottom
        }

        //find the deck
        for (var item in gameState.currentAbilityDecks) {
          if (item.name == a.type.deck && item.discardPile.isNotEmpty) {
            aInitiative = item.discardPile.peek.initiative;
          }
        }
      }
      if (b is Character) {
        bInitiative = b.characterState.initiative.value;
      } else if (b is Monster) {
        if (!b.isActive) {
          if (a is Monster && !a.isActive) {
            return 1;
          }
          return -1; //inactive at bottom
        }
        //find the deck
        for (var item in gameState.currentAbilityDecks) {
          if (item.name == b.type.deck && item.discardPile.isNotEmpty) {
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
      final id = GameMethods.perkGfxIdToCardId(item, perk, index);
      deck.addCard(s, id, type);
    }

    final className = character.characterClass.name;
    if (index == 17 && className == "Hail") {
      getIt<GameState>().modifierDeck.addHailSpecial(s);
    }
    if (index == 16 && className == "Pain Conduit") {
      final level = character.characterState.level.value;
      character.characterState._health.value =
          character.characterClass.healthByLevel[level - 1] + 5;
      character.characterState
          .setMaxHealth(s, character.characterState._health.value);
    }
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
      getIt<GameState>().modifierDeck.removeHailSpecial(s);
    }
    if (index == 16 && className == "Pain Conduit") {
      final state = character.characterState;
      final characterClass = character.characterClass;
      final int health = characterClass.healthByLevel[state.level.value - 1];
      state.setMaxHealth(s, health);
      state.setHealth(s, health);
    }
  }

  static void setRoundState(_StateModifier _, RoundState state) {
    final GameState gameState = getIt<GameState>();
    gameState._roundState.value = state;
  }

  static void setLevel(_StateModifier s, int level, String? monsterId) {
    final GameState gameState = getIt<GameState>();
    if (monsterId == null) {
      gameState._level.value = level;
      for (var item in gameState.currentList) {
        if (item is Monster) {
          item.setLevel(s, level);
        }
      }
      updateForSpecialRules(s);
    } else {
      Monster? monster;
      for (var item in gameState.currentList) {
        if (item.id == monsterId) {
          monster = item as Monster;
        }
      }
      monster?.setLevel(s, level);
    }
  }

  static void applyDifficulty(_StateModifier s) {
    final GameState gameState = getIt<GameState>();
    if (gameState.autoScenarioLevel.value) {
      //adjust difficulty
      int newLevel =
          GameMethods.getRecommendedLevel() + gameState.difficulty.value;
      if (newLevel > 7) {
        newLevel = 7;
      }
      setLevel(s, newLevel, null);
    }
  }

  static void setCharacterLevel(
      _StateModifier s, int level, String characterId) {
    final GameState gameState = getIt<GameState>();
    Character? character;
    for (var item in gameState.currentList) {
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
      if (list.isNotEmpty && list[0].name == name) {
        int hp = health + character.characterState.level.value * multiplier;
        list[0].setMaxHealth(s, hp);
        list[0].setHealth(s, hp);
      }
    }

    applyDifficulty(s);
  }

  static void resetCharacter(_StateModifier s, Character item) {
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
    item.characterState.conditions.value.clear();
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
  }

  //todo: too long method - split
  static void setScenario(_StateModifier s, String scenario, bool section) {
    final GameState gameState = getIt<GameState>();
    final GameData gameData = getIt<GameData>();
    if (!section) {
      //first reset state
      resetRound(s, 1, true);
      gameState._showAllyDeck.value = false;
      gameState._currentAbilityDecks.clear();
      gameState._scenarioSpecialRules.clear();
      applyDifficulty(s);

      gameState.modifierDeck._initDeck();
      gameState.modifierDeckAllies._initDeck();
      gameState._sanctuaryDeck._initDeck();

      setRoundState(s, RoundState.chooseInitiative);
      gameState._scenario.value = scenario;
      gameState._scenarioSectionsAdded = [];

      List<ListItemData> newList = [];
      for (var item in gameState.currentList) {
        if (item is Character) {
          if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
            resetCharacter(s, item);
            newList.add(item);
          }
        }
      }

      gameState._currentList = newList;

      //loot deck init
      if (scenario != "custom") {
        LootDeckModel? lootDeckModel = gameData
            .modelData
            .value[gameState.currentCampaign.value]!
            .scenarios[scenario]!
            .lootDeck;
        lootDeckModel != null
            ? gameState._lootDeck = LootDeck(lootDeckModel, gameState.lootDeck)
            : gameState._lootDeck = LootDeck.from(gameState.lootDeck);
      } else {
        if (gameState.currentCampaign.value == "Frosthaven") {
          //add loot deck for random scenarios
          LootDeckModel? lootDeckModel =
              const LootDeckModel(2, 2, 2, 12, 1, 1, 1, 1, 1, 1, 0);
          gameState._lootDeck = LootDeck(lootDeckModel, gameState.lootDeck);
        } else {
          gameState._lootDeck = LootDeck.from(gameState.lootDeck);
        }
      }

      clearTurnState(s, true);
      gameState._toastMessage.value = "";
    }

    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];
    List<String> subSections = [];

    String initMessage = "";
    if (section) {
      var sectionData = gameData
          .modelData
          .value[gameState.currentCampaign.value]
          ?.scenarios[gameState.scenario.value]
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
          gameState.currentCampaign.value != "Buttons and Bugs") {
        initMessage += "Remember to choose your Battle Goals.";
      }
      if (scenario != "custom") {
        var scenarioData = gameData.modelData
            .value[gameState.currentCampaign.value]?.scenarios[scenario];
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
      addMonster(s, monster, specialRules);
    }

    if (!section) {
      shuffleDecks(s);
    }

    //hack for banner spear solo special rule
    if (scenario.contains("Banner Spear: Scouting Ambush")) {
      MonsterAbilityState deck = gameState.currentAbilityDecks
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
        gameState._showAllyDeck.value = true;
      }
      if (item.type == "Objective") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition)) {
          Character? objective = createCharacter(
              s, "Objective", null, item.name, gameState.level.value + 1);
          final health =
              StatCalculator.calculateFormula(item.health.toString());
          if (health != null) {
            objective?.characterState._maxHealth.value = health;
          }
          objective?.characterState._health.value =
              objective.characterState.maxHealth.value;
          objective?.characterState._initiative.value = item.init;
          bool add = true;
          for (var item2 in gameState.currentList) {
            //don't add duplicates
            if (item2 is Character &&
                (item2).characterState.display.value == item.name) {
              add = false;
              break;
            }
          }
          if (add && objective != null) {
            gameState._currentList.add(objective);
          }
        }
      }
      if (item.type == "Escort") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition)) {
          final objective = createCharacter(
              s, "Escort", null, item.name, gameState.level.value + 1);
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
            for (var item2 in gameState.currentList) {
              //don't add duplicates
              if (item2 is Character &&
                  (item2).characterState.display.value == item.name) {
                add = false;
                break;
              }
            }
            if (add) {
              gameState._currentList.add(objective);
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
        resetRound(s, 1, false);
      }
      if (item.type == "Unlock") {
        unlockClass(s, item.name);
        initMessage += item.note;
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
                ScenarioModel? scenarioModel = gameData
                    .modelData
                    .value[gameState.currentCampaign.value]
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

    initMessage = autoAddStandees(s, roomMonsterData, initMessage);

    if (!section) {
      gameState._scenarioSpecialRules = specialRules;
      resetElements(s);
      sortCharactersFirst(s);
    } else {
      //remove earlier times if has "ResetRound"
      if (specialRules
              .firstWhereOrNull((element) => element.type == "ResetRound") !=
          null) {
        gameState._scenarioSpecialRules.removeWhere((oldItem) {
          if (oldItem.type == "Timer") {
            return true;
          }
          return false;
        });
      }

      //overwrite earlier timers with same time.
      for (var item in specialRules) {
        if (item.type == "Timer") {
          gameState._scenarioSpecialRules.removeWhere((oldItem) {
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
      gameState._scenarioSpecialRules.addAll(specialRules);
      gameState._scenarioSectionsAdded.add(scenario);
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

    gameState.updateList.value++;

    if (!section) {
      MainList.scrollToTop();
    }

    //show init message if exists:
    if (initMessage.isNotEmpty && getIt<Settings>().showReminders.value) {
      gameState._toastMessage.value += initMessage;
    } else {
      if (getIt.isRegistered<BuildContext>()) {
        ScaffoldMessenger.of(getIt<BuildContext>()).hideCurrentSnackBar();
      }
    }
  }

  static void returnLootCard(_StateModifier s, bool top) {
    final GameState gameState = getIt<GameState>();
    var card = gameState._lootDeck._discardPile.pop();
    card.owner = "";
    if (top) {
      gameState._lootDeck._drawPile.push(card);
    } else {
      gameState._lootDeck._drawPile.insert(0, card);
    }
  }

  static void returnModifierCard(_StateModifier s, String name) {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    var card = deck._discardPile.pop();
    deck._drawPile.push(card);
  }

  static void removeCharacters(_StateModifier s, List<Character> characters) {
    List<ListItemData> newList = [];
    final GameState gameState = getIt<GameState>();
    for (var item in gameState.currentList) {
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
    gameState._currentList = newList;
    updateForSpecialRules(s);
    gameState.updateList.value++;
  }

  static void removeMonsters(_StateModifier _, List<Monster> items) {
    List<String> deckIds = [];
    List<ListItemData> newList = [];
    final GameState gameState = getIt<GameState>();
    for (var item in gameState.currentList) {
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

    gameState._currentList = newList;

    for (var deck in deckIds) {
      bool removeDeck = true;
      for (var item in gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck) {
            removeDeck = false;
          }
        }
      }

      if (removeDeck) {
        for (var item in gameState.currentAbilityDecks) {
          if (item.name == deck) {
            gameState._currentAbilityDecks.remove(item);
            break;
          }
        }
      }
    }

    gameState.updateList.value++;
  }

  static void reorderMainList(_StateModifier _, int newIndex, int oldIndex) {
    final GameState gameState = getIt<GameState>();
    gameState._currentList
        .insert(newIndex, gameState._currentList.removeAt(oldIndex));
  }

  static void addToMainList(_StateModifier _, int? index, ListItemData item) {
    List<ListItemData> newList = [];
    final GameState gameState = getIt<GameState>();
    for (var item in gameState.currentList) {
      newList.add(item);
    }
    if (index != null) {
      newList.insert(index, item);
    } else {
      newList.add(item);
    }
    gameState._currentList = newList;
  }

  //note: while this changes the game state, it is a state used also by non game related instances.
  static void setToastMessage(String message) {
    final GameState gameState = getIt<GameState>();
    gameState._toastMessage.value = message;
  }

  static void setSolo(_StateModifier _, bool solo) {
    final GameState gameState = getIt<GameState>();
    gameState._solo.value = solo;
  }

  static void shuffleDecksIfNeeded(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    for (var deck in gameState.currentAbilityDecks) {
      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle ||
          deck.drawPile.isEmpty) {
        deck._shuffle();
      }
    }
  }

  static void shuffleDecks(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    for (var deck in gameState.currentAbilityDecks) {
      deck._shuffle();
    }
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
          monster._isActive = true;
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
      sortMonsterInstances(s, monsterList);
    }
    if (monsterList.length == 1 && monster != null) {
      //first added
      final roundState = getIt<GameState>().roundState.value;
      if (roundState == RoundState.chooseInitiative) {
        sortCharactersFirst(s);
      } else if (roundState == RoundState.playTurns) {
        drawAbilityCardFromInactiveDeck(s);
        sortItemToPlace(
            s,
            monster.id,
            GameMethods.getInitiative(
                monster)); //need to only sort this one item to place
      }
    }
  }

  static void addStandee(
      int? nr, Monster data, MonsterType type, bool addAsSummon) {
    final GameState gameState = getIt<GameState>();
    if (nr != null) {
      gameState.action(AddStandeeCommand(nr, null, data.id, type, addAsSummon));
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
          gameState
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

    final GameState gameState = getIt<GameState>();
    bool add = true;
    for (var item in gameState.currentList) {
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

      final munster = createMonster(s, monster,
          (gameState.level.value + levelAdjust).clamp(0, 7), isAlly);
      if (munster != null) {
        gameState._currentList.add(munster);
      }
    }
  }

  static String autoAddStandees(_StateModifier stateModifier,
      List<RoomMonsterData> roomMonsterData, String initMessage) {
    final GameState gameState = getIt<GameState>();
    //handle room data
    int characterIndex =
        GameMethods.getCurrentCharacterAmount().clamp(2, 4) - 2;
    for (int i = 0; i < roomMonsterData.length; i++) {
      var roomMonsters = roomMonsterData[i];
      addMonster(
          stateModifier, roomMonsters.name, gameState._scenarioSpecialRules);
    }
    bool addSorted = gameState.currentCampaign.value == "Buttons and Bugs";
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
          Monster data = gameState.currentList.firstWhereOrNull(
              (element) => element.id == roomMonsters.name) as Monster;

          int eliteAmount = roomMonsters.elite[characterIndex];
          int normalAmount = roomMonsters.normal[characterIndex];

          bool isBoss = false;
          if (data.type.levels.first.boss != null) {
            isBoss = true;
          }

          for (int i = 0; i < eliteAmount; i++) {
            int randomNr = GameMethods.getRandomStandee(data);
            if (randomNr != 0) {
              elites.add(randomNr);
              executeAddStandee(stateModifier, randomNr, null,
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
              executeAddStandee(
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

  static Character? createCharacter(_StateModifier _, String id,
      String? edition, String? display, int level) {
    Character? character;
    List<CharacterClass> characters = [];
    final GameData gameData = getIt<GameData>();
    final modelData = gameData.modelData.value;
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

  static Monster? createMonster(
      _StateModifier _, String name, int? level, bool isAlly) {
    final GameData gameData = getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    final modelData = gameData.modelData.value;
    for (String key in modelData.keys) {
      monsters.addAll(modelData[key]!.monsters);
    }
    level ??= getIt<GameState>().level.value;
    return Monster(name, level, isAlly);
  }

  static void showAllyDeck(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    gameState._showAllyDeck.value = true;
  }

  static void hideAllyDeck(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    gameState._showAllyDeck.value = false;
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
    final GameState gameState = getIt<GameState>();
    for (var item in gameState._currentList) {
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

  static void removeExpiringConditions(_StateModifier _, FigureState figure) {
    if (getIt<Settings>().expireConditions.value) {
      bool chillRemoved = false;
      final conditions = figure.conditions.value;
      for (int i = conditions.length - 1; i >= 0; i--) {
        Condition item = conditions[i];
        if (GameMethods.canExpire(item)) {
          if (item != Condition.chill || !chillRemoved) {
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
    final GameState gameState = getIt<GameState>();
    //set all before to done.
    for (int i = 0; i < index; i++) {
      if (gameState.currentList[i].turnState.value != TurnsState.done) {
        gameState.currentList[i]._turnState.value = TurnsState.done;
        removeExpiringConditionsFromListItem(s, gameState.currentList[i]);
      }
    }
    //if on index is NOT current then set to current else set to done
    int newIndex = index + 1;
    if (gameState.currentList[index].turnState.value == TurnsState.current) {
      gameState.currentList[index]._turnState.value = TurnsState.done;
      removeExpiringConditionsFromListItem(s, gameState.currentList[index]);
      //remove expiring conditions
    } else {
      newIndex = index;
    }

    //get next active item and set to current
    for (; newIndex < gameState.currentList.length; newIndex++) {
      ListItemData data = gameState.currentList[newIndex];
      if (data is Monster) {
        if (data.isActive && !GameMethods.isInactiveForRule(data.type.name)) {
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
    for (int i = newIndex + 1; i < gameState.currentList.length; i++) {
      if (gameState.currentList[i].turnState.value == TurnsState.done) {
        reapplyConditionsFromListItem(s, gameState.currentList[i]);
      }
      gameState.currentList[i]._turnState.value = TurnsState.notDone;
    }
  }

  static void updateForSpecialRules(_StateModifier _) {
    final GameState gameState = getIt<GameState>();
    final GameData gameData = getIt<GameData>();
    List<SpecialRule>? rules = gameData
        .modelData
        .value[gameState.currentCampaign.value]
        ?.scenarios[gameState.scenario.value]
        ?.specialRules;
    if (rules != null) {
      for (SpecialRule rule in rules) {
        if (rule.type == "Objective" || rule.type == "Escort") {
          Character? character = gameState.currentList
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
          Monster? monster = gameState.currentList
                  .firstWhereOrNull((element) => element.id == rule.name)
              as Monster?;
          if (monster != null) {
            if (gameState.level.value == monster.level.value) {
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

  static void resetRound(_StateModifier _, int round, bool resetTotal) {
    final GameState gameState = getIt<GameState>();
    gameState._round.value = round;
    if (resetTotal) {
      gameState._totalRounds.value = round;
    }
  }

  static void setRound(_StateModifier _, int round) {
    final GameState gameState = getIt<GameState>();
    gameState._round.value = round;
    gameState._totalRounds.value++;
  }

  static void setCampaign(_StateModifier _, String campaign) {
    final GameState gameState = getIt<GameState>();
    gameState._currentCampaign.value = campaign;
  }

  static void imbueElement(_StateModifier _, Elements element, bool half) {
    final GameState gameState = getIt<GameState>();
    gameState._elementState[element] = ElementState.full;
    if (half) {
      gameState._elementState[element] = ElementState.half;
    }
  }

  static void useElement(_StateModifier _, Elements element) {
    final GameState gameState = getIt<GameState>();
    gameState._elementState[element] = ElementState.inert;
  }

  static void unlockClass(_StateModifier _, String name) {
    final GameState gameState = getIt<GameState>();
    gameState._unlockedClasses.add(name);
  }

  static void clearUnlockedClasses(_StateModifier _) {
    getIt<GameState>()._unlockedClasses = {};
  }
}
