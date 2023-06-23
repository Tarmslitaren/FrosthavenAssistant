import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_standee_menu.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/commands/activate_monster_type_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/commands/add_standee_command.dart';
import '../Resource/enums.dart';
import '../Resource/stat_calculator.dart';
import '../Resource/state/character.dart';
import '../Resource/state/monster.dart';
import '../Resource/state/monster_instance.dart';
import '../Resource/ui_utils.dart';
import '../Resource/line_builder/line_builder.dart';
import 'menus/stat_card_zoom.dart';

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
  @override
  void initState() {
    super.initState();
  }

  static void _handleAddPressed(
      Monster data, BuildContext context, bool left, bool isBoss) {
    Settings settings = getIt<Settings>();
    if (settings.noStandees.value == true) {
      getIt<GameState>()
          .action(ActivateMonsterTypeCommand(data.id, !data.isActive));
      return;
    }

    if (data.monsterInstances.value.length == data.type.count - 1) {
      //directly add last standee
      GameMethods.addStandee(
          null,
          data,
          isBoss
              ? MonsterType.boss
              : left
                  ? MonsterType.normal
                  : MonsterType.elite,
          false);
    } else if (data.monsterInstances.value.length < data.type.count - 1) {
      if (settings.randomStandees.value == true) {
        int standeeNr = GameMethods.getRandomStandee(data);
        if (standeeNr != 0) {
          getIt<GameState>().action(AddStandeeCommand(
              standeeNr,
              null,
              data.id,
              isBoss
                  ? MonsterType.boss
                  : left
                      ? MonsterType.normal
                      : MonsterType.elite,
              false));
        }
      } else {
        openDialog(
          context,
          AddStandeeMenu(
            elite: !left,
            monster: data,
          ),
        );
      }
    }
  }

  static Widget buildNormalLayout(Monster data, double scale, var shadow,
      var leftStyle, var rightStyle, bool frosthavenStyle) {
    MonsterStatsModel normal = data.type.levels[data.level.value].normal!;
    MonsterStatsModel? elite = data.type.levels[data.level.value].elite;
    double height = 123 * 0.8 * scale;

    bool noCalculationSetting = getIt<Settings>().noCalculation.value;

    //normal stats calculated:
    String health = normal.health.toString();
    if (noCalculationSetting == false) {
      int? healthValue = StatCalculator.calculateFormula(normal.health);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }

    String move = normal.move.toString();
    if (noCalculationSetting == false) {
      int? moveValue = StatCalculator.calculateFormula(normal.move);
      if (moveValue != null) {
        move = moveValue.toString();
      }
    }

    String attack = normal.attack.toString();
    if (noCalculationSetting == false) {
      int? attackValue = StatCalculator.calculateFormula(normal.attack);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

    return Stack(
      //alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0 * scale),
          child: Image(
            height: 93.5 * scale,
            width: 167 * scale,
            fit: BoxFit.fitHeight,
            image:
                const AssetImage("assets/images/psd/monsterStats-normal.png"),
          ),
        ),
        Positioned(
            width: 167 * scale,
            left: 2 * scale,
            top: 3.5 * scale,
            child: Text(
              textAlign: TextAlign.center,
              data.type.display,
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'GermaniaOne' : 'Pirata',
                  color: Colors.white,
                  fontSize: 11 * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
            left: 3.2 * scale,
            top: 3.2 * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: 18 * 0.8 * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: 80.0 * 0.8 * scale,
          top: 26.0 * 0.8 * scale,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move, style: leftStyle),
              Text(attack, style: leftStyle),
              Text(normal.range != 0 ? normal.range.toString() : "-",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
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
                      data,
                      CrossAxisAlignment.end,
                      scale,
                      getIt<Settings>().shimmer.value),
                ])),
        Positioned(
          right: 77.0 * 0.8 * scale,
          top: 26.0 * 0.8 * scale,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(StatCalculator.calculateFormula(elite!.health).toString(),
                  style: rightStyle),
              Text(StatCalculator.calculateFormula(elite.move).toString(),
                  style: rightStyle),
              Text(StatCalculator.calculateFormula(elite.attack).toString(),
                  style: rightStyle),
              Text(elite.range != 0 ? elite.range.toString() : "-",
                  style: rightStyle),
            ],
          ),
        ),
        Positioned(
          width: 72 * 0.8 * scale,
          right: 0.0,
          top: 24.0 * 0.8 * scale,
          child: LineBuilder.createLines(
              elite.attributes,
              false,
              false,
              false,
              data,
              CrossAxisAlignment.start,
              scale,
              getIt<Settings>().shimmer.value),
        ),
        data.type.flying
            ? Positioned(
                height: 16 * scale,
                left: 74.8 * scale,
                top: 35.6 * scale,
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(frosthavenStyle
                      ? "assets/images/psd/flying-stat_fh.png"
                      : "assets/images/psd/flying-stat.png"),
                ))
            : frosthavenStyle
                ? Positioned(
                    height: 16 * scale,
                    left: 74.8 * scale,
                    top: 35.6 * scale,
                    child: const Image(
                      fit: BoxFit.fitHeight,
                      image: AssetImage("assets/images/psd/move-stat_fh.png"),
                    ))
                : Container(),
        if (frosthavenStyle)
          Positioned(
              height: 16 * scale,
              left: 74.8 * scale,
              top: 66 * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/range-stat_fh.png"),
              )),
        if (data.type.capture)
          Positioned(
              height: 16 * scale,
              left: 74.8 * scale,
              top: 66 * scale,
              child: const Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/psd/capture.png"),
              )),
        Positioned(
            //TODO: move position to FH place in corner
            left: 45 * scale,
            bottom: 10 * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: _createConditionList(data, scale, normal),
            )),
        Positioned(
            right: 45 * scale,
            bottom: 10 * scale,
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: _createConditionList(data, scale, elite),
            ))
      ],
    );
  }

  static Widget buildBossLayout(Monster data, double scale, var shadow,
      var leftStyle, var rightStyle, bool frosthavenStyle) {
    bool noCalculationSetting = getIt<Settings>().noCalculation.value;
    double height = 123 * 0.8 * scale;
    MonsterStatsModel normal = data.type.levels[data.level.value].boss!;
    //normal stats calculated:
    String health = normal.health.toString();
    if (noCalculationSetting == false) {
      int? healthValue = StatCalculator.calculateFormula(normal.health);
      if (healthValue != null) {
        health = healthValue.toString();
      }
    }
    //special case:
    if (health == "Hollowpact") {
      health = "7";
      for (var item in getIt<GameState>().currentList) {
        if (item is Character && item.id == "Hollowpact") {
          health = item
              .characterClass.healthByLevel[item.characterState.level.value - 1]
              .toString();
        }
      }
    }
    if (health == "Incarnate") {
      health = "36";
      for (var item in getIt<GameState>().currentList) {
        if (item is Character && item.id == "Incarnate") {
          health = (item.characterClass
                      .healthByLevel[item.characterState.level.value - 1] *
                  2)
              .toString();
        }
      }
    }

    String attack = normal.attack.toString();
    String move = normal.move.toString();
    if (noCalculationSetting == false) {
      int? moveValue = StatCalculator.calculateFormula(normal.move);
      if (moveValue != null) {
        move = moveValue.toString();
      }
      int? attackValue = StatCalculator.calculateFormula(normal.attack);
      if (attackValue != null) {
        attack = attackValue.toString();
      }
    }

    String bossAttackAttributes = "";
    List<String> bossOtherAttributes = [];

    for (String item in normal.attributes) {
      if (frosthavenStyle &&
          (item.startsWith('%wound%') ||
              item.startsWith('%poison%') ||
              item.startsWith("%brittle%"))) {
        bossAttackAttributes += item;
      } else if (item.startsWith("%target%")) {
        bossAttackAttributes += "^$item";
      } else {
        bossOtherAttributes.add(item);
      }
    }

    Widget attackAttributes = LineBuilder.createLines([bossAttackAttributes],
        true, false, false, data, CrossAxisAlignment.start, scale, false);

    final specialStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: 14 * 0.8 * scale,
        height: 1,
        shadows: [shadow]);

    return Stack(
      //alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0 * scale),
          child: Image(
            height: 93.5 * scale,
            width: 167 * scale,
            fit: BoxFit.fitWidth,
            image: const AssetImage("assets/images/psd/monsterStats-boss.png"),
          ),
        ),
        Positioned(
            left: 7.0 * scale,
            top: frosthavenStyle ? 0.5 * scale : 2.0 * scale,
            child: Text(
              data.level.value.toString(),
              style: TextStyle(
                  fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                  color: Colors.white,
                  fontSize: 18 * 0.8 * scale,
                  height: 1,
                  shadows: [shadow]),
            )),
        Positioned(
          left: 0,
          top: frosthavenStyle ? 29.4 * scale : 30.4 * scale,
          width: 24 * scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.end,
            // mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(health, style: leftStyle),
              Text(move, style: leftStyle),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: EdgeInsets.only(
                        right: bossAttackAttributes.contains("target")
                            ? 1 * scale
                            : 0),
                    child: attackAttributes),
                Text(attack, style: leftStyle)
              ]),
              Text(normal.range != 0 ? normal.range.toString() : "",
                  style: leftStyle),
            ],
          ),
        ),
        Positioned(
            left: 40.0 * scale,
            top: 20.0 * 0.8 * scale,
            width: 160 * 0.8 * scale, //useful or not?
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //alignment: Alignment.topRight,
                //width: 67*tempScale*scale,
                children: [
                  bossOtherAttributes.isNotEmpty
                      ? Row(children: [
                          Text("    ", style: specialStyle),
                          SizedBox(
                              width: 140 * 0.8 * scale,
                              child: LineBuilder.createLines(
                                  bossOtherAttributes,
                                  false,
                                  false,
                                  false,
                                  data,
                                  CrossAxisAlignment.start,
                                  scale,
                                  getIt<Settings>().shimmer.value)),
                        ])
                      : Container(),
                  if (bossOtherAttributes.isNotEmpty)
                    Image.asset(
                      // alignment: alignment == CrossAxisAlignment.start? Alignment.centerLeft : Alignment.center,
                      scale: 1 / (scale * 0.15),
                      height: 1 * scale,
                      fit: BoxFit.fill,
                      width: 125.0 * scale,
                      //actually 40, but some layout might depend on wider size so not changing now
                      filterQuality: FilterQuality.medium,
                      "assets/images/abilities/divider_boss_fh.png",
                    ),
                  normal.special1.isNotEmpty
                      ? Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                "1:",
                                style: specialStyle,
                              ),
                              SizedBox(
                                  width: 112 * scale,
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss!
                                          .special1,
                                      false,
                                      !noCalculationSetting,
                                      false,
                                      data,
                                      CrossAxisAlignment.start,
                                      scale,
                                      false)),
                            ])
                      : Container(),
                  normal.special2.isNotEmpty
                      ? Image.asset(
                          // alignment: alignment == CrossAxisAlignment.start? Alignment.centerLeft : Alignment.center,
                          scale: 1 / (scale * 0.15),
                          height: 1 * scale,
                          fit: BoxFit.fill,
                          width: 125.0 * scale,
                          //actually 40, but some layout might depend on wider size so not changing now
                          filterQuality: FilterQuality.medium,
                          "assets/images/abilities/divider_boss_fh.png",
                        )
                      : Container(),
                  normal.special2.isNotEmpty
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("2:", style: specialStyle),
                              SizedBox(
                                  width: 140 * 0.8 * scale,
                                  child: LineBuilder.createLines(
                                      data.type.levels[data.level.value].boss!
                                          .special2,
                                      false,
                                      !noCalculationSetting,
                                      false,
                                      data,
                                      CrossAxisAlignment.start,
                                      scale,
                                      false)),
                            ])
                      : Container()
                ])),
        data.type.flying
            ? Positioned(
                height: 16 * scale,
                left: 23.5 * scale,
                top: 44.4 * scale,
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(frosthavenStyle
                      ? "assets/images/psd/flying-stat_fh.png"
                      : "assets/images/psd/flying-stat.png"),
                ),
              )
            : !frosthavenStyle
                ? Positioned(
                    height: 16 * scale,
                    left: 23.5 * scale,
                    top: 44.4 * scale,
                    child: const Image(
                      fit: BoxFit.fitHeight,
                      image: AssetImage("assets/images/psd/move-stat.png"),
                    ),
                  )
                : Container(),
        if (normal.range != 0)
          Positioned(
              height: 16 * scale,
              left: 30.0 * 0.8 * scale,
              top: 93.0 * 0.8 * scale,
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/range-stat_fh.png"
                    : "assets/images/psd/range-stat.png"),
              )),
        Positioned(
            right: 10 * scale,
            top: 1 * scale,
            child: Row(
              children: _createConditionList(data, scale, normal),
            )),
      ],
    );
  }

  static Widget buildCard(Monster data, double scale) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    var shadow = Shadow(
      offset: Offset(0.4 * scale, 0.4 * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );

    var shadowLeft = Shadow(
      offset: Offset(0.4 * scale, 0.4 * scale),
      color: Colors.black54,
      blurRadius: 1 * scale,
    );

    final leftStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.black,
        fontSize: 12.8 * scale,
        height: 1.2,
        shadows: [shadowLeft]);

    final rightStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.white,
        fontSize: 16 * 0.8 * scale,
        height: 1.2,
        shadows: [shadow]);

    return ValueListenableBuilder<int>(
        valueListenable: data.level,
        builder: (context, value, child) {
          bool isBoss = data.type.levels[data.level.value].boss != null;

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
              child: isBoss
                  ? buildBossLayout(data, scale, shadow, leftStyle, rightStyle,
                      frosthavenStyle)
                  : buildNormalLayout(data, scale, shadow, leftStyle,
                      rightStyle, frosthavenStyle));
        });
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);

    bool isBoss = widget.data.type.levels[widget.data.level.value].boss != null;

    return Container(
        //height: 93.5 * scale,
        width: 166 * scale, //167
        child: Stack(children: [
          GestureDetector(
              onDoubleTap: () {
                setState(() {
                  openDialog(
                      context,
                      //problem: context is of stat card widget, not the + button
                      StatCardZoom(monster: widget.data));
                });
              },
              child: buildCard(widget.data, scale)),
          if (!isBoss)
            Positioned(
                bottom: 5 * scale * 0.8,
                left: 5 * scale * 0.8,
                child: SizedBox(
                    width: 25 * scale * 0.8 + 8,
                    height: 25 * scale * 0.8 + 8,
                    child: ValueListenableBuilder<List<MonsterInstance>>(
                        valueListenable: widget.data.monsterInstances,
                        builder: (context, value, child) {
                          bool allStandeesOut =
                              widget.data.monsterInstances.value.length ==
                                  widget.data.type.count;
                          return IconButton(
                            padding: const EdgeInsets.only(right: 8, top: 8),
                            icon: Image.asset(
                                height: 25 * scale * 0.8,
                                fit: BoxFit.fitHeight,
                                color: allStandeesOut
                                    ? Colors.white24
                                    : Colors.grey,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () {
                              _handleAddPressed(
                                  widget.data, context, true, false);
                            },
                          );
                        }))),
          Positioned(
              bottom: 5 * scale * 0.8,
              right: 5 * scale * 0.8,
              child: SizedBox(
                  width: 25 * scale * 0.8 + 8,
                  height: 25 * scale * 0.8 + 8,
                  child: ValueListenableBuilder<List<MonsterInstance>>(
                      valueListenable: widget.data.monsterInstances,
                      builder: (context, value, child) {
                        return IconButton(
                            padding: const EdgeInsets.only(left: 8, top: 8),
                            icon: Image.asset(
                                color:
                                    widget.data.monsterInstances.value.length ==
                                            widget.data.type.count
                                        ? Colors.white24
                                        : Colors.grey,
                                height: 25 * scale * 0.8,
                                fit: BoxFit.fitHeight,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () {
                              _handleAddPressed(
                                  widget.data, context, false, isBoss);
                            });
                      }))),
        ]));
  }

  static List<Widget> _createConditionList(
      Monster data, double scale, MonsterStatsModel stats) {
    List<Widget> list = [];
    String suffix = "";
    if (GameMethods.isFrosthavenStyle(data.type)) {
      suffix = "_fh";
    }
    for (var item in stats.immunities) {
      item = item.substring(1, item.length - 1);
      String imagePath = "assets/images/abilities/$item.png";
      if (suffix.isNotEmpty && hasGHVersion(item)) {
        imagePath = "assets/images/abilities/$item$suffix.png";
      }
      Image image = Image(
        height: 11 * scale,
        filterQuality: FilterQuality.medium, //needed because of the edges
        image: AssetImage(imagePath),
      );
      Image immuneIcon = Image(
        height: 4 * scale,
        filterQuality: FilterQuality.medium, //needed because of the edges
        image: const AssetImage("assets/images/psd/immune.png"),
      );
      Stack stack = Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0, top: 0, child: image),
          Positioned(left: 9 * scale, top: 3.5 * scale, child: immuneIcon),
        ],
      );
      list.add(SizedBox(
        width: 14 * scale,
        height: 11 * scale,
        child: stack,
      ));
    }
    return list;
  }
}
