import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/state/game_state.dart';

class AbilityCardZoom extends StatelessWidget {
  static const double _kCardWidth = 142.4;
  static const double _kCardHeight = 92.8;
  static const double _kDefaultZoom = 2.5;
  static const double _kHorizontalMargin = 40.0;
  static const double _kVerticalMargin = 60.0;
  static const double _kMinScalePixels = 269.0;

  const AbilityCardZoom(
      {super.key,
      required this.card,
      required this.monster,
      required this.calculateAll});

  final MonsterAbilityCardModel card;
  final Monster monster;
  final bool calculateAll;

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double zoomValue = _kDefaultZoom;
    final screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    double width = _kCardWidth * scale * zoomValue;
    double height = _kCardHeight * scale * zoomValue;
    if (screenWidth < _kHorizontalMargin + width) {
      zoomValue = (screenWidth - _kHorizontalMargin) / (_kCardWidth * scale);
    }

    if (screenHeight < _kVerticalMargin + height) {
      zoomValue = (screenHeight - _kVerticalMargin) / (_kCardHeight * scale);
    }

    double scaling = scale * zoomValue;
    if (scaling < _kMinScalePixels / _kCardWidth && screenWidth > _kHorizontalMargin + width) {
      scaling = _kMinScalePixels / _kCardWidth;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: SizedBox(
          width: _kCardWidth * scale * zoomValue,
          height: _kCardHeight * scale * zoomValue,
          child: MonsterAbilityCardWidget.buildFront(
              card, monster, scaling, calculateAll)),
    );
  }
}
