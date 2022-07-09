import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';
import '../Resource/modifier_deck_state.dart';

double tempScale = 0.8;

class ModifierCardWidget extends StatefulWidget {
  final ModifierCard card;
  bool revealed;

  ModifierCardWidget({Key? key, required this.card, required this.revealed}) : super(key: key);

  @override
  ModifierCardWidgetState createState() => ModifierCardWidgetState();

  static Widget buildFront(ModifierCard card, double scale) {
    return Container(
      //margin: EdgeInsets.all(2),
      width: 88,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0 ),
        child: Image(
          //height: 56,
          //height: 123 * tempScale * scale,
          image: AssetImage("assets/images/attack/${card.gfx}.png"),
        ),
      ),
    );
  }

  static Widget buildRear(double scale) {
    return Container(
      key: const ValueKey<int>(0),
      //margin: EdgeInsets.onl(2),
      width: 88,
      //this evaluates to same space as front somehow.
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image(
          //height: 56,
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

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
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
    return  AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: _transitionBuilder,
          layoutBuilder: (widget, list) => Stack(
            children: [widget!, ...list],
          ),
          //switchInCurve: Curves.easeInBack,
          //switchOutCurve: Curves.easeInBack.flipped,
          child: widget.revealed
              ? ModifierCardWidget.buildFront(widget.card, scale)
              : ModifierCardWidget.buildRear(scale),
          //AnimationController(duration: Duration(seconds: 1), vsync: 0);
          //CurvedAnimation(parent: null, curve: Curves.easeIn)
          //),
        );
  }
}
