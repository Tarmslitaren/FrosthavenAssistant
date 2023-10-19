import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import '../Resource/state/modifier_deck_state.dart';

class ModifierCardWidget extends StatefulWidget {
  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);
  final String name;

  ModifierCardWidget(
      {Key? key,
      required this.card,
      required bool revealed,
      required this.name})
      : super(key: key) {
    this.revealed.value = revealed;
  }

  @override
  ModifierCardWidgetState createState() => ModifierCardWidgetState();

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
          //height: 56,
          //height: 123 * tempScale * scale,
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
}

class ModifierCardWidgetState extends State<ModifierCardWidget> {
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
        ? ModifierCardWidget.buildFront(
            widget.card, settings.userScalingBars.value)
        : ModifierCardWidget.buildRear(
            settings.userScalingBars.value, widget.name);
  }
}
