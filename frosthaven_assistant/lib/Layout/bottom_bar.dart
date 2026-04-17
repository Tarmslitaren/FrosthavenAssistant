import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/view_models/bottom_bar_view_model.dart';
import 'package:frosthaven_assistant/services/network/network_ui.dart';

import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import 'bottom_bar_level_widget.dart';
import 'modifier_deck_widget.dart';

class BottomBar extends StatelessWidget {
  static const double _kBarHeight = 40.0;

  const BottomBar({super.key, this.settings, this.gameState});

  final Settings? settings;
  final GameState? gameState;

  @override
  Widget build(BuildContext context) {
    final vm = BottomBarViewModel(settings: settings, gameState: gameState);
    return ValueListenableBuilder<double>(
        valueListenable: vm.userScalingBars,
        builder: (context, value, child) {
          final barScale = vm.userScalingBars.value;
          return RepaintBoundary(
              child: SizedBox(
                  height: _kBarHeight * barScale,
                  child: Stack(children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ValueListenableBuilder<bool>(
                          valueListenable: vm.darkMode,
                          builder: (context, value, child) {
                            return Container(
                                height: _kBarHeight * barScale,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: vm.backgroundColor,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, -4),
                                    )
                                  ],
                                  image: DecorationImage(
                                      opacity: vm.backgroundOpacity,
                                      image: ResizeImage(
                                          AssetImage(vm.backgroundImagePath),
                                          height: (_kBarHeight * barScale).toInt()),
                                      fit: BoxFit.cover,
                                      repeat: ImageRepeat.repeatX),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const DrawButton(),
                                    BottomBarLevelWidget(),
                                    const NetworkUI(),
                                    if (vm.showModifierDeck(context))
                                      const ModifierDeckWidget(name: '')
                                  ],
                                ));
                          }),
                    )
                  ])));
        });
  }
}
