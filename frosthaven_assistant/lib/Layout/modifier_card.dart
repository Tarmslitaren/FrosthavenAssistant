import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';
import '../Resource/modifier_deck_state.dart';
import 'modifier_deck_widget.dart';

class ModifierCardWidget extends StatefulWidget {
  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);

  ModifierCardWidget({Key? key, required this.card, required bool revealed}) : super(key: key) {
    this.revealed.value = revealed;
  }

  @override
  ModifierCardWidgetState createState() => ModifierCardWidgetState();

  static Widget buildFront(ModifierCard card, double scale) {
    return Container(
      width: 58.6666 * scale,
      height: 39*scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0* scale),
        child: Image(
          fit: BoxFit.fitHeight,
          //height: 56,
          //height: 123 * tempScale * scale,
          image: AssetImage("assets/images/attack/${card.gfx}.png"),
        ),
      ),
    );
  }

  static Widget buildRear(double scale) {
    return Container(
      width: 58.6666 * scale,
      height: 39*scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0 * scale),
        child: Image(
          fit: BoxFit.fitHeight,
          image: const AssetImage("assets/images/attack/back.png"),
        ),
      ),
    );
  }
}

class ModifierCardWidgetState extends State<ModifierCardWidget> {
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
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
    double scale = getScaleByReference(context);
    return  widget.revealed.value
                ? ModifierCardWidget.buildFront(widget.card, 1)
                : ModifierCardWidget.buildRear(1);
  }
}
