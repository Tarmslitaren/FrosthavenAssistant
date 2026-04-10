import 'package:flutter/material.dart';

import '../Resource/app_constants.dart';
import '../Resource/enums.dart';
import '../Resource/game_actions.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class DrawButton extends StatefulWidget {
  const DrawButton({
    super.key,
  
      this.gameState,});

  final GameState? gameState;

  @override
  DrawButtonState createState() => DrawButtonState();
}

class DrawButtonState extends State<DrawButton> {
  late final GameState _gameState;

  void onPressed() {
    final result = runDrawOrNextRoundAction(_gameState);
    final blockedMessage = result.blockedMessage;
    if (blockedMessage != null) {
      showToast(context, blockedMessage);
    }
  }



  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
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

          return RepaintBoundary(
              child: Stack(alignment: Alignment.centerLeft, children: [
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
                          fontSize: kFontSizeSmall * scaling,
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
                            fontSize: kFontSizeBody * scaling,
                            color: Colors.white,
                            shadows: [shadow],
                          ),
                        )));
              },
            )
          ]));
        });
  }
}
