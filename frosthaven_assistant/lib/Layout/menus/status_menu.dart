import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/change_stat_commands/change_chill_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/commands/change_stat_commands/change_stat_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';
import 'main_menu.dart';

class StatusMenu extends StatefulWidget {
  const StatusMenu(
      {Key? key, required this.figureId, this.characterId, this.monsterId})
      : super(key: key);

  final String figureId;
  final String? monsterId;
  final String? characterId;

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
      ValueNotifier<int> notifier, int maxValue, String image, String figureId, String ownerId) {
    return Row(children: [
      Container(
          width: 40,
          height: 40,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              //iconSize: 30,
              onPressed: () {
                if (notifier.value > 0) {
                  _gameState
                      .action(ChangeChillCommand(-1, figureId, ownerId));
                  _gameState.action(
                      RemoveConditionCommand(Condition.chill, figureId, ownerId));
                }
                //increment
              })),
      Stack(children: [
        Container(
          width: 40,
          height: 40,
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
          width: 40,
          height: 40,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            //iconSize: 30,
            onPressed: () {
              if (notifier.value < maxValue) {
                _gameState
                    .action(ChangeChillCommand(1, figureId, ownerId));
                _gameState.action(
                    AddConditionCommand(Condition.chill, figureId, ownerId ));
              }
              //increment
            },
          )),
    ]);
  }

  Widget buildConditionButton(Condition condition, String figureId, String ownerId) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          Figure? figure = GameMethods.getFigure(ownerId, figureId);
          if(figure == null) {
            return Container();
          }
          bool isActive = isConditionActive(condition, figure );
          if (isActive) {
            color = getIt<Settings>().darkMode.value? Colors.white : Colors.black;
          }
          return Container(
                width: 42,
                  height: 42,
                  margin: const EdgeInsets.all(1),
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
                            AddConditionCommand(condition, figureId, ownerId));
                      } else {
                        _gameState.action(
                            RemoveConditionCommand(condition, figureId, ownerId));
                      }
                    },
                  ));
        });
  }

  @override
  Widget build(BuildContext context) {
    bool hasMireFoot = false;
    bool isSummon = (widget.monsterId == null && widget.characterId != widget.figureId); //hack - should have monsterBox send summon data instead
    for (var item in _gameState.currentList) {
      if (item.id == "Mirefoot") {
        hasMireFoot = true;
        break;
      }
    }

    String name = "";
    String ownerId = "";
    if(widget.monsterId != null) {
      name = widget.monsterId!;
      ownerId = widget.monsterId!;

    }else if(widget.characterId != null){
      name = widget.characterId!;
      ownerId = name;
    }

    String figureId = widget.figureId;
    Figure? figure = GameMethods.getFigure(ownerId, figureId);
    if (figure == null) {
      return Container();
    }

    if (figure is MonsterInstance) {
      name = (figure).name;
    }
      //has to be summon

    //get id and owner Id

    Monster? monster;
    if(widget.monsterId != null){
      for (var item in _gameState.currentList){
        if(item.id == widget.monsterId){
          monster = item as Monster;
        }
      }
    }

    Character? character;
    if(widget.characterId != null){
      for (var item in _gameState.currentList){
        if(item.id == widget.characterId){
          character = item as Character;
        }
      }
    }




    return Container(
        width: 340,
        height: 211,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value?
            'assets/images/bg/dark_bg.png'
                :'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text(name,
              style: getTitleTextStyle()
          ),
          Row(children: [
          ValueListenableBuilder<int>(
              valueListenable: _gameState.commandIndex,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CounterButton(figure.health,
                        ChangeHealthCommand(0, figureId, ownerId),
                        figure.maxHealth.value,
                         "assets/images/blood.png", false, Colors.red, figureId: figureId, ownerId: ownerId),
                    /*buildCounterButtons(
                        figure.health,
                        ChangeHealthCommand(0, figureId, ownerId),
                        figure.maxHealth.value,
                        "assets/images/blood.png", context, figure, false, Colors.red),*/
                    widget.characterId != null && !isSummon?
                    CounterButton((figure as CharacterState).xp, ChangeXPCommand(0, figureId, ownerId),
                        900, "assets/images/psd/xp.png", false, Colors.blue, figureId: figureId, ownerId: ownerId)
                        : Container(),
                    widget.characterId != null || isSummon
                        ? buildChillButtons(
                            figure.chill,
                            12, //technically you can have infinite, but realistically not so much
                            "assets/images/conditions/chill.png",
                      figureId,
                      ownerId
                    )
                        : Container(),
                    widget.monsterId!= null ?
                    CounterButton(_gameState.modifierDeck.blesses, ChangeBlessCommand(0, figureId, ownerId),
                        10, "assets/images/abilities/bless.png", true, Colors.white, figureId: figureId, ownerId: ownerId)
                        : Container(),
                    widget.monsterId!= null ?
                    CounterButton(_gameState.modifierDeck.curses, ChangeCurseCommand(0, figureId, ownerId),
                        10, "assets/images/abilities/curse.png", true, Colors.white, figureId: figureId, ownerId: ownerId)
                        : Container(),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          child: IconButton(
                            icon: Image.asset('assets/images/psd/skull.png'),
                            //iconSize: 10,
                            onPressed: () {
                              Navigator.pop(context);
                              _gameState.action(ChangeHealthCommand(
                                  -figure.health.value,
                                 figureId,
                                  ownerId)
                              );
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
                                if (figure is CharacterState) {
                                  openDialog(
                                    context,
                                    SetCharacterLevelMenu(character: character!),
                                  );
                                } else {
                                  openDialog(
                                    context,
                                    SetLevelMenu(monster: monster, figure: figure, characterId: widget.characterId),

                                  );
                                }
                              },
                            )),
                        Text(figure.level.value.toString(),
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
                height: 2,
              ),
              //const Text("Status", style: TextStyle(fontSize: 18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.stun,figureId, ownerId),
                  buildConditionButton(Condition.immobilize,figureId, ownerId),
                  buildConditionButton(Condition.disarm,figureId, ownerId),
                  buildConditionButton(Condition.wound,figureId, ownerId),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.muddle,figureId, ownerId),
                  buildConditionButton(Condition.poison,figureId, ownerId),
                  buildConditionButton(Condition.bane,figureId, ownerId),
                  buildConditionButton(Condition.brittle,figureId, ownerId),
                ],
              ),
              widget.characterId != null || isSummon
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildConditionButton(Condition.infect,figureId, ownerId),
                        if(!isSummon )buildConditionButton(Condition.impair,figureId, ownerId),
                        buildConditionButton(Condition.rupture,figureId, ownerId),
                      ],
                    )
                  : !hasMireFoot
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.poison2,figureId, ownerId),
                            buildConditionButton(Condition.rupture,figureId, ownerId),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.wound2,figureId, ownerId),
                            buildConditionButton(Condition.poison2,figureId, ownerId),
                            buildConditionButton(Condition.poison3,figureId, ownerId),
                            buildConditionButton(Condition.poison4,figureId, ownerId),
                            buildConditionButton(Condition.rupture,figureId, ownerId),
                          ],
                        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.strengthen,figureId, ownerId),
                  buildConditionButton(Condition.invisible,figureId, ownerId),
                  buildConditionButton(Condition.regenerate,figureId, ownerId),
                  buildConditionButton(Condition.ward,figureId, ownerId),
                ],
              ),
            ],
          ),
        ])]));
  }
}
