import 'dart:math';

import 'package:flutter/material.dart';

import '../../../Resource/state/game_state.dart';
import '../../ModifierCardWidget/modifier_card_front.dart';
import '../../ModifierCardWidget/modifier_card_rear.dart';

class ModifierDeckItem extends StatelessWidget {
  static const double _kItemBaseHeight = 40.0;
  static const double _kItemHeightCount = 12.0;
  static const double _kItemMarginMultiplier = 2.0;

  const ModifierDeckItem({
    super.key,
    required this.data,
    required this.revealed,
    required this.name,
  });

  final ModifierCard data;
  final bool revealed;
  final String name;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double scale =
        max(screenSize.height / (_kItemBaseHeight * _kItemHeightCount), 1);
    final Widget child = revealed
        ? ModifierCardFront(card: data, name: name, scale: scale)
        : ModifierCardRear(scale: scale, name: name);

    return Container(
        margin: EdgeInsets.all(_kItemMarginMultiplier * scale), child: child);
  }
}
