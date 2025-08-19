import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/state/game_state.dart';

class ModifierCardWidget extends StatelessWidget {
  ModifierCardWidget(
      {super.key,
      required this.card,
      required bool revealed,
      required this.name}) {
    this.revealed.value = revealed;
  }

  static Widget buildFront(ModifierCard card, String name, double scale) {
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
      gfx = gfx.replaceAll("-allies", "");
      extraGfx = 'assets/images/attack/allies.png';
    } else if (isCharacter) {
      extraGfx = 'assets/images/class-icons/$name.png';
    }

    //deal with perks. this part will be subject to change when/if data changes to accommodate building cards from parts
    if (gfx.startsWith("P")) {
      final character = GameMethods.getCharacterByName(name);
      assert(character != null);
      if (character != null) {
        gfx = gfx.substring(1);
        if (gfx.endsWith("-2")) {
          gfx = gfx.substring(0, gfx.length - 2);
          int index = int.parse(gfx);
          gfx = character.characterClass.perks[index].add.last;
        } else {
          int index = int.parse(gfx);
          gfx = character.characterClass.perks[index].add.first;
        }
      }
    }

    gfx = "assets/images/attack/$gfx.png";

    return Container(
        width: 58.6666 * scale,
        height: 39 * scale,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4 * scale,
              offset: Offset(2 * scale, 4 * scale), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0 * scale),
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage(gfx),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: 9 * scale,
                width: 9 * scale,
                top: 53 * scale / 2,
                left: 3 * scale,
                child: Image.asset(
                    'assets/images/attack/class-marker-background.png'),
              ),
            if (hasExtra)
              Positioned(
                height: 7 * scale,
                width: 7 * scale,
                top: 55 * scale / 2,
                left: 4 * scale,
                child: Image.asset(color: Colors.white, extraGfx),
              ),
          ],
        ));
  }

  static Widget buildRear(double scale, String name) {
    bool allies = name == "allies";
    bool isCharacter = name.isNotEmpty && !allies;
    bool hasExtra = isCharacter || allies;
    String extraGfx = "";
    if (allies) {
      extraGfx = 'assets/images/attack/allies.png';
    } else if (isCharacter) {
      extraGfx = 'assets/images/class-icons/$name.png';
    }

    return Container(
        width: 58.6666 * scale,
        height: 39 * scale,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4 * scale,
              offset: Offset(2 * scale, 4 * scale), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0 * scale),
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage("assets/images/attack/back.png"),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: 27 * scale,
                width: 27 * scale,
                top: 5.5 * scale,
                left: 15.7 * scale,
                child: Image.asset(
                    'assets/images/attack/class-marker-background.png'),
              ),
            if (hasExtra)
              Positioned(
                height: 20 * scale,
                width: 20 * scale,
                top: 9 * scale,
                left: 19 * scale,
                child: Image.asset(color: Colors.white, extraGfx),
              ),
          ],
        ));
  }

  final ModifierCard card;
  final revealed = ValueNotifier<bool>(false);
  final String name;

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, pi / 2);
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
        ? ModifierCardWidget.buildFront(card, name, userScalingBars)
        : ModifierCardWidget.buildRear(userScalingBars, name);
  }
}
