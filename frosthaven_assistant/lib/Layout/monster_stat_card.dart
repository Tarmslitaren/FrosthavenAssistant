import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/monster.dart';
import '../services/service_locator.dart';
import 'line_builder.dart';
import 'menus/main_menu.dart';
import 'monster_ability_card.dart';

double tempScale = 0.8;

class MonsterStatCardWidget extends StatefulWidget {
  final Monster data;

  const MonsterStatCardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _MonsterStatCardWidgetState createState() => _MonsterStatCardWidgetState();
}

class _MonsterStatCardWidgetState extends State<MonsterStatCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  int _level = 1;
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
    //TODO: handle special rules level changes for specific monster types.
    _level = widget.data.level; //is this the right start?
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = 123 * tempScale * scale;

    final leftStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.black,
        fontSize: 16 * tempScale * scale,
        height: 1.2,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black12)
        ]);

    final rightStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.white,
        fontSize: 16 * tempScale * scale,
        height: 1.2,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black)
        ]);

    final specialStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 14 * tempScale * scale,
        //height: 1.2,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black)
        ]);

    return GestureDetector(
        onTap: () {
          //if grayscale mode: fade in the stats
          setState(() {});
        },
        child: ValueListenableBuilder<int>(
            valueListenable: _gameState.level,
            builder: (context, value, child) {
              _level = _gameState.level.value; // widget.data.level;
              return Container(
                  margin: EdgeInsets.all(2 * scale * tempScale),
                  child: Stack(
                    //alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0 * scale),
                        child: Image(
                          height: height,
                          image: AssetImage(
                              widget.data.type.levels[_level].boss == null
                                  ? "assets/images/psd/monsterStats-normal.png"
                                  : "assets/images/psd/monsterStats-boss.png"),
                        ),
                      ),
                      Positioned(
                          left: 4.0 * tempScale * scale,
                          top: 0 * tempScale * scale,
                          child: Container(
                            child: Text(
                              _level.toString(),
                              style: TextStyle(
                                  fontFamily: 'Majalla',
                                  color: Colors.white,
                                  fontSize: 18 * tempScale * scale,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1 * scale, 1 * scale),
                                        color: Colors.black)
                                  ]),
                            ),
                          )),
                      widget.data.type.levels[_level].boss == null
                          ? Positioned(
                              left: 82.0 * tempScale * scale,
                              top: 26.0 * tempScale * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      widget.data.type.levels[_level].normal!
                                          .health
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget
                                          .data.type.levels[_level].normal!.move
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget.data.type.levels[_level].normal!
                                          .attack
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget.data.type.levels[_level].normal
                                                  ?.range !=
                                              0
                                          ? widget.data.type.levels[_level]
                                              .normal!.range
                                              .toString()
                                          : "-",
                                      style: leftStyle),
                                ],
                              ),
                            )
                          : Positioned(
                              left: 3.0 * tempScale * scale,
                              top: 38.0 * tempScale * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      widget
                                          .data.type.levels[_level].boss!.health
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget.data.type.levels[_level].boss!.move
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget
                                          .data.type.levels[_level].boss!.attack
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      widget.data.type.levels[_level].boss
                                                  ?.range !=
                                              0
                                          ? widget.data.type.levels[_level]
                                              .boss!.range
                                              .toString()
                                          : "",
                                      style: leftStyle),
                                ],
                              ),
                            ),
                      widget.data.type.levels[_level].boss == null
                          ? Positioned(
                              left: 6.0 * tempScale * scale,
                              top: 24.0 * tempScale * scale,
                              width: 65 * tempScale * scale,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    createLines(
                                        widget.data.type.levels[_level].normal!
                                            .attributes,
                                        true,
                                        false,
                                        widget.data,
                                        CrossAxisAlignment.end,
                                        scale),
                                  ]))
                          : Positioned(
                              left: 56.0 * tempScale * scale,
                              top: 24.0 * tempScale * scale,
                              width: 165 * tempScale * scale, //useful or not?
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    createLines(
                                        widget.data.type.levels[_level].boss!
                                            .attributes,
                                        true,
                                        false,
                                        widget.data,
                                        CrossAxisAlignment.end,
                                        scale),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("1:", style: specialStyle),
                                          createLines(
                                              widget.data.type.levels[_level]
                                                  .boss!.special1,
                                              false,
                                              false,
                                              widget.data,
                                              CrossAxisAlignment.start,
                                              scale),
                                        ]),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("2:", style: specialStyle),
                                          createLines(
                                              widget.data.type.levels[_level]
                                                  .boss!.special2,
                                              false,
                                              false,
                                              widget.data,
                                              CrossAxisAlignment.start,
                                              scale),
                                        ])
                                  ])),
                      widget.data.type.levels[_level].boss == null
                          ? Positioned(
                              right: 80.0 * tempScale * scale,
                              top: 26.0 * tempScale * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      widget.data.type.levels[_level].elite!
                                          .health
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      widget
                                          .data.type.levels[_level].elite!.move
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      widget.data.type.levels[_level].elite!
                                          .attack
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      widget.data.type.levels[_level].elite
                                                  ?.range !=
                                              0
                                          ? widget.data.type.levels[_level]
                                              .elite!.range
                                              .toString()
                                          : "-",
                                      style: rightStyle),
                                ],
                              ),
                            )
                          : Container(),
                      widget.data.type.levels[_level].boss == null
                          ? Positioned(
                              width: 65 * tempScale * scale,
                              right: 0.0,
                              top: 24.0 * tempScale * scale,
                              child: createLines(
                                  widget.data.type.levels[_level].elite!
                                      .attributes,
                                  false,
                                  false,
                                  widget.data,
                                  CrossAxisAlignment.start,
                                  scale),
                            )
                          : Container(),
                      widget.data.type.levels[_level].boss == null
                          ? widget.data.type.flying
                              ? Positioned(
                                  height: 20 * tempScale * scale,
                                  left: 94.0 * tempScale * scale,
                                  top: 45.0 * tempScale * scale,
                                  child: const Image(
                                    image: AssetImage(
                                        "assets/images/psd/flying-stat.png"),
                                  ))
                              : Container()
                          : widget.data.type.flying
                              ? Positioned(
                                  height: 20 * tempScale * scale,
                                  left: 31.0 * tempScale * scale,
                                  top: 56.0 * tempScale * scale,
                                  child: const Image(
                                    image: AssetImage(
                                        "assets/images/psd/flying-stat.png"),
                                  ),
                                )
                              : Container(),
                      Positioned(
                          bottom: 1 * scale * tempScale,
                          left: 1 * scale * tempScale,
                          child: Container(
                              width: 25 * scale,
                              height: 25 * scale,
                              child: IconButton(
                                icon: Image.asset('assets/images/psd/add.png'),
                                onPressed: () {
                                  openDialog(
                                      context,
                                      Stack(children: [
                                        Positioned(
                                          //TODO: how to get a good grip on position
                                          //left: 100, // left coordinate
                                          //top: 100,  // top coordinate
                                          child: Dialog(
                                            child: AddStandeeMenu(
                                              elite: false,
                                              monster: widget.data,
                                            ),
                                          ),
                                        )
                                      ]));
                                },
                              ))),
                      widget.data.type.levels[_level].boss == null
                          ? Positioned(
                              bottom: 1 * scale * tempScale,
                              right: 1 * scale * tempScale,
                              child: Container(
                                  width: 25 * scale,
                                  height: 25 * scale,
                                  child: IconButton(
                                    icon: Image.asset(
                                        'assets/images/psd/add.png'),
                                    onPressed: () {
                                      openDialog(
                                          context,
                                          Stack(children: [
                                            Positioned(
                                              //TODO: how to get a good grip on position
                                              //left: 100, // left coordinate
                                              //top: 100,  // top coordinate
                                              child: Dialog(
                                                child: AddStandeeMenu(
                                                  elite: true,
                                                  monster: widget.data,
                                                ),
                                              ),
                                            )
                                          ]));
                                    },
                                  )))
                          : Container(),
                    ],
                  ));
            }));
  }
}
