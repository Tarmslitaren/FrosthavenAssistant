import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../health_wheel_controller.dart';
import '../menus/StatusMenu/status_menu.dart';
import '../view_models/monster_box_view_model.dart';
import 'monster_box_body.dart';

class MonsterBox extends StatelessWidget {
  static const double conditionSize = 14;
  static const double _kBaseWidth = 47.0;
  static const double _kAnimationOffset = 30.0;
  static const int _kFlipAnimationDurationMs = 600;
  static const int _kConditionRowDivisor = 2;

  MonsterBox(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.displayStartAnimation,
      required this.blockInput,
      required this.scale,
      this.gameState,
      this.settings})
      : data = _resolveData(ownerId, figureId);

  static MonsterInstance _resolveData(String? ownerId, String figureId) {
    final figure = GameMethods.getFigure(ownerId, figureId);
    if (figure is! MonsterInstance) {
      throw StateError(
          'MonsterBox: expected MonsterInstance for $ownerId/$figureId, got ${figure.runtimeType}');
    }
    return figure;
  }

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  static double getWidth(double scale, MonsterInstance data) {
    double width = _kBaseWidth;
    final length = data.conditions.value.length;
    width += conditionSize * length / _kConditionRowDivisor;
    if (length % _kConditionRowDivisor != 0) {
      width += conditionSize / _kConditionRowDivisor;
    }
    width = width * scale;
    return width;
  }

  final String figureId;
  final String? ownerId;
  final String displayStartAnimation;
  final bool blockInput;
  final double scale;

  final MonsterInstance data;

  @override
  Widget build(BuildContext context) {
    final vm = MonsterBoxViewModel(data,
        ownerId: ownerId, gameState: gameState, settings: settings);
    final width = MonsterBox.getWidth(scale, data);

    Widget innerWidget = RepaintBoundary(
      child: AnimatedContainer(
          key: Key(data.getId()),
          width: width,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: kAnimationDurationMs),
          child: ValueListenableBuilder<int>(
              valueListenable: data.health,
              builder: (context, value, child) {
                final alive = vm.isAlive;
                final double offset = -_kAnimationOffset * scale;
                final child = MonsterBoxBody(
                    scale: scale, width: width, data: data, vm: vm);

                if (displayStartAnimation != figureId) {
                  return TweenAnimationBuilder<Offset>(
                      tween: Tween(
                        begin: Offset.zero,
                        end: (!alive && !blockInput)
                            ? Offset(0, -offset)
                            : Offset.zero,
                      ),
                      duration: const Duration(
                          milliseconds: _kFlipAnimationDurationMs),
                      curve: Curves.linear,
                      builder: (context, translation, _) => Transform.translate(
                          offset: translation, child: child));
                }

                return TweenAnimationBuilder<Offset>(
                    tween: Tween(
                      begin: Offset(0, alive ? offset : 0),
                      end: Offset(0, alive ? 0 : -offset),
                    ),
                    duration:
                        const Duration(milliseconds: _kFlipAnimationDurationMs),
                    curve: Curves.linear,
                    builder: (context, translation, _) => Transform.translate(
                        offset: translation,
                        child: AnimatedOpacity(
                          opacity: alive ? 1.0 : 0.0,
                          duration: const Duration(
                              milliseconds: _kFlipAnimationDurationMs),
                          child: child,
                        )));
              })),
    );

    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              if (!blockInput) {
                openDialog(
                  context,
                  StatusMenu(
                      figureId: data.getId(),
                      monsterId: vm.monsterId,
                      characterId: vm.characterId),
                );
              }
            },
            child: vm.useHealthWheel
                ? HealthWheelController(
                    figureId: data.getId(),
                    ownerId: ownerId,
                    child: innerWidget)
                : innerWidget));
  }
}
