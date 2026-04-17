import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Resource/state/game_state.dart';

class ModifierCardZoom extends StatelessWidget {
  static const double _kDefaultScale = 6.0;
  static const double _kCardWidthFactor = 7.0;
  static const double _kCardWidthBase = 58.6666;

  const ModifierCardZoom({super.key, required this.name, required this.card});

  final String name;
  final ModifierCard card;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = _kDefaultScale;
    final cardWidth = _kCardWidthFactor * _kCardWidthBase;
    if (screenSize.width < cardWidth) {
      scale = _kDefaultScale * (screenSize.width / cardWidth);
    }

    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ModifierCardWidget.buildFront(card, name, scale, 1)]));
  }
}
