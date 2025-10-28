import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class CharacterXPWidget extends StatelessWidget {
  CharacterXPWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow});
  final Character character;
  final double scale;
  final Shadow shadow;
  final GameState _gameState = getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _gameState.action(ChangeXPCommand(1, character.id, character.id));
        },
        onDoubleTap: () {
          if (character.characterState.xp.value > 0) {
            _gameState.action(ChangeXPCommand(-1, character.id, character.id));
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
