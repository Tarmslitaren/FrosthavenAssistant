import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';

class CharacterBackgroundWidget extends StatelessWidget {
  const CharacterBackgroundWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow});
  final Character character;
  final double scale;
  final Shadow shadow;

  SweepGradient buildGradiantBackground(List<Color> colors) {
    int nrOfColorEntries = colors.length * 3 + 1;

    List<Color> endList = [];
    for (int i = 0; i < 3; i++) {
      for (Color color in colors) {
        endList.add(color);
      }
    }
    endList.add(colors.first);

    List<double> stops = [];
    stops.add(0);
    for (int i = 1; i < nrOfColorEntries - 1; i++) {
      stops.add(i / nrOfColorEntries);
    }
    stops.add(1);

    return SweepGradient(
        center: FractionalOffset.bottomRight,
        transform: const GradientRotation(2),
        tileMode: TileMode.mirror,
        colors: endList,

        /*[
          Colors.yellow,
          Colors.purple,
          Colors.teal,
          Colors.white24,
          Colors.yellow,
          Colors.purple,
          Colors.teal,
          Colors.white24,
          Colors.yellow,
          Colors.purple,
          Colors.teal,
          Colors.white24,
          Colors.yellow,
        ],*/
        stops: stops
        /* [
          0,
          1 / 13,
          2 / 13,
          3 / 13,
          4 / 13,
          5 / 13,
          6 / 13,
          7 / 13,
          8 / 13,
          9 / 13,
          10 / 13,
          12 / 13,
          1
        ]*/
        );
  }

  @override
  Widget build(BuildContext context) {
    final className = character.characterClass.name;
    final color = character.characterClass.color;
    final colorSecondary = character.characterClass.colorSecondary;

    Gradient? gradient;
    bool hasGradient = false;
    if (className == "Shattersong") {
      gradient = buildGradiantBackground(
          [Colors.yellow, Colors.purple, Colors.teal, Colors.white24]);
      hasGradient = true;
    } else if (className == "Rimehearth") {
      gradient = buildGradiantBackground([colorSecondary, color]);
      hasGradient = true;
    } else if (className == "Elementalist") {
      gradient = buildGradiantBackground(
          [Colors.red, Colors.blue, Colors.green, Colors.yellow]);
      hasGradient = true;
    }

    return Container(
      margin: EdgeInsets.all(2 * scale),
      width: 408 * scale,
      height: 58 * scale,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4 * scale,
            offset: Offset(2 * scale, 4 * scale), // Shadow position
          ),
        ],
        image: DecorationImage(
          fit: BoxFit.fill,
          colorFilter: hasGradient
              ? ColorFilter.mode(color, BlendMode.softLight)
              : ColorFilter.mode(colorSecondary, BlendMode.color),
          image: ResizeImage(AssetImage("assets/images/psd/character-bar.png"),
              width: (408 * scale).toInt(), height: (58 * scale).toInt()),
        ),
        shape: BoxShape.rectangle,
      ),
      child: Container(
          decoration: BoxDecoration(
              backgroundBlendMode: hasGradient ? BlendMode.multiply : null,
              gradient: gradient)),
    );
  }
}
