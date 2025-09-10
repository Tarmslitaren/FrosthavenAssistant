import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Resource/state/game_state.dart';

class ModifierCardZoom extends StatelessWidget {
  const ModifierCardZoom({super.key, required this.name, required this.card});

  final String name;
  final ModifierCard card;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = 6;
    final cardWidth = 7 * 58.6666;
    if (screenSize.width < cardWidth) {
      scale = 6 * (screenSize.width / cardWidth);
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
