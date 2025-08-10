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
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                            width: MediaQuery.of(context).size.width,
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
                                const BottomBarLevelWidget(),
                                const NetworkUI(),
                                if (modifiersFitOnBar(context) &&
                                    getIt<Settings>().showAmdDeck.value &&
                                    getIt<GameState>().currentCampaign.value !=
                                        "Buttons and Bugs") //hide amd deck for buttons and bugs
                                  const ModifierDeckWidget(
                                    name: '',
                                  )
                              ],
                            ));
                      }),
                )
              ]));
        });
  }
}
