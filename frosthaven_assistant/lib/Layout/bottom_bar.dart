import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';

import '../Resource/game_state.dart';
import '../services/service_locator.dart';


Widget createBottomBar(BuildContext context) {
  GameState _gameState = getIt<GameState>();
  return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .primaryColor,
        image: const DecorationImage(
            image: AssetImage('assets/images/psd/frosthaven-bar.png'),
            //fit: BoxFit.fitHeight,
            repeat: ImageRepeat.repeat
        ),
      ),
      child: Row(
        children: [
          const DrawButton(),
          Column(
            children: [
              ValueListenableBuilder<String>(
                  valueListenable: _gameState.scenario,
                  builder: (context, value, child) {
                    return
                      Text(
                          _gameState.scenario.value
                      );
                  }),
              Text("level: 1 trap: 2 hazard: 1 xp: +4 coin: x2"),
            ],
          ),

        ],
      )

  );
}