import 'package:flutter/material.dart';

import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import 'menus/set_level_menu.dart';
import 'view_models/bottom_bar_level_widget_view_model.dart';

class BottomBarLevelWidget extends StatelessWidget {
  static const double _kScenarioWidth = 174.0;
  static const double _kLevelIconScale = 0.6;
  static const double _kXpIconScale = 0.9;

  const BottomBarLevelWidget({super.key, this.gameState, this.settings});

  final GameState? gameState;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final vm =
        BottomBarLevelWidgetViewModel(gameState: gameState, settings: settings);

    final userScalingBars = vm.userScalingBars;
    final fontHeight = vm.fontHeight;
    final textStyle = vm.textStyle(userScalingBars);

    return RepaintBoundary(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
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
                      valueListenable: vm.scenario,
                      builder: (context, value, child) {
                        return SizedBox(
                            width: _kScenarioWidth * userScalingBars,
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              vm.formattedScenarioName,
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ));
                      }),
                  ValueListenableBuilder<int>(
                      valueListenable: vm.commandIndex,
                      builder: (context, value, child) {
                        const double blurRadius = 3.0;
                        const double spreadRadius = 1.0;
                        const double opacity = 0.3;
                        final color = Colors.black.withValues(alpha: opacity);
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
                                          blurRadius:
                                              blurRadius * userScalingBars,
                                        ),
                                      ],
                                    ),
                                    child: Image(
                                      height: fontHeight * _kLevelIconScale,
                                      filterQuality: FilterQuality
                                          .medium, //needed because of the edges
                                      image: const AssetImage(
                                          "assets/images/psd/level.png"),
                                    ))),
                            TextSpan(
                              text: ": ${vm.level} ",
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
                                          blurRadius:
                                              blurRadius * userScalingBars,
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
                              text: ": ${vm.trapValue} ",
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
                                          blurRadius:
                                              blurRadius * userScalingBars,
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
                              text: ": ${vm.hazardValue} ",
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
                                          blurRadius:
                                              blurRadius * userScalingBars,
                                        ),
                                      ],
                                    ),
                                    child: Image(
                                      height: fontHeight * _kXpIconScale,
                                      filterQuality: FilterQuality
                                          .medium, //needed because of the edges
                                      image: const AssetImage(
                                          "assets/images/psd/xp.png"),
                                    ))),
                            TextSpan(
                              text: ": +${vm.xpValue} ",
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
                                          blurRadius:
                                              blurRadius * userScalingBars,
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
                              text: ": x${vm.coinValue}",
                              style: textStyle,
                            ),
                          ]),
                        );
                      }),
                ],
              ),
            )));
  }
}
