import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_list_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../monster_box.dart';

class MainListViewModel {
  static const double _kCharacterHeight = 60.0;
  static const double _kMonsterHeaderHeight = 96.0;
  static const double _kRowHeight = 32.0;
  MainListViewModel(
      {GameState? gameState, GameData? gameData, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _gameData = gameData ?? getIt<GameData>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final GameData _gameData;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<bool> get darkMode => _settings.darkMode;
  ValueListenable<Map<String, CampaignModel>> get modelData =>
      _gameData.modelData;
  ValueListenable<double> get userScalingMainList =>
      _settings.userScalingMainList;
  ValueListenable<int> get updateList => _gameState.updateList;
  ValueListenable<BuiltList<ListItemData>> get currentListNotifier =>
      _gameState.currentListNotifier;

  // Derived state
  int get currentListLength => _gameState.currentList.length;
  ListItemData itemAt(int index) => _gameState.currentList[index];
  String itemIdAt(int index) => _gameState.currentList[index].id;

  double get userScalingBars => _settings.userScalingBars.value;

  List<double> getItemHeights(BuildContext context) {
    double listHeight = 0;
    double scale = getScaleByReference(context);
    double mainListWidth = getMainListWidth(context);

    List<double> widgetPositions = [];
    for (int i = 0; i < _gameState.currentList.length; i++) {
      final item = _gameState.currentList[i];
      if (item is Character) {
        listHeight += _kCharacterHeight;
        final summonList = item.characterState.summonList;
        if (summonList.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in summonList) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }
          double rows = listWidth / mainListWidth;
          listHeight += _kRowHeight * (rows.ceil());
        }
      }
      if (item is Monster) {
        listHeight += _kMonsterHeaderHeight;
        if (item.monsterInstances.isNotEmpty) {
          double listWidth = 0;
          for (var monsterInstance in item.monsterInstances) {
            listWidth += MonsterBox.getWidth(scale, monsterInstance);
          }
          double rows = listWidth / mainListWidth;
          listHeight += _kRowHeight * rows.ceil();
        }
      }
      widgetPositions.add(listHeight * scale);
    }
    return widgetPositions;
  }

  void reorderItem(int oldIndex, int newIndex) {
    _gameState.action(
        ReorderListCommand(newIndex, oldIndex, gameState: _gameState));
  }
}
