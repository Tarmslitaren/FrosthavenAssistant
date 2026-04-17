import 'dart:math';

import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';

class CharacterIconWidget extends StatelessWidget {
  static const double _kIconSizeRatio = 0.6;
  static const int _kShattersongColor1 = 0xff759a9d;
  static const int _kShattersongColor2 = 0xffa0a8ac;
  static const double _kShadowAlpha = 0.6;
  static const double _kShadowSpread = 4.0;
  static const double _kMarginLeft = 26.0;
  static const double _kMarginV = 5.0;
  static const double _kShadowBlur = 13.0;
  static const double _kShaderStop1 = 0.0;
  static const double _kShaderStop2 = 0.2;
  static const double _kShaderStop3 = 1.0;

  const CharacterIconWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow,
      required this.scaledHeight,
      required this.isCharacter});
  final Character character;
  final double scale;
  final double scaledHeight;
  final Shadow shadow;
  final bool isCharacter;

  @override
  Widget build(BuildContext context) {
    final className = character.characterClass.name;
    return Container(
        width: scaledHeight * CharacterIconWidget._kIconSizeRatio,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: CharacterIconWidget._kShadowAlpha),
              spreadRadius: CharacterIconWidget._kShadowSpread,
              blurRadius: CharacterIconWidget._kShadowBlur * scale,
            ),
          ],
        ),
        margin: EdgeInsets.only(
            left: CharacterIconWidget._kMarginLeft * scale, top: CharacterIconWidget._kMarginV * scale, bottom: CharacterIconWidget._kMarginV * scale),
        child: className == "Shattersong"
            ? ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                      transform: const GradientRotation(pi * -0.6),
                      colors: [
                        Color(_kShattersongColor1),
                        Color(_kShattersongColor2),
                        Color(_kShattersongColor1),
                      ],
                      stops: const [
                        CharacterIconWidget._kShaderStop1,
                        CharacterIconWidget._kShaderStop2,
                        CharacterIconWidget._kShaderStop3
                      ]).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Image.asset(
                  "assets/images/class-icons/$className.png",
                  height: scaledHeight * CharacterIconWidget._kIconSizeRatio,
                  fit: BoxFit.contain,
                ),
              )
            : Image(
                fit: BoxFit.contain,
                height: scaledHeight * CharacterIconWidget._kIconSizeRatio,
                color: isCharacter ? character.characterClass.color : null,
                filterQuality: FilterQuality.medium,
                width: scaledHeight * CharacterIconWidget._kIconSizeRatio,
                image: AssetImage(
                    "assets/images/class-icons/${character.characterClass.name}.png"),
              ));
  }
}
