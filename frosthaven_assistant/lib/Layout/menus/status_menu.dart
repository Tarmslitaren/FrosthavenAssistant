
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/change_stat_commands/change_chill_command.dart';
import '../../Resource/commands/change_stat_commands/change_health_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../Resource/modifier_deck_state.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

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
  StatusMenuState createState() => StatusMenuState();
}

class StatusMenuState extends State<StatusMenu> {
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
      SizedBox(
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

  Widget buildConditionButton(Condition condition, String figureId, String ownerId, List<String> immunities) {
    bool enabled = true;
    for (var item in immunities) {
      if (condition.name.contains(item.substring(1, item.length-1))) {
        enabled = false;
      }
      if (item.substring(1, item.length-1) == "poison" && condition == Condition.infect) {
        enabled = false;
      }
      if (item.substring(1, item.length-1) == "wound" && condition == Condition.rupture) {
        enabled = false;
      }
      //immobilize or muddle: also chill - doesn't matter: monster can't be chilled and players don't have immunities.
    }
   // enabled = false;
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
          double scale = 2.1;
          return Container(
                width: 42,
                  height: 42,
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  child: IconButton(
                    //iconSize: 24,
                    icon: enabled? Image.asset(
                        'assets/images/conditions/${condition.name}.png'):

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(left: 0, top: 0, child: Image(
                            height: 11 * scale,
                            image: AssetImage('assets/images/conditions/${condition.name}.png'),
                          )),
                          Positioned(
                            //TODO: should be 9 but there is a clipping issue
                              left: 7.5 * scale, top: 3.5 * scale, child:
                          Image(
                            height: 4 * scale,
                            image: const AssetImage("assets/images/psd/immune.png"),
                          )),
                        ],

                    ),
                    //iconSize: 30,
                    onPressed: enabled? () {
                      if (!isActive) {
                        _gameState.action(
                            AddConditionCommand(
                                condition, figureId, ownerId));
                      } else {
                        _gameState.action(
                            RemoveConditionCommand(
                                condition, figureId, ownerId));
                      }
                    }: null,
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

    List<String> immunities = [];
    Monster? monster;
    if (figure is MonsterInstance) {
      name = (figure).name;

      if(widget.monsterId != null){
        for (var item in _gameState.currentList){
          if(item.id == widget.monsterId){
            monster = item as Monster;
            if(figure.type == MonsterType.normal) {
              immunities = monster.type.levels[monster.level.value].normal!.immunities;
            }else if(figure.type == MonsterType.elite) {
              immunities = monster.type.levels[monster.level.value].elite!.immunities;
            }else if(figure.type == MonsterType.boss) {
              immunities = monster.type.levels[monster.level.value].boss!.immunities;
            }
          }
        }
      }
    }
      //has to be summon

    //get id and owner Id


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

                ModifierDeck deck = _gameState.modifierDeck;
                if (widget.monsterId != null) {
                  for (var item in _gameState.currentList) {
                    if (item.id == widget.monsterId) {
                      if (item is Monster && item.isAlly) {
                        deck = _gameState.modifierDeckAllies;
                      }
                    }
                  }

                }

                bool canBeCursed = true;
                for (var item in immunities) {
                  if (item.substring(1, item.length - 1) == "curse") {
                    canBeCursed = false;
                  }
                }


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
                    CounterButton(deck.blesses, ChangeBlessCommand(0, figureId, ownerId),
                        10, "assets/images/abilities/bless.png", true, Colors.white, figureId: figureId, ownerId: ownerId)
                        : Container(),
                    widget.monsterId!= null && canBeCursed ?
                    CounterButton(deck.curses, ChangeCurseCommand(0, figureId, ownerId),
                        10, "assets/images/abilities/curse.png", true, Colors.white, figureId: figureId, ownerId: ownerId)
                        : Container(),
                    Row(
                      children: [
                        SizedBox(
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
                        SizedBox(
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
                  buildConditionButton(Condition.stun,figureId, ownerId, immunities),
                  buildConditionButton(Condition.immobilize,figureId, ownerId, immunities),
                  buildConditionButton(Condition.disarm,figureId, ownerId, immunities),
                  buildConditionButton(Condition.wound,figureId, ownerId, immunities),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.muddle,figureId, ownerId, immunities),
                  buildConditionButton(Condition.poison,figureId, ownerId, immunities),
                  buildConditionButton(Condition.bane,figureId, ownerId, immunities),
                  buildConditionButton(Condition.brittle,figureId, ownerId, immunities),
                ],
              ),
              widget.characterId != null || isSummon
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildConditionButton(Condition.infect,figureId, ownerId, immunities),
                        if(!isSummon )buildConditionButton(Condition.impair,figureId, ownerId, immunities),
                        buildConditionButton(Condition.rupture,figureId, ownerId, immunities),
                      ],
                    )
                  : !hasMireFoot
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.poison2,figureId, ownerId, immunities),
                            buildConditionButton(Condition.rupture,figureId, ownerId, immunities),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildConditionButton(Condition.wound2,figureId, ownerId, immunities),
                            buildConditionButton(Condition.poison2,figureId, ownerId, immunities),
                            buildConditionButton(Condition.poison3,figureId, ownerId, immunities),
                            buildConditionButton(Condition.poison4,figureId, ownerId, immunities),
                            buildConditionButton(Condition.rupture,figureId, ownerId, immunities),
                          ],
                        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildConditionButton(Condition.strengthen,figureId, ownerId, immunities),
                  buildConditionButton(Condition.invisible,figureId, ownerId, immunities),
                  buildConditionButton(Condition.regenerate,figureId, ownerId, immunities),
                  buildConditionButton(Condition.ward,figureId, ownerId, immunities),
                ],
              ),
            ],
          ),
        ])]));
  }
}
