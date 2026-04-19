part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class ScenarioMethods {
  static const int _kMinLevel = 0;
  static const int _kMaxLevel = 7;
  static const int _kRound1 = 1;
  static const int _kTimerAlways = -1;
  static const int _kRandomSectionCount = 3;

  static void setCampaign(_StateModifier _, String campaign, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._currentCampaign.value = campaign;
  }

  static void setSolo(_StateModifier _, bool solo, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._solo.value = solo;
  }

  static void unlockClass(_StateModifier _, String name, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses.add(name);
  }

  static void clearUnlockedClasses(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses = {};
  }

  static void clearUnlockedClass(_StateModifier _, String id, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses.remove(id);
  }

  static void setLevel(_StateModifier s, int level, String? monsterId, {GameState? gameState}) {
    assert(level >= _kMinLevel && level <= _kMaxLevel);
    final gs = gameState ?? getIt<GameState>();
    if (monsterId == null) {
      gs._level.value = level;
      for (var item in gs.currentList) {
        if (item is Monster) {
          item.setLevel(s, level);
        }
      }
      RoundMethods.updateForSpecialRules(s);
    } else {
      Monster? monster;
      for (var item in gs.currentList) {
        if (item.id == monsterId) {
          monster = item as Monster;
        }
      }
      monster?.setLevel(s, level);
    }
  }

  static void applyDifficulty(_StateModifier s, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    if (gs.autoScenarioLevel.value) {
      //adjust difficulty
      int newLevel =
          GameMethods.getRecommendedLevel() + gs.difficulty.value;
      if (newLevel > _kMaxLevel) {
        newLevel = _kMaxLevel;
      }
      setLevel(s, newLevel, null);
    }
  }

  //todo: too long method - split
  static void setScenario(_StateModifier s, String scenario, bool section,
      {GameState? gameState, GameData? gameData, Settings? settings}) {
    final gs = gameState ?? getIt<GameState>();
    final gd = gameData ?? getIt<GameData>();
    if (!section) {
      //first reset state
      RoundMethods.resetRound(s, 1, true);
      gs._showAllyDeck.value = false;
      gs._currentAbilityDecks.clear();
      gs._scenarioSpecialRules.clear();
      applyDifficulty(s);

      gs.modifierDeck._initDeck();
      gs.modifierDeckAllies._initDeck();
      gs._sanctuaryDeck._initDeck();

      RoundMethods.setRoundState(s, RoundState.chooseInitiative);
      gs._scenario.value = scenario;
      gs._scenarioSectionsAdded = [];

      List<ListItemData> newList = [];
      for (var item in gs.currentList) {
        if (item is Character) {
          if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
            CharacterMethods.resetCharacter(s, item);
            newList.add(item);
          }
        }
      }

      gs._currentList = newList;

      //loot deck init
      if (scenario != "custom") {
        LootDeckModel? lootDeckModel = gd
            .modelData
            .value[gs.currentCampaign.value]! // ignore: avoid-non-null-assertion
            .scenarios[scenario]! // ignore: avoid-non-null-assertion
            .lootDeck;
        lootDeckModel != null
            ? gs._lootDeck = LootDeck(lootDeckModel, gs.lootDeck)
            : gs._lootDeck = LootDeck.from(gs.lootDeck);
      } else {
        if (gs.currentCampaign.value == "Frosthaven") {
          //add loot deck for random scenarios
          LootDeckModel? lootDeckModel =
              const LootDeckModel(2, 2, 2, 12, 1, 1, 1, 1, 1, 1, 0);
          gs._lootDeck = LootDeck(lootDeckModel, gs.lootDeck);
        } else {
          gs._lootDeck = LootDeck.from(gs.lootDeck);
        }
      }

      RoundMethods.clearTurnState(s, true);
      gs._toastMessage.value = "";
    }

    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];
    List<String> subSections = [];

    String initMessage = "";
    if (section) {
      var sectionData = gd
          .modelData
          .value[gs.currentCampaign.value]
          ?.scenarios[gs.scenario.value]
          ?.sections
          .firstWhereOrNull((element) => element.name == scenario);
      if (sectionData != null) {
        monsters = sectionData.monsters;
        specialRules = sectionData.specialRules.toList();
        initMessage = sectionData.initMessage;
        final monsterStandees = sectionData.monsterStandees;
        roomMonsterData =
            monsterStandees != null ? monsterStandees.toList() : [];
      }
    } else {
      if ((settings ?? getIt<Settings>()).showBattleGoalReminder.value &&
          gs.currentCampaign.value != "Buttons and Bugs") {
        initMessage += "Remember to choose your Battle Goals.";
      }
      if (scenario != "custom") {
        var scenarioData = gd.modelData
            .value[gs.currentCampaign.value]?.scenarios[scenario];
        if (scenarioData != null) {
          monsters = scenarioData.monsters;
          specialRules = scenarioData.specialRules.toList();
          initMessage += initMessage.isNotEmpty && scenarioData.initMessage.isNotEmpty
              ? "\n\n${scenarioData.initMessage}"
              : scenarioData.initMessage;
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
      MonsterMethods.addMonster(s, monster, specialRules);
    }

    if (!section) {
      DeckMethods.shuffleDecks(s);
    }

    //hack for banner spear solo special rule
    if (scenario.contains("Scouting Ambush")) {
      MonsterAbilityState? deck = gs.currentAbilityDecks
          .firstWhereOrNull((element) => element.name.contains("Scout"));
      if (deck == null) return;
      final drawPileList = deck._drawPile.getList();
      for (int i = 0; i < drawPileList.length; i++) {
        if (drawPileList[i].title == "Rancid Arrow") {
          deck._drawPile.add(deck._drawPile.removeAt(i));
          break;
        }
      }
    }

    //add objectives and escorts
    for (var item in specialRules) {
      if (item.type == "AllyDeck") {
        gs._showAllyDeck.value = true;
      }
      if (item.type == "Objective") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition as Object)) {
          Character? objective = CharacterMethods.createCharacter(
              s, "Objective", null, item.name, gs.level.value + 1);
          final health =
              StatCalculator.calculateFormula(item.health.toString());
          if (health != null) {
            objective?.characterState._maxHealth.value = health;
          }
          objective?.characterState._health.value =
              objective.characterState.maxHealth.value;
          objective?.characterState._initiative.value = item.init;
          bool add = true;
          for (var item2 in gs.currentList) {
            //don't add duplicates
            if (item2 is Character &&
                (item2).characterState.display.value == item.name) {
              add = false;
              break;
            }
          }
          if (add && objective != null) {
            gs._currentList.add(objective);
          }
        }
      }
      if (item.type == "Escort") {
        if (item.condition == "" ||
            StatCalculator.evaluateCondition(item.condition as Object)) {
          final objective = CharacterMethods.createCharacter(
              s, "Escort", null, item.name, gs.level.value + 1);
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
            for (var item2 in gs.currentList) {
              //don't add duplicates
              if (item2 is Character &&
                  (item2).characterState.display.value == item.name) {
                add = false;
                break;
              }
            }
            if (add) {
              gs._currentList.add(objective);
            }
          }
        }
      }

      //special case for start of round and round is 1
      if (!section) {
        if (item.type == "Timer" && item.startOfRound) {
          for (int round in item.list.cast<int>()) {
            //minus 1 means always
            if (round == _kRound1 || round == _kTimerAlways) {
              initMessage += initMessage.isNotEmpty
                  ? "\n\n${item.note}"
                  : item.note;
            }
          }
        }
      }

      if (item.type == "ResetRound") {
        RoundMethods.resetRound(s, 1, false);
      }
      if (item.type == "Unlock") {
        unlockClass(s, item.name);
        initMessage += item.note;
      }
    }

    //in case of spawns at round 1 start of round, add to roomMonsterData
    for (var rule in specialRules) {
      if (rule.type == "Timer" && rule.startOfRound) {
        for (int round in rule.list.cast<int>()) {
          //minus 1 means always
          if (round == 1 || round == -1) {
            if ((settings ?? getIt<Settings>()).autoAddSpawns.value) {
              if (rule.name.isNotEmpty) {
                //get room data and deal with spawns
                ScenarioModel? scenarioModel = gd
                    .modelData
                    .value[gs.currentCampaign.value]
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
                            item.normal.first + spawnItem.normal.first,
                            item.normal[1] + spawnItem.normal[1],
                            item.normal[2] + spawnItem.normal[2]
                          ];
                          List<int> elite = [
                            item.elite.first + spawnItem.elite.first,
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

    initMessage = MonsterMethods.autoAddStandees(s, roomMonsterData, initMessage);

    if (!section) {
      gs._scenarioSpecialRules = specialRules;
      ElementMethods.resetElements(s);
      RoundMethods.sortCharactersFirst(s);
    } else {
      //remove earlier times if has "ResetRound"
      if (specialRules
              .firstWhereOrNull((element) => element.type == "ResetRound") !=
          null) {
        gs._scenarioSpecialRules.removeWhere((oldItem) {
          if (oldItem.type == "Timer") {
            return true;
          }
          return false;
        });
      }

      //overwrite earlier timers with same time.
      for (var item in specialRules) {
        if (item.type == "Timer") {
          gs._scenarioSpecialRules.removeWhere((oldItem) {
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
      gs._scenarioSpecialRules.addAll(specialRules);
      gs._scenarioSectionsAdded.add(scenario);
    }

    //handle random sections
    var rule = specialRules
        .firstWhereOrNull((element) => element.type == "RandomSections");
    if (rule != null) {
      subSections.shuffle();
      //add the random selected to rule.list
      SpecialRule newRule = SpecialRule("RandomSections", "", 0, 0, 0, "",
          subSections.sublist(0, _kRandomSectionCount), false, "");
      specialRules.remove(rule);
      specialRules.add(newRule);
    }

    gs._notifyCurrentList();

    if (!section) {
      MainList.scrollToTop();
    }

    //show init message if exists:
    if (initMessage.isNotEmpty && (settings ?? getIt<Settings>()).showReminders.value) {
      gs._toastMessage.value += initMessage;
    } else {
      if (getIt.isRegistered<BuildContext>()) {
        ScaffoldMessenger.of(getIt<BuildContext>()).hideCurrentSnackBar();
      }
    }
  }
}
