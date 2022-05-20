import 'dart:html';

import 'package:flutter/material.dart';

import '../Model/character_class.dart';
import '../Resource/action_handler.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class CharacterWidget extends StatefulWidget {
  //final String icon;
  final double height;

  //final Color color;
  final double borderWidth = 2;

  //final String name;
  final CharacterClass characterClass;

  const CharacterWidget({
    Key? key,
    //required this.icon,
    this.height = 60,
    required this.characterClass,
    //required this.name,
    //required this.color
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
              margin: const EdgeInsets.all(2),
              width: 495,
              height: widget.height - widget.borderWidth,
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
                      height: widget.height,
                      image: AssetImage(
                        "assets/images/class-icons/${widget.characterClass.name}.png",
                      ),
                      //width: widget.height*0.8,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Image(
                            //fit: BoxFit.contain,
                            height: widget.height * 0.1,
                            image: const AssetImage("assets/images/init.png"),
                          ),
                        ),
                        ValueListenableBuilder<int>(
                            valueListenable: _gameState.commandIndex,
                            builder: (context, value, child) {
                              if (_characterState.initiative == 0) {
                                return SizedBox(
                                  height: 33,
                                  width: 24,
                                  child: TextField(
                                      textAlign: TextAlign.center,
                                      cursorColor: Colors.white,
                                      maxLength: 2,
                                      style: const TextStyle(
                                          fontFamily: 'Pirata',
                                          color: Colors.white,
                                          fontSize: 24,
                                          shadows: [
                                            Shadow(
                                                offset: Offset(1, 1),
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
                                    height: 33,
                                    width: 24,
                                    child: Text(
                                      _characterState.initiative.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontFamily: 'Pirata',
                                          color: Colors.white,
                                          fontSize: 24,
                                          shadows: [
                                            Shadow(
                                                offset: Offset(1, 1),
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
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              widget.characterClass.name,
                              style: const TextStyle(
                                  fontFamily: 'Pirata',
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1),
                                        color: Colors.black)
                                  ]),
                            ),
                          ),
                          Text(
                            'health: ${_characterState.health.value.toString()} / ${widget.characterClass.healthByLevel[_characterState.level.value - 1].toString()}',
                            style: const TextStyle(
                                fontFamily: 'Pirata',
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1, 1), color: Colors.black)
                                ]),
                          )
                        ])
                  ],
                ))
          ],
        ));
  }
}
