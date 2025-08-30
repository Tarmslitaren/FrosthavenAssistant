import 'package:flutter/material.dart';

import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'menus/set_level_menu.dart';

class BottomBarLevelWidget extends StatelessWidget {
  const BottomBarLevelWidget({super.key});

  String formattedScenarioName(GameState gameState) {
    String scenario = gameState.scenario.value;
    if (gameState.currentCampaign.value == "Solo") {
      if (scenario.contains(':')) {
        return scenario.split(':')[1];
      }
    }
    return scenario;
  }

  @override
  Widget build(BuildContext context) {
    GameState gameState = getIt<GameState>();
    Settings settings = getIt<Settings>();

    final userScalingBars = settings.userScalingBars.value;
    double fontHeight = 14 * userScalingBars;

    final shadow = Shadow(
      offset: Offset(1 * userScalingBars, 1 * userScalingBars),
      color: Colors.black87,
      blurRadius: 1 * userScalingBars,
    );

    final darkMode = settings.darkMode.value;
    final textStyle = TextStyle(
        color: darkMode ? Colors.white : Colors.black,
        overflow: TextOverflow.fade,
        fontSize: fontHeight,
        shadows: darkMode
            ? [shadow]
            : [
                Shadow(
                    offset:
                        Offset(1.0 * userScalingBars, 1.0 * userScalingBars),
                    blurRadius: 3.0 * userScalingBars,
                    color: Colors.white),
                Shadow(
                    offset:
                        Offset(1.0 * userScalingBars, 1.0 * userScalingBars),
                    blurRadius: 8.0 * userScalingBars,
                    color: Colors.white),
              ]);

    return Material(
        color: Colors.transparent,
        child: InkWell(
          canRequestFocus: false,
          onTap: () {
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
                        width: 174 * userScalingBars,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          formattedScenarioName(gameState),
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ));
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: gameState.commandIndex,
                  builder: (context, value, child) {
                    const double blurRadius = 3.0;
                    const double spreadRadius = 1.0;
                    const double opacity = 0.3;
                    final color = Colors.black.withOpacity(opacity);
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
                                      color: color,
                                      spreadRadius: spreadRadius,
                                      blurRadius: blurRadius * userScalingBars,
                                    ),
                                  ],
                                ),
                                child: Image(
                                  height: fontHeight * 0.6,
                                  filterQuality: FilterQuality
                                      .medium, //needed because of the edges
                                  image: const AssetImage(
                                      "assets/images/psd/level.png"),
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
                                      color: color,
                                      spreadRadius: spreadRadius,
                                      blurRadius: blurRadius * userScalingBars,
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
                                      color: color,
                                      spreadRadius: spreadRadius,
                                      blurRadius: blurRadius * userScalingBars,
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
                                      color: color,
                                      spreadRadius: spreadRadius,
                                      blurRadius: blurRadius * userScalingBars,
                                    ),
                                  ],
                                ),
                                child: Image(
                                  height: fontHeight * 0.9,
                                  filterQuality: FilterQuality
                                      .medium, //needed because of the edges
                                  image: const AssetImage(
                                      "assets/images/psd/xp.png"),
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
                                      color: color,
                                      spreadRadius: spreadRadius,
                                      blurRadius: blurRadius *
                                          settings.userScalingBars.value,
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
}
