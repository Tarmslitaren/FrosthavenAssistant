//portrait + name
//ability card
//stat sheet
//monster boxes
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';

import 'monster_stat_card.dart';

class MonsterWidget extends StatefulWidget {
  //final String icon;
  final double height;
  final double borderWidth = 2;
  final int level;
  final MonsterModel data;

  const MonsterWidget(
      {Key? key,
      //required this.icon,
      this.height = 123,
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
                margin: const EdgeInsets.all(2),
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  Image(
                    //fit: BoxFit.contain,
                    height: widget.height,
                    width: widget.height,
                    image: AssetImage("assets/images/monsters/${widget.data.gfx}.png"),
                    //width: widget.height*0.8,
                  ),
                  Text(
                    widget.data.display,
                    style: const TextStyle(
                        fontFamily: 'Pirata',
                        color: Colors.white,
                        fontSize: 20,
                        shadows: [
                          Shadow(offset: Offset(1, 1), color: Colors.black)
                        ]),
                  )
                ]))),
        MonsterAbilityCardWidget(data: widget.data),
        MonsterStatCardWidget(data: widget.data, level: widget.level,),
      ],
    );
  }
}
