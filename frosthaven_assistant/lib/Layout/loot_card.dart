import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/state/game_state.dart';

class LootCardWidget extends StatelessWidget {
  static const double _kCardWidth = 39.0;
  static const double _kCardHeight = 58.6666;
  static const double _kBorderRadius = 4.0;
  static const double _kShadowBlur = 4.0;
  static const double _kShadowOffsetX = 2.0;
  static const double _kShadowOffsetY = 4.0;
  static const double _kShadowTextOffsetX = 0.6;
  static const double _kShadowTextOffsetY = 0.6;
  static const double _kShadowTextBlur = 1.0;
  static const double _kValueFontSize = 30.0;
  static const double _kSpecialTextFontSize = 25.0;
  static const double _kEnhancedFontSize = 9.0;
  static const double _kEnhancedBottom = 5.0;
  static const int _kAnimationSpeedMs = 350;
  static const double _kOwnerIconSize = 15.0;
  static const double _kOwnerIconTop = 2.0;
  static const double _kOwnerIconRight = 2.0;
  static const double _kHalfPi = pi / 2;

  LootCardWidget({super.key, required this.card, required bool revealed}) {
    this.revealed.value = revealed;
  }

  static Widget buildFront(LootCard card, double scale, bool _,
      {Settings? settings}) {
    settings = settings ?? getIt<Settings>();
    var shadow = Shadow(
      offset: Offset(_kShadowTextOffsetX * scale, _kShadowTextOffsetY * scale),
      color: Colors.black87,
      blurRadius: _kShadowTextBlur * scale,
    );
    int? value = card.getValue();

    return Container(
        width: _kCardWidth * scale,
        height: _kCardHeight * scale,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: _kShadowBlur * scale,
              offset: Offset(_kShadowOffsetX * scale, _kShadowOffsetY * scale), // Shadow position
            ),
          ],
        ),
        child: RepaintBoundary(
          child: Stack(
              alignment: AlignmentDirectional.center,
              clipBehavior: Clip.none, //if text overflows it still visible

              children: [
                RepaintBoundary(
                    child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
                  child: Image(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/loot/${card.gfx}.png"),
                  ),
                )),
                if (value != null)
                  Text(
                    "+$value",
                    style: TextStyle(
                      shadows: [shadow],
                      fontSize: _kValueFontSize * scale,
                      color: Colors.white,
                    ),
                  ),
                if (card.gfx.contains("1418"))
                  Text(
                    "1418",
                    style: TextStyle(
                      shadows: [shadow],
                      fontSize: _kSpecialTextFontSize * scale,
                      color: Colors.white,
                    ),
                  ),
                if (card.gfx.contains("1419"))
                  Text(
                    "1419",
                    style: TextStyle(
                      shadows: [shadow],
                      fontSize: _kSpecialTextFontSize * scale,
                      color: Colors.white,
                    ),
                  ),
                if (card.enhanced > 0)
                  Positioned(
                    bottom: _kEnhancedBottom * scale,
                    child: settings.shimmer.value
                        ? RepaintBoundary(
                            child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              ColorizeAnimatedText(
                                "Enhanced: ${card.enhanced.toString()}",
                                speed: const Duration(milliseconds: _kAnimationSpeedMs),
                                textStyle: TextStyle(
                                  fontSize: _kEnhancedFontSize * scale,
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
                          ))
                        : Text("Enhanced: ${card.enhanced.toString()}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _kEnhancedFontSize * scale,
                            )),
                  ),
                if (card.owner != "")
                  Positioned(
                    height: _kOwnerIconSize * scale,
                    width: _kOwnerIconSize * scale,
                    top: _kOwnerIconTop * scale,
                    right: _kOwnerIconRight * scale,
                    child: Image(
                        fit: BoxFit.scaleDown,
                        color: Colors.black,
                        image: AssetImage(
                            'assets/images/class-icons/${card.owner}.png')),
                  )
              ]),
        ));
  }

  static Widget buildRear(double scale) {
    return RepaintBoundary(
        child: Container(
      width: _kCardWidth * scale,
      height: _kCardHeight * scale,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: _kShadowBlur * scale,
            offset: Offset(_kShadowOffsetX * scale, _kShadowOffsetY * scale), // Shadow position
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
        child: Image(
          fit: BoxFit.fitHeight,
          image: AssetImage("assets/images/loot/back.png"),
        ),
      ),
    ));
  }

  final LootCard card;
  final revealed = ValueNotifier<bool>(false);

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, _kHalfPi);
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
        ? LootCardWidget.buildFront(card, settings.userScalingBars.value, true)
        : LootCardWidget.buildRear(settings.userScalingBars.value);
  }
}
