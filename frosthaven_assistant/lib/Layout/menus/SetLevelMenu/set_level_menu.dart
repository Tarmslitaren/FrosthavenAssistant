import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_auto_level_adjust_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_solo_command.dart';

import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../../services/service_locator.dart';
import '../../view_models/set_level_menu_view_model.dart';
import '../../widgets/modal_background.dart';
import 'difficulty_button.dart';
import 'level_button.dart';
import 'level_legend.dart';

class SetLevelMenu extends StatelessWidget {
  static const double _kMenuWidth = 270.0;
  static const double _kMenuHeightWithLegend = 400.0;
  static const double _kMenuHeightNoLegend = 287.0;
  static const int _kMaxHealth = 900;
  static const int _kLevelMin = 0;
  static const int _kLevelRowSize = 4;
  static const int _kLevelRow2Start = _kLevelRowSize;
  static const int _kDifficultyMin = -1;
  static const int _kDifficultyMax = 3;
  static const int _kDifficultyCount = _kDifficultyMax - _kDifficultyMin + 1;

  const SetLevelMenu({
    super.key,
    this.monster,
    this.figure,
    this.characterId,
    this.gameState,
    this.settings,
  });

  final Monster? monster;
  final String? characterId;
  final FigureState? figure;

  final GameState? gameState;
  final Settings? settings;

  GameState get _gameState => gameState ?? getIt<GameState>();
  Settings get _settings => settings ?? getIt<Settings>();

  @override
  Widget build(BuildContext context) {
    final vm = SetLevelMenuViewModel(
      monster: monster,
      figure: figure,
      characterId: characterId,
    );

    final bool darkMode = _settings.darkMode.value;
    final double scale = getModalMenuScale(context);

    return ModalBackground(
        width: SetLevelMenu._kMenuWidth * scale,
        height: vm.showLegend
            ? SetLevelMenu._kMenuHeightWithLegend * scale
            : SetLevelMenu._kMenuHeightNoLegend * scale,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: kMenuTopPadding * scale,
              ),
              Text(vm.title, style: getTitleTextStyle(scale)),
              if (!vm.isSummon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    SetLevelMenu._kLevelRowSize,
                    (i) => LevelButton(
                        nr: SetLevelMenu._kLevelMin + i,
                        scale: scale,
                        monster: monster,
                        gameState: _gameState,
                        settings: _settings),
                  ),
                ),
              if (!vm.isSummon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    SetLevelMenu._kLevelRowSize,
                    (i) => LevelButton(
                        nr: SetLevelMenu._kLevelRow2Start + i,
                        scale: scale,
                        monster: monster,
                        gameState: _gameState,
                        settings: _settings),
                  ),
                ),
              if (figure == null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Solo:", style: getSmallTextStyle(scale)),
                  ValueListenableBuilder<bool>(
                      valueListenable: _gameState.solo,
                      builder: (context, value, child) {
                        return Checkbox(
                          checkColor: Colors.black,
                          activeColor: Colors.grey.shade200,
                          side: BorderSide(
                              color: darkMode ? Colors.white : Colors.black),
                          onChanged: (bool? newValue) {
                            _gameState
                                .action(SetSoloCommand(newValue ?? false));
                          },
                          value: _gameState.solo.value,
                        );
                      })
                ]),
              if (figure == null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Automatic Scenario Level:",
                      style: getSmallTextStyle(scale)),
                  ValueListenableBuilder<bool>(
                      valueListenable: _gameState.autoScenarioLevel,
                      builder: (context, value, child) {
                        return Checkbox(
                          checkColor: Colors.black,
                          activeColor: Colors.grey.shade200,
                          side: BorderSide(
                              color: darkMode ? Colors.white : Colors.black),
                          onChanged: (bool? newValue) {
                            _gameState.action(SetAutoLevelAdjustCommand(
                                newValue ?? false,
                                gameState: _gameState));
                          },
                          value: _gameState.autoScenarioLevel.value,
                        );
                      })
                ]),
              if (figure == null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Difficulty:", style: getSmallTextStyle(scale)),
                  ...List.generate(
                    SetLevelMenu._kDifficultyCount,
                    (i) => DifficultyButton(
                        nr: SetLevelMenu._kDifficultyMin + i,
                        scale: scale,
                        gameState: _gameState,
                        settings: _settings),
                  ),
                ]),
              if (figure != null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CounterButton(
                      // ignore: avoid-non-null-assertion, obviously non null
                      notifier: figure!.maxHealth,
                      command: ChangeMaxHealthCommand(0, vm.figureId, vm.ownerId,
                          gameState: _gameState),
                      maxValue: SetLevelMenu._kMaxHealth,
                      image: "assets/images/abilities/heal.png",
                      showTotalValue: true,
                      color: Colors.red,
                      figureId: vm.figureId,
                      ownerId: vm.ownerId,
                      scale: scale)
                ]),
              if (vm.showLegend)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LevelLegend(
                        name: "trap damage",
                        gfx: "assets/images/psd/traps-fh.png",
                        value: ": ${vm.trapValue}",
                        scale: scale),
                    LevelLegend(
                        name: "hazardous terrain damage",
                        gfx: "assets/images/psd/hazard-fh.png",
                        value: ": ${vm.hazardValue}",
                        scale: scale),
                    LevelLegend(
                        name: "experience added",
                        gfx: "assets/images/psd/xp.png",
                        value: ": +${vm.xpValue}",
                        scale: scale),
                    LevelLegend(
                        name: "gold coin value",
                        gfx: "assets/images/psd/coins-fh.png",
                        value: ": x${vm.coinValue}",
                        scale: scale),
                    LevelLegend(
                        name: "level",
                        gfx: "assets/images/psd/level.png",
                        value: ": ${_gameState.level.value}",
                        scale: scale),
                  ],
                )
            ],
          ),
        ]));
  }
}
