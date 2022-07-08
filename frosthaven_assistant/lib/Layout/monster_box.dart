import 'package:animated_widgets/AnimatedWidgets.dart';
import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';
import '../Resource/ui_utils.dart';
import 'menus/main_menu.dart';
import 'menus/status_menu.dart';
import 'monster_stat_card.dart';

class MonsterBox extends StatefulWidget {
  final MonsterInstance data;
  final int display;

  const MonsterBox({Key? key, required this.data, required this.display})
      : super(key: key);

  static const double conditionSize = 14;

  static double getWidth(double scale, MonsterInstance data) {
    double width = 47;
    width += conditionSize * data.conditions.value.length / 2;
    if (data.conditions.value.length % 2 != 0) {
      width += conditionSize / 2;
    }
    width = width * scale;
    return width;
  }

  @override
  _MonsterBoxState createState() => _MonsterBoxState();
}

class _MonsterBoxState extends State<MonsterBox> {
  @override
  void initState() {
    super.initState();
  }

  List<Image> createConditionList(double scale) {
    List<Image> list = [];
    for (var item in widget.data.conditions.value) {
      Image image = Image(
        height: MonsterBox.conditionSize * scale,
        image: AssetImage("assets/images/conditions/${item.name}.png"),
      );
      list.add(image);
    }
    return list;
  }

  Monster? getMonster() {
    for (var item in getIt<GameState>().currentList) {
      if (item is Monster) {
        //this will cause issues if several monsters use same gfx.
        if (item.id == widget.data.name) {
          return item;
        }
      }
    }
    return null;
  }

