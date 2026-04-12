import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Model/scenario.dart';

class SectionListViewModel {
  SectionListViewModel({Settings? settings, GameData? gameData, GameState? gameState})
      : _settings = settings ?? getIt<Settings>(),
        _gameData = gameData ?? getIt<GameData>(),
        _gameState = gameState ?? getIt<GameState>();

  final Settings _settings;
  final GameData _gameData;
  final GameState _gameState;

  // Notifiers the widget subscribes to
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  /// Returns the filtered section list for the current scenario,
  /// or an empty list if all sections have been added.
  List<ScenarioModel> get sections {
    var list = _gameData
        .modelData
        .value[_gameState.currentCampaign.value]
        ?.scenarios[_gameState.scenario.value]
        ?.sections
        .toList();

    // Apply random sections filter if present
    final randomSections = _gameState.scenarioSpecialRules
        .firstWhereOrNull((element) => element.type == "RandomSections");
    if (randomSections != null && list != null) {
      final newList = <ScenarioModel>[];
      for (var item in randomSections.list) {
        final section =
            list.firstWhereOrNull((element) => element.name == item);
        if (section != null) {
          newList.add(section);
        }
      }
      list = newList;
    }

    // When autoAddStandees is off, filter out sections with only room data
    if (_settings.autoAddStandees.value == false) {
      list = list?.where((element) {
        return element.specialRules.isNotEmpty ||
            element.initMessage.isNotEmpty ||
            element.monsters.isNotEmpty;
      }).toList();
    }

    // Hide list when all non-spawn sections have been added
    if (list != null) {
      final nonSpawnCount =
          list.where((s) => !s.name.contains("spawn")).length;
      if (_gameState.scenarioSectionsAdded.length == nonSpawnCount) {
        return [];
      }
    }

    return list ?? [];
  }
}
