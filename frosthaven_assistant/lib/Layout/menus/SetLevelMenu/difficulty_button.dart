import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../Resource/commands/set_difficulty_command.dart';

class DifficultyButton extends StatelessWidget {
  const DifficultyButton({
    super.key,
    required this.nr,
    required this.scale,
    required this.gameState,
    required this.settings,
  });

  final int nr;
  final double scale;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.difficulty,
        builder: (context, value, child) {
          bool isCurrentlySelected = nr == gameState.difficulty.value;
          Color color = Colors.transparent;
          String text = nr.toString();
          if (nr > 0) {
            text = "+$text";
          }
          bool darkMode = settings.darkMode.value;
          Color shadowColor =
              isCurrentlySelected && !darkMode ? Colors.grey : Colors.black;
          Color selectedTextColor = darkMode ? Colors.white : Colors.black;
          Color textColor =
              isCurrentlySelected ? selectedTextColor : Colors.grey;
          return SizedBox(
            width: kButtonSize * scale,
            height: kButtonSize * scale,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.all(Radius.circular(
                        kRoundButtonBorderRadius * scale))),
                child: TextButton(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: kFontSizeTitle * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(
                                  kShadowOffset * scale, kShadowOffset * scale),
                              color: shadowColor)
                        ],
                        color: textColor),
                  ),
                  onPressed: () {
                    if (!isCurrentlySelected) {
                      gameState.action(
                          SetDifficultyCommand(nr, gameState: gameState));
                    }
                  },
                )),
          );
        });
  }
}
