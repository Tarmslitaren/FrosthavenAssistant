import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';

class CharacterLevelWidget extends StatelessWidget {
  const CharacterLevelWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow});
  final Character character;
  final double scale;
  final Shadow shadow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(
          height: 12.0 * scale,
          image: const AssetImage("assets/images/psd/level.png"),
        ),
        ValueListenableBuilder<int>(
            valueListenable: character.characterState.level,
            builder: (context, value, child) {
              return Text(
                character.characterState.level.value.toString(),
                style: TextStyle(
                    fontFamily: GameMethods.isFrosthavenStyle(null)
                        ? 'GermaniaOne'
                        : 'Pirata',
                    color: Colors.white,
                    fontSize: 14 * scale,
                    shadows: [shadow]),
              );
            }),
      ],
    );
  }
}
