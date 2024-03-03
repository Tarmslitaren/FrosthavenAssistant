import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/section_button.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/scenario.dart';
import '../Resource/game_data.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

class SectionList extends StatelessWidget {
  const SectionList({super.key});

  List<Widget> generateList(List<ScenarioModel> inputList) {
    List<Widget> list = [];
   // if(inputList.length <=20) { //arbitrary limit, so view is not filled up with extra buttons
      for (int index = 0; index < inputList.length; index++) {
        var item = inputList[index];
        if (!item.name.contains("spawn")) {
          SectionButton value =
          SectionButton(key: Key(item.name), data: item.name);
          list.add(value);
        }
      }
    //}
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: getIt<Settings>().userScalingBars,
        builder: (context, value, child) {
          double scale = getIt<Settings>().userScalingBars.value;
          final GameData gameData = getIt<GameData>();
          final GameState gameState = getIt<GameState>();
          return ValueListenableBuilder<int>(
              valueListenable: getIt<GameState>().commandIndex,
              builder: (context, value, child) {
                var list = gameData
                    .modelData
                    .value[gameState.currentCampaign.value]
                    ?.scenarios[gameState.scenario.value]
                    ?.sections
                    .toList();

                //handle random list
                var randomSections = gameState.scenarioSpecialRules.firstWhereOrNull((element) => element.type == "RandomSections");
                if(randomSections != null && list != null) {
                  List<ScenarioModel> newList = [];
                  for(var item in randomSections.list) {
                    var section = list.firstWhereOrNull((element) => element.name == item);
                    if(section != null) {
                      newList.add(section);
                    }
                  }
                  list = newList;
                }

                if (getIt<Settings>().autoAddStandees.value == false) {
                  //filter out all sections with only room data
                  list = list?.where((element) {
                    if (element.specialRules.isNotEmpty) {
                      return true;
                    }
                    if (element.initMessage.isNotEmpty) {
                      return true;
                    }
                    if (element.monsters.isNotEmpty) {
                      return true;
                    }
                    return false;
                  }).toList();
                }

                if (list != null &&
                    gameState.scenarioSectionsAdded.length == list.length - list.where((section) => section.name.contains("spawn")).length) {
                  list = [];
                }
                list ??= [];

                return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4 * scale,
                    runSpacing: 0 * scale,
                    children: generateList(list));
              });
        });
  }
}
