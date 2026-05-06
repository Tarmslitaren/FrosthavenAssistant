import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'loot_card_row.dart';

const int _kCoinRowSize = 3;
const double _kCoinRowSpacing = 6.0;

class CoinRowsSection extends StatelessWidget {
  const CoinRowsSection({
    super.key,
    required this.start,
    required this.rows,
    required this.gameState,
    required this.getCard,
  });

  final int start;
  final int rows;
  final GameState gameState;
  final LootCard? Function(String, int) getCard;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int row = 0; row < rows; row++) ...[
        LootCardRow(
            type: "coin",
            start: start + row * _kCoinRowSize,
            count: _kCoinRowSize,
            gameState: gameState,
            getCard: getCard),
        if (row < rows - 1) const SizedBox(height: _kCoinRowSpacing),
      ],
    ]);
  }
}
