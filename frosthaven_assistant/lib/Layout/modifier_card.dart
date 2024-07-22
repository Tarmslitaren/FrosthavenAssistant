import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/state/game_state.dart';

class ModifierCardWidget extends StatelessWidget {
  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);
  final String name;

  ModifierCardWidget({super.key, required this.card, required bool revealed, required this.name}) {
    this.revealed.value = revealed;
  }

  static Widget buildFront(ModifierCard card, double scale) {
    return Container(
      width: 58.6666 * scale,
      height: 39 * scale,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * scale,
            offset: Offset(2 * scale, 4 * scale), // Shadow position
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0 * scale),
        child: Image(
          fit: BoxFit.fitHeight,
          image: AssetImage("assets/images/attack/${card.gfx}.png"),
        ),
      ),
    );
  }

  static Widget buildRear(double scale, String name) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return Container(
      width: 58.6666 * scale,
      height: 39 * scale,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * scale,
            offset: Offset(2 * scale, 4 * scale), // Shadow position
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0 * scale),
        child: Image(
          fit: BoxFit.fitHeight,
          image: AssetImage("assets/images/attack/back$suffix.png"),
        ),
      ),
    );
  }

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, pi / 2);
          return Transform(
            transform: Matrix4.rotationX(value),
            alignment: Alignment.center,
            child: widget,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = getIt<Settings>();
    return revealed.value
        ? ModifierCardWidget.buildFront(card, settings.userScalingBars.value)
        : ModifierCardWidget.buildRear(settings.userScalingBars.value, name);
  }
}
