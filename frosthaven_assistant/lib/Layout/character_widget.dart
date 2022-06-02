
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/character_class.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class CharacterWidget extends StatefulWidget {
  final CharacterClass characterClass;

  const CharacterWidget({
    Key? key,
    required this.characterClass,
  }) : super(key: key);

  @override
  _CharacterWidgetState createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget> {
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
    _initTextFieldController.clear();
    _initTextFieldController.addListener(() {
      for (var item in _gameState.currentList) {
        if (item is Character) {
          if (item.characterClass.name == widget.characterClass.name) {
            if(_initTextFieldController
                .value.text.isNotEmpty) {
              item.characterState.initiative =
                  int.parse(_initTextFieldController
                      .value.text); //TODO: sanity check inputs
            }
          }
        }
      }
    });
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
          setState(() {});
        },
        child: Stack(
          //alignment: Alignment.centerLeft,
          children: [
            Container(
              margin: EdgeInsets.all(2 * scale),
              width: 408 * scale,
              height: 58 * scale,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                        widget.characterClass.color, BlendMode.color),
                    image: const AssetImage(
                        "assets/images/psd/character-bar.png")),
                shape: BoxShape.rectangle,
                color: widget.characterClass.color,
              ),
            ),
            Align(
                // alignment: Alignment.centerLeft,
                child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20 * scale, top: 5*scale, bottom: 5*scale),
                  child: Image(
                    fit: BoxFit.contain,
                    height: scaledHeight,
                    image: AssetImage(
                      "assets/images/class-icons/${widget.characterClass.name}.png",
                    ),
                    width: scaledHeight*0.8,
                  ),
                ),
                Align(
                  child: Column(children: [
                    Container(
                      margin:
                          EdgeInsets.only(top: scaledHeight / 6, left: 10 * scale),
                      child: Image(
                        //fit: BoxFit.contain,
                        height: scaledHeight * 0.1,
                        image: const AssetImage("assets/images/init.png"),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                        valueListenable: _gameState.commandIndex,
                        builder: (context, value, child) {
                          //_initTextFieldController.clear();
                          //if (_characterState.initiative == 0) {
                          if (_gameState.roundState.value == RoundState.chooseInitiative) {
                            return Container(
                              margin: EdgeInsets.only(left: 10 * scale),
                              height: 33 * scale,
                              width: 25 * scale,
                              child: TextField(
                                //TODO: clear on enter focus
                                //TODO: close soft keyboard on 2 chars entered
                                //expands: true,
                                  textAlign: TextAlign.center,
                                  cursorColor: Colors.white,
                                  maxLength: 2,

                                  style: TextStyle(
                                    height: 0.9, //quick fix for web-phone disparity.
                                      fontFamily: 'Pirata',
                                      color: Colors.white,
                                      fontSize: 24 * scale,
                                      shadows: [
                                        Shadow(
                                            offset:
                                                Offset(1 * scale, 1 * scale),
                                            color: Colors.black)
                                      ]),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
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
                            _initTextFieldController.clear();
                            return Container(
                                height: 33 * scale,
                                width: 25 * scale,
                                margin: EdgeInsets.only(left: 10 * scale),
                                child: Text(
                                  _characterState.initiative.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Pirata',
                                      color: Colors.white,
                                      fontSize: 24 * scale,
                                      shadows: [
                                        Shadow(
                                            offset:
                                                Offset(1 * scale, 1 * scale),
                                            color: Colors.black)
                                      ]),
                                ));
                          }
                        }),
                  ]),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //align children to the left
                    children: [
                  Container(
                    margin: EdgeInsets.only(top: 10 * scale, left: 10 * scale),
                    child: Text(
                      widget.characterClass.name,
                      style: TextStyle(
                          fontFamily: 'Pirata',
                          color: Colors.white,
                          fontSize: 16 * scale,
                          shadows: [
                            Shadow(
                                offset: Offset(1 * scale, 1 * scale),
                                color: Colors.black)
                          ]),
                    ),
                  ),
                  Container(
                      margin:
                          EdgeInsets.only( left: 10 * scale),
                      child: Text(
                        'health: ${_characterState.health.value.toString()} / ${widget.characterClass.healthByLevel[_characterState.level.value - 1].toString()}',
                        style: TextStyle(
                            fontFamily: 'Pirata',
                            color: Colors.white,
                            fontSize: 16 * scale,
                            shadows: [
                              Shadow(
                                  offset: Offset(1 * scale, 1 * scale),
                                  color: Colors.black)
                            ]),
                      ))
                ])
              ],
            ))
          ],
        ));
  }
}
