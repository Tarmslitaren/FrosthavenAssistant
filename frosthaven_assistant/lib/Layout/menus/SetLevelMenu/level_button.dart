import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../Resource/commands/set_level_command.dart';

class LevelButton extends StatelessWidget {
  const LevelButton({
    super.key,
    required this.nr,
    required this.scale,
    required this.monster,
    required this.gameState,
    required this.settings,
  });

  final int nr;
  final double scale;
  final Monster? monster;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: gameState.solo,
        builder: (context, value, child) {
          return ValueListenableBuilder<int>(
              valueListenable: gameState.level,
              builder: (context, value, child) {
                bool isCurrentlySelected = monster != null
                    ? nr == monster?.level.value
                    : nr == gameState.level.value;
                bool isRecommended = GameMethods.getRecommendedLevel() == nr;
                Color color = Colors.transparent;
                if (isRecommended) {
                  color = Colors.grey;
                }
                String text = nr.toString();
                bool darkMode = settings.darkMode.value;
                Color shadowColor = isCurrentlySelected && !darkMode
                    ? Colors.grey
                    : Colors.black;
                Color selectedTextColor =
                    darkMode ? Colors.white : Colors.black;
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
                                    offset: Offset(kShadowOffset * scale,
                                        kShadowOffset * scale),
                                    color: shadowColor)
                              ],
                              color: textColor),
                        ),
                        onPressed: () {
                          if (!isCurrentlySelected) {
                            String? monsterId = monster?.id;
                            gameState.action(SetLevelCommand(nr, monsterId));
                          }
                          Navigator.pop(context);
                        },
                      )),
                );
              });
        });
  }
}
