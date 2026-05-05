import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/set_as_summon_command.dart';
import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';

class StatusMenuSummonButton extends StatelessWidget {
  static const double _kSummonMargin = 1.0;
  static const double _kSummonIconSize = 24.0;
  static const String _kImagePath = "assets/images/summon/green.png";

  const StatusMenuSummonButton({
    super.key,
    required this.figureId,
    required this.ownerId,
    required this.scale,
    required this.gameState,
    required this.settings,
  });

  final String figureId;
  final String? ownerId;
  final double scale;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          FigureState? figure = GameMethods.getFigure(ownerId, figureId);
          if (figure == null) {
            return Container();
          }

          if (figure is! MonsterInstance) return Container();
          bool isActive = figure.roundSummoned != -1;
          if (isActive) {
            color = settings.darkMode.value ? Colors.white : Colors.black;
          }

          return Container(
              width: kConditionButtonSize * scale,
              height: kConditionButtonSize * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(_kSummonMargin * scale),
              decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.all(
                      Radius.circular(kRoundButtonBorderRadius * scale))),
              child: IconButton(
                  icon: isActive
                      ? Image(
                          height: _kSummonIconSize * scale,
                          filterQuality: FilterQuality.medium,
                          image: const AssetImage(_kImagePath))
                      : Image.asset(
                          filterQuality: FilterQuality.medium,
                          height: _kSummonIconSize * scale,
                          width: _kSummonIconSize * scale,
                          _kImagePath),
                  onPressed: () {
                    gameState.action(SetAsSummonCommand(
                        !isActive, figureId, ownerId,
                        gameState: gameState));
                  }));
        });
  }
}
