import 'package:flutter/material.dart';

import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';
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
    return GestureDetector(
        onTap: () {
          ChangeXPCommand(1, character.id, character.id).execute();
        },
        onDoubleTap: () {
          if (character.characterState.xp.value > 0) {
            ChangeXPCommand(-1, character.id, character.id).execute();
          }
        },
        child: Row(
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
        ));
  }
}
