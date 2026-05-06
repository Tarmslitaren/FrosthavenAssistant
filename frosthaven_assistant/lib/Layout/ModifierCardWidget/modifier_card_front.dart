import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Layout/view_models/modifier_card_front_view_model.dart';

const double _kCardHeight = 39.0;
const double _kMarkerBgSize = 10.0;
const double _kMarkerBgTopDivisor = 2.0;
const double _kMarkerBgLeft = 3.0;
const double _kMarkerTopNumerator = 53.0;
const double _kMarkerIconSize = 7.5;
const double _kMarkerIconTopNumerator = 55.5;
const double _kMarkerIconLeft = 4.2;

class ModifierCardFront extends StatelessWidget {
  const ModifierCardFront({
    super.key,
    required this.card,
    required this.name,
    required this.scale,
  });

  final ModifierCard card;
  final String name;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final vm = ModifierCardFrontViewModel(card: card, name: name);

    return RepaintBoundary(
        child: Container(
            width: kModifierCardBaseWidth * scale,
            height: _kCardHeight * scale,
            decoration: BoxDecoration(
              boxShadow: [cardBoxShadow(scale)],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(kCardBorderRadius * scale)),
                  child: Image(
                    fit: BoxFit.fitHeight,
                    image: AssetImage(vm.gfx),
                  ),
                ),
                if (vm.hasExtra)
                  Positioned(
                    height: _kMarkerBgSize * scale,
                    width: _kMarkerBgSize * scale,
                    top: _kMarkerTopNumerator * scale / _kMarkerBgTopDivisor,
                    left: _kMarkerBgLeft * scale,
                    child: Image.asset(
                        'assets/images/attack/class-marker-background.png'),
                  ),
                if (vm.hasExtra)
                  Positioned(
                    height: _kMarkerIconSize * scale,
                    width: _kMarkerIconSize * scale,
                    top: _kMarkerIconTopNumerator * scale / _kMarkerBgTopDivisor,
                    left: _kMarkerIconLeft * scale,
                    child: Image(
                      color: Colors.white,
                      image: AssetImage(vm.extraGfx),
                    ),
                  ),
              ],
            )));
  }
}
