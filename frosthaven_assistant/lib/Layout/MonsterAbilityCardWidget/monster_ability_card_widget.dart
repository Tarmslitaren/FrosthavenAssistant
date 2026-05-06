import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../view_models/monster_ability_card_view_model.dart';
import 'monster_ability_card_front.dart';
import 'monster_ability_card_rear.dart';

const int _kAnimationDurationMs = 600;

class MonsterAbilityCardWidget extends StatefulWidget {
  const MonsterAbilityCardWidget({
    super.key,
    required this.data,
    this.gameState,
    this.settings,
  });

  final Monster data;
  final GameState? gameState;
  final Settings? settings;

  @override
  MonsterAbilityCardWidgetState createState() =>
      MonsterAbilityCardWidgetState();
}

class MonsterAbilityCardWidgetState extends State<MonsterAbilityCardWidget> {
  MonsterAbilityCardViewModel? _vmInstance;
  MonsterAbilityCardViewModel get _vm =>
      _vmInstance ??= MonsterAbilityCardViewModel(
        widget.data,
        gameState: widget.gameState,
        settings: widget.settings,
      );

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final value = min(rotateAnim.value, kHalfPi);
        return Transform(
          transform: Matrix4.rotationX(value),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = getScaleByReference(context);
    return ValueListenableBuilder<int>(
      valueListenable: _vm.commandIndex,
      builder: (context, value, child) {
        final showFront = _vm.shouldShowFront;
        final card = _vm.currentCard;

        return InkWell(
          onTap: () {
            setState(() => _vm.openDeckMenu(context));
          },
          onDoubleTap: () {
            if (showFront) {
              setState(() => _vm.openZoom(context));
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: _kAnimationDurationMs),
            transitionBuilder: _transitionBuilder,
            layoutBuilder: (currentWidget, list) =>
                Stack(children: [?currentWidget, ...list]),
            child: showFront && card != null
                ? MonsterAbilityCardFront(
                    card: card,
                    data: widget.data,
                    scale: scale,
                    calculateAll: false,
                  )
                : MonsterAbilityCardRear(
                    scale: scale,
                    size: _vm.deckSize,
                    monster: widget.data,
                  ),
          ),
        );
      },
    );
  }
}
