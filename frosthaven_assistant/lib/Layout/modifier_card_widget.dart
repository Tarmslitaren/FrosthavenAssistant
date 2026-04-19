import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/game_methods.dart';
import '../Resource/state/game_state.dart';

class ModifierCardWidget extends StatelessWidget {
  static const double _kCardWidth = 58.6666;
  static const double _kCardHeight = 39.0;
  static const double _kBorderRadius = 4.0;
  static const double _kShadowBlur = 4.0;
  static const double _kShadowOffsetX = 2.0;
  static const double _kShadowOffsetY = 4.0;
  // Front layout marker icon positions
  static const double _kMarkerBgSize = 10.0;
  static const double _kMarkerBgTopDivisor = 2.0;
  static const double _kMarkerBgLeft = 3.0;
  static const double _kMarkerTopNumerator = 53.0;
  static const double _kMarkerIconSize = 7.5;
  static const double _kMarkerIconTopNumerator = 55.5;
  static const double _kMarkerIconLeft = 4.2;
  // Rear layout class marker positions
  static const double _kRearMarkerBgSize = 27.0;
  static const double _kRearMarkerBgTop = 5.5;
  static const double _kRearMarkerBgLeft = 15.7;
  static const double _kRearMarkerIconSize = 20.0;
  static const double _kRearMarkerIconTop = 9.0;
  static const double _kRearMarkerIconLeft = 19.0;
  static const double _kHalfPi = pi / 2;
  static const int _kPerkSuffixLength = 2; // length of "-2" suffix

  ModifierCardWidget(
      {super.key,
      required this.card,
      required bool revealed,
      required this.name}) {
    this.revealed.value = revealed;
  }

  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);
  final String name;

  Widget transitionBuilder(Widget widget, Animation<double> animation) { // ignore: avoid-returning-widgets, required AnimatedSwitcher callback signature
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, _kHalfPi);
          return Transform(
            transform: Matrix4.rotationX(value),
            alignment: Alignment.center,
            child: widget,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userScalingBars = getIt<Settings>().userScalingBars.value;
    return revealed.value
        ? ModifierCardFront(card: card, name: name, scale: userScalingBars)
        : ModifierCardRear(scale: userScalingBars, name: name);
  }
}

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

    //deal with perks. this part will be subject to change when/if data changes to accommodate building cards from parts
    if (gfx.startsWith("P")) {
      final character = GameMethods.getCharacterByName(name);
      assert(character != null);
      if (character != null) {
        final perks = character.characterState.useFHPerks.value
            ? character.characterClass.perksFH
            : character.characterClass.perks;
        gfx = gfx.substring(1);
        if (gfx.endsWith("-2")) {
          gfx = gfx.substring(0, gfx.length - ModifierCardWidget._kPerkSuffixLength);
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

    return RepaintBoundary(child: Container(
        width: ModifierCardWidget._kCardWidth * scale,
        height: ModifierCardWidget._kCardHeight * scale,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: ModifierCardWidget._kShadowBlur * scale,
              offset: Offset(ModifierCardWidget._kShadowOffsetX * scale, ModifierCardWidget._kShadowOffsetY * scale), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(ModifierCardWidget._kBorderRadius * scale)),
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(gfx),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: ModifierCardWidget._kMarkerBgSize * scale,
                width: ModifierCardWidget._kMarkerBgSize * scale,
                top: ModifierCardWidget._kMarkerTopNumerator * scale / ModifierCardWidget._kMarkerBgTopDivisor,
                left: ModifierCardWidget._kMarkerBgLeft * scale,
                child: Image.asset(
                    'assets/images/attack/class-marker-background.png'),
              ),
            if (hasExtra)
              Positioned(
                height: ModifierCardWidget._kMarkerIconSize * scale,
                width: ModifierCardWidget._kMarkerIconSize * scale,
                top: ModifierCardWidget._kMarkerIconTopNumerator * scale / ModifierCardWidget._kMarkerBgTopDivisor,
                left: ModifierCardWidget._kMarkerIconLeft * scale,
                child: Image(
                  color: Colors.white,
                  image: AssetImage(extraGfx),
                ),
              ),
          ],
        )));
  }
}

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

    return RepaintBoundary(child: Container(
        width: ModifierCardWidget._kCardWidth * scale,
        height: ModifierCardWidget._kCardHeight * scale,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: ModifierCardWidget._kShadowBlur * scale,
              offset: Offset(ModifierCardWidget._kShadowOffsetX * scale, ModifierCardWidget._kShadowOffsetY * scale), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(ModifierCardWidget._kBorderRadius * scale)),
              child: Image(
                fit: BoxFit.fitHeight,
                image: const AssetImage("assets/images/attack/back.png"),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: ModifierCardWidget._kRearMarkerBgSize * scale,
                width: ModifierCardWidget._kRearMarkerBgSize * scale,
                top: ModifierCardWidget._kRearMarkerBgTop * scale,
                left: ModifierCardWidget._kRearMarkerBgLeft * scale,
                child: Image(
                  image: AssetImage(
                      'assets/images/attack/class-marker-background.png'),
                ),
              ),
            if (hasExtra)
              Positioned(
                height: ModifierCardWidget._kRearMarkerIconSize * scale,
                width: ModifierCardWidget._kRearMarkerIconSize * scale,
                top: ModifierCardWidget._kRearMarkerIconTop * scale,
                left: ModifierCardWidget._kRearMarkerIconLeft * scale,
                child: Image(
                  color: Colors.white,
                  image: AssetImage(extraGfx),
                ),
              ),
          ],
        )));
  }
}
