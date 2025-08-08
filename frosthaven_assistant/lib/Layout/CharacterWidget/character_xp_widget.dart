import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';

class CharacterXPWidget extends StatelessWidget {
  const CharacterXPWidget(
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
          height: 16 * scale,
          color: Colors.blue,
          colorBlendMode: BlendMode.modulate,
          image: const AssetImage("assets/images/psd/xp.png"),
        ),
        ValueListenableBuilder<int>(
            valueListenable: character.characterState.xp,
            builder: (context, value, child) {
              return Text(
                character.characterState.xp.value.toString(),
                style: TextStyle(
                    fontFamily: GameMethods.isFrosthavenStyle(null)
                        ? 'GermaniaOne'
                        : 'Pirata',
                    color: Colors.blue,
                    fontSize: 14 * scale,
                    shadows: [shadow]),
              );
            }),
      ],
    );
  }
}
