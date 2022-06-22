import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';

import '../Resource/game_methods.dart';
import '../Resource/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'menus/main_menu.dart';

Widget createLevelWidget(BuildContext context) {
  GameState _gameState = getIt<GameState>();

  var textStyle = const TextStyle(
      //fontFamily: 'Majalla',
      color: Colors.white,
      //fontWeight: FontWeight.bold,
      //backgroundColor: Colors.transparent.withAlpha(100),
      fontSize: 15.5,
      shadows: [
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 3.0,
          color: Colors.black
        ),
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 8.0,
          color: Colors.black
        ),
        //Shadow(offset: Offset(1, 1),blurRadius: 2, color: Colors.black)
      ]);

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
                    style: textStyle,
                  ));
            }),
        ValueListenableBuilder<int>(
            valueListenable: _gameState.level,
            builder: (context, value, child) {
              return Text.rich(
                //textAlign: textAlign,
                TextSpan(
                  children:[
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        style: textStyle,
                        child: const Image(
                          height: 15.5,
                          image: AssetImage("assets/images/psd/level.png"),
                        )
                    ),
                    TextSpan(
                        text: " : ${_gameState.level.value} ", style: textStyle,
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        style: textStyle,
                        child: const Image(
                          height: 15.5,
                          image: AssetImage("assets/images/psd/traps.png"),
                        )
                    ),
                    TextSpan(
                      text: " : ${GameMethods.getTrapValue()} / ${GameMethods.getHazardValue()} ", style: textStyle,
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        style: textStyle,
                        child: const Image(
                          height: 15.5,
                          image: AssetImage("assets/images/psd/xp.png"),
                        )
                    ),
                    TextSpan(
                      text: " : ${GameMethods.getXPValue()} ", style: textStyle,
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        style: textStyle,
                        child: const Image(
                          height: 15.5,
                          image: AssetImage("assets/images/psd/coins.png"),
                        )
                    ),
                    TextSpan(
                      text: " : ${GameMethods.getCoinValue()}", style: textStyle,
                    ),
                  ]
                ),
              );

                Text(
                  "level: ${_gameState.level.value} trap: ${GameMethods.getTrapValue()} hazard: ${GameMethods.getHazardValue()} xp: +${GameMethods.getXPValue()} coin: x${GameMethods.getCoinValue()}",
              style: textStyle,);
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
        //color: Theme.of(context).primaryColor,
        color: Colors.black,
        image: DecorationImage(
            colorFilter:  ColorFilter.mode(Colors.black.withOpacity(0.85),
                BlendMode.dstATop),
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
