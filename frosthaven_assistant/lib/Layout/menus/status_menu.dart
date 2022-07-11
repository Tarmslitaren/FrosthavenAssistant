import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/change_stat_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import 'main_menu.dart';

class StatusMenu extends StatefulWidget {
  const StatusMenu(
      {Key? key, required this.figure, this.character, this.monster})
      : super(key: key);

  final Figure figure;
  final Character? character;
  final Monster? monster;

  //conditions always:
  //stun,
  //immobilize,
  //disarm,
  //wound,
  //muddle,
  //poison,
  //bane,
  //brittle,
  //strengthen,
  //invisible,
  //regenerate,
  //ward;

  //rupture

  //only monsters:

  //only certain character:
  //poison3,
  //poison4,
  //wound2,

  //poison2,

  //only characters;
  //chill, ((only certain scenarios/monsters)
  //infect,((only certain scenarios/monsters)
  //impair

  //character:
  // sliders: hp, xp, chill: normal
  //monster:
  // sliders: hp bless, curse: normal

  //monster layout:
  //stun immobilize  disarm  wound
  //muddle poison bane brittle
  //variable: rupture poison 2 OR  rupture, wound2, poison 2-4
  //strengthen invisible regenerate ward

  //character layout
  //same except line 3: infect impair rupture

  //TODO: add setting: turn off CS conditions?


  @override
  _StatusMenuState createState() => _StatusMenuState();
}

