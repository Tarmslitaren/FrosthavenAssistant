import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../l10n/app_localizations.dart';
import 'loot_card_row.dart';
import 'loot_type_header.dart';

const int _kMaterial1Count = 2;
const int _kMaterial2x2Start = _kMaterial1Count;
const int _kMaterial2x2Count = 3;
const int _kMaterial2x3Start = _kMaterial2x2Start + _kMaterial2x2Count;
const int _kMaterial2x3Count = 3;

class MaterialSection extends StatelessWidget {
  const MaterialSection(
      {super.key,
      required this.type,
      required this.gameState,
      required this.getCard});

  final String type;
  final GameState gameState;
  final LootCard? Function(String, int) getCard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LootTypeHeader(type: type, amount: "1"),
      LootCardRow(
          type: type,
          start: 0,
          count: _kMaterial1Count,
          gameState: gameState,
          getCard: getCard),
      const Divider(),
      LootTypeHeader(type: type, amount: l10n.lootAmount2For2),
      LootCardRow(
          type: type,
          start: _kMaterial2x2Start,
          count: _kMaterial2x2Count,
          gameState: gameState,
          getCard: getCard),
      const Divider(),
      LootTypeHeader(type: type, amount: l10n.lootAmount2For23),
      LootCardRow(
          type: type,
          start: _kMaterial2x3Start,
          count: _kMaterial2x3Count,
          gameState: gameState,
          getCard: getCard),
      const Divider(),
    ]);
  }
}
