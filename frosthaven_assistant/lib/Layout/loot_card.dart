import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/state/game_state.dart';

class LootCardWidget extends StatelessWidget {
  final LootCard card;
  final revealed = ValueNotifier<bool>(false);

  LootCardWidget({super.key, required this.card, required bool revealed}) {
    this.revealed.value = revealed;
  }

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
              child: Image.asset(
                "assets/images/loot/${card.gfx}.png",
                filterQuality: FilterQuality.medium,
                //cacheWidth: Platform.isIOS || Platform.isAndroid ? 250 : 250,
                fit: BoxFit.cover,
                //image: AssetImage("assets/images/loot/${card.gfx}.png"),
              ),
            ),
            if (value != null)
              Text(
                "+$value",
                style: TextStyle(
                  shadows: [shadow],
                  fontSize: 30 * scale,
                  color: Colors.white,
                ),
              ),
            if (card.gfx.contains("1418"))
              Text(
                "1418",
                style: TextStyle(
                  shadows: [shadow],
                  fontSize: 25 * scale,
                  color: Colors.white,
                ),
              ),
            if (card.gfx.contains("1419"))
              Text(
                "1419",
                style: TextStyle(
                  shadows: [shadow],
                  fontSize: 25 * scale,
                  color: Colors.white,
                ),
              ),
            if (card.enhanced > 0)
              Positioned(
                bottom: 5 * scale,
                child: getIt<Settings>().shimmer.value == true
                    ? AnimatedTextKit(
                        repeatForever: true,
                        //pause: const Duration(milliseconds: textAnimationDelay),
                        animatedTexts: [
                          ColorizeAnimatedText(
                            "Enhanced: ${card.enhanced.toString()}",
                            speed: Duration(milliseconds: (350).ceil()),
                            textStyle: TextStyle(
                              fontSize: 9 * scale,
                            ),
                            colors: [
                              Colors.white,
                              Colors.white,
                              Colors.blueGrey,
                              Colors.white,
                              Colors.blueGrey,
                              Colors.white,
                              Colors.blueGrey,
                              Colors.white,
                            ],
                          ),
                        ],
                        // isRepeatingAnimation: true,
                      )
                    : Text("Enhanced: ${card.enhanced.toString()}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9 * scale,
                        )),
              ),
            if (card.owner != "")
              Positioned(
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
        ? LootCardWidget.buildFront(card, settings.userScalingBars.value)
        : LootCardWidget.buildRear(settings.userScalingBars.value);
  }
}
