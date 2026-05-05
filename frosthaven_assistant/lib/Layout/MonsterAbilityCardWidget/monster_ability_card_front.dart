import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/line_builder/line_builder.dart';
import '../../Resource/ui_utils.dart';

const double _kCardHeight = 94.4;
const double _kCardImageHeight = 92.8;
const double _kShadowTextOffsetX = 0.6;
const double _kShadowTextOffsetY = 0.6;
const double _kShadowTextBlur = 1.0;
const double _kTitleAreaHeight = 88.0;
const double _kTitleTopFh = 2.0;
const double _kTitleFontSizeFh = 10.0;
const double _kTitleFontSizeGh = 11.2;
const double _kInitLeft = 4.0;
const double _kInitTop = 12.8;
const double _kInitFontSizeFh = 15.0;
const double _kInitFontSizeGh = 16.0;
const double _kCardNrLeft = 4.8;
const double _kCardNrBottom = 0.4;
const double _kCardNrFontSize = 6.4;
const double _kShuffleLeft = 124.0;
const double _kShuffleBottom = 3.2;
const double _kShuffleHeightFactor = 0.13;
const double _kShuffleBaseHeight = 98.4;
const double _kLinesTop = 11.0;
const double _kGfxScaleBase = 0.8;
const double _kGfxScaleAsset = 0.55;
const double _kGfxScaleElement = 0.6;
const double _kDegreesToRadians = 180.0;
const int _kGfxIndex2 = 2;
const int _kGfxIndex3 = 3;

List<Widget> buildGraphicPositionals(
    double scale, List<GraphicPositional> positionals) {
  List<Widget> list = [];
  double cardWidth = kAbilityCardWidth * scale;
  double cardHeight = _kCardHeight * scale;

  for (GraphicPositional item in positionals) {
    double scaleConstant = _kGfxScaleBase * _kGfxScaleAsset;
    if (LineBuilder.isElement(item.gfx)) {
      scaleConstant *= _kGfxScaleElement;
    }

    Positioned pos = Positioned(
        left: item.x * cardWidth,
        top: item.y * cardHeight,
        child: Transform.rotate(
            alignment: Alignment.topLeft,
            angle: item.angle * pi / _kDegreesToRadians,
            child: Transform.scale(
              scale: item.scale * scale * scaleConstant,
              alignment: Alignment.topLeft,
              child: Image.asset("assets/images/abilities/${item.gfx}.png"),
            )));
    list.add(pos);
  }

  return list;
}

class MonsterAbilityCardFront extends StatelessWidget {
  const MonsterAbilityCardFront({
    super.key,
    required this.card,
    required this.data,
    required this.scale,
    required this.calculateAll,
    this.settings,
  });

  final MonsterAbilityCardModel card;
  final Monster data;
  final double scale;
  final bool calculateAll;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final settings_ = settings ?? getIt<Settings>();
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    String initText = card.initiative.toString();
    if (initText.length == 1) {
      initText = "0$initText";
    }

    final shadow = Shadow(
      offset: Offset(_kShadowTextOffsetX * scale, _kShadowTextOffsetY * scale),
      color: Colors.black87,
      blurRadius: _kShadowTextBlur * scale,
    );

    List<Widget> positionals =
        buildGraphicPositionals(scale, card.graphicPositional);

    return RepaintBoundary(
        child: Container(
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
            key: const ValueKey<int>(1),
            margin: EdgeInsets.all(kMonsterCardMargin * scale),
            width: kAbilityCardWidth * scale,
            height: _kCardHeight * scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(kGameCardBorderRadius * scale)),
                  child: Image(
                    fit: BoxFit.fill,
                    height: _kCardImageHeight * scale,
                    width: kAbilityCardWidth * scale,
                    image: AssetImage(frosthavenStyle
                        ? "assets/images/psd/monsterAbility-front_fh.png"
                        : "assets/images/psd/monsterAbility-front.png"),
                  ),
                ),
                Positioned(
                    top: frosthavenStyle ? _kTitleTopFh * scale : 0,
                    child: SizedBox(
                      height: _kTitleAreaHeight * scale,
                      width: kAbilityCardWidth * scale,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            card.title,
                            style: getCardTitleStyle(
                                frosthavenStyle
                                    ? _kTitleFontSizeFh * scale
                                    : _kTitleFontSizeGh * scale,
                                shadow,
                                frosthavenStyle),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    left: _kInitLeft * scale,
                    top: _kInitTop * scale,
                    child: Text(
                      textAlign: TextAlign.center,
                      initText,
                      style: getCardTitleStyle(
                          frosthavenStyle
                              ? _kInitFontSizeFh * scale
                              : _kInitFontSizeGh * scale,
                          shadow,
                          frosthavenStyle),
                    )),
                Positioned(
                    left: _kCardNrLeft * scale,
                    bottom: _kCardNrBottom * scale,
                    child: Text(
                      card.nr.toString(),
                      style: getCardNumberStyle(
                          _kCardNrFontSize * scale, shadow, frosthavenStyle),
                    )),
                card.shuffle
                    ? Positioned(
                        left: _kShuffleLeft * scale,
                        bottom: _kShuffleBottom * scale,
                        child: Image(
                          height: _kShuffleBaseHeight *
                              _kShuffleHeightFactor *
                              scale,
                          fit: BoxFit.cover,
                          image: const AssetImage(
                              "assets/images/abilities/shuffle.png"),
                        ))
                    : Container(),
                if (positionals.isNotEmpty) positionals.first,
                if (positionals.length > 1) positionals[1],
                if (positionals.length > _kGfxIndex2)
                  positionals[_kGfxIndex2],
                if (positionals.length > _kGfxIndex3)
                  positionals[_kGfxIndex3],
                Positioned(
                  top: _kLinesTop * scale,
                  child: SizedBox(
                    height: _kTitleAreaHeight * scale,
                    width: kAbilityCardWidth * scale,
                    child: LineBuilder.createLines(
                        card.lines,
                        false,
                        !settings_.noCalculation.value,
                        calculateAll,
                        data,
                        CrossAxisAlignment.center,
                        scale,
                        false),
                  ),
                )
              ],
            )));
  }
}
