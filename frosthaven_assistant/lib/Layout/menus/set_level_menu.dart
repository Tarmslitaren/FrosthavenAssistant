import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/counter_button.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import '../../Resource/commands/set_level_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class SetLevelMenu extends StatefulWidget {
  const SetLevelMenu({Key? key, this.monster, this.figure, this.characterId}) : super(key: key);

  final Monster? monster;
  final String? characterId;
  final Figure? figure;

  @override
  _SetLevelMenuState createState() => _SetLevelMenuState();
}

class _SetLevelMenuState extends State<SetLevelMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  Widget buildLevelButton(int nr) {
    return ValueListenableBuilder<bool>(
        valueListenable: _gameState.solo,
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
          if (isCurrentlySelected) {
            //color = Colors.black;
          }
          String text = nr.toString();
          bool darkMode = getIt<Settings>().darkMode.value;
          return SizedBox(
            width: 32,
            height: 32,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                        shadows: [
                      Shadow(
                          offset: Offset(1, 1),
                          color:
                              isCurrentlySelected ?
                              darkMode? Colors.black : Colors.grey :
                              darkMode? Colors.black : Colors.black)
                    ],
                        color: isCurrentlySelected ?
                        darkMode? Colors.white : Colors.black :
                        darkMode? Colors.grey :Colors.grey),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      String? monsterId;
                      if(widget.monster != null) {
                        monsterId = widget.monster!.id;
                      }
                      _gameState.action(SetLevelCommand(nr, monsterId));
                    }
                    Navigator.pop(context);
                  },
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String title = "Set Scenario Level";
    if (widget.monster != null) {
      title = "Set " + widget.monster!.type.display + "'s level";
    }
    //if summon:
    bool isSummon = widget.monster == null && widget.figure is MonsterInstance;
    if(isSummon) {
      title = "Set ${(widget.figure as MonsterInstance).name}'s max health";
    }


    String name = "";
    String ownerId = "";
    String figureId = "";
    if(widget.monster != null) {
      name = widget.monster!.type.display;
      ownerId = widget.monster!.id;

    }else if(widget.figure is CharacterState){
      figureId = ( widget.figure as CharacterState).display;
      ownerId = name;
    }
    if (widget.figure is MonsterInstance) {
      name = (widget.figure as MonsterInstance).name;
      int nr = (widget.figure as MonsterInstance).standeeNr;
      String gfx = (widget.figure as MonsterInstance).gfx;
      figureId = name + gfx + nr.toString();
      if(widget.characterId != null) {
        ownerId = widget.characterId!;
      }
    }


    return Container(
        width: 10,
        height: 160,
        decoration: BoxDecoration(
          //color: Colors.black,
          //borderRadius: BorderRadius.all(Radius.circular(8)),

          /*border: Border.fromBorderSide(BorderSide(
            color: Colors.blueGrey,
            width: 10
          )),*/
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value?
            'assets/images/bg/dark_bg.png'
                :'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            //alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(title, style: getTitleTextStyle()),
                  if (!isSummon) Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLevelButton(0),
                      buildLevelButton(1),
                      buildLevelButton(2),
                      buildLevelButton(3),
                    ],
                  ),
                  if (!isSummon) Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLevelButton(4),
                      buildLevelButton(5),
                      buildLevelButton(6),
                      buildLevelButton(7),
                    ],
                  ),
                  widget.figure == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text("Solo:", style: getSmallTextStyle()),
                              ValueListenableBuilder<bool>(
                                  valueListenable: _gameState.solo,
                                  builder: (context, value, child) {
                                    return Checkbox(
                                      checkColor: Colors.black,
                                      activeColor:  Colors.grey.shade200,
                                      side: BorderSide(color: getIt<Settings>().darkMode.value? Colors.white : Colors.black),
                                      onChanged: (bool? newValue) {
                                        _gameState.solo.value = newValue!;
                                      },
                                      value: _gameState.solo.value,
                                    );
                                  })
                            ])
                      : Container(),
                  widget.figure != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CounterButton(widget.figure!.maxHealth, ChangeMaxHealthCommand(0, figureId, ownerId),
                                900, "assets/images/blood.png", true, Colors.red, figureId: figureId, ownerId: ownerId)
                            ])
                      : Container(),
                ],
              ),
            ]));
  }
}
