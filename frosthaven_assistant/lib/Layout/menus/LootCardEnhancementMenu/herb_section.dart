import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import 'loot_card_row.dart';
import 'loot_type_header.dart';

const int _kHerbCount = 2;

class HerbSection extends StatelessWidget {
  const HerbSection(
      {super.key,
      required this.type,
      required this.gameState,
      required this.getCard});

  final String type;
  final GameState gameState;
  final LootCard? Function(String, int) getCard;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LootTypeHeader(type: type, amount: ""),
      LootCardRow(
          type: type,
          start: 0,
          count: _kHerbCount,
          gameState: gameState,
          getCard: getCard),
      const Divider(),
    ]);
  }
}
