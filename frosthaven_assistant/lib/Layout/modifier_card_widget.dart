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
      extraGfx = 'assets/images/attack/allies.png';
    } else if (isCharacter) {
      extraGfx = 'assets/images/class-icons/$name.png';
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
          gfx = gfx.substring(0, gfx.length - 2);
          int index = int.parse(gfx);
          gfx = perks[index].add.last;
        } else {
          int index = int.parse(gfx);
          gfx = perks[index].add.first;
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
                image: ResizeImage(AssetImage(gfx),
                    //can't set to actual size, since the scale animation would look crap
                    width: (58.6666 * scale * 4).toInt(),
                    height: (39 * scale * 4).toInt(),
                    policy: ResizeImagePolicy.fit),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: 10 * scale,
                width: 10 * scale,
                top: 53 * scale / 2,
                left: 3 * scale,
                child: Image.asset(
                    'assets/images/attack/class-marker-background.png'),
              ),
            if (hasExtra)
              Positioned(
                height: 7.5 * scale,
                width: 7.5 * scale,
                top: 55.5 * scale / 2,
                left: 4.2 * scale,
                child: Image(
                    color: Colors.white,
                    image: ResizeImage(
                      AssetImage(extraGfx),
                      width: (7.5 * scale).toInt(),
                      height: (7.5 * scale).toInt(),
                    )),
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
                image: ResizeImage(AssetImage("assets/images/attack/back.png"),
                    height: (39 * scale).toInt(),
                    width: (58.6666 * scale).toInt()),
              ),
            ),
            if (hasExtra)
              Positioned(
                height: 27 * scale,
                width: 27 * scale,
                top: 5.5 * scale,
                left: 15.7 * scale,
                child: Image(
                    image: ResizeImage(
                        AssetImage(
                            'assets/images/attack/class-marker-background.png'),
                        width: (27 * scale).toInt(),
                        height: (27 * scale).toInt())),
              ),
            if (hasExtra)
              Positioned(
                height: 20 * scale,
                width: 20 * scale,
                top: 9 * scale,
                left: 19 * scale,
                child: Image(
                    color: Colors.white,
                    image: ResizeImage(
                      AssetImage(extraGfx),
                      width: (20 * scale).toInt(),
                      height: (20 * scale).toInt(),
                    )),
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
