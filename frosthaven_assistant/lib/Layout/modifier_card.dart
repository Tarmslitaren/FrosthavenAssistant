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
  final revealed = ValueNotifier<bool>(false);

  ModifierCardWidget({Key? key, required this.card, required bool revealed}) {
    //super(key: key);
    this.revealed.value = revealed;
  }

  @override
  ModifierCardWidgetState createState() => ModifierCardWidgetState();

  static Widget buildFront(ModifierCard card, double scale) {
    return Container(
      //margin: EdgeInsets.all(2),
      //key: UniqueKey(),
      width: 88,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
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
      key: const ValueKey<int>(0), //with a unique key this would run the switcher animation for 2 backsides
      width: 88,
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
    return ValueListenableBuilder<bool>(
        valueListenable: _gameState.solo, //not needed
        builder: (context, value, child) {
          return AnimatedSwitcher( //wrong place: should add animated switcher as part of animation stack?
            duration: const Duration(milliseconds: 800),
            transitionBuilder: transitionBuilder,
            layoutBuilder: (widget, list) => Stack(
              children: [widget!, ...list],
            ),
            //switchInCurve: Curves.easeInBack,
            //switchOutCurve: Curves.easeInBack.flipped,
            child: widget.revealed.value
                ? ModifierCardWidget.buildFront(widget.card, scale)
                : ModifierCardWidget.buildRear(scale),
            //AnimationController(duration: Duration(seconds: 1), vsync: 0);
            //CurvedAnimation(parent: null, curve: Curves.easeIn)
            //),
          );
        });
  }
}
