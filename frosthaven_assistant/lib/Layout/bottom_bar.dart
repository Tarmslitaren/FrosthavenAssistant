import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';

import '../Resource/game_state.dart';
import '../services/service_locator.dart';
import 'menus/main_menu.dart';

Widget createLevelWidget(BuildContext context) {
  GameState _gameState = getIt<GameState>();
  return GestureDetector(
    onVerticalDragStart: (details) {
      //start moving the widget in the list
    },
    onVerticalDragUpdate: (details) {
      //update widget position?
    },
    onVerticalDragEnd: (details) {
      //place back in list
    },
    onTap: () {
      //open stats menu
      openDialog(
        context,
        const Dialog(
          child: SetLevelMenu(),
        ),
      );
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<String>(
            valueListenable: _gameState.scenario,
            builder: (context, value, child) {
              return Container(
                  //color: Colors.amber,
                  width: 200,
                  child: Text(
                    _gameState.scenario.value,
                    textAlign: TextAlign.center,
                  ));
            }),
        ValueListenableBuilder<int>(
            valueListenable: _gameState.level,
            builder: (context, value, child) {
              return Text(
                  "level: ${_gameState.level.value} trap: ${_gameState.getTrapValue()} hazard: ${_gameState.getHazardValue()} xp: +${_gameState.getXPValue()} coin: x${_gameState.getCoinValue()}");
            })
      ],
    ),
  );
}

//TODO: scale: minimum 40 height but scale up
Widget createBottomBar(BuildContext context) {
  GameState _gameState = getIt<GameState>();
  return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: const DecorationImage(
            image: AssetImage('assets/images/psd/frosthaven-bar.png'),
            //fit: BoxFit.fitHeight,
            repeat: ImageRepeat.repeat),
      ),
      child: Row(
        children: [
          const DrawButton(),
          createLevelWidget(context)

          //TODO: monster modifier deck widget
        ],
      ));
}
