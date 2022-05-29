//portrait + name
//ability card
//stat sheet
//monster boxes
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import 'monster_stat_card.dart';

double tempScale = 0.8;

class MonsterWidget extends StatefulWidget {
  //final String icon;
  //final double height;
  //final double borderWidth = 2;
  final int level;
  final MonsterModel data;

  const MonsterWidget(
      {Key? key,
      //required this.icon,
      //this.height = 123,
        required this.data,
        required this.level})
      : super(key: key);

  @override
  _MonsterWidgetState createState() => _MonsterWidgetState();
}

class _MonsterWidgetState extends State<MonsterWidget> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = scale *tempScale* 121.5;
    return Row(

      children: [
        GestureDetector(
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
            child: Container(
                //margin: EdgeInsets.all(2*tempScale*scale),
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  Image(
                    //fit: BoxFit.contain,
                    height: height,
                    width: height,
                    image: AssetImage("assets/images/monsters/${widget.data.gfx}.png"),
                    //width: widget.height*0.8,
                  ),
                  Text(
                    widget.data.display,
                    style: TextStyle(
                        fontFamily: 'Pirata',
                        color: Colors.white,
                        fontSize: 20*tempScale*scale,
                        shadows: [
                          Shadow(offset: Offset(1*scale, 1*scale), color: Colors.black)
                        ]),
                  )
                ]))),
        MonsterAbilityCardWidget(data: widget.data),
        MonsterStatCardWidget(data: widget.data, level: widget.level,),
      ],
    );
  }
}