  Widget buildInternal(double scale, double width, Color color) {
    String folder = "monsters";
    bool isSummon = false;
    if (widget.data.type == MonsterType.summon) {
      isSummon = true;
      folder = "summon";
    }
    return Container(
        decoration: null,
        padding: EdgeInsets.zero,
        height: 30 * scale,
        width: width,
        color: Color(int.parse("7A000000", radix: 16)),
        //black with some opacity
        child: Stack(alignment: Alignment.centerLeft, children: [
          Image(
            //fit: BoxFit.contain,
            height: 30 * scale,
            width: 47 * scale,
            fit: BoxFit.fill,
            //scale up disregarding aspect ratio
            image: AssetImage("assets/images/psd/monster-box.png"),
            //width: widget.height*0.8,
          ),
          Container(
            margin: EdgeInsets.only(
                left: 3 * scale, top: 3 * scale, bottom: 2 * scale),
            child: Image(
              //fit: BoxFit.contain,
              height: 100 * scale,
              width: 17 * scale,
              fit: BoxFit.cover,
              image: AssetImage("assets/images/$folder/${widget.data.gfx}.png"),
              //width: widget.height*0.8,
            ),
          ),
          Positioned(
            width: 22 * scale,
            //baked in edge insets to line up with picture
            top: 1 * scale,
            child: Text(
              textAlign: TextAlign.center,
              widget.data.standeeNr.toString(),
              style: TextStyle(
                  fontFamily: 'Pirata',
                  color: color,
                  fontSize: 20 * scale,
                  shadows: [
                    Shadow(
                        offset: Offset(1 * scale, 1 * scale),
                        color: Colors.black)
                  ]),
            ),
          ),
          Positioned(
            left: 20 * scale,
            //width: width-20*scale,
            top: 0,

            child: Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        //fit: BoxFit.contain,
                        color: Colors.red,
                        height: 12 * scale,
                        image: const AssetImage("assets/images/blood.png"),
                      ),
                      Container(
                        width: 18 * scale,
                        child: Text(
                          //textAlign: TextAlign.center,
                          "${widget.data.health.value}",
                          style: TextStyle(
                              fontFamily: 'Pirata',
                              color: Colors.white,
                              fontSize: widget.data.health.value > 99
                                  ? 13 * scale
                                  : 18 * scale,
                              shadows: [
                                Shadow(
                                    offset: Offset(1 * scale, 1 * scale),
                                    color: Colors.red)
                              ]),
                        ),
                      ),
                      ValueListenableBuilder<List<Condition>>(
                          valueListenable: widget.data.conditions,
                          builder: (context, value, child) {
                            return Container(
                                height: 30 * scale,
                                child: Wrap(
                                  spacing: 0,
                                  runSpacing: 0,
                                  direction: Axis.vertical,
                                  //verticalDirection: VerticalDirection.up,
                                  //clipBehavior: Clip.none,
                                  //runAlignment: ,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,

                                  children: createConditionList(scale),
                                ));
                          }),
                    ])),
          ),
          Container(
              //the hp bar
              margin: EdgeInsets.only(
                  bottom: 2.5 * scale, left: 2.5 * scale, right: 2.7 * scale),
              alignment: Alignment.bottomCenter,
              width: 42 * scale,
              child: ValueListenableBuilder<int>(
                  valueListenable: widget.data.maxHealth,
                  builder: (context, value, child) {
                    return FAProgressBar(
                      currentValue: widget.data.health.value.toDouble(),
                      maxValue: widget.data.maxHealth.value.toDouble(),
                      size: 4.0 * scale,
                      //animatedDuration: const Duration(milliseconds: 0),
                      direction: Axis.horizontal,
                      //verticalDirection: VerticalDirection.up,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5 * scale,
                      ),
                      backgroundColor: Colors.black,
                      progressColor: Colors.red,
                      //formatValueFixed: 2,
                      //what does this do?
                      changeColorValue: (widget.data.maxHealth.value).toInt(),
                      changeProgressColor: Colors.green,
                    );
                  }))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    //double height = scale * 40;
    Color color = Colors.white;
    if (widget.data.type == MonsterType.elite) {
      color = Colors.yellow;
    }
    if (widget.data.type == MonsterType.boss) {
      color = Colors.red;
    }
    //if (widget.data.type == MonsterType.summon) {
    //  color = Colors.lightGreenAccent;
    //}

    double width = MonsterBox.getWidth(scale, widget.data);
    return GestureDetector(
        onTap: () {
          //open stats menu
          openDialog(
            context,
            StatusMenu(figure: widget.data, monster: getMonster()),
          );
        },
        child: AnimatedContainer(
            //makes it grow nicely when adding conditions
            key: Key(widget.data.standeeNr.toString()),
            width: width,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder<int>(
                valueListenable: widget.data.health,
                builder: (context, value, child) {
                  bool alive = true;
                  if (widget.data.health.value <= 0) {
                    alive = false;
                  }

                  double offset = -30 * scale;
                  Widget child = buildInternal(scale, width, color);

                  if (widget.display != widget.data.standeeNr) {
                    //if this one is not added
                    return TranslationAnimatedWidget.tween(
                        enabled: !alive,
                        translationDisabled: Offset(0, 0),
                        translationEnabled: Offset(0, alive ? 0 : -offset),
                        duration: Duration(milliseconds: 600),
                        curve: alive ? Curves.linear : Curves.linear,
                        child:
                            child); /*OpacityAnimatedWidget.tween(
                            enabled: alive,
                            opacityDisabled: 0,
                            opacityEnabled: 1,
                            child: child
                        ));*/
                  }

                  //find out if added

                  return TranslationAnimatedWidget.tween(
                      enabled: true,
                      //fix is to only set enabled on added/removed ones?
                      translationDisabled: Offset(0, alive ? offset : 0),
                      translationEnabled: Offset(0, alive ? 0 : -offset),
                      duration: Duration(milliseconds: 600),
                      curve: alive ? Curves.linear : Curves.linear,
                      child: OpacityAnimatedWidget.tween(
                          enabled: alive,
                          opacityDisabled: 0,
                          opacityEnabled: 1,
                          child: child));
                })));
  }
}
