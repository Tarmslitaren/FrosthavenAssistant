import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

const double _kCardHeight = 39.0;
const double _kRearMarkerBgSize = 27.0;
const double _kRearMarkerBgTop = 5.5;
const double _kRearMarkerBgLeft = 15.7;
const double _kRearMarkerIconSize = 20.0;
const double _kRearMarkerIconTop = 9.0;
const double _kRearMarkerIconLeft = 19.0;

class ModifierCardRear extends StatelessWidget {
  const ModifierCardRear({
    super.key,
    required this.scale,
    required this.name,
  });

  final double scale;
  final String name;

  @override
  Widget build(BuildContext context) {
    bool allies = name == "allies";
    bool isCharacter = name.isNotEmpty && !allies;
    bool hasExtra = isCharacter || allies;
    String extraGfx = "";
    if (allies) {
      extraGfx = 'assets/images/attack/allies.png';
    } else if (isCharacter) {
      extraGfx = 'assets/images/class-icons/$name.png';
    }

    return RepaintBoundary(
        child: Container(
            width: kModifierCardBaseWidth * scale,
            height: _kCardHeight * scale,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: kCardShadowBlur * scale,
                  offset: Offset(kCardShadowOffsetX * scale,
                      kCardShadowOffsetY * scale),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(kCardBorderRadius * scale)),
                  child: Image(
                    fit: BoxFit.fitHeight,
                    image: const AssetImage("assets/images/attack/back.png"),
                  ),
                ),
                if (hasExtra)
                  Positioned(
                    height: _kRearMarkerBgSize * scale,
                    width: _kRearMarkerBgSize * scale,
                    top: _kRearMarkerBgTop * scale,
                    left: _kRearMarkerBgLeft * scale,
                    child: Image(
                      image: AssetImage(
                          'assets/images/attack/class-marker-background.png'),
                    ),
                  ),
                if (hasExtra)
                  Positioned(
                    height: _kRearMarkerIconSize * scale,
                    width: _kRearMarkerIconSize * scale,
                    top: _kRearMarkerIconTop * scale,
                    left: _kRearMarkerIconLeft * scale,
                    child: Image(
                      color: Colors.white,
                      image: AssetImage(extraGfx),
                    ),
                  ),
              ],
            )));
  }
}
