import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/services/network/network_ui.dart';

import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'modifier_deck_widget.dart';


String formattedScenarioName(GameState gameState) {
  String scenario = gameState.scenario.value;
  if (gameState.currentCampaign.value == "Solo") {
    return scenario.split(':')[1];
  }
  return scenario;
}

Widget createLevelWidget(BuildContext context) {
  GameState gameState = getIt<GameState>();
  Settings settings = getIt<Settings>();

  double fontHeight = 14 * settings.userScalingBars.value;

  var shadow = Shadow(
    offset: Offset(
        1 * settings.userScalingBars.value, 1 * settings.userScalingBars.value),
    color: Colors.black87,
    blurRadius: 1 * settings.userScalingBars.value,
  );

  var textStyle = TextStyle(
      color: settings.darkMode.value ? Colors.white : Colors.black,
      overflow: TextOverflow.fade,
      fontSize: fontHeight,
      shadows: settings.darkMode.value
          ? [shadow]
          : [
        Shadow(
            offset: Offset(1.0 * settings.userScalingBars.value,
                1.0 * settings.userScalingBars.value),
            blurRadius: 3.0 * settings.userScalingBars.value,
            color: Colors.white),
        Shadow(
            offset: Offset(1.0 * settings.userScalingBars.value,
                1.0 * settings.userScalingBars.value),
            blurRadius: 8.0 * settings.userScalingBars.value,
            color: Colors.white),
      ]);

  return Material(
    color: Colors.transparent,
      child :InkWell(
    onTap: () {
      //open stats menu
      openDialog(
        context,
        const SetLevelMenu(),
      );
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<String>(
            valueListenable: gameState.scenario,
            builder: (context, value, child) {
              return SizedBox(
                  width: 174 * settings.userScalingBars.value,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    formattedScenarioName(gameState),
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ));
            }),
        ValueListenableBuilder<int>(
            valueListenable: gameState.level,
            builder: (context, value, child) {
              const double blurRadius = 3.0;
              const double spreadRadius = 1.0;
              const double opacity = 0.3;
              return Text.rich(
                TextSpan(children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(opacity),
                                spreadRadius: spreadRadius,
                                blurRadius: blurRadius * settings.userScalingBars.value,
                              ),
                            ],
                          ),
                          child: Image(
                            height: fontHeight * 0.6,
                            filterQuality: FilterQuality
                                .medium, //needed because of the edges
                            image: const AssetImage("assets/images/psd/level.png"),
                          ))),
                  TextSpan(
                    text: ": ${gameState.level.value} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(opacity),
                                spreadRadius: spreadRadius,
                                blurRadius: blurRadius * settings.userScalingBars.value,
                              ),
                            ],
                          ),
                          child: Image(
                            height: fontHeight,
                            filterQuality: FilterQuality
                                .medium, //needed because of the edges
                            image: const AssetImage(
                                "assets/images/psd/traps-fh.png"),
                          ))),
                  TextSpan(
                    text: ": ${GameMethods.getTrapValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(opacity),
                                spreadRadius: spreadRadius,
                                blurRadius: blurRadius * settings.userScalingBars.value,
                              ),
                            ],
                          ),
                          child: Image(
                            height: fontHeight,
                            filterQuality: FilterQuality
                                .medium, //needed because of the edges
                            image: const AssetImage(
                                "assets/images/psd/hazard-fh.png"),
                          ))),
                  TextSpan(
                    text: ": ${GameMethods.getHazardValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(opacity),
                                spreadRadius: spreadRadius,
                                blurRadius: blurRadius * settings.userScalingBars.value,
                              ),
                            ],
                          ),
                          child: Image(
                            height: fontHeight * 0.9,
                            filterQuality: FilterQuality
                                .medium, //needed because of the edges
                            image: const AssetImage("assets/images/psd/xp.png"),
                          ))),
                  TextSpan(
                    text: ": +${GameMethods.getXPValue()} ",
                    style: textStyle,
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      style: textStyle,
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(opacity),
                                spreadRadius: spreadRadius,
                                blurRadius: blurRadius * settings.userScalingBars.value,
                              ),
                            ],
                          ),
                          child: Image(
                            height: fontHeight,
                            filterQuality: FilterQuality
                                .medium, //needed because of the edges
                            image: const AssetImage(
                                "assets/images/psd/coins-fh.png"),
                          ))),
                  TextSpan(
                    text: ": x${GameMethods.getCoinValue()}",
                    style: textStyle,
                  ),
                ]),
              );
            }),
      ],
    ),
  ));
}

Widget createBottomBar(BuildContext context) {
  Settings settings = getIt<Settings>();
  return ValueListenableBuilder<double>(
      valueListenable: settings.userScalingBars,
      builder: (context, value, child) {
        return SizedBox(
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
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, -4), // Shadow position
                              )
                            ],
                            image: DecorationImage(
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
                              const NetworkUI(),
                              modifiersFitOnBar(context) && getIt<Settings>().showAmdDeck.value
                                  ? const ModifierDeckWidget(name: '',)
                                  : Container()
                            ],
                          ));
                    }),
              )
            ]));
      });
}
