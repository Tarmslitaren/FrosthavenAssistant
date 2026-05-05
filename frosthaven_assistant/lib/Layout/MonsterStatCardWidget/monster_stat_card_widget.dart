import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/ui_utils.dart';
import '../menus/stat_card_zoom.dart';
import '../view_models/monster_stat_card_view_model.dart';
import 'monster_stat_card_view.dart';

class MonsterStatCardWidget extends StatelessWidget {
  static const double _kWidgetWidth = 166.0;
  static const double _kButtonBottom = 4.0;
  static const double _kButtonSide = 4.0;
  static const double _kButtonIconSize = 20.0;
  static const double _kButtonPadding = 8.0;

  const MonsterStatCardWidget({
    super.key,
    required this.data,
    this.gameState,
    this.settings,
  });

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  final Monster data;

  @override
  Widget build(BuildContext context) {
    final vm = MonsterStatCardViewModel(data,
        gameState: gameState, settings: settings);
    final settings_ = settings ?? getIt<Settings>();
    double scale = getScaleByReference(context);

    return SizedBox(
        width: _kWidgetWidth * scale,
        child: Stack(children: [
          GestureDetector(
              onDoubleTap: () {
                openDialog(context, StatCardZoom(monster: data));
              },
              child: MonsterStatCardView(
                  data: data,
                  scale: scale,
                  viewModel: vm,
                  settings: settings_)),
          if (!vm.isBoss)
            Positioned(
                bottom: _kButtonBottom * scale,
                left: _kButtonSide * scale,
                child: SizedBox(
                    width: _kButtonIconSize * scale + _kButtonPadding,
                    height: _kButtonIconSize * scale + _kButtonPadding,
                    child: ListenableBuilder(
                        listenable: vm.monsterInstancesNotifier,
                        builder: (context, child) {
                          return IconButton(
                            padding: EdgeInsets.only(
                                right: _kButtonPadding, top: _kButtonPadding),
                            icon: Image.asset(
                                height: _kButtonIconSize * scale,
                                fit: BoxFit.fitHeight,
                                color: vm.allStandeesOut
                                    ? Colors.white24
                                    : Colors.grey,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () => vm.handleAddNormal(context),
                          );
                        }))),
          Positioned(
              bottom: _kButtonBottom * scale,
              right: _kButtonSide * scale,
              child: SizedBox(
                  width: _kButtonIconSize * scale + _kButtonPadding,
                  height: _kButtonIconSize * scale + _kButtonPadding,
                  child: ListenableBuilder(
                      listenable: vm.monsterInstancesNotifier,
                      builder: (context, child) {
                        return IconButton(
                            padding: EdgeInsets.only(
                                left: _kButtonPadding, top: _kButtonPadding),
                            icon: Image.asset(
                                color: vm.allStandeesOut
                                    ? Colors.white24
                                    : Colors.grey,
                                height: _kButtonIconSize * scale,
                                fit: BoxFit.fitHeight,
                                colorBlendMode: BlendMode.modulate,
                                'assets/images/psd/add.png'),
                            onPressed: () => vm.handleAddElite(context));
                      }))),
        ]));
  }
}
