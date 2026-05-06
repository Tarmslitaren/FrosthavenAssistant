import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/state/game_state.dart';
import 'modifier_card_front.dart';
import 'modifier_card_rear.dart';

class ModifierCardWidget extends StatelessWidget {
  ModifierCardWidget(
      {super.key,
      required this.card,
      required bool revealed,
      required this.name,
      this.settings}) {
    this.revealed.value = revealed;
  }

  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);
  final String name;
  final Settings? settings;

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, kHalfPi);
          return Transform(
            transform: Matrix4.rotationX(value),
            alignment: Alignment.center,
            child: widget,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userScalingBars =
        (settings ?? getIt<Settings>()).userScalingBars.value;
    return revealed.value
        ? ModifierCardFront(card: card, name: name, scale: userScalingBars)
        : ModifierCardRear(scale: userScalingBars, name: name);
  }
}
