import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'enhancement_counter_button.dart';

class LootCardRow extends StatelessWidget {
  const LootCardRow({
    super.key,
    required this.type,
    required this.start,
    required this.count,
    required this.gameState,
    required this.getCard,
  });

  final String type;
  final int start;
  final int count;
  final GameState gameState;
  final LootCard? Function(String, int) getCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        count,
        (i) => EnhancementCounterButton(
            card: getCard(type, start + i)!, gameState: gameState),
      ),
    );
  }
}
