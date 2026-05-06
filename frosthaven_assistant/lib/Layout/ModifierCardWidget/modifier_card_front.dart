import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../Resource/game_methods.dart';

const double _kCardHeight = 39.0;
const double _kMarkerBgSize = 10.0;
const double _kMarkerBgTopDivisor = 2.0;
const double _kMarkerBgLeft = 3.0;
const double _kMarkerTopNumerator = 53.0;
const double _kMarkerIconSize = 7.5;
const double _kMarkerIconTopNumerator = 55.5;
const double _kMarkerIconLeft = 4.2;
const int _kPerkSuffixLength = 2;

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
    bool allies = name == "allies";
    bool isCharacter = name.isNotEmpty && !allies;
    bool imbue = card.gfx.contains("imbue");
    bool imbue2 = card.gfx.contains("imbue2");

    bool hasExtra = card.gfx.startsWith("P") || allies || imbue;
    String gfx = card.gfx;
    String extraGfx = "";
    if (imbue) {
      gfx = gfx.replaceAll("imbue-", "");
      extraGfx = 'assets/images/attack/imbue.png';
      if (imbue2) {
        extraGfx = 'assets/images/attack/advancedImbue.png';
        gfx = gfx.replaceAll("imbue2-", "");
      }
      if (gfx != "plus1") {
        gfx = "perks/$gfx";
      }
    } else if (allies) {
      extraGfx = 'assets/images/attack/allies.png';
    } else if (isCharacter) {
      extraGfx = 'assets/images/class-icons/$name.png';
    }

    if (card.gfx.startsWith("Demons")) {
      gfx = gfx.replaceAll("Demons-", "");
      extraGfx = 'assets/images/demons.png';
      hasExtra = true;
    } else if (card.gfx.startsWith("Merchant-Guild")) {
      gfx = gfx.replaceAll("Merchant-Guild-", "");
      extraGfx = 'assets/images/merchant-guild.png';
      hasExtra = true;
    } else if (card.gfx.startsWith("Military")) {
      gfx = gfx.replaceAll("Military-", "");
      extraGfx = 'assets/images/military.png';
      hasExtra = true;
    }

    if (gfx.startsWith("P")) {
      final character = GameMethods.getCharacterByName(name);
      assert(character != null);
      if (character != null) {
        final perks = character.characterState.useFHPerks.value
            ? character.characterClass.perksFH
            : character.characterClass.perks;
        gfx = gfx.substring(1);
        if (gfx.endsWith("-2")) {
          gfx = gfx.substring(0, gfx.length - _kPerkSuffixLength);
          final int? index = int.tryParse(gfx);
          if (index != null &&
              index >= 0 &&
              index < perks.length &&
              perks[index].add.isNotEmpty) {
            gfx = perks[index].add.last;
          }
        } else {
          final int? index = int.tryParse(gfx);
          if (index != null &&
              index >= 0 &&
              index < perks.length &&
              perks[index].add.isNotEmpty) {
            gfx = perks[index].add.first;
          }
        }
      }
    }

    gfx = "assets/images/attack/$gfx.png";

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
                    image: AssetImage(gfx),
                  ),
                ),
                if (hasExtra)
                  Positioned(
                    height: _kMarkerBgSize * scale,
                    width: _kMarkerBgSize * scale,
                    top: _kMarkerTopNumerator * scale / _kMarkerBgTopDivisor,
                    left: _kMarkerBgLeft * scale,
                    child: Image.asset(
                        'assets/images/attack/class-marker-background.png'),
                  ),
                if (hasExtra)
                  Positioned(
                    height: _kMarkerIconSize * scale,
                    width: _kMarkerIconSize * scale,
                    top: _kMarkerIconTopNumerator * scale / _kMarkerBgTopDivisor,
                    left: _kMarkerIconLeft * scale,
                    child: Image(
                      color: Colors.white,
                      image: AssetImage(extraGfx),
                    ),
                  ),
              ],
            )));
  }
}
