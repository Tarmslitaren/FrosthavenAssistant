part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class MonsterMethods {
  static const int _kMinLevel = 0;
  static const int _kMaxLevel = 7;
  static const int _kMinCharacters = 2;
  static const int _kMaxCharacters = 4;
  static const int _kCharIndexOffset = 2;
  static const int _kTrailingCommaLength = 2;

  static void showAllyDeck(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._showAllyDeck.value = true;
  }

  static void hideAllyDeck(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._showAllyDeck.value = false;
  }

  static Monster? createMonster(
      _StateModifier _, String name, int? level, bool isAlly,
      {GameState? gameState, GameData? gameData}) {
    final gd = gameData ?? getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    final modelData = gd.modelData.value;
    for (String key in modelData.keys) {
      monsters.addAll(modelData[key]!.monsters);
    }
    level ??= (gameState ?? getIt<GameState>()).level.value;
    return Monster(name, level, isAlly);
  }

  static void removeMonsters(_StateModifier _, List<Monster> items, {GameState? gameState}) {
    List<String> deckIds = [];
    List<ListItemData> newList = [];
    final gs = gameState ?? getIt<GameState>();
    for (var item in gs.currentList) {
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

    gs._currentList = newList;

    for (var deck in deckIds) {
      bool removeDeck = true;
      for (var item in gs.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck) {
            removeDeck = false;
          }
        }
      }

      if (removeDeck) {
        for (var item in gs.currentAbilityDecks) {
          if (item.name == deck) {
            gs._currentAbilityDecks.remove(item);
            break;
          }
        }
      }
    }

    gs._notifyCurrentList();
  }

  static void executeAddStandee(
      _StateModifier s,
      final int nr,
      final SummonData? summon,
      final MonsterType type,
      final String ownerId,
      final bool addAsSummon,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    MonsterInstance instance;
    Monster? monster;
    if (summon == null) {
      for (var item in gs.currentList) {
        if (item.id == ownerId && item is Monster) {
          monster = item;
          monster._isActive = true;
          break;
        }
      }
      if (monster == null) return;
      instance = MonsterInstance(nr, type, addAsSummon, monster);
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
          gs.round.value);
    }

    List<MonsterInstance> monsterList = [];
    Character? character;
    //find list
    if (monster != null) {
      monsterList = monster._monsterInstances;
    } else {
      for (var item in gs.currentList) {
        if (item.id == ownerId) {
          character = item as Character;
          monsterList = character.characterState._summonList;
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
                  gs.round.value);
              ok = false;
            }
          }
        }
      }
    }

    monsterList.add(instance);
    if (monster != null) {
      RoundMethods.sortMonsterInstances(s, monsterList);
      monster._notifyMonsterInstances();
    } else {
      character?.characterState._notifySummonList();
    }
    if (monsterList.length == 1 && monster != null) {
      //first added
      final roundState = gs.roundState.value;
      if (roundState == RoundState.chooseInitiative) {
        RoundMethods.sortCharactersFirst(s);
      } else if (roundState == RoundState.playTurns) {
        DeckMethods.drawAbilityCardFromInactiveDeck(s);
        RoundMethods.sortItemToPlace(
            s,
            monster.id,
            GameMethods.getInitiative(
                monster)); //need to only sort this one item to place
      }
    }
  }

  static void addStandee(
      int? nr, Monster data, MonsterType type, bool addAsSummon,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    if (nr != null) {
      gs.action(AddStandeeCommand(nr, null, data.id, type, addAsSummon,
          gameState: gs));
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
          gs.action(AddStandeeCommand(i, null, data.id, type, addAsSummon,
              gameState: gs));
          return;
        }
      }
    }
  }

  static void addMonster(
      _StateModifier s, String monster, List<SpecialRule> specialRules,
      {GameState? gameState}) {
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

    final gs = gameState ?? getIt<GameState>();
    bool add = true;
    for (var item in gs.currentList) {
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
          (gs.level.value + levelAdjust).clamp(_kMinLevel, _kMaxLevel), isAlly);
      if (munster != null) {
        gs._currentList.add(munster);
      }
    }
  }

  static String autoAddStandees(_StateModifier stateModifier,
      List<RoomMonsterData> roomMonsterData, String initMessage,
      {GameState? gameState, Settings? settings}) {
    final gs = gameState ?? getIt<GameState>();
    //handle room data
    int characterIndex =
        GameMethods.getCurrentCharacterAmount().clamp(_kMinCharacters, _kMaxCharacters) - _kCharIndexOffset;
    for (int i = 0; i < roomMonsterData.length; i++) {
      var roomMonsters = roomMonsterData[i];
      addMonster(
          stateModifier, roomMonsters.name, gs._scenarioSpecialRules);
    }
    bool addSorted = gs.currentCampaign.value == "Buttons and Bugs";
    final s = settings ?? getIt<Settings>();
    if (!s.noStandees.value && s.autoAddStandees.value) {
      if (s.randomStandees.value || addSorted) {
        if (initMessage.isNotEmpty && !addSorted) {
          initMessage += "\n";
        }
        for (int i = 0; i < roomMonsterData.length; i++) {
          List<int> normals = [];
          List<int> elites = [];
          var roomMonsters = roomMonsterData[i];
          Monster data = gs.currentList.firstWhereOrNull(
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
                      initMessage.substring(0, initMessage.length - _kTrailingCommaLength);
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
                      initMessage.substring(0, initMessage.length - _kTrailingCommaLength);
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
}
