import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/activate_monster_type_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/enums.dart';
import '../../Resource/ui_utils.dart';
import '../menus/add_standee_menu.dart';

class MonsterStatCardViewModel {
  MonsterStatCardViewModel(this.monster,
      {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Monster monster;
  final GameState _gameState;
  final Settings _settings;

  // Notifiers the widget should subscribe to
  ValueListenable<int> get levelChanges => monster.level;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  // Derived state
  bool get isBoss => monster.type.levels[monster.level.value].boss != null;
  bool get allStandeesOut =>
      monster.monsterInstances.length == monster.type.count;

  // Boss health special cases: some bosses derive HP from a character's level
  String resolveBossHealth(String rawHealth) {
    if (rawHealth == "Hollowpact") {
      for (var item in _gameState.currentList) {
        if (item is Character && item.id == "Hollowpact") {
          return item.characterClass
              .healthByLevel[item.characterState.level.value - 1]
              .toString();
        }
      }
      return "7";
    }
    if (rawHealth == "Incarnate") {
      for (var item in _gameState.currentList) {
        if (item is Character && item.id == "Incarnate") {
          return (item.characterClass
                      .healthByLevel[item.characterState.level.value - 1] *
                  2)
              .toString();
        }
      }
      return "36";
    }
    return rawHealth;
  }

  void handleAddNormal(BuildContext context) =>
      _handleAdd(context, left: true, isBossStandee: false);

  void handleAddElite(BuildContext context) =>
      _handleAdd(context, left: false, isBossStandee: isBoss);

  void _handleAdd(BuildContext context,
      {required bool left, required bool isBossStandee}) {
    if (_settings.noStandees.value) {
      _gameState.action(ActivateMonsterTypeCommand(
          monster.id, !monster.isActive,
          gameState: _gameState));
      return;
    }

    final nrOfStandees = monster.monsterInstances.length;
    final maxStandees = monster.type.count;
    final type = isBossStandee
        ? MonsterType.boss
        : left
            ? MonsterType.normal
            : MonsterType.elite;

    if (nrOfStandees == maxStandees - 1) {
      MonsterMethods.addStandee(null, monster, type, false);
    } else if (nrOfStandees < maxStandees - 1) {
      if (_settings.randomStandees.value) {
        int standeeNr = GameMethods.getRandomStandee(monster);
        if (_gameState.currentCampaign.value == "Buttons and Bugs") {
          standeeNr = GameMethods.getNextAvailableBnBStandee(monster);
        }
        if (standeeNr != 0) {
          _gameState.action(AddStandeeCommand(
              standeeNr, null, monster.id, type, false,
              gameState: _gameState));
        }
      } else {
        openDialog(context, AddStandeeMenu(elite: !left, monster: monster));
      }
    }
  }
}
