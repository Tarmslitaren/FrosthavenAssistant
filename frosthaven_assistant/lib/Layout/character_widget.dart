import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/line_builder.dart';
import 'package:frosthaven_assistant/Layout/menus/main_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/character_class.dart';
import '../Resource/color_matrices.dart';
import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class CharacterWidget extends StatefulWidget {
  final Character character;
  final int? initPreset;

  const CharacterWidget(
  {required this.character, required this.initPreset, Key? key  }): super(key: key);

  @override
  _CharacterWidgetState createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget> {
  final GameState _gameState = getIt<GameState>();
  late bool isCharacter = true;
  final _initTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initPreset != null) {
      _initTextFieldController.text = widget.initPreset.toString();
    }
    _initTextFieldController.addListener(() {
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.characterState.display== widget.character.characterState.display) {
            if (_initTextFieldController.value.text.isNotEmpty) {
              item.characterState.initiative = int.parse(
                  _initTextFieldController
                      .value.text); //TODO: sanity check inputs
            }
          }
        }
      }
    });

    if(widget.character.characterClass.name == "Objective" || widget.character.characterClass.name == "Escort") {
      isCharacter = false;
      //widget.character.characterState.initiative = widget.initPreset!;
    }
    if (isCharacter) {
      _initTextFieldController.clear();
    }
  }

  List<Image> createConditionList(double scale) {
    List<Image> list = [];
    for (var item in widget.character.characterState.conditions.value) {
      Image image = Image(
        height: 16 * scale,
        image: AssetImage("assets/images/conditions/${item.name}.png"),
      );
      list.add(image);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double scaledHeight = 60 * scale;


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
              Stack(children: [
                Positioned(
                  //left: 100, // left coordinate
                  //top: 100,  // top coordinate
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: StatusMenu(
                        figure: widget.character.characterState,
                        character: widget.character),
                  ),
                )
              ]));
          setState(() {});
        },
        child: ValueListenableBuilder<int>(
            valueListenable: getIt<GameState>().commandIndex,
            //TODO: more granularity for performance?
            builder: (context, value, child) {
              return ColorFiltered(
                  colorFilter: widget.character.characterState.health.value != 0
                      ? ColorFilter.matrix(identity)
                      : ColorFilter.matrix(grayScale),
                  child: Container(
                      width: getMainListWidth(context),
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
                                      widget.character.characterClass.color,
                                      BlendMode.color),
                                  image: const AssetImage(
                                      "assets/images/psd/character-bar.png")),
                              shape: BoxShape.rectangle,
                              color: widget.character.characterClass.color,
                            ),
                          ),
                          Align(
                              //alignment: Alignment.centerLeft,
                              child: Row(
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
                                    "assets/images/class-icons/${widget.character.characterClass.name}.png",
                                  ),
                                  width: scaledHeight * 0.8,
                                ),
                              ),
                              Align(
                                child: Column(children: [
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
                                        if (isCharacter && _gameState
                                            .commandIndex.value >= 0 &&_gameState.commands[_gameState
                                            .commandIndex
                                            .value] is DrawCommand) {
                                          _initTextFieldController.clear();
                                        }
                                        if (_gameState.roundState.value ==
                                                RoundState.chooseInitiative &&
                                            widget.character.characterState.health
                                                    .value >
                                                0) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                                left: 10 * scale),
                                            height: 33 * scale,
                                            width: 25 * scale,
                                            child: TextField(

                                                //scrollPadding: EdgeInsets.zero,
                                                onTap: () => {
                                                      //clear on enter focus
                                                      _initTextFieldController.clear()
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
                                                keyboardType:
                                                    TextInputType.number),
                                          );
                                        } else {
                                          if(isCharacter) {
                                            _initTextFieldController.clear();
                                          }
                                          return Container(
                                              height: 33 * scale,
                                              width: 25 * scale,
                                              margin: EdgeInsets.only(
                                                  left: 10 * scale),
                                              child: Text(
                                                widget.character.characterState.health.value > 0 &&
                                                    widget.character.characterState.initiative > 0
                                                    ? widget.character.characterState
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
                              ),
                              Column(
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //align children to the left
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 10 * scale, left: 10 * scale),
                                      child: Text(
                                        widget.character.characterState.display,
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
                                        valueListenable:
                                        widget.character.characterState.health,
                                        //not working?
                                        builder: (context, value, child) {
                                          return Container(
                                              margin: EdgeInsets.only(
                                                  left: 10 * scale),
                                              child: Row(children: [
                                                Image(
                                                  //fit: BoxFit.contain,
                                                  height: scaledHeight * 0.3,
                                                  image: const AssetImage(
                                                      "assets/images/blood.png"),
                                                ),
                                                Text(
                                                  '${widget.character.characterState.health.value.toString()} / ${widget.character.characterState.maxHealth.value.toString()}',
                                                  style: TextStyle(
                                                      fontFamily: 'Pirata',
                                                      color: Colors.white,
                                                      fontSize: 16 * scale,
                                                      shadows: [
                                                        Shadow(
                                                            offset: Offset(
                                                                1 * scale,
                                                                1 * scale),
                                                            color: Colors.black)
                                                      ]),
                                                ),
                                                //add conditions here
                                                ValueListenableBuilder<
                                                        List<Condition>>(
                                                    valueListenable: widget.character
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
                          )),
                          isCharacter? Positioned(
                              top: 10 * scale,
                              left: 318 * scale,
                              child: Row(
                                children: [
                                  ValueListenableBuilder<int>(
                                      valueListenable:
                                      widget.character.characterState.xp,
                                      builder: (context, value, child) {
                                        return Text(
                                          widget.character.characterState.xp.value
                                              .toString(),
                                          style: TextStyle(
                                              fontFamily: 'Pirata',
                                              color: Colors.blue,
                                              fontSize: 14 * scale,
                                              shadows: [
                                                Shadow(
                                                    offset: Offset(
                                                        1 * scale, 1 * scale),
                                                    color: Colors.black)
                                              ]),
                                        );
                                      }),
                                  Image(
                                    height:
                                        20.0 * scale * LineBuilder.tempScale,
                                    color: Colors.blue,
                                    image: const AssetImage(
                                        "assets/images/psd/xp.png"),
                                  ),
                                ],
                              )): Container()
                        ],
                      )));
            }));
  }
}
