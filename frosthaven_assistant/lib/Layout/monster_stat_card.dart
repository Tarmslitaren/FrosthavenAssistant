import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Model/monster.dart';
import 'line_builder.dart';
import 'monster_ability_card.dart';
double tempScale = 0.8;
class MonsterStatCardWidget extends StatefulWidget {
  //final String icon;
  //final double height;
  //final double borderWidth = 2;
  final int level;
  final MonsterModel data;


  const MonsterStatCardWidget({
    Key? key,
    required this.data,
    required this.level,
  }) : super(key: key);

  @override
  _MonsterStatCardWidgetState createState() => _MonsterStatCardWidgetState();
}

class _MonsterStatCardWidgetState extends State<MonsterStatCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _level = widget.level;
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double height = 123*tempScale*scale;

    final leftStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.black,
        fontSize: 16*tempScale*scale,
        height: 1.2,
        shadows: [Shadow(offset: Offset(1*scale, 1*scale), color: Colors.black12)]);

    final rightStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.white,
        fontSize: 16*tempScale*scale,
        height: 1.2,
        shadows: [Shadow(offset: Offset(1*scale, 1*scale), color: Colors.black)]);

    return GestureDetector(
        onTap: () {
          //if grayscale mode: fade in the stats
          setState(() {});
        },
        child: Container(
            margin:  EdgeInsets.all(2*scale*tempScale),
            child: Stack(
              //alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0*scale),
                  child: Image(
                    height: height,
                    image: const AssetImage(
                        "assets/images/psd/monsterStats-normal.png"),
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
                Positioned(
                  left: 82.0*tempScale*scale,
                  top: 26.0*tempScale*scale,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.data.levels[_level].normal!.health.toString(),
                          style: leftStyle),
                      Text(widget.data.levels[_level].normal!.attack.toString(),
                          style: leftStyle),
                      Text(widget.data.levels[_level].normal!.move.toString(),
                          style: leftStyle),
                      Text(
                          widget.data.levels[_level].normal?.range != 0
                              ? widget.data.levels[_level].normal!.range
                                  .toString()
                              : "-",
                          style: leftStyle),
                    ],
                  ),
                ),
                Positioned(

                  left: 6.0*tempScale*scale,
                  top: 24.0*tempScale*scale,
                    width: 65*tempScale*scale,
                  child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        //alignment: Alignment.topRight,
                    //width: 67*tempScale*scale,
                    children: [createLines(
                        widget.data.levels[_level].normal!.attributes, true,CrossAxisAlignment.end, scale),]
                  )

                ),
                Positioned(
                  right: 80.0*tempScale*scale,
                  top: 26.0*tempScale*scale,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.data.levels[_level].normal!.health.toString(),
                          style: rightStyle),
                      Text(widget.data.levels[_level].normal!.attack.toString(),
                          style: rightStyle),
                      Text(widget.data.levels[_level].normal!.move.toString(),
                          style: rightStyle),
                      Text(
                          widget.data.levels[_level].normal?.range != 0
                              ? widget.data.levels[_level].normal!.range
                                  .toString()
                              : "-",
                          style: rightStyle),
                    ],
                  ),
                ),
                Positioned(
                  width: 65*tempScale*scale,
                  right: 0.0,
                  top: 24.0*tempScale*scale,
                  child: createLines(
                      widget.data.levels[_level].normal!.attributes, false, CrossAxisAlignment.start, scale),
                )
              ],
            )));
  }
}
