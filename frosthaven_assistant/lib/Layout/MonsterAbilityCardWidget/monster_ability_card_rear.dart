import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/game_methods.dart';

const double _kCardHeight = 94.4;
const double _kCardRearImageHeight = 91.2;
const double _kRearDeckSizeRight = 4.8;
const double _kRearDeckSizeFontSize = 12.8;
const double _kRearShadowOffset = 0.8;

class MonsterAbilityCardRear extends StatelessWidget {
  const MonsterAbilityCardRear({
    super.key,
    required this.scale,
    required this.size,
    required this.monster,
  });

  final double scale;
  final int size;
  final Monster monster;

  @override
  Widget build(BuildContext context) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(monster.type);
    final rearShadow = Shadow(
        offset: Offset(_kRearShadowOffset, _kRearShadowOffset),
        color: Colors.black);
    return Container(
        decoration: BoxDecoration(
          boxShadow: [cardBoxShadow(scale)],
        ),
        key: const ValueKey<int>(0),
        margin: EdgeInsets.all(kMonsterCardMargin * scale),
        width: kAbilityCardWidth * scale,
        height: _kCardHeight * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(kGameCardBorderRadius * scale)),
              child: Image(
                fit: BoxFit.fitHeight,
                height: _kCardRearImageHeight * scale,
                image: AssetImage(frosthavenStyle
                    ? "assets/images/psd/MonsterAbility-back_fh.png"
                    : "assets/images/psd/MonsterAbility-back.png"),
              ),
            ),
            size >= 0
                ? Positioned(
                    right: _kRearDeckSizeRight * scale,
                    bottom: 0,
                    child: Text(
                      size.toString(),
                      style: getCardNumberStyle(
                          _kRearDeckSizeFontSize * scale,
                          rearShadow,
                          frosthavenStyle),
                    ))
                : Container(),
          ],
        ));
  }
}
