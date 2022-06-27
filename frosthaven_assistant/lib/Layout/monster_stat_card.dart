import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/stat_calculator.dart';
import '../Resource/ui_utils.dart';
import 'line_builder.dart';

double tempScale = 0.8; //TODO: f this

class MonsterStatCardWidget extends StatefulWidget {
  final Monster data;

  const MonsterStatCardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  MonsterStatCardWidgetState createState() => MonsterStatCardWidgetState();
}

class MonsterStatCardWidgetState extends State<MonsterStatCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _level = widget.data.level.value; //is this the right start?
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
          //if grayscale mode: fade in the stats (if hide stats enabled)
        },
        child: ValueListenableBuilder<int>(
            valueListenable: widget.data.level,
            builder: (context, value, child) {
              _level = widget.data.level.value;
              bool isBoss = widget.data.type.levels[_level].boss != null;
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
                      !isBoss
                          ? Positioned(
                              left: 82.0 * tempScale * scale,
                              top: 26.0 * tempScale * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                              .data
                                              .type
                                              .levels[_level]
                                              .normal!
                                              .health)
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .elite!
                                          .move)
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .elite!
                                          .attack)
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
                              left: 0.0 * tempScale * scale,
                              top: 38.0 * tempScale * scale,
                              width: 30 * tempScale * scale,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                               // mainAxisAlignment: MainAxisAlignment.end,
                               // mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                              .data
                                              .type
                                              .levels[_level]
                                              .boss!
                                              .health)
                                          .toString(),
                                      textAlign: TextAlign.end,
                                      style: leftStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .boss!
                                          .move)
                                          .toString(),
                                      style: leftStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .boss!
                                          .attack)
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
                      !isBoss
                          ? Positioned(
                              left: 0.0,
                              top: 24.0 * tempScale * scale,
                              width: 73 * tempScale * scale,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    LineBuilder.createLines(
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
                              width: 160 * tempScale * scale, //useful or not?
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    LineBuilder.createLines(
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
                                          Container(
                                              width: 140 * tempScale * scale,
                                              child: LineBuilder.createLines(
                                                  widget
                                                      .data
                                                      .type
                                                      .levels[_level]
                                                      .boss!
                                                      .special1,
                                                  false,
                                                  true,
                                                  widget.data,
                                                  CrossAxisAlignment.start,
                                                  scale)),
                                        ]),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("2:", style: specialStyle),
                                          Container(
                                              width: 140 * tempScale * scale,
                                              child: LineBuilder.createLines(
                                                  widget
                                                      .data
                                                      .type
                                                      .levels[_level]
                                                      .boss!
                                                      .special2,
                                                  false,
                                                  true,
                                                  widget.data,
                                                  CrossAxisAlignment.start,
                                                  scale)),
                                        ])
                                  ])),
                      !isBoss
                          ? Positioned(
                              right: 80.0 * tempScale * scale,
                              top: 26.0 * tempScale * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                              .data
                                              .type
                                              .levels[_level]
                                              .elite!
                                              .health)
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .elite!
                                          .move)
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      StatCalculator.calculateFormula(widget
                                          .data
                                          .type
                                          .levels[_level]
                                          .elite!
                                          .attack)
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
                      !isBoss
                          ? Positioned(
                              width: 70 * tempScale * scale,
                              right: 0.0,
                              top: 24.0 * tempScale * scale,
                              child: LineBuilder.createLines(
                                  widget.data.type.levels[_level].elite!
                                      .attributes,
                                  false,
                                  false,
                                  widget.data,
                                  CrossAxisAlignment.start,
                                  scale),
                            )
                          : Container(),
                      !isBoss
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
                                  if (widget
                                          .data.monsterInstances.value.length ==
                                      widget.data.type.count - 1) {
                                    //directly add last standee
                                    GameMethods.addStandee(
                                        null,
                                        widget.data,
                                        isBoss
                                            ? MonsterType.boss
                                            : MonsterType.normal);
                                  } else if (widget
                                          .data.monsterInstances.value.length <
                                      widget.data.type.count - 1) {
                                    openDialogAtPosition(
                                        context,
                                        //problem: context is of stat card widget, not the + button
                                        AddStandeeMenu(
                                          elite: false,
                                          monster: widget.data,
                                        ),
                                        -185 * scale,
                                        //does not take into account the popup does not scale. (should it?)
                                        12 * scale);
                                  }
                                },
                              ))),
                      !isBoss
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
                                        if (widget.data.monsterInstances.value
                                                .length ==
                                            widget.data.type.count - 1) {
                                          //directly add last standee
                                          GameMethods.addStandee(null,
                                              widget.data, MonsterType.elite);
                                        } else if (widget.data.monsterInstances
                                                .value.length <
                                            widget.data.type.count - 1) {
                                          openDialogAtPosition(
                                              context,
                                              AddStandeeMenu(
                                                elite: true,
                                                monster: widget.data,
                                              ),
                                              -45 * scale,
                                              12 * scale);
                                        }
                                      })))
                          : Container(),
                      Positioned(
                          right: 10 * scale,
                          top: 1 * scale,
                          child: Row(
                            children: createConditionList(scale),
                          ))
                    ],
                  ));
            }));
  }

  List<Image> createConditionList(double scale) {
    List<Image> list = [];
    if (widget.data.type.levels[_level].boss == null) {
      return list;
    }
    for (var item in widget.data.type.levels[_level].boss!.immunities) {
      item = item.substring(1, item.length - 1);
      Image image = Image(
        height: 11 * scale,
        image: AssetImage("assets/images/conditions/$item.png"),
      );
      list.add(image);
    }
    return list;
  }
}
