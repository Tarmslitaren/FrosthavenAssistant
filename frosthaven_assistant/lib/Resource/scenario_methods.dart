part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class ScenarioMethods {
  static const int _kMinLevel = 0;
  static const int _kMaxLevel = 7;
  static const int _kRound1 = 1;
  static const int _kTimerAlways = -1;
  static const int _kRandomSectionCount = 3;

  static void setCampaign(_StateModifier _, String campaign,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._currentCampaign.value = campaign;
  }

  static void setSolo(_StateModifier _, bool solo, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._solo.value = solo;
  }

  static void unlockClass(_StateModifier _, String name,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses.add(name);
    gs._unlockedClassesVersion.value++;
  }

  static void clearUnlockedClasses(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses = {};
    gs._unlockedClassesVersion.value++;
  }

  static void clearUnlockedClass(_StateModifier _, String id,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._unlockedClasses.remove(id);
    gs._unlockedClassesVersion.value++;
  }

  static void setLevel(_StateModifier s, int level, String? monsterId,
      {GameState? gameState}) {
    assert(level >= _kMinLevel && level <= _kMaxLevel);
    final gs = gameState ?? getIt<GameState>();
    if (monsterId == null) {
      gs._level.value = level;
      for (final item in gs.currentList) {
        if (item is Monster) {
          item.setLevel(s, level);
        }
      }
      RoundMethods.updateForSpecialRules(s);
    } else {
      Monster? monster;
      for (final item in gs.currentList) {
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
      int newLevel = GameMethods.getRecommendedLevel() + gs.difficulty.value;
      if (newLevel > _kMaxLevel) {
        newLevel = _kMaxLevel;
      }
      setLevel(s, newLevel, null);
    }
  }

  static void _resetForNewScenario(
      _StateModifier s, String scenario, GameState gs, GameData gd) {
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
    for (final item in gs.currentList) {
      if (item is Character) {
        if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
          CharacterMethods.resetCharacter(s, item);
          newList.add(item);
        }
      }
    }
    gs._currentList = newList;

    _initLootDeck(scenario, gs, gd);

    RoundMethods.clearTurnState(s, true);
    gs._toastMessage.value = "";
  }

  static void _initLootDeck(String scenario, GameState gs, GameData gd) {
    if (scenario != "custom") {
      final campaignModel = gd.modelData.value[gs.currentCampaign.value];
      LootDeckModel? lootDeckModel =
          campaignModel?.scenarios[scenario]?.lootDeck;
      lootDeckModel != null
          ? gs._lootDeck = LootDeck(lootDeckModel, gs.lootDeck)
          : gs._lootDeck = LootDeck.from(gs.lootDeck);
    } else {
      if (gs.currentCampaign.value == "Frosthaven") {
        LootDeckModel? lootDeckModel =
            const LootDeckModel(2, 2, 2, 12, 1, 1, 1, 1, 1, 1, 0);
        gs._lootDeck = LootDeck(lootDeckModel, gs.lootDeck);
      } else {
        gs._lootDeck = LootDeck.from(gs.lootDeck);
      }
    }
  }

  static ({
    List<String> monsters,
    List<SpecialRule> specialRules,
    List<RoomMonsterData> roomMonsterData,
    List<String> subSections,
    String initMessage,
  }) _loadData(bool section, String scenario, GameState gs, GameData gd,
      Settings? settings) {
    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];
    List<String> subSections = [];
    String initMessage = "";

    if (section) {
      final sectionData = gd.modelData.value[gs.currentCampaign.value]
          ?.scenarios[gs.scenario.value]?.sections
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
        final scenarioData =
            gd.modelData.value[gs.currentCampaign.value]?.scenarios[scenario];
        if (scenarioData != null) {
          monsters = scenarioData.monsters;
          specialRules = scenarioData.specialRules.toList();
          initMessage +=
              initMessage.isNotEmpty && scenarioData.initMessage.isNotEmpty
                  ? "\n\n${scenarioData.initMessage}"
                  : scenarioData.initMessage;
          final monsterStandees = scenarioData.monsterStandees;
          roomMonsterData =
              monsterStandees != null ? monsterStandees.toList() : [];
          for (final item in scenarioData.sections) {
            subSections.add(item.name);
          }
        }
      }
    }

    return (
      monsters: monsters,
      specialRules: specialRules,
      roomMonsterData: roomMonsterData,
      subSections: subSections,
      initMessage: initMessage,
    );
  }

  // Returns false if setScenario should abort early (banner spear solo edge case).
  static bool _applyBannerSpearHack(String scenario, GameState gs) {
    if (!scenario.contains("Scouting Ambush")) return true;
    final deck = gs.currentAbilityDecks
        .firstWhereOrNull((element) => element.name.contains("Scout"));
    if (deck == null) return false;
    final drawPileList = deck._drawPile.getList();
    for (int i = 0; i < drawPileList.length; i++) {
      if (drawPileList[i].title == "Rancid Arrow") {
        deck._drawPile.add(deck._drawPile.removeAt(i));
        break;
      }
    }
    return true;
  }

  static String _processSpecialRules(
      _StateModifier s,
      List<SpecialRule> specialRules,
      bool section,
      GameState gs,
      String initMessage,
      Settings? settings) {
    for (final item in specialRules) {
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
          for (final item2 in gs.currentList) {
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
            for (final item2 in gs.currentList) {
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
      if (!section && item.type == "Timer" && item.startOfRound) {
        for (int round in item.list.cast<int>()) {
          if (round == _kRound1 || round == _kTimerAlways) {
            initMessage +=
                initMessage.isNotEmpty ? "\n\n${item.note}" : item.note;
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
    return initMessage;
  }

  static List<RoomMonsterData> _applyRound1Spawns(
    List<RoomMonsterData> roomMonsterData,
    List<SpecialRule> specialRules,
    String scenario,
    GameState gs,
    GameData gd,
    Settings? settings,
  ) {
    for (final rule in specialRules) {
      if (rule.type != "Timer" || !rule.startOfRound) continue;
      for (final round in rule.list.cast<int>()) {
        if (round != _kRound1 && round != _kTimerAlways) continue;
        if (!(settings ?? getIt<Settings>()).autoAddSpawns.value) continue;
        if (rule.name.isEmpty) continue;

        final scenarioModel =
            gd.modelData.value[gs.currentCampaign.value]?.scenarios[scenario];
        if (scenarioModel == null) continue;

        final spawnSection = scenarioModel.sections.firstWhereOrNull(
            (element) => element.name.substring(1) == rule.name);
        final spawnStandees = spawnSection?.monsterStandees;
        if (spawnStandees == null) continue;

        for (final spawnItem in spawnStandees) {
          final existing = roomMonsterData
              .firstWhereOrNull((element) => element.name == spawnItem.name);
          if (existing != null) {
            final merged = RoomMonsterData(
              existing.name,
              [
                existing.normal.first + spawnItem.normal.first,
                existing.normal[1] + spawnItem.normal[1],
                existing.normal[2] + spawnItem.normal[2],
              ],
              [
                existing.elite.first + spawnItem.elite.first,
                existing.elite[1] + spawnItem.elite[1],
                existing.elite[2] + spawnItem.elite[2],
              ],
            );
            for (int i = 0; i < roomMonsterData.length; i++) {
              if (roomMonsterData[i].name == existing.name) {
                roomMonsterData[i] = merged;
                break;
              }
            }
          } else {
            roomMonsterData.add(spawnItem);
          }
        }
      }
    }
    return roomMonsterData;
  }

  static void _updateScenarioRules(
      _StateModifier s,
      bool section,
      String scenario,
      List<SpecialRule> specialRules,
      List<String> subSections,
      GameState gs) {
    if (!section) {
      gs._scenarioSpecialRules = specialRules;
      ElementMethods.resetElements(s);
      RoundMethods.sortCharactersFirst(s);
    } else {
      if (specialRules
              .firstWhereOrNull((element) => element.type == "ResetRound") !=
          null) {
        gs._scenarioSpecialRules
            .removeWhere((oldItem) => oldItem.type == "Timer");
      }
      for (final item in specialRules) {
        if (item.type == "Timer") {
          gs._scenarioSpecialRules.removeWhere((oldItem) {
            if (oldItem.type == "Timer" &&
                item.startOfRound == oldItem.startOfRound) {
              if (item.list.contains(-1) || oldItem.list.contains(-1)) {
                return true;
              }
              final set2 = oldItem.list.toSet();
              return item.list.any(set2.contains);
            }
            return false;
          });
        }
      }
      gs._scenarioSpecialRules.addAll(specialRules);
      gs._scenarioSectionsAdded.add(scenario);
    }
    gs._scenarioSectionsVersion.value++;

    final randomRule = specialRules
        .firstWhereOrNull((element) => element.type == "RandomSections");
    if (randomRule != null) {
      subSections.shuffle();
      final newRule = SpecialRule("RandomSections", "", 0, 0, 0, "",
          subSections.sublist(0, _kRandomSectionCount), false, "");
      specialRules.remove(randomRule);
      specialRules.add(newRule);
    }
  }

  static void setScenario(_StateModifier s, String scenario, bool section,
      {GameState? gameState, GameData? gameData, Settings? settings}) {
    final gs = gameState ?? getIt<GameState>();
    final gd = gameData ?? getIt<GameData>();

    if (!section) {
      _resetForNewScenario(s, scenario, gs, gd);
    }

    final data = _loadData(section, scenario, gs, gd, settings);

    for (final monster in data.monsters) {
      MonsterMethods.addMonster(s, monster, data.specialRules);
    }
    if (!section) {
      DeckMethods.shuffleDecks(s);
    }

    if (!_applyBannerSpearHack(scenario, gs)) return;

    final initMessage = _processSpecialRules(
        s, data.specialRules, section, gs, data.initMessage, settings);

    final roomMonsterData = _applyRound1Spawns(
        data.roomMonsterData, data.specialRules, scenario, gs, gd, settings);

    final finalInitMessage =
        MonsterMethods.autoAddStandees(s, roomMonsterData, initMessage);

    _updateScenarioRules(
        s, section, scenario, data.specialRules, data.subSections, gs);

    gs._notifyCurrentList();
    if (!section) {
      MainList.scrollToTop();
    }

    if (finalInitMessage.isNotEmpty &&
        (settings ?? getIt<Settings>()).showReminders.value) {
      gs._toastMessage.value += finalInitMessage;
    } else {
      gs._toastMessage.value = "";
    }
  }
}
