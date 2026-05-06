import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/MonsterAbilityCardWidget/monster_ability_card_front.dart';
import 'package:frosthaven_assistant/Layout/MonsterAbilityCardWidget/monster_ability_card_rear.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

const double _kScaleCardHeight = 40.0;
const int _kScaleCardRows = 14;
const double _kScaleMin = 0.5;
const double _kListWidthRatio = 0.4;

class AbilityCardListItem extends StatelessWidget {
  const AbilityCardListItem({
    super.key,
    required this.data,
    required this.revealed,
    required this.monsterData,
  });

  final MonsterAbilityCardModel data;
  final Monster monsterData;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double scale = max(
        (screenSize.height / (_kScaleCardHeight * _kScaleCardRows)), _kScaleMin);
    if (screenSize.width * _kListWidthRatio < kAbilityCardWidth * scale) {
      scale = screenSize.width * _kListWidthRatio / kAbilityCardWidth;
    }

    return revealed
        ? MonsterAbilityCardFront(
            card: data, data: monsterData, scale: scale, calculateAll: true)
        : MonsterAbilityCardRear(scale: scale, size: -1, monster: monsterData);
  }
}
