
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_stat_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/state/monster.dart';


class StatCardZoom extends StatefulWidget {
  const StatCardZoom(
      {Key? key, required this.monster})
      : super(key: key);

  final Monster monster;

  @override
  StatCardZoomState createState() => StatCardZoomState();
}

class StatCardZoomState extends State<StatCardZoom> {

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double zoomValue = 2.5;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cardWidth = 167;
    double cardHeight = 96.5;
    double width = cardWidth * scale* zoomValue; //TODO: tweak this
    double height = cardHeight * scale * zoomValue;
    double horizontalMargin = 40;
    if(screenWidth < horizontalMargin + width) {
      zoomValue = (screenWidth-horizontalMargin)/ (cardWidth * scale);// 2;
    }

    double verticalMargin = 60;
    if(screenHeight < verticalMargin + height) {
      zoomValue = (screenHeight-verticalMargin)/ (cardHeight * scale);// 2;
    }

    double scaling = scale * zoomValue;
    if (scaling < 269/cardWidth && screenWidth > horizontalMargin + width) {
      scaling = 269/cardWidth;

    }




    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        // color: Colors.amber,
        //margin: EdgeInsets.all(2 * scale * zoomValue * 0.8),
        width: width,
        height: height,
          child:MonsterStatCardWidgetState.buildCard(widget.monster, scaling)
      ),
    );
  }
}

