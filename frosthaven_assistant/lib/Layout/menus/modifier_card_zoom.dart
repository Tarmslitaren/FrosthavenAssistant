import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/ModifierCardWidget/modifier_card_front.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/state/game_state.dart';

class ModifierCardZoom extends StatelessWidget {

  const ModifierCardZoom({super.key, required this.name, required this.card});

  final String name;
  final ModifierCard card;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = kCardZoomDefaultScale;
    final cardWidth = kCardZoomWidthFactor * kModifierCardBaseWidth;
    if (screenSize.width < cardWidth) {
      scale = kCardZoomDefaultScale * (screenSize.width / cardWidth);
    }

    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ModifierCardFront(card: card, name: name, scale: scale)]));
  }
}
