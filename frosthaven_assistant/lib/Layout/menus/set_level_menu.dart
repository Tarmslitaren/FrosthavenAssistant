import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_auto_level_adjust_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_difficulty_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_solo_command.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/commands/set_level_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SetLevelMenu extends StatefulWidget {
  static const double _kButtonSize = 40.0;
  static const double _kButtonBorderRadius = 30.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;
  static const double _kLegendImageHeight = 20.0;
  static const double _kLegendLevelImageHeight = 15.0;
  static const double _kLegendSpacer = 8.0;
  static const double _kBoxShadowSpread = 1.0;
  static const double _kBoxShadowBlur = 3.0;
  static const double _kMenuWidth = 270.0;
  static const double _kMenuHeightWithLegend = 400.0;
  static const double _kMenuHeightNoLegend = 287.0;
  static const double _kTopSpacing = 20.0;
  static const int _kMaxHealth = 900;
  static const double _kBoxShadowAlpha = 0.3;
  static const int _kLevelMin = 0;
  static const int _kLevelMax = 7;
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

  @override
  SetLevelMenuState createState() => SetLevelMenuState();
}

class SetLevelMenuState extends State<SetLevelMenu> {
  late final GameState _gameState;
  late final Settings _settings;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
  }

  Widget buildLevelButton(int nr, double scale) {
    return ValueListenableBuilder<bool>(
        valueListenable: _gameState.solo,
        builder: (context, value, child) {
          return ValueListenableBuilder<int>(
              valueListenable: _gameState.level,
              builder: (context, value, child) {
                bool isCurrentlySelected;
                if (widget.monster != null) {
                  isCurrentlySelected = nr == widget.monster!.level.value;
                } else {
                  isCurrentlySelected = nr == _gameState.level.value;
                }
                bool isRecommended = GameMethods.getRecommendedLevel() == nr;
                Color color = Colors.transparent;
                if (isRecommended) {
                  color = Colors.grey;
                }
                String text = nr.toString();
                bool darkMode = _settings.darkMode.value;
                return SizedBox(
                  width: SetLevelMenu._kButtonSize * scale,
                  height: SetLevelMenu._kButtonSize * scale,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: color,
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(SetLevelMenu._kButtonBorderRadius * scale))),
                      child: TextButton(
                        child: Text(
                          text,
                          style: TextStyle(
                              fontSize: kFontSizeTitle * scale,
                              shadows: [
                                Shadow(
                                    offset: Offset(SetLevelMenu._kShadowOffset * scale, SetLevelMenu._kShadowOffset * scale),
                                    color: isCurrentlySelected
                                        ? darkMode
                                            ? Colors.black
                                            : Colors.grey
                                        : Colors.black)
                              ],
                              color: isCurrentlySelected
                                  ? darkMode
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.grey),
                        ),
                        onPressed: () {
                          if (!isCurrentlySelected) {
                            String? monsterId = widget.monster?.id;
                            _gameState.action(SetLevelCommand(nr, monsterId));
                          }
                          Navigator.pop(context);
                        },
                      )),
                );
              });
        });
  }

  Widget createLegend(String name, String gfx, String value, double scale) {
    var shadow = Shadow(
      offset: Offset(SetLevelMenu._kShadowOffset * scale, SetLevelMenu._kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: SetLevelMenu._kShadowBlur * scale,
    );
    var textStyleLevelWidget = TextStyle(
        color: Colors.white,
        overflow: TextOverflow.fade,
        fontSize: kFontSizeTitle * scale,
        shadows: [shadow]);
    double height = SetLevelMenu._kLegendImageHeight * scale;
    if (gfx.contains("level")) {
      height = SetLevelMenu._kLegendLevelImageHeight * scale;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: SetLevelMenu._kLegendSpacer * scale,
        ),
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: SetLevelMenu._kBoxShadowAlpha),
                  spreadRadius: SetLevelMenu._kBoxShadowSpread,
                  blurRadius: SetLevelMenu._kBoxShadowBlur,
                ),
              ],
            ),
            child: Image(height: height, image: AssetImage(gfx))),
        Text(value, style: textStyleLevelWidget),
        Text(" ($name)", style: textStyleLevelWidget),
      ],
    );
  }

  Widget buildDifficultyButton(int nr, double scale) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.difficulty,
        builder: (context, value, child) {
          bool isCurrentlySelected = nr == _gameState.difficulty.value;
          Color color = Colors.transparent;
          String text = nr.toString();
          if (nr > 0) {
            text = "+$text";
          }
          bool darkMode = _settings.darkMode.value;
          return SizedBox(
            width: SetLevelMenu._kButtonSize * scale,
            height: SetLevelMenu._kButtonSize * scale,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                    ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(SetLevelMenu._kButtonBorderRadius * scale))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: kFontSizeTitle * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(SetLevelMenu._kShadowOffset * scale, SetLevelMenu._kShadowOffset * scale),
                              color: isCurrentlySelected
                                  ? darkMode
                                      ? Colors.black
                                      : Colors.grey
                                  : Colors.black)
                        ],
                        color: isCurrentlySelected
                            ? darkMode
                                ? Colors.white
                                : Colors.black
                            : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      _gameState.action(SetDifficultyCommand(nr,
                          gameState: _gameState));
                    }
                  },
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String title = "Set Scenario Level";
    if (widget.monster != null) {
      String name = widget.monster!.type.display;
      if (widget.monster!.type.display.endsWith("y")) {
        name = "${name.substring(0, name.length - 1)}ie";
      }
      title = "Set $name's level";
    }
    //if summon:
    bool isSummon = widget.monster == null && widget.figure is MonsterInstance;
    if (isSummon) {
      title = "Set ${(widget.figure as MonsterInstance).name}'s max health";
    }

    String name = "";
    String ownerId = "";
    String figureId = "";
    if (widget.monster != null) {
      name = widget.monster!.type.display;
      ownerId = widget.monster!.id;
    } else if (widget.figure is CharacterState) {
      figureId = (widget.figure as CharacterState).display.value;
      ownerId = name;
    }
    if (widget.figure is MonsterInstance) {
      name = (widget.figure as MonsterInstance).name;
      int nr = (widget.figure as MonsterInstance).standeeNr;
      String gfx = (widget.figure as MonsterInstance).gfx;
      figureId = name + gfx + nr.toString();
      if (widget.characterId != null) {
        ownerId = widget.characterId!;
      }
    }

    bool showLegend = widget.figure == null;

    bool darkMode = _settings.darkMode.value;

    double scale = getModalMenuScale(context);

    return ModalBackground(
        width: SetLevelMenu._kMenuWidth * scale,
        height: showLegend ? SetLevelMenu._kMenuHeightWithLegend * scale : SetLevelMenu._kMenuHeightNoLegend * scale,
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: SetLevelMenu._kTopSpacing * scale,
              ),
              Text(title, style: getTitleTextStyle(scale)),
              if (!isSummon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    SetLevelMenu._kLevelRowSize,
                    (i) => buildLevelButton(SetLevelMenu._kLevelMin + i, scale),
                  ),
                ),
              if (!isSummon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    SetLevelMenu._kLevelRowSize,
                    (i) => buildLevelButton(SetLevelMenu._kLevelRow2Start + i, scale),
                  ),
                ),
              if (widget.figure == null)
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
                            _gameState.action(SetSoloCommand(newValue!));
                          },
                          value: _gameState.solo.value,
                        );
                      })
                ]),
              if (widget.figure == null)
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
                                newValue!,
                                gameState: _gameState));
                          },
                          value: _gameState.autoScenarioLevel.value,
                        );
                      })
                ]),
              if (widget.figure == null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Difficulty:", style: getSmallTextStyle(scale)),
                  ...List.generate(
                    SetLevelMenu._kDifficultyCount,
                    (i) => buildDifficultyButton(SetLevelMenu._kDifficultyMin + i, scale),
                  ),
                ]),
              if (widget.figure != null)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CounterButton(
                      notifier: widget.figure!.maxHealth,
                      command: ChangeMaxHealthCommand(0, figureId, ownerId,
                          gameState: _gameState),
                      maxValue: SetLevelMenu._kMaxHealth,
                      image: "assets/images/abilities/heal.png",
                      showTotalValue: true,
                      color: Colors.red,
                      figureId: figureId,
                      ownerId: ownerId,
                      scale: scale)
                ]),
              if (showLegend)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    createLegend(
                        "trap damage",
                        "assets/images/psd/traps-fh.png",
                        ": ${GameMethods.getTrapValue()}",
                        scale),
                    createLegend(
                        "hazardous terrain damage",
                        "assets/images/psd/hazard-fh.png",
                        ": ${GameMethods.getHazardValue()}",
                        scale),
                    createLegend("experience added", "assets/images/psd/xp.png",
                        ": +${GameMethods.getXPValue()}", scale),
                    createLegend(
                        "gold coin value",
                        "assets/images/psd/coins-fh.png",
                        ": x${GameMethods.getCoinValue()}",
                        scale),
                    createLegend("level", "assets/images/psd/level.png",
                        ": ${_gameState.level.value}", scale),
                  ],
                )
            ],
          ),
        ]));
  }
}
