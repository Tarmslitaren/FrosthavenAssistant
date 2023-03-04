import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/room.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/state/monster_ability_state.dart';

import '../../Layout/main_list.dart';
import '../../Layout/menus/auto_add_standee_menu.dart';
import '../../Model/scenario.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../settings.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/list_item_data.dart';
import '../state/loot_deck_state.dart';
import '../state/monster.dart';
import '../state/monster_instance.dart';
import '../ui_utils.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  late final String _scenario;
  late final bool section;

  SetScenarioCommand(this._scenario, this.section);

  void _addMonster(String monster, List<SpecialRule> specialRules) {
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
      _gameState.currentList.add(GameMethods.createMonster(
          monster, (_gameState.level.value + levelAdjust).clamp(0, 7), isAlly)!);
    }
  }

  @override
  void execute() {

    if (!section) {
      //first reset state
      _gameState.round.value = 1;
      _gameState.currentAbilityDecks.clear();
      _gameState.scenarioSpecialRules.clear();
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
      _gameState.currentList = newList;

      //loot deck init
      if (_scenario != "custom") {
        LootDeckModel? lootDeckModel = _gameState.modelData.value[_gameState
            .currentCampaign.value]!.scenarios[_scenario]!.lootDeck;
        if (lootDeckModel != null) {
          _gameState.lootDeck = LootDeck(lootDeckModel, _gameState.lootDeck);
        } else {
          _gameState.lootDeck = LootDeck.from(_gameState.lootDeck);
        }
      } else {
        _gameState.lootDeck = LootDeck.from(_gameState.lootDeck);
      }

      GameMethods.clearTurnState(true);
      _gameState.toastMessage.value = "";
    }


    List<String> monsters = [];
    List<SpecialRule> specialRules = [];
    List<RoomMonsterData> roomMonsterData = [];

    String initMessage = "";
    if (section) {
      var sectionData = _gameState.modelData.value[_gameState
          .currentCampaign.value]?.scenarios[_gameState.scenario.value]?.sections.firstWhere((element) => element.name == _scenario);
      if(sectionData != null) {
        monsters = sectionData.monsters;
        specialRules = sectionData.specialRules.toList();
        initMessage = sectionData.initMessage;
        roomMonsterData = sectionData.monsterStandees != null ? sectionData.monsterStandees! : [];
      }
    }else{
      if(_scenario != "custom") {
        var scenarioData = _gameState.modelData.value[_gameState
            .currentCampaign.value]?.scenarios[_scenario];
        if (scenarioData != null) {
          monsters = scenarioData.monsters;
          specialRules = scenarioData.specialRules.toList();
          initMessage = scenarioData.initMessage;
          roomMonsterData = scenarioData.monsterStandees != null ? scenarioData.monsterStandees! : [];
        }
      }
    }

    //handle special rules
    for (String monster in monsters) {
      _addMonster(monster, specialRules);
    }

    if (!section) {
      GameMethods.shuffleDecks();
    }

    //hack for banner spear solo special rule
    if (_scenario.contains("Banner Spear: Scouting Ambush") ) {
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
        Character objective = GameMethods.createCharacter("Objective", item.name, _gameState.level.value+1)!;
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
          _gameState.currentList.add(objective);
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
          _gameState.currentList.add(objective);
        }
      }

      //special case for start of round and round is 1
      if(item.type == "Timer" && item.startOfRound == true) {
        for(int round in item.list) {
          //minus 1 means always
          if(round == 1 || round == -1) {
            if(initMessage.isNotEmpty) {
              initMessage += "\n\n${item.note}";
            } else {
              initMessage += item.note;
            }
          }
        }
      }

      if (item.type == "ResetRound") {
        _gameState.round.value = 1;
      }
    }

    int characterIndex = GameMethods.getCurrentCharacterAmount().clamp(2, 4) - 2;
    //handle room data

    for (int i = 0; i < roomMonsterData.length; i++) {
      var roomMonsters = roomMonsterData[i];
      _addMonster(roomMonsters.name, _gameState.scenarioSpecialRules);
    }

    if(getIt<Settings>().randomStandees.value == true) {
      if (initMessage.isNotEmpty) {
        initMessage += "\n";
      }
      for (int i = 0; i < roomMonsterData.length; i++) {
        var roomMonsters = roomMonsterData[i];
        Monster data = _gameState.currentList.firstWhereOrNull((element) => element.id == roomMonsters.name) as Monster;
        
        int eliteAmount = roomMonsters.elite[characterIndex];
        int normalAmount = roomMonsters.normal[characterIndex];
        //TODO: handle bosses?!
        if(i != 0) {
          initMessage += "\n";
        }
        initMessage += "${data.type.display} added: ";

        if(eliteAmount > 0) {
          initMessage += "\nElite standee nr: ";
        }

        for (int i = 0; i < eliteAmount; i++) {
          int randomNr = GameMethods.getRandomStandee(data);
          if (randomNr != 0) {
            initMessage += "$randomNr, "; //todo: sort by nr
            if (i == normalAmount-1) {
              initMessage = initMessage.substring(0, initMessage.length-2);
            }
            GameMethods.executeAddStandee(
                randomNr,null, MonsterType.elite, data.id, false);
          }
        }

        if(normalAmount > 0) {
          initMessage += "\nNormal standee nr: ";
        }
        for (int i = 0; i < normalAmount; i++) {
          int randomNr = GameMethods.getRandomStandee(data);
          if (randomNr != 0) {
            initMessage += "$randomNr, ";
            if (i == normalAmount-1) {
              initMessage = initMessage.substring(0, initMessage.length-2);
            }
            GameMethods.executeAddStandee(
                randomNr,null, MonsterType.normal, data.id, false);
          }
        }
      }
    } else {
      if(roomMonsterData.isNotEmpty) {
        openDialog(
          getIt<BuildContext>(),
          AutoAddStandeeMenu(
            monsterData: roomMonsterData,
          ),
        );
      }
    }

    if (!section) {
      _gameState.scenarioSpecialRules = specialRules;
      GameMethods.updateElements();
      GameMethods.updateElements(); //twice to make sure they are inert.
      GameMethods.setRoundState(RoundState.chooseInitiative);
      GameMethods.sortCharactersFirst();
      _gameState.scenario.value = _scenario;
      _gameState.scenarioSectionsAdded = [];
    }else {
      _gameState.scenarioSpecialRules.addAll(specialRules);
      _gameState.scenarioSectionsAdded.add(_scenario);
    }

    _gameState.updateList.value++;

    if (!section) {
      MainList.scrollToTop();
    }

    //show init message if exists:
    if(initMessage.isNotEmpty && getIt<Settings>().showReminders.value == true) {
      _gameState.toastMessage.value += initMessage;
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if(!section) {
      return "Set Scenario";
    }
    return "Add Section";
  }
}