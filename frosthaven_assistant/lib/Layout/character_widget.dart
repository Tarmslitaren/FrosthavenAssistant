import 'dart:html';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/character_class.dart';
import '../Resource/action_handler.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class CharacterWidget extends StatefulWidget {

  //final double borderWidth = 2;
  final CharacterClass characterClass;

  const CharacterWidget({
    Key? key,
    required this.characterClass,
  }) : super(key: key);

  @override
  _CharacterWidgetState createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  //int _init = 99;
  //bool _selectInitMode = false;
  final GameState _gameState = getIt<GameState>();
  late CharacterState _characterState;
  final _initTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var character in _gameState.currentList) {
      if (character is Character &&
          character.characterClass.name == widget.characterClass.name) {
        _characterState = character.characterState;
      }
    }
    _initTextFieldController.addListener(() {
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.characterClass.name == widget.characterClass.name) {
            item.characterState.initiative = int.parse(_initTextFieldController
                .value.text); //TODO: sanity check inputs
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = 60 * scale;

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
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              margin: EdgeInsets.all(2*scale),
              width: 495 * scale,
              height: 58 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: widget.characterClass.color,
              ),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image(
                      //fit: BoxFit.contain,
                      height: height,
                      image: AssetImage(
                        "assets/images/class-icons/${widget.characterClass.name}.png",
                      ),
                      //width: widget.height*0.8,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(children: [
                        Container(
                          margin: EdgeInsets.only(top: 10 * scale),
                          child: Image(
                            //fit: BoxFit.contain,
                            height: height * 0.1,
                            image: const AssetImage("assets/images/init.png"),
                          ),
                        ),
                        ValueListenableBuilder<int>(
                            valueListenable: _gameState.commandIndex,
                            builder: (context, value, child) {
                              if (_characterState.initiative == 0) {
                                return SizedBox(
                                  height: 33*scale,
                                  width: 24*scale,
                                  child: TextField(
                                      textAlign: TextAlign.center,
                                      cursorColor: Colors.white,
                                      maxLength: 2,
                                      style: TextStyle(
                                          fontFamily: 'Pirata',
                                          color: Colors.white,
                                          fontSize: 24*scale, //TODO: does scaleing work right with the fontsizes?
                                          shadows: [
                                            Shadow(
                                                offset: Offset(1*scale, 1*scale),
                                                color: Colors.black)
                                          ]),
                                      decoration: const InputDecoration(
                                          counterText: '',
                                        enabledBorder:
                                            UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder:
                                            UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        // border: UnderlineInputBorder(
                                        //   borderSide:
                                        //      BorderSide(color: Colors.pink),
                                        // ),
                                      ),
                                      controller: _initTextFieldController,
                                      keyboardType: TextInputType.number),
                                );
                              } else {
                                return SizedBox(
                                    height: 33*scale,
                                    width: 24*scale,
                                    child: Text(
                                      _characterState.initiative.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Pirata',
                                          color: Colors.white,
                                          fontSize: 24*scale,
                                          shadows: [
                                            Shadow(
                                                offset: Offset(1*scale, 1*scale),
                                                color: Colors.black)
                                          ]),
                                    ));
                              }
                            }),
                      ]),
                    ),
                    Column(
                        //mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10*scale),
                            child: Text(
                              widget.characterClass.name,
                              style: TextStyle(
                                  fontFamily: 'Pirata',
                                  color: Colors.white,
                                  fontSize: 16*scale,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1*scale, 1*scale),
                                        color: Colors.black)
                                  ]),
                            ),
                          ),
                          Text(
                            'health: ${_characterState.health.value.toString()} / ${widget.characterClass.healthByLevel[_characterState.level.value - 1].toString()}',
                            style: TextStyle(
                                fontFamily: 'Pirata',
                                color: Colors.white,
                                fontSize: 16*scale,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1*scale, 1*scale), color: Colors.black)
                                ]),
                          )
                        ])
                  ],
                ))
          ],
        ));
  }
}
