import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';

import '../Resource/game_methods.dart';
import '../Resource/game_state.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'menus/main_menu.dart';
import 'modifier_deck_widget.dart';

Widget createLevelWidget(BuildContext context) {
  GameState _gameState = getIt<GameState>();
  Settings settings = getIt<Settings>();

  double fontHeight = 14 * settings.userScalingBars.value;

  var textStyle = TextStyle(
      //fontFamily: 'Majalla',
      color: Colors.white,
      overflow: TextOverflow.fade,
      //fontWeight: FontWeight.bold,
      //backgroundColor: Colors.transparent.withAlpha(100),
      fontSize: fontHeight,
      shadows: [
        Shadow(
            offset: Offset(1.0 * settings.userScalingBars.value,
                1.0 * settings.userScalingBars.value),
            blurRadius: 3.0 * settings.userScalingBars.value,
            color: Colors.black),
        Shadow(
            offset: Offset(1.0 * settings.userScalingBars.value,
                1.0 * settings.userScalingBars.value),
            blurRadius: 8.0 * settings.userScalingBars.value,
            color: Colors.black),
        //Shadow(offset: Offset(1, 1),blurRadius: 2, color: Colors.black)
      ]);

  return GestureDetector(
    onTap: () {
      //open stats menu
      openDialog(
        context,
        SetLevelMenu(),
      );
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<String>(
            valueListenable: _gameState.scenario,
            builder: (context, value, child) {
              return Container(
                  width: 174 * settings.userScalingBars.value,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
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
                TextSpan(children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Image(
                        height: fontHeight * 0.6,
                        image: AssetImage("assets/images/psd/level.png"),
                      )),
                  TextSpan(
                    text: ": ${_gameState.level.value} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Image(
                        height: fontHeight,
                        image:
                            const AssetImage("assets/images/psd/traps-fh.png"),
                      )),
                  TextSpan(
                    text: ": ${GameMethods.getTrapValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Image(
                        height: fontHeight,
                        image:
                            const AssetImage("assets/images/psd/hazard-fh.png"),
                      )),
                  TextSpan(
                    text: ": ${GameMethods.getHazardValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Image(
                        height: fontHeight * 0.9,
                        image: const AssetImage("assets/images/psd/xp.png"),
                      )),
                  TextSpan(
                    text: ": +${GameMethods.getXPValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Image(
                        height: fontHeight,
                        image:
                            const AssetImage("assets/images/psd/coins-fh.png"),
                      )),
                  TextSpan(
                    text: ": x${GameMethods.getCoinValue()}",
                    style: textStyle,
                  ),
                ]),
              );

              Text(
                "level: ${_gameState.level.value} trap: ${GameMethods.getTrapValue()} hazard: ${GameMethods.getHazardValue()} xp: +${GameMethods.getXPValue()} coin: x${GameMethods.getCoinValue()}",
                style: textStyle,
              );
            })
      ],
    ),
  );
}

Widget createBottomBar(BuildContext context) {
  Settings settings = getIt<Settings>();
  return ValueListenableBuilder<double>(
      valueListenable: settings.userScalingBars,
      builder: (context, value, child) {
        return Container(
            height: 40 * settings.userScalingBars.value,
            child: Stack(children: [
              Positioned(
                bottom: 0,
                left: 0,
                child: ValueListenableBuilder<bool>(
                    valueListenable: getIt<Settings>().darkMode,
                    builder: (context, value, child) {
                      return Container(
                          height: 40 * settings.userScalingBars.value,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                                //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.dstATop),
                                image: AssetImage(getIt<Settings>()
                                        .darkMode
                                        .value
                                    ? 'assets/images/psd/gloomhaven-bar.png'
                                    : 'assets/images/psd/frosthaven-bar.png'),
                                fit: BoxFit.cover,
                                repeat: ImageRepeat.repeatX),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const DrawButton(),
                              createLevelWidget(context),
                              modifiersFitOnBar(context)
                                  ? const ModifierDeckWidget()
                                  : Container()
                            ],
                          ));
                    }),
              )
              //const ModifierDeckWidget(),
            ]));
      });
}
