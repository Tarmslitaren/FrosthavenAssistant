import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/services/network/network_ui.dart';

import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../services/service_locator.dart';
import 'bottom_bar_level_widget.dart';
import 'modifier_deck_widget.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, this.settings, this.gameState});

  final Settings? settings;
  final GameState? gameState;

  @override
  Widget build(BuildContext context) {
    final s = this.settings ?? getIt<Settings>();
    final gs = this.gameState ?? getIt<GameState>();
    return ValueListenableBuilder<double>(
        valueListenable: s.userScalingBars,
        builder: (context, value, child) {
          return RepaintBoundary(child:SizedBox(
              height: 40 * s.userScalingBars.value,
              child: Stack(children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: s.darkMode,
                      builder: (context, value, child) {
                        final darkMode = s.darkMode.value;
                        return Container(
                            height: 40 * s.userScalingBars.value,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color:
                                  darkMode ? Colors.black : Colors.transparent,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, -4), // Shadow position
                                )
                              ],
                              image: DecorationImage(
                                  opacity: darkMode ? 0.4 : 1,
                                  image: ResizeImage(
                                      AssetImage(darkMode
                                          ? 'assets/images/psd/gloomhaven-bar.png'
                                          : 'assets/images/psd/frosthaven-bar.png'),
                                      height:
                                          (40 * s.userScalingBars.value)
                                              .toInt()),
                                  fit: BoxFit.cover,
                                  repeat: ImageRepeat.repeatX),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const DrawButton(),
                                BottomBarLevelWidget(),
                                const NetworkUI(),
                                if (modifiersFitOnBar(context) &&
                                    s.showAmdDeck.value &&
                                    gs.currentCampaign.value !=
                                        "Buttons and Bugs") //hide amd deck for buttons and bugs
                                  const ModifierDeckWidget(
                                    name: '',
                                  )
                              ],
                            ));
                      }),
                )
              ])));
        });
  }
}
