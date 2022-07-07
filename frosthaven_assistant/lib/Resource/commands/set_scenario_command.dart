
import 'dart:math';

import 'package:frosthaven_assistant/Resource/stat_calculator.dart';

import '../../Layout/main_list.dart';
import '../../Model/scenario.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../game_state.dart';

class SetScenarioCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _scenario;
  final bool section;

  SetScenarioCommand(this._scenario, this.section);

  @override
  void execute() {
    //first reset state

    if (!section) {
      List<ListItemData> newList = [];
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.id != "Objective" && item.id != "Escort") {
            //newList.add(item);item.characterState.initiative = 0;

            item.characterState.health.value =
            item.characterClass.healthByLevel[item.characterState.level.value -
                1];
            item.characterState.xp.value = 0;
            item.characterState.conditions.value.clear();
            newList.add(item);
          }
        }

        if (item is Monster) {
          _gameState.currentList.remove(item);
        }
      }
      GameMethods.shuffleDecks();
      _gameState.currentList = newList;
    }


    List<String> monsters;
    List<SpecialRule> specialRules = [];
    if (section) {
      monsters = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.sections[_scenario]!.monsters;

      specialRules = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.sections[_scenario]!.specialRules;
      //TODO: don't add duplicates! - this would not be needed if we keep track on added sections
    }else{
      monsters = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.scenarios[_scenario]!.monsters;
      specialRules = _gameState.modelData.value[_gameState
          .currentCampaign.value]!.scenarios[_scenario]!.specialRules;
    }

    //handle special rules
    for (String monster in monsters) {
      int levelAdjust = 0;
      String? healthAdjust;
      for (var rule in specialRules) {
        if(rule.name == monster) {
          if(rule.type == "LevelAdjust") {
            levelAdjust = rule.level;
          }
          //TODO: f this - if I ever decide this is good: I would instead have the monster state have an extraHpSpecial field and also name field for named monsters?
          if(rule.type == "HealthAdjust") {
            //healthAdjust = rule.health;
          }
        }
      }

      _gameState.currentList.add(GameMethods.createMonster(monster, min(_gameState.level.value + levelAdjust, 7), healthAdjust)!);
    }

    //add objectives and escorts
    for(var item in specialRules) {
      if(item.type == "Objective"){
        Character objective = GameMethods.createCharacter("Objective", item.name, _gameState.level.value)!;
        objective.characterState.maxHealth.value = StatCalculator.calculateFormula(item.health.toString())!;
        objective.characterState.health.value = objective.characterState.maxHealth.value;
        objective.characterState.initiative = item.init;
        _gameState.currentList.add(objective);
      }
      if (item.type == "Escort") {
        Character objective = GameMethods.createCharacter("Escort", item.name, _gameState.level.value)!;
        objective.characterState.maxHealth.value = StatCalculator.calculateFormula(item.health.toString())!;
        objective.characterState.health.value = objective.characterState.maxHealth.value;
        objective.characterState.initiative = item.init;
        _gameState.currentList.add(objective);
      }
    }

    if (!section) {
      GameMethods.updateElements();
      GameMethods.updateElements(); //twice to make sure they are inert.
      GameMethods.setRoundState(RoundState.chooseInitiative);
      GameMethods.sortCharactersFirst();
      _gameState.scenario.value = _scenario;
    }

    //Future.delayed(Duration(milliseconds: 10), () {
      _gameState.updateList.value++;
      MainList.scrollToTop();
    //});
  }

  @override
  void undo() {
    //TODO: implement
  }
}