import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_card_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/monster_ability_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:reorderables/reorderables.dart';
import '../../Resource/commands/reorder_ability_list_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';


class AbilityCardZoom extends StatefulWidget {
  const AbilityCardZoom(
      {Key? key, required this.card, required this.monster, required this.calculateAll})
      : super(key: key);

  final MonsterAbilityCardModel card;
  final Monster monster;
  final bool calculateAll;

  @override
  AbilityCardZoomState createState() => AbilityCardZoomState();
}

class AbilityCardZoomState extends State<AbilityCardZoom> {

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double zoomValue = 2.5;
    double screenWidth = MediaQuery.of(context).size.width;
    double width = 178 * 0.8 * scale* zoomValue;
    if(screenWidth < 40 + width) {
      width = screenWidth - 40;
    }

    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
       // color: Colors.amber,
          //margin: EdgeInsets.all(2 * scale * zoomValue * 0.8),
          //width: width,
          //height: 118 * 0.8 * scale* zoomValue,
          child:MonsterAbilityCardWidget.buildFront(widget.card, widget.monster, scale * zoomValue, widget.calculateAll)
      ),
    );
  }
}

