
import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import '../Resource/enums.dart';
import '../Resource/ui_utils.dart';
import 'menus/status_menu.dart';

class MonsterBox extends StatefulWidget {
  //final MonsterInstance data;
  final String figureId;
  final String ownerId;
  final int display;

  const MonsterBox({Key? key, required this.figureId, required this.ownerId, required this.display})
      : super(key: key);

  static const double conditionSize = 14;

  static double getWidth(double scale, MonsterInstance data) {
    double width = 47; //some margin there
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
  late MonsterInstance data;

  @override
  void initState() {
    super.initState();
    data = GameMethods.getFigure(widget.ownerId, widget.figureId) as MonsterInstance;
  }

  List<Image> createConditionList(double scale) {
    List<Image> list = [];
    for (var item in data.conditions.value) {
      Image image = Image(
        height: MonsterBox.conditionSize * scale,
        image: AssetImage("assets/images/conditions/${item.name}.png"),
      );
      list.add(image);
    }
    return list;
  }

  String? getMonster() {
    for (var item in getIt<GameState>().currentList) {
      if (item is Monster) {
        //this will cause issues if several monsters use same gfx.
        if (item.id == data.name) {
          return item.id;
        }
      }
    }
    return null;
  }

  Widget buildInternal(double scale, double width, Color color) {
    String folder = "monsters";
    bool isSummon = false;
    if (data.type == MonsterType.summon) {
      isSummon = true;
      folder = "summon";
    }
    String standeeNr = "";
    if (data.standeeNr > 0) {
      standeeNr = data.standeeNr.toString();
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
                image: AssetImage("assets/images/$folder/${data.gfx}.png"),
                //width: widget.height*0.8,
              ),
            ),
            Positioned(
              width: 22 * scale,
              //baked in edge insets to line up with picture
              top: 1 * scale,
              child: Text(
                textAlign: TextAlign.center,
                standeeNr,
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
                          height: 11 * scale,
                          image: const AssetImage("assets/images/blood.png"),
                        ),
                        Container(
                          width: 16.8 * scale,
                          alignment: Alignment.center,
                          child: Text(
                            textAlign: TextAlign.end,
                            "${data.health.value}",
                            style: TextStyle(
                                fontFamily: 'Pirata',
                                color: Colors.white,
                                fontSize: data.health.value > 99
                                    ? 13 * scale
                                    : 18 * scale,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1 * scale, 1 * scale),
                                      color: Colors.red)
                                ]),
                          ),
                        ),
                        SizedBox(
                          width: (2.5) *scale,
                        ),
                        ValueListenableBuilder<List<Condition>>(
                            valueListenable: data.conditions,
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
                    valueListenable: data.maxHealth,
                    builder: (context, value, child) {
                      return FAProgressBar(
                        currentValue: data.health.value.toDouble(),
                        maxValue: data.maxHealth.value.toDouble(),
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
                        changeColorValue: (data.maxHealth.value).toInt(),
                        changeProgressColor: Colors.green,
                      );
                    }))
          ]));
    }


  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    data = GameMethods.getFigure(widget.ownerId, widget.figureId) as MonsterInstance;
    //double height = scale * 40;
    Color color = Colors.white;
    if (data.type == MonsterType.elite) {
      color = Colors.yellow;
    }
    if (data.type == MonsterType.boss) {
      color = Colors.red;
    }
    //if (widget.data.type == MonsterType.summon) {
    //  color = Colors.lightGreenAccent;
    //}

    double width = MonsterBox.getWidth(scale, data);
    String figureId = data.name + data.gfx + data.standeeNr.toString();
    String? characterId;
    if(widget.ownerId != data.name){
      characterId = widget.ownerId; //this is probably wrong
    }
    return GestureDetector(
        onTap: () {
          //open stats menu
          openDialog(
            context,
            StatusMenu(figureId: figureId, monsterId: getMonster(), characterId: characterId),
          );
        },
        child: AnimatedContainer(
            //makes it grow nicely when adding conditions
            key: Key(data.standeeNr.toString()), //TODO: shiiiet wont work for summons, use index?
            width: width,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder<int>(
                valueListenable: data.health,
                builder: (context, value, child) {
                  bool alive = true;
                  if (data.health.value <= 0) {
                    alive = false;
                  }

                  double offset = -30 * scale;
                  Widget child = buildInternal(scale, width, color);

                  //TODO: this needs to be fixed some other way. id by stnadee nr might be ok for monsters, but summons need other way ot tell it is new
                  if (widget.display != data.standeeNr ) {
                    //if this one is not added

                    //TODO: make own widget: make it run add animation only once
                    return TranslationAnimatedWidget.tween(
                        enabled: !alive,
                        translationDisabled: const Offset(0, 0),
                        translationEnabled: Offset(0, alive ? 0 : -offset),
                        duration: const Duration(milliseconds: 600),
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
                      duration: const Duration(milliseconds: 600),
                      curve: alive ? Curves.linear : Curves.linear,
                      child: OpacityAnimatedWidget.tween(
                          enabled: alive,
                          opacityDisabled: 0,
                          opacityEnabled: 1,
                          child: child));
                })));
  }
}
