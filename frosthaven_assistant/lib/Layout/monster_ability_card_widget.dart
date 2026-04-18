import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/game_methods.dart';
import '../Resource/line_builder/line_builder.dart';
import 'view_models/monster_ability_card_view_model.dart';

class MonsterAbilityCardWidget extends StatefulWidget {
  static const double _kCardWidth = 142.4;
  static const double _kCardHeight = 94.4;
  static const double _kCardImageHeight = 92.8;
  static const double _kCardRearImageHeight = 91.2;
  static const double _kBorderRadius = 8.0;
  static const double _kShadowBlur = 4.0;
  static const double _kShadowOffsetX = 2.0;
  static const double _kShadowOffsetY = 4.0;
  static const double _kShadowTextOffsetX = 0.6;
  static const double _kShadowTextOffsetY = 0.6;
  static const double _kShadowTextBlur = 1.0;
  static const double _kMargin = 1.6;
  static const double _kTitleAreaHeight = 88.0;
  static const double _kTitleTopFh = 2.0;
  static const double _kTitleFontSizeFh = 10.0;
  static const double _kTitleFontSizeGh = 11.2;
  static const double _kInitLeft = 4.0;
  static const double _kInitTop = 12.8;
  static const double _kInitFontSizeFh = 15.0;
  static const double _kInitFontSizeGh = 16.0;
  static const double _kCardNrLeft = 4.8;
  static const double _kCardNrBottom = 0.4;
  static const double _kCardNrFontSize = 6.4;
  static const double _kShuffleLeft = 124.0;
  static const double _kShuffleBottom = 3.2;
  static const double _kShuffleHeightFactor = 0.13;
  static const double _kShuffleBaseHeight = 98.4;
  static const double _kLinesTop = 11.0;
  static const double _kRearDeckSizeRight = 4.8;
  static const double _kRearDeckSizeFontSize = 12.8;
  static const double _kRearShadowOffset = 0.8;
  // Graphic positional scale factors
  static const double _kGfxScaleBase = 0.8;
  static const double _kGfxScaleAsset = 0.55;
  static const double _kGfxScaleElement = 0.6;
  static const double _kDegreesToRadians = 180.0;
  static const double _kHalfPi = pi / 2;
  static const int _kAnimationDurationMs = 600;
  static const int _kGfxIndex2 = 2;
  static const int _kGfxIndex3 = 3;

  const MonsterAbilityCardWidget({
    super.key,
    required this.data,
    this.gameState,
    this.settings,
  });

