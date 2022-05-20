import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';

import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class DrawButton extends StatefulWidget {
  final double height;

  const DrawButton({
    Key? key,
    this.height = 60,
  }) : super(key: key);

  @override
  _DrawButtonState createState() => _DrawButtonState();
}

class _DrawButtonState extends State<DrawButton> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
  }

  void onPressed() {
    if (_gameState.roundState.value == RoundState.chooseInitiative) {
      if (_gameState.canDraw()) {
        _gameState.action(DrawCommand());
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
    return Stack(alignment: Alignment.centerLeft, children: [
      ValueListenableBuilder<RoundState>(
        valueListenable: _gameState.roundState,
        builder: (context, value, child) {
          return TextButton(
              onPressed: onPressed,
              child: Text(
                _gameState.roundState.value == RoundState.chooseInitiative
                    ? "Draw"
                    : " Next\nRound",
                style: const TextStyle(
                  height: 0.8,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(1, 1), color: Colors.black)],
                ),
              ));
        },
      )
    ]);
  }
}
