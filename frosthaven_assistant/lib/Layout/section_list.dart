import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/section_button.dart';
import 'package:frosthaven_assistant/Layout/view_models/section_list_view_model.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/scenario.dart';
import '../Resource/game_data.dart';
import '../Resource/settings.dart';

class SectionList extends StatelessWidget {
  const SectionList({super.key, this.settings, this.gameData, this.gameState});

  final Settings? settings;
  final GameData? gameData;
  final GameState? gameState;

  List<Widget> _generateList(List<ScenarioModel> inputList) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      final item = inputList[index];
      if (!item.name.contains("spawn")) {
        list.add(SectionButton(key: Key(item.name), data: item.name));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vm = SectionListViewModel(
        settings: settings, gameData: gameData, gameState: gameState);
    return ValueListenableBuilder<double>(
        valueListenable: vm.userScalingBars,
        builder: (context, value, child) {
          final scale = vm.userScalingBars.value;
          return ValueListenableBuilder<int>(
              valueListenable: vm.commandIndex,
              builder: (context, value, child) {
                return RepaintBoundary(
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4 * scale,
                        runSpacing: 0 * scale,
                        children: _generateList(vm.sections)));
              });
        });
  }
}
