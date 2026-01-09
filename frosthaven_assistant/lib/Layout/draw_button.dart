import 'package:flutter/material.dart';

import '../Resource/commands/draw_command.dart';
import '../Resource/commands/next_round_command.dart';
import '../Resource/enums.dart';
import '../Resource/game_methods.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class DrawButton extends StatefulWidget {
  const DrawButton({
    super.key,
  });

  @override
  DrawButtonState createState() => DrawButtonState();
}

class DrawButtonState extends State<DrawButton> {
  final GameState _gameState = getIt<GameState>();

  void onPressed() {
    if (_gameState.roundState.value == RoundState.chooseInitiative) {
      if (GameMethods.canDraw()) {
        _gameState.action(DrawCommand());
      } else {
        String text =
            "Player Initiative numbers must be set (tap the character icon or under the initiative marker to the right of it)";
        if (_gameState.currentList.isEmpty) {
          text =
              "Add characters first from the side menu (tap the hamburger icon to open)";
        }
        showToast(context, text);
      }
    } else {
      _gameState.action(NextRoundCommand());
    }
  }

  @override
  Widget build(BuildContext context) {
    //TextButton says Draw/Next Round
    //has a turn counter
    //and a timer
    //2 states
    Settings settings = getIt<Settings>();
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          final scaling = settings.userScalingBars.value;
          final shadow = Shadow(
            offset: Offset(1 * scaling, 1 * scaling),
            color: Colors.black87,
            blurRadius: 1 * scaling,
          );

          return Stack(alignment: Alignment.centerLeft, children: [
            ValueListenableBuilder<int>(
              valueListenable: _gameState.round,
              builder: (context, value, child) {
                String text = _gameState.round.value.toString();
                if (_gameState.totalRounds.value != _gameState.round.value) {
                  text = "${"$text(${_gameState.totalRounds.value}"})";
                }
                return Positioned(
                    bottom: 2 * scaling,
                    left: 45 * scaling,
                    child: Text(text,
                        style: TextStyle(
                          fontSize: 14 * scaling,
                          color: Colors.white,
                          shadows: [shadow],
                        )));
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: _gameState.commandIndex,
              builder: (context, value, child) {
                return Container(
                    margin: EdgeInsets.zero,
                    height: 40 * scaling,
                    width:
                        (_gameState.totalRounds.value != _gameState.round.value
                                ? 75
                                : 60) *
                            scaling,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 10 * scaling, right: 10 * scaling),
                            alignment: Alignment.center),
                        onPressed: onPressed,
                        child: Text(
                          _gameState.roundState.value ==
                                  RoundState.chooseInitiative
                              ? "Draw"
                              : " Next Round",
                          style: TextStyle(
                            height: 0.8,
                            fontSize: 16 * scaling,
                            color: Colors.white,
                            shadows: [shadow],
                          ),
                        )));
              },
            )
          ]);
        });
  }
}