class _StatusMenuState extends State<StatusMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  bool isConditionActive(Condition condition, Figure figure) {
    bool isActive = false;
    for (var item in figure.conditions.value) {
      if (item == condition) {
        isActive = true;
        break;
      }
    }
    return isActive;
  }

  void activateCondition(Condition condition, Figure figure) {
    List<Condition> newList = [];
    newList.addAll(figure.conditions.value);
    newList.add(condition);
    figure.conditions.value = newList;
  }

  Widget buildChillButtons(
      ValueNotifier<int> notifier, int maxValue, String image) {
    return Row(children: [
      Container(
          width: 42,
          height: 42,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              //iconSize: 30,
              onPressed: () {
                if (notifier.value > 0) {
                  _gameState
                      .action(ChangeStatCommand(-1, notifier, widget.figure));
                  _gameState.action(
                      RemoveConditionCommand(Condition.chill, widget.figure));
                }
                //increment
              })),
      Stack(children: [
        Container(
          width: 42,
          height: 42,
          child: Image(
            image: AssetImage(image),
          ),
        ),
        ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (context, value, child) {
              String text = notifier.value.toString();
              if(notifier.value == 0) {
                text = "";
              }
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(text, style: const TextStyle(color: Colors.blue,
                      shadows: [
                        Shadow(offset: Offset(1, 1), color: Colors.black)]),)
              );
            })
      ]),
      Container(
          width: 42,
          height: 42,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            //iconSize: 30,
            onPressed: () {
              if (notifier.value < maxValue) {
                _gameState
                    .action(ChangeStatCommand(1, notifier, widget.figure));
                _gameState.action(
                    AddConditionCommand(Condition.chill, widget.figure));
              }
              //increment
            },
          )),
    ]);
  }

  Widget buildConditionButton(Condition condition) {
    return ValueListenableBuilder<List<Condition>>(
        valueListenable: widget.figure.conditions,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          bool isActive = isConditionActive(condition, widget.figure);
          if (isActive) {
            color = Colors.black;
          }
          return SizedBox(
              width: 42,
              height: 42,
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  child: IconButton(
                    icon: Image.asset(
                        'assets/images/conditions/${condition.name}.png'),
                    //iconSize: 30,
                    onPressed: () {
                      if (!isActive) {
                        _gameState.action(
                            AddConditionCommand(condition, widget.figure));
                      } else {
                        _gameState.action(
                            RemoveConditionCommand(condition, widget.figure));
                      }
                    },
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    bool hasMireFoot = false;
    bool isSummon = (widget.monster == null && widget.character == null); //hack - should have monsterBox send summon data instead
    for (var item in _gameState.currentList) {
      if (item.id == "Mirefoot") {
        hasMireFoot = true;
        break;
      }
    }
    String name = "";
    if(widget.monster != null) {
      name = widget.monster!.type.display;

    }else if(widget.character != null){
      name = widget.character!.characterState.display;
    }else if (widget.figure is MonsterInstance) {
      name = (widget.figure as MonsterInstance).name;
    }
      //has to be summon


    return Container(
        width: 336,
        height: 210,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage('assets/images/bg/white_bg.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text(name),
          Row(children: [
          ValueListenableBuilder<int>(
              valueListenable: widget.figure.maxHealth,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCounterButtons(
                        widget.figure.health,
                        widget.figure.maxHealth.value,
                        "assets/images/blood.png", context, widget.figure, false, Colors.red),
                    widget.character != null
                        ? buildCounterButtons(
                            widget.character!.characterState.xp,
                            900,
                            "assets/images/psd/xp.png", context, widget.figure, false, Colors.blue)
                        : Container(),
                    widget.character != null || isSummon
                        ? buildChillButtons(
                            widget.figure.chill,
                            5,
                            "assets/images/conditions/chill.png")
                        : Container(),
                    widget.monster!= null ?
                        buildCounterButtons(_gameState.modifierDeck.blesses, 10, "assets/images/abilities/bless.png", context, widget.figure, true, Colors.white): Container(),
                    widget.monster!= null ?
                    buildCounterButtons(_gameState.modifierDeck.curses, 10, "assets/images/abilities/curse.png", context, widget.figure, true, Colors.white): Container(),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          child: IconButton(
                            icon: Image.asset('assets/images/psd/skull.png'),
                            //iconSize: 10,
                            onPressed: () {
                              _gameState.action(ChangeStatCommand(
                                  -widget.figure.health.value,
                                  widget.figure.health,
                                  widget.figure));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                            width: 42,
                            height: 42,
                            child: IconButton(
                              icon: Image.asset(
                                  colorBlendMode: BlendMode.multiply,
                                  'assets/images/psd/level.png'),
                              //iconSize: 10,
                              onPressed: () {
                                if (widget.figure is CharacterState) {
                                  openDialog(
                                    context,
                                    SetCharacterLevelMenu(character: widget.character!),
                                  );
                                } else {
                                  openDialog(
                                    context,
                                    SetLevelMenu(monster: widget.monster, figure: widget.figure,), //TODO: should add summon data here instead

                                  );
                                }
                              },
                            )),
                        Text(widget.figure.level.value.toString(),
                            style:
                                const TextStyle(color: Colors.white, shadows: [
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  color: Colors.black),
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  color: Colors.black),
                              //Shadow(offset: Offset(1, 1),blurRadius: 2, color: Colors.black)
                            ])),
                      ],
                    )
                  ], //three +/- button groups and then kill/setlevel buttons
                );
              }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              //const Text("Status", style: TextStyle(fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.stun),
                  buildConditionButton(Condition.immobilize),
                  buildConditionButton(Condition.disarm),
                  buildConditionButton(Condition.wound),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.muddle),
                  buildConditionButton(Condition.poison),
                  buildConditionButton(Condition.bane),
                  buildConditionButton(Condition.brittle),
                ],
              ),
              widget.character != null || isSummon
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildConditionButton(Condition.infect),
                        if(!isSummon )buildConditionButton(Condition.impair),
                        buildConditionButton(Condition.rupture),
                      ],
                    )
                  : !hasMireFoot
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.poison2),
                            buildConditionButton(Condition.rupture),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.wound2),
                            buildConditionButton(Condition.poison2),
                            buildConditionButton(Condition.poison3),
                            buildConditionButton(Condition.poison4),
                            buildConditionButton(Condition.rupture),
                          ],
                        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.strengthen),
                  buildConditionButton(Condition.invisible),
                  buildConditionButton(Condition.regenerate),
                  buildConditionButton(Condition.ward),
                ],
              ),
            ],
          ),
        ])]));
  }
}
