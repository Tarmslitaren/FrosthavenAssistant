part of game_state;

GameState _gameState = getIt<GameState>();

class GameMethods {
  static void updateElements() {
    for (var key in _gameState.elementState.keys) {
      if (_gameState._elementState[key] == ElementState.full) {
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
    return 1 + (_gameState.level.value / 3.0).ceil();
  }

  static int getXPValue() {
    return 4 + 2 * _gameState.level.value;
  }

  static int getCoinValue() {
    if (_gameState.level.value == 7) {
      return 6;
    }
    return 2 + (_gameState.level.value / 2.0).floor();
  }

  static int getRecommendedLevel() {
    double totalLevels = 0;
    double nrOfCharacters = 0;
    for (var item in _gameState.currentList) {
      if (item is Character && item.characterClass.name != "Escort" && item.characterClass.name != "Objective") {
        totalLevels += item.characterState.level.value;
        nrOfCharacters++;
      }
    }
    if (nrOfCharacters == 0) {
      return 1;
    }
    if (_gameState.solo.value == true) {
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

  static void addAbilityDeck(Monster monster) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      if (deck.name == monster.type.deck) {
        return;
      }
    }
    _gameState._currentAbilityDecks.add(MonsterAbilityState(monster.type.deck));
  }

  static bool canDraw() {
    if(_gameState.currentList.isEmpty) {
      return false;
    }
    if (getIt<Settings>().noInit.value == true) {
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

  static void drawAbilityCardFromInactiveDeck() {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.value.isNotEmpty || item.isActive) {
              if (deck.lastRoundDrawn != _gameState.round.value) {
                deck.draw();
                break;
              }
            }
          }
        }
      }
    }
  }

  static void drawAbilityCards() {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.value.isNotEmpty || item.isActive) {
              deck.draw();
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

  static void sortCharactersFirst() {
    //late List<ListItemData> newList = List.from(_gameState.currentList);
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
          if (b.monsterInstances.value.isEmpty && !b.isActive) {
            return -1;
          }
        }
        if (a.monsterInstances.value.isEmpty && !a.isActive) {
          return 1;
        }
      }
      if (b is Monster) {
        if (b.monsterInstances.value.isEmpty && !b.isActive) {
          return -1;
        }
        if (a is Monster) {
          if (a.monsterInstances.value.isEmpty && !a.isActive) {
            return 1;
          }
        }
      }

      return -1;
    });
    //_gameState.currentList = newList;
  }

  static int getInitiative(ListItemData item) {
    if(item is Character) {
      return item.characterState.initiative.value;
    } else if (item is Monster) {
      if (item.monsterInstances.value.isEmpty && !item.isActive) {
        return 99; //sorted last
      }
      for (var deck in _gameState.currentAbilityDecks) {
        if (deck.name == item.type.deck) {
          if(deck.discardPile.isNotEmpty) {
            return deck.discardPile.peek.initiative;
          }
        }
      }
    }
    return 0;
  }

  static void sortItemToPlace(String id, int initiative) {
    var newList = _gameState.currentList.toList();
    ListItemData? item;
    int currentTurnItemIndex = 0;
    for (int i = 0; i < newList.length; i++) {
      if(newList[i].turnState == TurnsState.current) {
        currentTurnItemIndex = i;
      }
      if(newList[i].id == id) {
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
      if(currentItemInitiative > initiative && currentItemInitiative > init) {
        if(i > currentTurnItemIndex) {
          newList.insert(i, item);
          _gameState._currentList = newList;
          return;
        } else {
          //in case initiative is earlier than current turn, place just after current turn item
          newList.insert(currentTurnItemIndex+1, item);
          _gameState._currentList = newList;
          return;
        }
      }
      init = currentItemInitiative; //this check is for the case user has moved items around the order may be off
    }

    newList.add(item);
    _gameState._currentList = newList;
  }

  static void sortByInitiative() {
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
        if (a.monsterInstances.value.isEmpty && !a.isActive) {
          if (b is Monster && b.monsterInstances.value.isEmpty && !b.isActive) {
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
        if (b.monsterInstances.value.isEmpty && ! b.isActive) {
          if (a is Monster && a.monsterInstances.value.isEmpty && !a.isActive) {
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

  static void sortMonsterInstances(List<MonsterInstance> instances) {
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

  static List<Character> getCurrentCharacters() {
    List<Character> characters = [];
    for (ListItemData data in _gameState.currentList) {
      if (data is Character && data.characterClass.name != "Escort" && data.characterClass.name != "Objective") {
        characters.add(data);
      }
    }
    return characters;
  }

  static int getCurrentCharacterAmount() {
    int res = 0;
    for (ListItemData data in _gameState.currentList) {
      if (data is Character){
        if (data.characterClass.name != "Escort" && data.characterClass.name != "Objective") {
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

  static void setRoundState(RoundState state) {
    _gameState._roundState.value = state;
  }

  static void setLevel(int level) {
    _gameState._level.value = level;
  }

  static void setScenario(String scenario, bool section) {
    if (!section) {
      //first reset state
      GameMethods.setRound(1);
      _gameState._currentAbilityDecks.clear();
      _gameState._scenarioSpecialRules.clear();
      List<ListItemData> newList = [];
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.characterClass.name != "Objective" && item.characterClass.name != "Escort") {
            item.characterState.initiative.value = 0;
            item.characterState.health.value =
            item.characterClass.healthByLevel[item.characterState.level.value -
                1];
            item.characterState.maxHealth.value = item.characterState.health.value;
            item.characterState.xp.value = 0;
            item.characterState.conditions.value.clear();
            item.characterState.summonList.value.clear();

            if(item.id == "Beast Tyrant") {
              //create the bear summon
              final int bearHp = 8 + item.characterState.level.value * 2;
              MonsterInstance bear = MonsterInstance.summon(
                  0, MonsterType.summon, "Bear", bearHp, 3, 2, 0, "beast", -1);
              item.characterState.summonList.value.add(bear);
            }

            newList.add(item);
          }
        }
      }

      _gameState.modifierDeck.initDeck("");
      _gameState.modifierDeckAllies.initDeck("Allies");
      _gameState._currentList = newList;

      //loot deck init
      if (scenario != "custom") {
        LootDeckModel? lootDeckModel = _gameState.modelData.value[_gameState
            .currentCampaign.value]!.scenarios[scenario]!.lootDeck;
        if (lootDeckModel != null) {
          _gameState._lootDeck = LootDeck(lootDeckModel, _gameState.lootDeck);
        } else {
          _gameState._lootDeck = LootDeck.from(_gameState.lootDeck);
        }
      } else {
        _gameState._lootDeck = LootDeck.from(_gameState.lootDeck);
      }

      GameMethods.clearTurnState(true);
      _gameState._toastMessage.value = "";
    }


    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];

    String initMessage = "";
    if (section) {
      var sectionData = _gameState.modelData.value[_gameState
          .currentCampaign.value]?.scenarios[_gameState.scenario.value]?.sections.firstWhere((element) => element.name == scenario);
      if(sectionData != null) {
        monsters = sectionData.monsters;
        specialRules = sectionData.specialRules.toList();
        initMessage = sectionData.initMessage;
        roomMonsterData = sectionData.monsterStandees != null ? sectionData.monsterStandees! : [];
      }
    }else{
      if(scenario != "custom") {
        var scenarioData = _gameState.modelData.value[_gameState
            .currentCampaign.value]?.scenarios[scenario];
        if (scenarioData != null) {
          monsters = scenarioData.monsters;
          specialRules = scenarioData.specialRules.toList();
          initMessage = scenarioData.initMessage;
          roomMonsterData = scenarioData.monsterStandees != null ? scenarioData.monsterStandees!.toList() : [];
        }
      }
    }

    //handle special rules
    for (String monster in monsters) {
      GameMethods.addMonster(monster, specialRules);
    }

    if (!section) {
      GameMethods.shuffleDecks();
    }

    //hack for banner spear solo special rule
    if (scenario.contains("Banner Spear: Scouting Ambush") ) {
      MonsterAbilityState deck = _gameState.currentAbilityDecks.firstWhere((element) => element.name.contains("Scout"));
      List<MonsterAbilityCardModel> list = deck.drawPile.getList();
      for (int i = 0; i < list.length; i++) {
        if(list[i].title == "Rancid Arrow") {
          list.add(list.removeAt(i));
          break;
        }
      }
    }

    //add objectives and escorts
    for(var item in specialRules) {
      if(item.type == "Objective"){
        if (item.condition == ""  || StatCalculator.evaluateCondition(item.condition)) {
          Character objective = GameMethods.createCharacter(
              "Objective", item.name, _gameState.level.value + 1)!;
          objective.characterState.maxHealth.value =
          StatCalculator.calculateFormula(item.health.toString())!;
          objective.characterState.health.value =
              objective.characterState.maxHealth.value;
          objective.characterState.initiative.value = item.init;
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
      if (item.type == "Escort") {
        Character objective = GameMethods.createCharacter("Escort", item.name, _gameState.level.value+1)!;
        objective.characterState.maxHealth.value = StatCalculator.calculateFormula(item.health.toString())!;
        objective.characterState.health.value = objective.characterState.maxHealth.value;
        objective.characterState.initiative.value = item.init;
        bool add = true;
        for (var item2 in _gameState.currentList) {
          //don't add duplicates
          if(item2 is Character && (item2).characterState.display.value == item.name) {
            add = false;
            break;
          }
        }
        if(add) {
          _gameState._currentList.add(objective);
        }
      }

      //special case for start of round and round is 1
      if(!section) {
        if (item.type == "Timer" && item.startOfRound == true) {
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
        GameMethods.setRound(1);
      }
    }

    //in case of spawns at round 1 start of round, add to roomMonsterData
    for (var rule in specialRules) {
      if (rule.type == "Timer" && rule.startOfRound == true) {
        for (int round in rule.list) {
          //minus 1 means always
          if (round == 1|| round == -1) {
            if(getIt<Settings>().autoAddSpawns.value == true) {
              if (rule.name.isNotEmpty) {
                //get room data and deal with spawns
                ScenarioModel? scenarioModel = _gameState.modelData.value[_gameState
                    .currentCampaign.value]?.scenarios[scenario];
                if (scenarioModel != null) {
                  ScenarioModel? spawnSection = scenarioModel.sections.firstWhereOrNull((
                      element) => element.name.substring(1) == rule.name);
                  if (spawnSection != null && spawnSection.monsterStandees != null) {
                    bool existed = false;
                    for(var spawnItem in spawnSection.monsterStandees!) {
                      var item = roomMonsterData.firstWhereOrNull((element) => element.name == spawnItem.name);
                      if(item != null) {
                        //merge
                        item.elite[0]+=spawnItem.elite[0];
                        item.elite[1]+=spawnItem.elite[1];
                        item.elite[2]+=spawnItem.elite[2];
                        item.normal[0]+=spawnItem.normal[0];
                        item.normal[1]+=spawnItem.normal[1];
                        item.normal[2]+=spawnItem.normal[2];
                      }else {
                        roomMonsterData.add(spawnItem);
                      }
                    }

                    if(!existed) {
                      roomMonsterData.addAll(spawnSection.monsterStandees!);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    initMessage = GameMethods.autoAddStandees(roomMonsterData, initMessage);

    if (!section) {
      _gameState._scenarioSpecialRules = specialRules;

      //todo: create a gamestate set scenario method to handle all these
      GameMethods.updateElements();
      GameMethods.updateElements(); //twice to make sure they are inert.
      GameMethods.setRoundState(RoundState.chooseInitiative);
      GameMethods.sortCharactersFirst();
      _gameState._scenario.value = scenario;
      _gameState._scenarioSectionsAdded = [];
    }else {
      //remove earlier times if has "ResetRound"
      if(specialRules.firstWhereOrNull((element) => element.type == "ResetRound") != null) {
        _gameState._scenarioSpecialRules.removeWhere((oldItem) {
          if(oldItem.type == "Timer") {
            return true;
          }
          return false;
        });
      }

      //overwrite earlier timers with same time.
      for (var item in specialRules) {
        if(item.type == "Timer") {
          _gameState._scenarioSpecialRules.removeWhere((oldItem) {
            if(oldItem.type == "Timer" && item.startOfRound == oldItem.startOfRound) {
              if(item.list.contains(-1) || oldItem.list.contains(-1)) {
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

    _gameState.updateList.value++;

    if (!section) {
      MainList.scrollToTop();
    }

    //show init message if exists:
    if(initMessage.isNotEmpty && getIt<Settings>().showReminders.value == true) {
      _gameState._toastMessage.value += initMessage;
    } else {
      ScaffoldMessenger.of(getIt<BuildContext>()).hideCurrentSnackBar();
    }
  }

  static void removeCharacters(List<Character> characters) {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Character) {
        bool remove = false;
        for (var name in characters) {
          if (item.characterState.display.value == name.characterState.display.value) {
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
    GameMethods.updateForSpecialRules();
    _gameState.updateList.value++;
  }

  static void removeMonsters(List<Monster> items) {
    List<String> deckIds = [];
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        bool remove = false;
        for(var name in items) {
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
      for(var item in _gameState.currentList) {
        if (item is Monster){
          if(item.type.deck == deck){
            removeDeck = false;
          }
        }
      }

      if(removeDeck) {
        for (var item in _gameState.currentAbilityDecks) {
          if(item.name == deck) {
            _gameState._currentAbilityDecks.remove(item);
            break;
          }
        }
      }
    }

    _gameState.updateList.value++;
  }

  static void reorderMainList(int newIndex, int oldIndex) {
    _gameState._currentList.insert(newIndex,
        _gameState._currentList.removeAt(oldIndex));
  }

  static void addToMainList(int? index, ListItemData item) {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      newList.add(item);
    }
    if(index != null) {
      newList.insert(index, item);
    } else {
      newList.add(item);
    }
    _gameState._currentList = newList;
  }

  static void setToastMessage(String message) {
    _gameState._toastMessage.value = message;
  }

  static void setSolo(bool solo) {
    _gameState._solo.value = solo;
  }

  static void shuffleDecksIfNeeded() {
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle || deck.drawPile.isEmpty == true) {
        deck.shuffle();
      }
    }
  }

  static void shuffleDecks() {
    for (var deck in _gameState.currentAbilityDecks) {
      deck.shuffle();
    }
  }

  static int getRandomStandee(Monster data) {
    //TODO: handle standees used by other special monsters
    int nrOfStandees = data.type.count;
    List<int> available = [];
    for (int i = 0; i < nrOfStandees; i++) {
      bool isAvailable = true;
      for (var item in data.monsterInstances.value) {
        if (item.standeeNr == i + 1) {
          isAvailable = false;
          break;
        }
      }
      if(isAvailable) { //check for special monsters with same standees
        for (var item in _gameState.currentList) {
          if (item is Monster) {
            if (item.id != data.id) {
              if (item.type.gfx == data.type.gfx) {
                for (var standee in item.monsterInstances.value) {
                  if (standee.standeeNr == i + 1) {
                    isAvailable = false;
                    break;
                  }
                }
              }
            }
          }
          if(!isAvailable) {
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

  static void executeAddStandee(  final int nr, final SummonData? summon, final MonsterType type, final String ownerId, final bool addAsSummon) {
    MonsterInstance instance;
    Monster? monster;
    if (summon == null) {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId && item is Monster) {
          monster = item;
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

    List<MonsterInstance> newList = [];
    ValueNotifier<List<MonsterInstance>>? monsterList;
    //find list
    if (monster != null) {
      monsterList = monster.monsterInstances;
    } else {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          monsterList = (item as Character).characterState.summonList;
          break;
        }
      }
    }

    //make sure summons can not have same gfx and nr:
    if (instance.standeeNr != 0) {
      bool ok = false;
      while (!ok) {
        ok = true;
        for (var item in monsterList!.value) {
          if (item.standeeNr == instance.standeeNr) {
            if (item.gfx == instance.gfx) {
              //can not have same gfx and nr
              instance = MonsterInstance.summon(
                  instance.standeeNr + 1,
                  type,
                  summon!.name,
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

    newList.addAll(monsterList!.value);
    newList.add(instance);

    if (monster != null) {
      GameMethods.sortMonsterInstances(newList);
    }
    monsterList.value = newList;
    if (monsterList.value.length == 1 && monster != null) {
      //first added
      if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst();
      } else if (getIt<GameState>().roundState.value == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck();
        GameMethods.sortItemToPlace(
            monster.id,
            GameMethods.getInitiative(
                monster)); //need to only sort this one item to place
      }
    }
  }

  static void addStandee(int? nr, Monster data, MonsterType type, bool addAsSummon) {
    if (nr != null) {
      _gameState.action(AddStandeeCommand(nr, null, data.id, type, addAsSummon));
    } else {
      //add first un added nr
      for (int i = 1; i <= data.type.count; i++) {
        bool added = false;
        for (var item in data.monsterInstances.value) {
          if (item.standeeNr == i) {
            added = true;
            break;
          }
        }
        if (!added) {
          _gameState.action(AddStandeeCommand(i, null, data.id, type, addAsSummon));
          return;
        }
      }
    }
  }

  static void addMonster(String monster, List<SpecialRule> specialRules) {
    int levelAdjust = 0;
    Set<String> alliedMonsters = {};
    for (var rule in specialRules) {
      if(rule.name == monster) {
        if(rule.type == "LevelAdjust") {
          levelAdjust = rule.level;
        }
      }
      if(rule.type == "Allies"){
        for (String item in rule.list){
          alliedMonsters.add(item);
        }
      }
    }

    bool add = true;
    for (var item in _gameState.currentList) {
      //don't add duplicates
      if(item.id == monster) {
        add = false;
        break;
      }
    }
    if(add) {
      bool isAlly = false;
      if(alliedMonsters.contains(monster)){
        isAlly = true;
      }
      _gameState._currentList.add(GameMethods.createMonster(
          monster, (_gameState.level.value + levelAdjust).clamp(0, 7), isAlly)!);
    }
  }

  static String autoAddStandees(List<RoomMonsterData> roomMonsterData, String initMessage) {
    //handle room data
    int characterIndex = GameMethods.getCurrentCharacterAmount().clamp(2, 4) - 2;
    for (int i = 0; i < roomMonsterData.length; i++) {
      var roomMonsters = roomMonsterData[i];
      addMonster(roomMonsters.name, _gameState._scenarioSpecialRules);
    }
    if(getIt<Settings>().noStandees.value != true && getIt<Settings>().autoAddStandees.value != false) {
      if (getIt<Settings>().randomStandees.value == true) {
        if (initMessage.isNotEmpty) {
          initMessage += "\n";
        }
        for (int i = 0; i < roomMonsterData.length; i++) {
          List<int> normals = [];
          List<int> elites = [];
          var roomMonsters = roomMonsterData[i];
          Monster data = _gameState.currentList.firstWhereOrNull((
              element) => element.id == roomMonsters.name) as Monster;

          int eliteAmount = roomMonsters.elite[characterIndex];
          int normalAmount = roomMonsters.normal[characterIndex];

          bool isBoss = false;
          if(data.type.levels[0].boss != null) {
            isBoss = true;
          }

          for (int i = 0; i < eliteAmount; i++) {
            int randomNr = GameMethods.getRandomStandee(data);
            if (randomNr != 0) {
              elites.add(randomNr);
              GameMethods.executeAddStandee(
                  randomNr, null, MonsterType.elite, data.id, false);
            }
          }

          for (int i = 0; i < normalAmount; i++) {
            int randomNr = GameMethods.getRandomStandee(data);
            if (randomNr != 0) {
              normals.add(randomNr);
              GameMethods.executeAddStandee(
                  randomNr, null, isBoss ? MonsterType.boss : MonsterType.normal, data.id, false);
            }
          }

          if(elites.isNotEmpty || normals.isNotEmpty) {
            elites.sort();
            normals.sort();
            if (i != 0) {
              initMessage += "\n";
            }
            initMessage += "${data.type.display} added - ";

            if(elites.isNotEmpty) {
              initMessage += "Elite: ";
              for(int i = 0; i < elites.length; i++) {
                initMessage += "${elites[i]}, ";
                if (i == elites.length - 1) {
                  initMessage = initMessage.substring(0, initMessage.length - 2);
                }
              }
            }
            if(normals.isNotEmpty) {
              if(isBoss) {
                //only numbers matter
              } else {
                if(elites.isNotEmpty) {
                  initMessage += ", ";
                }
                initMessage += "Normal: ";
              }
              for(int i = 0; i < normals.length; i++) {
                initMessage += "${normals[i]}, ";
                if (i == normals.length - 1) {
                  initMessage = initMessage.substring(0, initMessage.length - 2);
                }
              }
            }
          }
        }
      } else {
        if (roomMonsterData.isNotEmpty) {
          openDialogWithDismissOption(
              getIt<BuildContext>(),
              AutoAddStandeeMenu(
                monsterData: roomMonsterData,
              ),
              false
          );
        }
      }
    }
    return initMessage;
  }

  static FigureState? getFigure(String ownerId, String figureId) {
    for(var item in getIt<GameState>().currentList) {
      if(item.id == figureId) {
        return (item as Character).characterState;
      }
      if(item.id == ownerId){
        if(item is Monster) {

          for (var instance in item.monsterInstances.value) {
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
            if(id == figureId){
              return instance;
            }
          }
        }else if(item is Character){
          for (var instance in item.characterState.summonList.value){
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
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
    for(var item in getIt<GameState>().currentList) {
      if(item.id == ownerId){
        if(item is Monster) {
          for (var instance in item.monsterInstances.value) {
            if(instance.standeeNr == nr){
              return instance.name + instance.gfx + instance.standeeNr.toString();
            }
          }
        }
      }
    }
    return "";
  }

  static Character? createCharacter(String name, String? display, int level) {

    Character? character;
    List<CharacterClass> characters = [];
    for (String key in _gameState.modelData.value.keys){
      characters.addAll(
          _gameState.modelData.value[key]!.characters
      );
    }
    for (CharacterClass characterClass in characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;

        if (name == "Escort" || name == "Objective") {
          characterState.initiative.value = 99;
        }
        characterState.health.value = characterClass.healthByLevel[level - 1];
        characterState.maxHealth.value = characterState.health.value;

        characterState.display.value = name;
        if (display != null) {
          characterState.display.value = display;
        }
        character = Character(characterState, characterClass);

        if(name == "Beast Tyrant") {
          //create the bear summon
          final int bearHp = 8 + characterState.level.value * 2;

          MonsterInstance bear = MonsterInstance.summon(
              0, MonsterType.summon, "Bear", bearHp, 3, 2, 0, "beast", -1);

          character.characterState.summonList.value.add(bear);
        }

        break;
      }
    }
    return character;
  }

  static Monster? createMonster(String name, int? level, bool isAlly) {
    Map<String, MonsterModel> monsters = {};
    for (String key in _gameState.modelData.value.keys) {
      monsters.addAll(_gameState.modelData.value[key]!.monsters);
    }
    level ??= getIt<GameState>().level.value;
    Monster monster = Monster(name, level, isAlly: isAlly);
    return monster;
  }

  static bool hasAllies(){
    for (var item in _gameState.currentList) {
      if (item is Monster) {
        if (item.isAlly) {
          return true;
        }
      }
    }
    return false;
  }

  static void clearTurnStateConditions(FigureState figure, bool clearLastTurnToo) {
    if(!clearLastTurnToo){
      figure.conditionsAddedPreviousTurn.value = figure.conditionsAddedThisTurn.value.toSet();
    } else {
      figure.conditionsAddedPreviousTurn.value.clear();
    }
    if(!clearLastTurnToo) {
      if (figure.conditionsAddedThisTurn.value.contains(Condition.chill)) {
        figure.chill.value--;
        if(figure.chill.value > 0){
          figure.conditionsAddedThisTurn.value = {Condition.chill};
        } else {
          figure.conditionsAddedThisTurn.value.clear();
        }
      } else {
        figure.conditionsAddedThisTurn.value.clear();
      }
    } else {
      figure.conditionsAddedThisTurn.value.clear();
    }

  }

  static void clearTurnState(bool clearLastTurnToo){
    for (var item in _gameState.currentList) {
      item.turnState = TurnsState.notDone;
      if(item is Character) {
        clearTurnStateConditions(item.characterState, clearLastTurnToo);
        for (var instance in item.characterState.summonList.value) {
          clearTurnStateConditions(instance, clearLastTurnToo);
        }

      } else if(item is Monster) {
        for (var instance in item.monsterInstances.value) {
          clearTurnStateConditions(instance, clearLastTurnToo);
        }
      }
    }
  }

  static bool canExpire(Condition condition) {
    //TODO look it up
    if(
    //condition == Condition.bane || //don't remove bane because user need to remember to remove 10hp as well
        condition == Condition.strengthen ||
        condition == Condition.stun ||
        condition == Condition.immobilize ||
        condition == Condition.muddle ||
        condition == Condition.invisible ||
        condition == Condition.disarm ||
        condition == Condition.chill ||
        condition == Condition.impair
    ) {
     return true;
    }
    return false;
  }

  static void removeExpiringConditions(FigureState figure) {
    if(getIt<Settings>().expireConditions.value == true) {
      bool chillRemoved = false;
      for (int i = figure.conditions.value.length-1; i >= 0; i--) {
        Condition item = figure.conditions.value[i];
        if (canExpire(item)) {
          if(item != Condition.chill || chillRemoved == false) {
            if (!figure.conditionsAddedThisTurn.value.contains(item)) {
              figure.conditions.value.removeAt(i);
              figure.conditionsAddedPreviousTurn.value.add(item);
            }
            if (item == Condition.chill) {
              figure.chill.value--;
              chillRemoved = true;
            }
          }
        }
      }
    }
  }

  static void removeExpiringConditionsFromListItem(ListItemData item) {
    if(item is Character) {
      removeExpiringConditions(item.characterState);
      for (var summon in item.characterState.summonList.value) {
        removeExpiringConditions(summon);
      }
    } else if (item is Monster) {
      for (var instance in item.monsterInstances.value) {
        removeExpiringConditions(instance);
      }
    }
  }

  static void reapplyConditions(FigureState figure) {
    for(var condition in figure.conditionsAddedPreviousTurn.value) {
      if(!figure.conditions.value.contains(condition) || condition == Condition.chill) {
        figure.conditions.value.add(condition);
        figure.conditionsAddedThisTurn.value.remove(condition);
      }
      if(condition == Condition.chill) {
        figure.chill.value++;
      }
    }
  }

  static void reapplyConditionsFromListItem(ListItemData item) {
    if(item is Character) {
      reapplyConditions(item.characterState);
      for (var summon in item.characterState.summonList.value) {
        reapplyConditions(summon);
      }
    } else if (item is Monster) {
      for (var instance in item.monsterInstances.value) {
        reapplyConditions(instance);
      }
    }
  }

  static void setTurnDone(int index) {
    for (int i = 0; i < index; i++) {
      if(_gameState.currentList[i].turnState != TurnsState.done) {
        _gameState.currentList[i].turnState = TurnsState.done;
        removeExpiringConditionsFromListItem(_gameState.currentList[i]);
      }

    }
    //if on index is NOT current then set to current else set to done
    int newIndex = index + 1;
    if (_gameState.currentList[index].turnState == TurnsState.current){
      _gameState.currentList[index].turnState = TurnsState.done;
      removeExpiringConditionsFromListItem(_gameState.currentList[index]);
      //remove expiring conditions

    }else {
      newIndex = index;
    }
    for ( ; newIndex < _gameState.currentList.length; newIndex++) {
      ListItemData data = _gameState.currentList[newIndex];
      if(data is Monster){
        if (data.monsterInstances.value.isNotEmpty || data.isActive){
          if(data.turnState == TurnsState.done) {
            reapplyConditionsFromListItem(data);
          }
          data.turnState = TurnsState.current;
          break;
        }
      }
      else if(data is Character){
        if (data.characterState.health.value > 0){
          if(data.turnState == TurnsState.done) {
            reapplyConditionsFromListItem(data);
          }
          data.turnState = TurnsState.current;
          break;
        }
      }
    }
    for (int i = newIndex+1; i < _gameState.currentList.length; i++) {
      if(_gameState.currentList[i].turnState == TurnsState.done) {
        reapplyConditionsFromListItem(_gameState.currentList[i]);
      }
      _gameState.currentList[i].turnState = TurnsState.notDone;

    }
  }

  static bool isFrosthavenStyle(MonsterModel? monster) {
    if(monster != null && monster.edition == "Frosthaven") {
      return true;
    }
    if(getIt<Settings>().style.value != Style.frosthaven && monster != null && monster.edition != "Frosthaven") {
      return false;
    }
    bool frosthavenStyle = getIt<Settings>().style.value == Style.frosthaven ||
        getIt<Settings>().style.value == Style.original && getIt<GameState>().currentCampaign.value == "Frosthaven";
    return frosthavenStyle;
  }

  static bool isCustomCampaign(String campaign) {
    if(campaign == "Crimson Scales") {
      return true;
    }
    if(campaign == "Trail of Ashes") {
      return true;
    }
    return false;
  }

  static void updateForSpecialRules() {
    List<SpecialRule>? rules = _gameState.modelData.value[_gameState.currentCampaign.value]?.scenarios[_gameState.scenario.value]?.specialRules;
    if(rules != null) {
      for(SpecialRule rule in rules) {
        if(rule.type == "Objective" || rule.type == "Escort") {
          Character? character = _gameState.currentList.firstWhereOrNull((element) => element.id == rule.name) as Character?;
          if(character != null) {
            int newHealth = StatCalculator.calculateFormula(rule.health.toString())!;
            if(newHealth != character.characterState.maxHealth.value) {
              character.characterState.maxHealth.value = newHealth;
              character.characterState.health.value = newHealth;
            }
          }
        } else if ( rule.type == "LevelAdjust") {
          Monster? monster = _gameState.currentList.firstWhereOrNull((element) => element.id == rule.name) as Monster?;
          if(monster != null) {
            if(_gameState.level.value == monster.level.value) {
              int newLevel = (monster.level.value + rule.level).clamp(0, 7);
              monster.level.value = newLevel;
              for(MonsterInstance instance in monster.monsterInstances.value) {
                instance.setLevel(monster);
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
        int? number = int.tryParse(nr);
        return number;
      }
    }

    return null;
  }

  static void setRound(int round) {
    _gameState._round.value = round;
  }

  static void setCampaign(String campaign) {
    _gameState._currentCampaign.value = campaign;
  }

  static void imbueElement(Elements element, bool half) {
    _gameState._elementState[element] = ElementState.full;
    if (half) {
      _gameState._elementState[element] = ElementState.half;
    }
  }

  static void useElement(Elements element) {
    _gameState._elementState[element] = ElementState.inert;
  }

  static void unlockClass(String name) {
    _gameState._unlockedClasses.add(name);
  }

  static void clearUnlockedClasses() {
    getIt<GameState>()._unlockedClasses = {};
  }
}
