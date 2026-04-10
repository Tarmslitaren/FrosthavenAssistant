import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/section_button.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/scenario.dart';
import '../Resource/game_data.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

class SectionList extends StatelessWidget {
  const SectionList({super.key, this.settings, this.gameData, this.gameState});

  final Settings? settings;
  final GameData? gameData;
  final GameState? gameState;

  List<Widget> generateList(List<ScenarioModel> inputList) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      var item = inputList[index];
      if (!item.name.contains("spawn")) {
        SectionButton value =
            SectionButton(key: Key(item.name), data: item.name);
        list.add(value);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = this.settings ?? getIt<Settings>();
    final gd = this.gameData ?? getIt<GameData>();
    final gs = this.gameState ?? getIt<GameState>();
    return ValueListenableBuilder<double>(
        valueListenable: s.userScalingBars,
        builder: (context, value, child) {
          double scale = s.userScalingBars.value;
          return ValueListenableBuilder<int>(
              valueListenable: gs.commandIndex,
              builder: (context, value, child) {
                var list = gd
                    .modelData
                    .value[gs.currentCampaign.value]
                    ?.scenarios[gs.scenario.value]
                    ?.sections
                    .toList();

                //handle random list
                var randomSections = gs.scenarioSpecialRules
                    .firstWhereOrNull(
                        (element) => element.type == "RandomSections");
                if (randomSections != null && list != null) {
                  List<ScenarioModel> newList = [];
                  for (var item in randomSections.list) {
                    var section = list
                        .firstWhereOrNull((element) => element.name == item);
                    if (section != null) {
                      newList.add(section);
                    }
                  }
                  list = newList;
                }

                if (s.autoAddStandees.value == false) {
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
                    gs.scenarioSectionsAdded.length ==
                        list.length -
                            list
                                .where(
                                    (section) => section.name.contains("spawn"))
                                .length) {
                  list = [];
                }
                list ??= [];

                return RepaintBoundary(child:Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4 * scale,
                    runSpacing: 0 * scale,
                    children: generateList(list)));
              });
        });
  }
}
