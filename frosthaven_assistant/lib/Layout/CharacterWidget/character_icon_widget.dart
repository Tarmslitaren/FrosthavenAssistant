import 'dart:math';

import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';

class CharacterIconWidget extends StatelessWidget {
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
        width: scaledHeight * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              spreadRadius: 4,
              blurRadius: 13.0 * scale,
            ),
          ],
        ),
        margin: EdgeInsets.only(
            left: 26 * scale, top: 5 * scale, bottom: 5 * scale),
        child: className == "Shattersong"
            ? ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                      transform: const GradientRotation(pi * -0.6),
                      colors: [
                        Color(int.parse("ff759a9d", radix: 16)),
                        Color(int.parse("ffa0a8ac", radix: 16)),
                        Color(int.parse("ff759a9d", radix: 16)),
                      ],
                      stops: const [
                        0,
                        0.2,
                        1
                      ]).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Image.asset(
                  "assets/images/class-icons/$className.png",
                  height: scaledHeight * 0.6,
                  fit: BoxFit.contain,
                ),
              )
            : Image(
                fit: BoxFit.contain,
                height: scaledHeight * 0.6,
                color: isCharacter ? character.characterClass.color : null,
                filterQuality: FilterQuality.medium,
                width: scaledHeight * 0.6,
                image: ResizeImage(
                  AssetImage(
                      "assets/images/class-icons/${character.characterClass.name}.png"),
                  height: (scaledHeight * 0.6).toInt() * 2,
                )));
  }
}
