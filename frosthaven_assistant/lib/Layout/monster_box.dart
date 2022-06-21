import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'menus/main_menu.dart';
import 'menus/status_menu.dart';
import 'monster_stat_card.dart';

class MonsterBox extends StatefulWidget {
  final MonsterInstance data;

  const MonsterBox({Key? key, required this.data}) : super(key: key);

  static const double conditionSize = 14;
  static double getWidth(double scale, MonsterInstance data ){
    double width = 57;
    width += conditionSize * data.conditions.value.length / 2;
    if(data.conditions.value.length % 2 != 0) {
      width += conditionSize/2;
    }
    width *= scale;
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

  Monster? getMonster(){
    for( var item in getIt<GameState>().currentList){
      if (item is Monster){
        if(item.id == widget.data.name) {
          return item;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale * 40;
    Color color = Colors.white;
    if (widget.data.type == MonsterType.elite) {
      color = Colors.yellow;
    }
    if (widget.data.type == MonsterType.boss) {
      color = Colors.red;
    }

    double width = MonsterBox.getWidth(scale, widget.data);
    return GestureDetector(
        onTap: () {
          //open stats menu
          openDialog(
              context,
              Stack(children: [
                Positioned(
                  //TODO: how to get a good grip on position
                  //left: 100, // left coordinate
                  //top: 100,  // top coordinate
                  child: Dialog(
                    child: StatusMenu(figure: widget.data, monster: getMonster()),
                  ),
                )
              ]));
          setState(() {});
        },
        child: Container(
            decoration: null,
            padding: EdgeInsets.all(0),
            height: 30 * scale,
            width: width,
            color: Color(int.parse("7A000000", radix: 16)),
            child: Stack(alignment: Alignment.centerLeft, children: [
              /*Image( //TODO make nice background image frame go around. think about color for text
                //fit: BoxFit.contain,
                height: height,
                //width: height,
                //fit: BoxFit.cover,
                image: AssetImage(
                    "assets/images/psd/monster-box.png"),
                //width: widget.height*0.8,
              ),*/
              Image(
                //fit: BoxFit.contain,
                height: height * 2.5,
                width: height / 2,
                fit: BoxFit.cover,
                image: AssetImage(
                    "assets/images/monsters/${widget.data.name}.png"),
                //width: widget.height*0.8,
              ),

              Positioned(
                left: 5 * scale,
                child: Text(
                  textAlign: TextAlign.center,
                  widget.data.standeeNr.toString(),
                  style: TextStyle(
                      fontFamily: 'Pirata',
                      color: color,
                      fontSize: height * 0.5,
                      shadows: [
                        Shadow(
                            offset: Offset(1 * scale, 1 * scale),
                            color: Colors.black)
                      ]),
                ),
              ),
              Positioned(
                  left: 20 * scale,
                  top: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Image(
                      //fit: BoxFit.contain,
                      color: Colors.red,
                      height: height * 0.6,
                      image: const AssetImage("assets/images/blood.png"),
                    ),
                    Container(
                      width: 30,
                      child:Text(
                      //textAlign: TextAlign.center,
                      "${widget.data.health.value}",///${widget.data.maxHealth.value}",
                      style: TextStyle(
                          fontFamily: 'Pirata',
                          color: Colors.white,
                          fontSize: height * 0.5,
                          shadows: [
                            Shadow(
                                offset: Offset(1 * scale, 1 * scale),
                                color: Colors.red)
                          ]),
                    ),),
                    ValueListenableBuilder<List<Condition>>(
                        valueListenable: widget.data.conditions,
                        builder: (context, value, child) {
                          return Container(
                              height: 30 * scale,
                              child: Wrap(
                                direction: Axis.vertical,
                                //verticalDirection: VerticalDirection.up,
                                //clipBehavior: Clip.none,
                                //runAlignment: ,
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,

                                children: createConditionList(scale),
                              ));
                        }),
                  ])
              ),
              Container(
                alignment: Alignment.bottomCenter,
                  width: 57 * scale,

                  child: FAProgressBar(
                    currentValue: widget.data.health.value.toDouble(),
                    maxValue: widget.data.maxHealth.value.toDouble(),
                    size: 8 * scale,
                    animatedDuration: const Duration(milliseconds: 0), //TODO: glitch with animation due to redraw?
                    direction: Axis.horizontal,
                    //verticalDirection: VerticalDirection.up,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5 * scale,
                    ),
                    backgroundColor: Colors.white,
                    progressColor: Colors.red,
                    formatValueFixed: 2, //what does this do?
                    changeColorValue:(widget.data.maxHealth.value/2).toInt(),
                    changeProgressColor: Colors.green,
                  ),
              )
            ])
        ));
  }
}
