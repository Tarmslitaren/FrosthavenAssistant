import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/line_builder.dart';
import 'package:frosthaven_assistant/Layout/menus/main_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/numpad_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/character_class.dart';
import '../Resource/color_matrices.dart';
import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'main_list.dart';
import 'menus/add_standee_menu.dart';
import 'menus/add_summon_menu.dart';
import 'monster_box.dart';

class CharacterWidget extends StatefulWidget {
  final String characterId;
  final int? initPreset;

  const CharacterWidget(
      {required this.characterId, required this.initPreset, Key? key})
      : super(key: key);

  @override
  _CharacterWidgetState createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget> {

  final GameState _gameState = getIt<GameState>();
  late bool isCharacter = true;
  final _initTextFieldController = TextEditingController();
  late List<MonsterInstance> lastList = [];
  late Character character;

  @override
  void initState() {
    super.initState();
    for (var item in _gameState.currentList) {
      if (item.id == widget.characterId){
        character = item as Character;
      }
    }
    lastList = character.characterState.summonList.value;

    if (widget.initPreset != null) {
      _initTextFieldController.text = widget.initPreset.toString();
    }
    _initTextFieldController.addListener(() {
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.characterState.display ==
              character.characterState.display) {
            if (_initTextFieldController.value.text.isNotEmpty) {
              item.characterState.initiative = int.parse(
                  _initTextFieldController
                      .value.text); //TODO: sanity check inputs
            }
            break;
          }

        }
      }
    });
    
    if (character.characterClass.name == "Objective" ||
        character.characterClass.name == "Escort") {
      isCharacter = false;
      //widget.character.characterState.initiative = widget.initPreset!;
    }
    if (isCharacter) {
      _initTextFieldController.clear();
    }
  }

  //TODO: try wrap
  List<Image> createConditionList(double scale) {
    List<Image> list = [];
    for (var item in character.characterState.conditions.value) {
      Image image = Image(
        height: 16 * scale,
        image: AssetImage("assets/images/conditions/${item.name}.png"),
      );
      list.add(image);
    }
    return list;
  }

  Widget summonsButton(double scale) {
    return Container(
        width: 30 * scale,
        height: 30 * scale,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Image.asset(
              color: Colors.white24,
              colorBlendMode: BlendMode.modulate,
              'assets/images/psd/add.png'),
          onPressed: () {
            openDialog(
              context,
              //problem: context is of stat card widget, not the + button
              AddSummonMenu(
                character: character,
              ),
            );
          },
        ));
  }

  Widget buildMonsterBoxGrid(double scale) {

    int displaystartAnimation = -1;

    if (lastList.length <
        character.characterState.summonList.value.length) {
      //find which is new - always the last one
      displaystartAnimation =
          character.characterState.summonList.value.length - 1;
    }

    final generatedChildren = List<Widget>.generate(
        character.characterState.summonList.value.length,
        (index) =>
            AnimatedSize(
              //not really needed now
              key: Key(index.toString()),
              duration: const Duration(milliseconds: 300),
              child: MonsterBox(
                  key: Key(character.characterState.summonList
                      .value[index].standeeNr
                      .toString()),
                  figureId: character.characterState.summonList
                      .value[index].name + character.characterState.summonList
                      .value[index].gfx + character.characterState.summonList
                      .value[index].standeeNr.toString(),
                  ownerId: character.id,
                  display: -2),
            ));
    lastList = character.characterState.summonList.value;
    return Wrap(
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double scaledHeight = 60 * scale;

    for (var item in _gameState.currentList) {
      if (item.id == widget.characterId){
        character = item as Character;
      }
    }

    return GestureDetector(
        onVerticalDragStart: (details) {
          //start moving the widget in the list
        },
        onVerticalDragUpdate: (details) {
          //update widget position?
        },
        onVerticalDragEnd: (details) {
          //place back in list
        },
        onTap: () {
          //open stats menu
          openDialog(
            context,
            StatusMenu(
                figureId: character.id,
                characterId: character.id
            ),
          );
        },
        child: ValueListenableBuilder<dynamic>(
            valueListenable: getIt<GameState>().modelData,
            //TODO: is this even needed?
            builder: (context, value, child) {
              return ColorFiltered(
                  colorFilter: character.characterState.health.value != 0
                      ? ColorFilter.matrix(identity)
                      : ColorFilter.matrix(grayScale),
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                    Container(
                      //padding: EdgeInsets.zero,
                      // color: Colors.amber,
                      //height: 50,
                      margin: EdgeInsets.only(
                          left: 4 * scale * 0.8,
                          right: 4 * scale * 0.8),
                      width:
                          getMainListWidth(context) - 8 * scale * 0.8,
                      child: ValueListenableBuilder<int>(
                          valueListenable:
                              getIt<GameState>().killMonsterStandee,
                          // widget.data.monsterInstances,
                          builder: (context, value, child) {
                            return buildMonsterBoxGrid(scale);
                          }),
                    ),
                    Container(
                        width: getMainListWidth(context),// 408 * scale,
                        height: 60 * scale,
                        child: Stack(
                      //alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          //background
                          margin: EdgeInsets.all(2 * scale),
                          width: 408 * scale,
                          height: 58 * scale,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                colorFilter: ColorFilter.mode(
                                    character.characterClass.color,
                                    BlendMode.color),
                                image: const AssetImage(
                                    "assets/images/psd/character-bar.png")),
                            shape: BoxShape.rectangle,
                            color: character.characterClass.color,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: 20 * scale,
                                  top: 5 * scale,
                                  bottom: 5 * scale),
                              child: Image(
                                fit: BoxFit.contain,
                                height: scaledHeight,
                                image: AssetImage(
                                  "assets/images/class-icons/${character.characterClass.name}.png",
                                ),
                                width: scaledHeight * 0.8,
                              ),
                            ),
                            Column(children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: scaledHeight / 6,
                                    left: 10 * scale),
                                child: Image(
                                  //fit: BoxFit.contain,
                                  height: scaledHeight * 0.1,
                                  image: const AssetImage(
                                      "assets/images/init.png"),
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                  valueListenable: _gameState.commandIndex,
                                  builder: (context, value, child) {
                                    if (isCharacter &&
                                        _gameState.commandIndex.value >=
                                            0 &&
                                        _gameState.commands[_gameState
                                            .commandIndex
                                            .value] is DrawCommand) {
                                      _initTextFieldController.clear();
                                    }
                                    if (_gameState.roundState.value ==
                                            RoundState.chooseInitiative &&
                                        character.characterState
                                                .health.value >
                                            0) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 10 * scale),
                                        height: 33 * scale,
                                        width: 25 * scale,
                                        child: TextField(

                                            //scrollPadding: EdgeInsets.zero,
                                            onTap: () {
                                                  //clear on enter focus
                                                  _initTextFieldController.clear();
                                                  if(getIt<Settings>().softNumpadInput.value){
                                                    openDialog(context, NumpadMenu(controller: _initTextFieldController,maxLength: 2,));
                                                  }
                                                },
                                            onChanged: (String str) {
                                              //close soft keyboard on 2 chars entered
                                              if (str.length == 2) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              }
                                            },

                                            //expands: true,
                                            textAlign: TextAlign.center,
                                            cursorColor: Colors.white,
                                            maxLength: 2,
                                            style: TextStyle(
                                                height: 1,
                                                //quick fix for web-phone disparity.
                                                fontFamily: 'Pirata',
                                                color: Colors.white,
                                                fontSize: 24 * scale,
                                                shadows: [
                                                  Shadow(
                                                      offset: Offset(
                                                          1 * scale,
                                                          1 * scale),
                                                      color: Colors.black)
                                                ]),
                                            decoration:
                                                const InputDecoration(
                                              counterText: '',
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.transparent),
                                              ),
                                              // border: UnderlineInputBorder(
                                              //   borderSide:
                                              //      BorderSide(color: Colors.pink),
                                              // ),
                                            ),
                                            controller:
                                                _initTextFieldController,
                                            keyboardType: getIt<Settings>().softNumpadInput.value?
                                                TextInputType.none :
                                            TextInputType.number),
                                      );
                                    } else {
                                      if (isCharacter) {
                                        _initTextFieldController.clear();
                                      }
                                      return Container(
                                          height: 33 * scale,
                                          width: 25 * scale,
                                          margin: EdgeInsets.only(
                                              left: 10 * scale),
                                          child: Text(
                                            character.characterState
                                                            .health.value >
                                                        0 &&
                                                    character
                                                            .characterState
                                                            .initiative >
                                                        0
                                                ? character
                                                    .characterState
                                                    .initiative
                                                    .toString()
                                                : "",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Pirata',
                                                color: Colors.white,
                                                fontSize: 24 * scale,
                                                shadows: [
                                                  Shadow(
                                                      offset: Offset(
                                                          1 * scale,
                                                          1 * scale),
                                                      color: Colors.black)
                                                ]),
                                          ));
                                    }
                                  }),
                            ]),
                            Column(
                                //mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                //align children to the left
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10 * scale, left: 10 * scale),
                                    child: Text(
                                      character.characterState.display,
                                      style: TextStyle(
                                          fontFamily: 'Pirata',
                                          color: Colors.white,
                                          fontSize: 16 * scale,
                                          shadows: [
                                            Shadow(
                                                offset: Offset(
                                                    1 * scale, 1 * scale),
                                                color: Colors.black)
                                          ]),
                                    ),
                                  ),
                                  ValueListenableBuilder<int>(
                                      valueListenable: character.characterState.health,
                                      //not working?
                                      builder: (context, value, child) {
                                        return Container(
                                            margin: EdgeInsets.only(
                                                left: 10 * scale),
                                            child: Row(children: [
                                              Image(
                                                fit: BoxFit.contain,
                                                height: scaledHeight * 0.2,
                                                image: const AssetImage(
                                                    "assets/images/blood.png"),
                                              ),
                                              Text(
                                                '${character.characterState.health.value.toString()} / ${character.characterState.maxHealth.value.toString()}',
                                                style: TextStyle(
                                                    fontFamily: 'Pirata',
                                                    color: Colors.white,
                                                    fontSize: 16 * scale,
                                                    shadows: [
                                                      Shadow(
                                                          offset: Offset(
                                                              1 * scale,
                                                              1 * scale),
                                                          color:
                                                              Colors.black)
                                                    ]),
                                              ),
                                              //add conditions here
                                              ValueListenableBuilder<
                                                      List<Condition>>(
                                                  valueListenable: character
                                                      .characterState
                                                      .conditions,
                                                  builder: (context, value,
                                                      child) {
                                                    return Row(
                                                      children:
                                                          createConditionList(
                                                              scale),
                                                    );
                                                  }),
                                            ]));
                                      })
                                ])
                          ],
                        ),
                        isCharacter
                            ? Positioned(
                                top: 10 * scale,
                                left: 318 * scale,
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<int>(
                                        valueListenable: character.characterState.xp,
                                        builder: (context, value, child) {
                                          return Text(
                                            character.characterState
                                                .xp.value
                                                .toString(),
                                            style: TextStyle(
                                                fontFamily: 'Pirata',
                                                color: Colors.blue,
                                                fontSize: 14 * scale,
                                                shadows: [
                                                  Shadow(
                                                      offset: Offset(
                                                          1 * scale,
                                                          1 * scale),
                                                      color: Colors.black)
                                                ]),
                                          );
                                        }),
                                    Image(
                                      height: 20.0 *
                                          scale *
                                          0.8,
                                      color: Colors.blue,
                                      colorBlendMode: BlendMode.modulate,
                                      image: const AssetImage(
                                          "assets/images/psd/xp.png"),
                                    ),
                                  ],
                                ))
                            : Container(),
                        isCharacter
                            ? Positioned(
                                right: 29 * scale,
                                top: 14 * scale,
                                child: summonsButton(scale),
                              )
                            : Container()
                      ],
                    )
                    ),

                      ]));
            }));
  }
}
