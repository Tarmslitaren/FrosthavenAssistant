import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/state/game_state.dart';


class AbilityCardZoom extends StatefulWidget {
  const AbilityCardZoom(
      {super.key,
      required this.card,
      required this.monster,
      required this.calculateAll});

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
    double screenHeight = MediaQuery.of(context).size.height;
    double width = 142.4 * scale * zoomValue;
    double height = 92.8 * scale * zoomValue;
    if (screenWidth < 40 + width) {
      zoomValue = (screenWidth - 40) / (142.4 * scale); // 2;
    }

    if (screenHeight < 60 + height) {
      zoomValue = (screenHeight - 60) / (92.8 * scale); // 2;
    }

    double scaling = scale * zoomValue;
    if (scaling < 269 / (142.4) && screenWidth > 40 + width) {
      scaling = 269 / (142.4);
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: SizedBox(
          width: 142.4 * scale * zoomValue,
          height: 92.8 * scale * zoomValue,
          child: MonsterAbilityCardWidget.buildFront(
              widget.card, widget.monster, scaling, widget.calculateAll)),
    );
  }
}
