import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Resource/app_constants.dart';
import '../../../Resource/commands/add_condition_command.dart';
import '../../../Resource/commands/remove_condition_command.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/state/game_state.dart';

class StatusMenuStackableConditionButtons extends StatelessWidget {
  static const double _kTextHeight = 0.5;

  const StatusMenuStackableConditionButtons({
    super.key,
    required this.notifier,
    required this.stackableCondition,
    required this.maxValue,
    required this.image,
    required this.figureId,
    required this.ownerId,
    required this.scale,
    required this.gameState,
  });

  final ValueListenable<int> notifier;
  final Condition stackableCondition;
  final int maxValue;
  final String image;
  final String figureId;
  final String? ownerId;
  final double scale;
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
          width: kButtonSize * scale,
          height: kButtonSize * scale,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              onPressed: () {
                if (notifier.value > 0) {
                  gameState.action(RemoveConditionCommand(
                      stackableCondition, figureId, ownerId,
                      gameState: gameState));
                }
              })),
      Stack(children: [
        SizedBox(
          width: kIconSize * scale,
          height: kIconSize * scale,
          child: Image(image: AssetImage(image)),
        ),
        ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (context, value, child) {
              final text = notifier.value == 0 ? "" : notifier.value.toString();
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(text,
                      style: TextStyle(
                          color: Colors.white,
                          height: _kTextHeight,
                          fontSize: kFontSizeBody * scale,
                          shadows: [
                            Shadow(
                              offset: Offset(
                                  kShadowOffset * scale, kShadowOffset * scale),
                              color: Colors.black87,
                              blurRadius: kShadowOffset * scale,
                            )
                          ])));
            })
      ]),
      SizedBox(
          width: kButtonSize * scale,
          height: kButtonSize * scale,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            onPressed: () {
              if (notifier.value < maxValue) {
                gameState.action(AddConditionCommand(
                    stackableCondition, figureId, ownerId,
                    gameState: gameState));
              }
            },
          )),
    ]);
  }
}
