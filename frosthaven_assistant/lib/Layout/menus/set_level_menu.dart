import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_auto_level_adjust_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_difficulty_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_solo_command.dart';

import '../../Resource/commands/set_level_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SetLevelMenu extends StatefulWidget {
  const SetLevelMenu({super.key, this.monster, this.figure, this.characterId});

  final Monster? monster;
  final String? characterId;
  final FigureState? figure;

  @override
  SetLevelMenuState createState() => SetLevelMenuState();
}

class SetLevelMenuState extends State<SetLevelMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
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
          bool darkMode = getIt<Settings>().darkMode.value;
          return SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30 * scale))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 18 * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: isCurrentlySelected
                                  ? darkMode
                                      ? Colors.black
                                      : Colors.grey
                                  : darkMode
                                      ? Colors.black
                                      : Colors.black)
                        ],
                        color: isCurrentlySelected
                            ? darkMode
                                ? Colors.white
                                : Colors.black
                            : darkMode
                                ? Colors.grey
                                : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      String? monsterId;
                      if (widget.monster != null) {
                        monsterId = widget.monster!.id;
                      }
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
      offset: Offset(1 * scale, 1 * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );
    var textStyleLevelWidget = TextStyle(
        color: Colors.white,
        overflow: TextOverflow.fade,
        fontSize: 18 * scale,
        shadows: [
          shadow
        ]);
    double height = 20 * scale;
    if (gfx.contains("level")) {
      height = 15 * scale;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 8 * scale,
        ),
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3.0,
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
          if(nr > 0) {
            text = "+$text";
          }
          bool darkMode = getIt<Settings>().darkMode.value;
          return SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30 * scale))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 18 * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: isCurrentlySelected
                                  ? darkMode
                                  ? Colors.black
                                  : Colors.grey
                                  : darkMode
                                  ? Colors.black
                                  : Colors.black)
                        ],
                        color: isCurrentlySelected
                            ? darkMode
                            ? Colors.white
                            : Colors.black
                            : darkMode
                            ? Colors.grey
                            : Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      _gameState.action(SetDifficultyCommand(nr));
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
      if(widget.monster!.type.display.endsWith("y")) {
        name = "${name.substring(0, name.length-1)}ie";
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

    bool darkMode = getIt<Settings>().darkMode.value;

    double scale = 1;
    if (!isPhoneScreen(context)) {
      scale = 1.5;
      if (isLargeTablet(context)) {
        scale = 2;
      }
    }

    return Container(
        width: 270 * scale,
        height: showLegend ? 400 * scale : 287 * scale,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(
                darkMode ? 'assets/images/bg/dark_bg.png' : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20 * scale,
                  ),
                  Text(title, style: getTitleTextStyle(scale)),
                  if (!isSummon)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildLevelButton(0, scale),
                        buildLevelButton(1, scale),
                        buildLevelButton(2, scale),
                        buildLevelButton(3, scale),
                      ],
                    ),
                  if (!isSummon)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildLevelButton(4, scale),
                        buildLevelButton(5, scale),
                        buildLevelButton(6, scale),
                        buildLevelButton(7, scale),
                      ],
                    ),
                  if(widget.figure == null)
                       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text("Solo:", style: getSmallTextStyle(scale)),
                          ValueListenableBuilder<bool>(
                              valueListenable: _gameState.solo,
                              builder: (context, value, child) {
                                return Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.grey.shade200,
                                  side: BorderSide(color: darkMode ? Colors.white : Colors.black),
                                  onChanged: (bool? newValue) {
                                    _gameState.action(SetSoloCommand(newValue!));
                                  },
                                  value: _gameState.solo.value,
                                );
                              })
                        ]),

                  if(widget.figure == null)
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Automatic Scenario Level:", style: getSmallTextStyle(scale)),
                      ValueListenableBuilder<bool>(
                          valueListenable: _gameState.autoScenarioLevel,
                          builder: (context, value, child) {
                            return Checkbox(
                              checkColor: Colors.black,
                              activeColor: Colors.grey.shade200,
                              side: BorderSide(color: darkMode ? Colors.white : Colors.black),
                              onChanged: (bool? newValue) {
                                _gameState.action(SetAutoLevelAdjustCommand(newValue!));
                              },
                              value: _gameState.autoScenarioLevel.value,
                            );
                          })
                    ]),

                  if(widget.figure == null)
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Difficulty:", style: getSmallTextStyle(scale)),

                        buildDifficultyButton(-1, scale),
                      buildDifficultyButton(0, scale),
                      buildDifficultyButton(1, scale),
                      buildDifficultyButton(2, scale),
                      buildDifficultyButton(3, scale),

                    ]),

                  if(widget.figure != null)
                       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          CounterButton(
                              widget.figure!.maxHealth,
                              ChangeMaxHealthCommand(0, figureId, ownerId),
                              900,
                              "assets/images/abilities/heal.png",
                              true,
                              Colors.red,
                              figureId: figureId,
                              ownerId: ownerId,
                              scale: scale)
                        ]),
                  if (showLegend == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        createLegend("trap damage", "assets/images/psd/traps-fh.png",
                            ": ${GameMethods.getTrapValue()}", scale),
                        createLegend("hazardous terrain damage", "assets/images/psd/hazard-fh.png",
                            ": ${GameMethods.getHazardValue()}", scale),
                        createLegend("experience added", "assets/images/psd/xp.png",
                            ": +${GameMethods.getXPValue()}", scale),
                        createLegend("gold coin value", "assets/images/psd/coins-fh.png",
                            ": x${GameMethods.getCoinValue()}", scale),
                        createLegend("level", "assets/images/psd/level.png",
                            ": ${_gameState.level.value}", scale),
                      ],
                    )
                ],
              ),
            ]));
  }
}
