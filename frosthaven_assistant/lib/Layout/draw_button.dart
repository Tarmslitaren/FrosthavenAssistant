import 'package:flutter/material.dart';

import '../Resource/commands/draw_command.dart';
import '../Resource/commands/next_round_command.dart';
import '../Resource/game_methods.dart';
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
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
  }

  void onPressed() {
    if (_gameState.roundState.value == RoundState.chooseInitiative) {
      if (GameMethods.canDraw()) {
        _gameState.action(DrawCommand());
      } else {
        //show toast
        //TODO: show other message if no characters or no monsters
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Player Initiative numbers must be set (under the initiative marker to the right of the character symbol)"),
        ));
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
          return
          Container(
            margin: EdgeInsets.zero,
            width: 60,
            child:
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    //minimumSize: Size(50, 30),
                    //tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center
                     ),

              onPressed: onPressed,
              child: Text(
                _gameState.roundState.value == RoundState.chooseInitiative
                    ? "Draw"
                    : " Next Round",
                style: const TextStyle(
                  height: 0.8,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(1, 1), color: Colors.black)],
                ),
              )));
        },
      )
    ]);
  }
}
