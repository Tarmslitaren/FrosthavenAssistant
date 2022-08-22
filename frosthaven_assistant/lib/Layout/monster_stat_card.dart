import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';
import '../Resource/stat_calculator.dart';
import '../Resource/ui_utils.dart';
import 'line_builder.dart';


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
    double height = 123 * 0.8 * scale;

    final leftStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.black,
        fontSize: 16 * 0.8 * scale,
        height: 1.2,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black12)
        ]);

    final rightStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.white,
        fontSize: 16 * 0.8 * scale,
        height: 1.2,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black)
        ]);

    final specialStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 14 * 0.8 * scale,
        height: 1,
        shadows: [
          Shadow(offset: Offset(1 * scale, 1 * scale), color: Colors.black)
        ]);

    final lineStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 14 * 0.8 * scale,
        height: 0.1,
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
              MonsterStatsModel normal;
              MonsterStatsModel? elite = widget.data.type.levels[_level].elite;
              if (isBoss) {
                normal = widget.data.type.levels[_level].boss!;
              } else {
                normal = widget.data.type.levels[_level].normal!;
              }
              //normal stats calculated:
              int? healthValue = StatCalculator.calculateFormula(normal.health);
              String health = normal.health.toString();
              if (healthValue != null) {
                health = healthValue.toString();
              }
              //special case:
              if (health == "Hollowpact") {
                health = "7";
                for (var item in getIt<GameState>().currentList) {
                  if (item is Character && item.id == "Hollowpact") {
                    health = item.characterClass
                        .healthByLevel[item.characterState.level.value - 1]
                        .toString();
                  }
                }
              }

              int? moveValue = StatCalculator.calculateFormula(normal.move);
              String move = normal.move.toString();
              if (moveValue != null) {
                move = moveValue.toString();
              }
              int? attackValue = StatCalculator.calculateFormula(normal.attack);
              String attack = normal.attack.toString();
              if (attackValue != null) {
                attack = attackValue.toString();
              }

              return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4 * scale,
                        offset: Offset(2 * scale, 4 * scale), // Shadow position
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(2 * scale * 0.8),
                  child: Stack(
                    //alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0 * scale),
                        child:
                        Image(
                          height: height,
                          fit: BoxFit.fitHeight,

                          //height: height,
                          image: AssetImage(

                              !isBoss
                              ? "assets/images/psd/monsterStats-normal.png"
                              : "assets/images/psd/monsterStats-boss.png"),
                        ),
                      ),
                      Positioned(
                          left: 4.0 * 0.8 * scale,
                          top: 0 * 0.8 * scale,
                          child: Text(
                            _level.toString(),
                            style: TextStyle(
                                fontFamily: 'Majalla',
                                color: Colors.white,
                                fontSize: 18 * 0.8 * scale,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1 * scale, 1 * scale),
                                      color: Colors.black)
                                ]),
                          )),
                      !isBoss
                          ? Positioned(
                              left: 80.0 * 0.8 * scale,
                              top: 26.0 * 0.8 * scale,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(health, style: leftStyle),
                                  Text(move, style: leftStyle),
                                  Text(attack, style: leftStyle),
                                  Text(
                                      normal.range != 0
                                          ? normal.range.toString()
                                          : "-",
                                      style: leftStyle),
                                ],
                              ),
                            )
                          : Positioned(
                              left: 0.0 * 0.8 * scale,
                              top: 38.0 * 0.8 * scale,
                              width: 30 * 0.8 * scale,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                // mainAxisAlignment: MainAxisAlignment.end,
                                // mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(health, style: leftStyle),
                                  Text(move, style: leftStyle),
                                  Text(attack, style: leftStyle),
                                  Text(
                                      normal.range != 0
                                          ? normal.range.toString()
                                          : "",
                                      style: leftStyle),
                                ],
                              ),
                            ),
                      !isBoss
                          ? Positioned(
                              left: 0.0,
                              top: 24.0 * 0.8 * scale,
                              width: 73 * 0.8 * scale,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    LineBuilder.createLines(
                                        normal.attributes,
                                        true,
                                        false,
                                        false,
                                        widget.data,
                                        CrossAxisAlignment.end,
                                        scale),
                                  ]))
                          : Positioned(
                              left: 56.0 * 0.8 * scale,
                              top: 20.0 * 0.8 * scale,
                              width: 160 * 0.8 * scale, //useful or not?
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //alignment: Alignment.topRight,
                                  //width: 67*tempScale*scale,
                                  children: [
                                    normal.attributes.isNotEmpty
                                        ? Row(children: [
                                            Text("    ", style: specialStyle),
                                            SizedBox(
                                                width: 140 * 0.8 * scale,
                                                child: LineBuilder.createLines(
                                                    normal.attributes,
                                                    false,
                                                    false,
                                                    false,
                                                    widget.data,
                                                    CrossAxisAlignment.start,
                                                    scale)),
                                          ])
                                        : Container(),
                                    normal.special1.isNotEmpty
                                        ? Row(
                                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Text("1:", style: specialStyle,),
                                                SizedBox(
                                                    width:
                                                        140 * 0.8 * scale,
                                                    child:
                                                        LineBuilder.createLines(
                                                            widget
                                                                .data
                                                                .type
                                                                .levels[_level]
                                                                .boss!
                                                                .special1,
                                                            false,
                                                            true,
                                                            false,
                                                            widget.data,
                                                            CrossAxisAlignment
                                                                .start,
                                                            scale)),
                                              ])
                                        : Container(),
                                    normal.special2.isNotEmpty
                                        ? Row(children: [
                                            Text(
                                                "_______________________________\n\n\n",
                                                style: lineStyle),
                                          ])
                                        : Container(),
                                    normal.special2.isNotEmpty
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Text("2:", style: specialStyle),
                                                SizedBox(
                                                    width:
                                                        140 * 0.8 * scale,
                                                    child:
                                                        LineBuilder.createLines(
                                                            widget
                                                                .data
                                                                .type
                                                                .levels[_level]
                                                                .boss!
                                                                .special2,
                                                            false,
                                                            true,
                                                            false,
                                                            widget.data,
                                                            CrossAxisAlignment
                                                                .start,
                                                            scale)),
                                              ])
                                        : Container()
                                  ])),
                      !isBoss
                          ? Positioned(
                              right: 77.0 * 0.8 * scale,
                              top: 26.0 * 0.8 * scale,
                              child: Column(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                      StatCalculator.calculateFormula(
                                              elite!.health)
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      StatCalculator.calculateFormula(
                                              elite.move)
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      StatCalculator.calculateFormula(
                                              elite.attack)
                                          .toString(),
                                      style: rightStyle),
                                  Text(
                                      elite.range != 0
                                          ? elite.range.toString()
                                          : "-",
                                      style: rightStyle),
                                ],
                              ),
                            )
                          : Container(),
                      !isBoss
                          ? Positioned(
                              width: 72 * 0.8 * scale,
                              right: 0.0,
                              top: 24.0 * 0.8 * scale,
                              child: LineBuilder.createLines(
                                  elite!.attributes,
                                  false,
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
                                  height: 20 * 0.8 * scale,
                                  left: 94.0 * 0.8 * scale,
                                  top: 45.0 * 0.8 * scale,
                                  child: const Image(
                                    fit: BoxFit.fitHeight,
                                    image: AssetImage(
                                        "assets/images/psd/flying-stat.png"),
                                  ))
                              : Container()
                          : widget.data.type.flying
                              ? Positioned(
                                  height: 20 * 0.8 * scale,
                                  left: 31.0 * 0.8 * scale,
                                  top: 56.0 * 0.8 * scale,
                                  child: const Image(
                                    fit: BoxFit.fitHeight,
                                    image: AssetImage(
                                        "assets/images/psd/flying-stat.png"),
                                  ),
                                )
                              : Container(),
                      isBoss
                          ? normal.range != 0
                              ? Positioned(
                                  height: 20 * 0.8 * scale,
                                  left: 30.0 * 0.8 * scale,
                                  top: 93.0 * 0.8 * scale,
                                  child: const Image(
                                    fit: BoxFit.fitHeight,
                                    image: AssetImage(
                                        "assets/images/psd/range-stat.png"),
                                  ))
                              : Container()
                          : Container(),
                      !isBoss
                          ? Positioned(
                              bottom: 5 * scale * 0.8,
                              left: 5 * scale * 0.8,
                              child: SizedBox(
                                  width: 25 * scale * 0.8 +8,
                                  height: 25 * scale * 0.8 +8,
                                  child: ValueListenableBuilder<
                                          List<MonsterInstance>>(
                                      valueListenable:
                                          widget.data.monsterInstances,
                                      builder: (context, value, child) {
                                        bool allStandeesOut = widget
                                                .data
                                                .monsterInstances
                                                .value
                                                .length ==
                                            widget.data.type.count;
                                        return IconButton(
                                          padding: const EdgeInsets.only(right: 8, top: 8),
                                          icon: Image.asset(
                                              //TODO: is not updated on remove
                                              color: allStandeesOut
                                                  ? Colors.white24
                                                  : Colors.grey,
                                              colorBlendMode:
                                                  BlendMode.modulate,
                                              'assets/images/psd/add.png'),
                                          onPressed: () {
                                            if (widget.data.monsterInstances
                                                    .value.length ==
                                                widget.data.type.count - 1) {
                                              //directly add last standee
                                              GameMethods.addStandee(
                                                  null,
                                                  widget.data,
                                                  isBoss
                                                      ? MonsterType.boss
                                                      : MonsterType.normal);
                                            } else if (widget
                                                    .data
                                                    .monsterInstances
                                                    .value
                                                    .length <
                                                widget.data.type.count - 1) {
                                              openDialogAtPosition(
                                                  context,
                                                  //problem: context is of stat card widget, not the + button
                                                  AddStandeeMenu(
                                                    elite: false,
                                                    monster: widget.data,
                                                  ),
                                                  -185,
                                                  //does not take into account the popup does not scale. (should it?)
                                                  -120);
                                            }
                                          },
                                        );
                                      })))
                          : Container(),
                      Positioned(
                          bottom: 5 * scale * 0.8,
                          right: 5 * scale * 0.8 ,
                          child: SizedBox(
                              width: 25 * scale * 0.8 + 8,
                              height: 25 * scale * 0.8 + 8,
                              child: IconButton(
                                  padding: const EdgeInsets.only(left: 8, top: 8),
                                  icon: Image.asset(
                                      color: widget.data.monsterInstances.value
                                                  .length ==
                                              widget.data.type.count
                                          ? Colors.white24
                                          : Colors.grey,
                                      colorBlendMode: BlendMode.modulate,
                                      'assets/images/psd/add.png'),
                                  onPressed: () {
                                    if (widget.data.monsterInstances.value
                                            .length ==
                                        widget.data.type.count - 1) {
                                      //directly add last standee
                                      GameMethods.addStandee(
                                          null,
                                          widget.data,
                                          isBoss
                                              ? MonsterType.boss
                                              : MonsterType.elite);
                                    } else if (widget.data.monsterInstances
                                            .value.length <
                                        widget.data.type.count - 1) {
                                      openDialogAtPosition(
                                          context,
                                          AddStandeeMenu(
                                            elite: isBoss ? false : true,
                                            monster: widget.data,
                                          ),
                                          -100,
                                          -12);
                                    }
                                  }))),
                      isBoss
                          ? Positioned(
                              right: 10 * scale,
                              top: 1 * scale,
                              child: Row(
                                children: createConditionList(scale, normal),
                              ))
                          : Positioned( //TODO: move position to FH place in corner
                              left: 45 * scale,
                              bottom: 10 * scale,
                              child: Column(
                                verticalDirection: VerticalDirection.up,
                                children: createConditionList(scale, normal),
                              )),
                      isBoss
                          ? Container()
                          : Positioned(
                              right: 45 * scale,
                              bottom: 10 * scale,
                              child: Column(
                                verticalDirection: VerticalDirection.up,
                                children: createConditionList(scale, elite!),
                              ))
                    ],
                  ));
            }));
  }

  List<Widget> createConditionList(double scale, MonsterStatsModel stats) {
    List<Widget> list = [];
    for (var item in stats.immunities) {
      item = item.substring(1, item.length - 1);
      Image image = Image(
        height: 11 * scale,
        image: AssetImage("assets/images/conditions/$item.png"),
      );
      Image immuneIcon = Image(
        height: 4 * scale,
        image: const AssetImage("assets/images/psd/immune.png"),
      );
      Stack stack = Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              left: 0,
              top: 0,
              child: image),
          Positioned(
            left: 9 * scale,
              top: 3.5*scale,
              child: immuneIcon),

        ],
      );
      list.add(SizedBox(
        width: 14*scale,
        height: 11*scale,
        child: stack,
      ));
    }
    return list;
  }
}