  static List<Widget> _buildGraphicPositionals(
      double scale, List<GraphicPositional> positionals) {
    List<Widget> list = [];
    double cardWidth = _kCardWidth * scale;
    double cardHeight = _kCardHeight * scale;

    for (GraphicPositional item in positionals) {
      double scaleConstant =
          _kGfxScaleBase * _kGfxScaleAsset; //this is because of the actual size of the assets
      if (LineBuilder.isElement(item.gfx)) {
        //because we added new graphics for these that are bigger
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
                child: Image.asset(
                  "assets/images/abilities/${item.gfx}.png",
                ), //note: default scale is 0.6? since all pngs are uniformly sized (probably)
              )));
      list.add(pos);
    }

    return list;
  }

  static Widget buildFront(MonsterAbilityCardModel? card, Monster data,
      double scale, bool calculateAll,
      {Settings? settings}) {
    settings = settings ?? getIt<Settings>();
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    String initText = card!.initiative.toString();
    if (initText.length == 1) {
      initText = "0$initText";
    }

    var shadow = Shadow(
      offset: Offset(_kShadowTextOffsetX * scale, _kShadowTextOffsetY * scale),
      color: Colors.black87,
      blurRadius: _kShadowTextBlur * scale,
    );

    List<Widget> positionals =
        _buildGraphicPositionals(scale, card.graphicPositional);

    return RepaintBoundary(
        child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: _kShadowBlur * scale,
                  offset: Offset(_kShadowOffsetX * scale, _kShadowOffsetY * scale), // Shadow position
                ),
              ],
            ),
            key: const ValueKey<int>(1),
            margin: EdgeInsets.all(_kMargin * scale),
            width: _kCardWidth * scale,
            height: _kCardHeight * scale,
            child: Stack(
              clipBehavior: Clip.none, //if text overflows it still visible

              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
                  child: Image(
                    fit: BoxFit.fill,
                    height: _kCardImageHeight * scale,
                    width: _kCardWidth * scale,
                    image: AssetImage(frosthavenStyle
                        ? "assets/images/psd/monsterAbility-front_fh.png"
                        : "assets/images/psd/monsterAbility-front.png"),
                  ),
                ),
                Positioned(
                    top: frosthavenStyle ? _kTitleTopFh * scale : 0,
                    child: SizedBox(
                      height: _kTitleAreaHeight * scale,
                      width: _kCardWidth * scale, //needed for line breaks in lines

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                                fontFamily:
                                    frosthavenStyle ? "GermaniaOne" : 'Pirata',
                                color: Colors.white,
                                fontSize:
                                    frosthavenStyle ? _kTitleFontSizeFh * scale : _kTitleFontSizeGh * scale,
                                shadows: [shadow]),
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
                      style: TextStyle(
                          fontFamily:
                              frosthavenStyle ? "GermaniaOne" : 'Pirata',
                          color: Colors.white,
                          fontSize: frosthavenStyle ? _kInitFontSizeFh * scale : _kInitFontSizeGh * scale,
                          shadows: [shadow]),
                    )),
                Positioned(
                    left: _kCardNrLeft * scale,
                    bottom: _kCardNrBottom * scale,
                    child: Text(
                      card.nr.toString(),
                      style: TextStyle(
                          fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                          color: Colors.white,
                          fontSize: _kCardNrFontSize * scale,
                          shadows: [shadow]),
                    )),
                card.shuffle
                    ? Positioned(
                        left: _kShuffleLeft * scale,
                        bottom: _kShuffleBottom * scale,
                        child: Image(
                          height: _kShuffleBaseHeight * _kShuffleHeightFactor * scale,
                          fit: BoxFit.cover,
                          image: const AssetImage(
                              "assets/images/abilities/shuffle.png"),
                        ))
                    : Container(),

                //add graphic positionals here
                if (positionals.isNotEmpty) positionals.first,
                if (positionals.length > 1) positionals[1],
                if (positionals.length > _kGfxIndex2) positionals[_kGfxIndex2],
                if (positionals.length > _kGfxIndex3) positionals[_kGfxIndex3],

                Positioned(
                  top: _kLinesTop * scale,
                  //alignment: Alignment.center,
                  child: SizedBox(
                    height: _kTitleAreaHeight * scale,
                    width: _kCardWidth * scale, //needed for line breaks in lines
                    child: LineBuilder.createLines(
                        card.lines,
                        false,
                        !settings.noCalculation.value,
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

  static Widget buildRear(double scale, int size, Monster monster) {
    bool frosthavenStyle = GameMethods.isFrosthavenStyle(monster.type);
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: _kShadowBlur * scale,
              offset: Offset(_kShadowOffsetX * scale, _kShadowOffsetY * scale), // Shadow position
            ),
          ],
        ),
        key: const ValueKey<int>(0),
        margin: EdgeInsets.all(_kMargin * scale),
        width: _kCardWidth * scale, //this evaluates to same space as front somehow.
        height: _kCardHeight * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(_kBorderRadius * scale)),
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
                      style: TextStyle(
                          fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                          color: Colors.white,
                          fontSize: _kRearDeckSizeFontSize * scale,
                          shadows: [
                            Shadow(
                                offset: Offset(_kRearShadowOffset, _kRearShadowOffset), color: Colors.black)
                          ]),
                    ))
                : Container(),
          ],
        ));
  }

  final Monster data;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  MonsterAbilityCardWidgetState createState() =>
      MonsterAbilityCardWidgetState();
}

class MonsterAbilityCardWidgetState extends State<MonsterAbilityCardWidget> {
  late final MonsterAbilityCardViewModel _vm;

  @override
  void initState() {
    _vm = MonsterAbilityCardViewModel(widget.data,
        gameState: widget.gameState, settings: widget.settings);
    super.initState();
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, MonsterAbilityCardWidget._kHalfPi);
          return Transform(
            transform: Matrix4.rotationX(value),
            alignment: Alignment.center,
            child: widget,
          );
        });
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
                duration: const Duration(milliseconds: MonsterAbilityCardWidget._kAnimationDurationMs),
                transitionBuilder: _transitionBuilder,
                layoutBuilder: (widget, list) => Stack(
                  children: [widget!, ...list],
                ),
                child: showFront && card != null
                    ? MonsterAbilityCardWidget.buildFront(
                        card, widget.data, scale, false)
                    : MonsterAbilityCardWidget.buildRear(
                        scale, _vm.deckSize, widget.data),
              ));
        });
  }
}
