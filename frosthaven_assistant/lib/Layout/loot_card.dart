import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import '../Resource/state/loot_deck_state.dart';

class LootCardWidget extends StatefulWidget {
  final LootCard card;
  final revealed = ValueNotifier<bool>(false);

  LootCardWidget({Key? key, required this.card, required bool revealed})
      : super(key: key) {
    this.revealed.value = revealed;
  }

  @override
  LootCardWidgetState createState() => LootCardWidgetState();

  static Widget buildFront(LootCard card, double scale) {
    var shadow = Shadow(
      offset: Offset(0.6 * scale, 0.6 * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );
    int? value = card.getValue();
    return Container(
      width: 39 * scale,
      height: 58.6666 * scale,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * scale,
            offset: Offset(2 * scale, 4 * scale), // Shadow position
          ),
        ],
      ),
      child: Stack(
          //fit: StackFit.loose,
          alignment: AlignmentDirectional.center,
          clipBehavior: Clip.none, //if text overflows it still visible

          children: [
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(4.0 * scale),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/loot/${card.gfx}.png"),
              ),
            ),
            if (value != null) Text(
              "+$value",
              style: TextStyle(
                shadows: [shadow],
                fontSize: 30 * scale,
                color: Colors.white,
              ),
            ),
            if (card.gfx.contains("1418")) Text(
              "1418",
              style: TextStyle(
                shadows: [shadow],
                fontSize: 25 * scale,
                color: Colors.white,
              ),
            ),
            if (card.gfx.contains("1419")) Text(
              "1419",
              style: TextStyle(
                shadows: [shadow],
                fontSize: 25 * scale,
                color: Colors.white,
              ),
            ),
            if (card.owner != "" ) Positioned(
              height: 15 * scale,
              width: 15 * scale,
              top: 2 * scale,
              right: 2 * scale,
              child: Image.asset(
                 fit: BoxFit.scaleDown,
                  color: Colors.black,
                  'assets/images/class-icons/${card.owner}.png'),
            )
          ]),
    );
  }

  static Widget buildRear(double scale) {
    return Container(
      width: 39 * scale,
      height: 58.6666 * scale,
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
        child: const Image(
          fit: BoxFit.fitHeight,
          image: AssetImage("assets/images/loot/back.png"),
        ),
      ),
    );
  }
}

class LootCardWidgetState extends State<LootCardWidget> {
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
    Settings settings = getIt<Settings>();
    return widget.revealed.value
        ? LootCardWidget.buildFront(widget.card, settings.userScalingBars.value)
        : LootCardWidget.buildRear(settings.userScalingBars.value);
  }
}
