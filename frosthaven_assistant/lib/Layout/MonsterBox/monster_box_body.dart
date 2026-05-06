import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/color_matrices.dart';
import '../../Resource/enums.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../condition_icon.dart';
import '../view_models/monster_box_view_model.dart';

const double _kBoxHeight = 30.0;
const double _kBaseWidth = 47.0;
const double _kShadowOffset = 0.4;
const double _kConditionSize = 14.0;
const double _kImageMarginLeft = 3.0;
const double _kImageMarginTop = 3.0;
const double _kImageMarginBottom = 2.0;
const double _kImageHeight = 100.0;
const double _kImageWidth = 17.0;
const double _kStandeeWidth = 22.0;
const double _kStandeeTop = 1.0;
const double _kHealthLeftSmall = 23.0;
const double _kHealthLeftLarge = 22.0;
const double _kBloodIconHeight = 7.0;
const double _kHealthMarginBottom = 2.0;
const double _kHealthWidthLarge = 21.0;
const double _kHealthWidthSmall = 16.8;
const double _kSpacerWidthLarge = 4.5;
const double _kSpacerWidthSmall = 6.5;
const double _kProgressBarMarginBottom = 2.5;
const double _kProgressBarMarginLeft = 2.5;
const double _kProgressBarMarginRight = 2.7;
const double _kProgressBarWidth = 42.0;
const double _kProgressBarSize = 4.0;
const double _kProgressBarBorderWidth = 0.5;
const int _kHealthLargeThreshold = 99;
const int _kHexRadix = 16;

class MonsterBoxBody extends StatelessWidget {
  const MonsterBoxBody({
    super.key,
    required this.scale,
    required this.width,
    required this.data,
    required this.vm,
  });

  final double scale;
  final double width;
  final MonsterInstance data;
  final MonsterBoxViewModel vm;

  List<Widget> _createConditionList() {
    final owner = vm.ownerItem;
    if (owner == null) return [];
    return data.conditions.value
        .map((condition) => ConditionIcon(
              condition,
              _kConditionSize,
              owner,
              data,
              scale: scale,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = vm.color;
    String imagePath = "assets/images/tombstone.png";
    if (data.type == MonsterType.summon) {
      imagePath = "assets/images/summon/${data.gfx}.png";
    } else {
      if (data.roundSummoned != -1) {
        imagePath = "assets/images/summon/green.png";
      }
    }
    String standeeNr = "";
    if (data.standeeNr > 0) {
      standeeNr = data.standeeNr.toString();
    }
    Color? borderColor = color;
    if (data.type == MonsterType.summon) {
      borderColor = Colors.blue;
    }
    BlendMode blendMode = BlendMode.hue;
    if (color == Colors.red) {
      blendMode = BlendMode.modulate;
    }
    if (color == Colors.yellow) {
      borderColor = null;
    }

    final shadow = Shadow(
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: kShadowOffset * scale,
    );

    final health = data.health.value;

    return RepaintBoundary(
        child: ColorFiltered(
            colorFilter: vm.isSummonedThisTurn
                ? ColorFilter.matrix(grayScale)
                : ColorFilter.matrix(identity),
            child: Container(
                padding: EdgeInsets.zero,
                height: _kBoxHeight * scale,
                width: width,
                decoration: BoxDecoration(
                  color: Color(int.parse("7A000000", radix: _kHexRadix)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: kCardShadowBlur * scale,
                      offset: Offset(kCardShadowOffsetX * scale,
                          kCardShadowOffsetY * scale),
                    ),
                  ],
                ),
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Image(
                    height: _kBoxHeight * scale,
                    width: _kBaseWidth * scale,
                    fit: BoxFit.fill,
                    color: borderColor,
                    colorBlendMode: blendMode,
                    image:
                        const AssetImage("assets/images/psd/monster-box.png"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: _kImageMarginLeft * scale,
                        top: _kImageMarginTop * scale,
                        bottom: _kImageMarginBottom * scale),
                    child: Image(
                      height: _kImageHeight * scale,
                      width: _kImageWidth * scale,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      image: AssetImage(imagePath),
                    ),
                  ),
                  Positioned(
                    width: _kStandeeWidth * scale,
                    top: _kStandeeTop * scale,
                    child: Text(
                      textAlign: TextAlign.center,
                      standeeNr,
                      style: TextStyle(
                          color: color,
                          fontSize: kFontSizeButtonLabel * scale,
                          shadows: [shadow]),
                    ),
                  ),
                  Positioned(
                    left: health > _kHealthLargeThreshold
                        ? _kHealthLeftLarge * scale
                        : _kHealthLeftSmall * scale,
                    top: 0,
                    child: Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: Row(children: [
                          Column(children: [
                            Image(
                              color: Colors.red,
                              height: _kBloodIconHeight * scale,
                              image:
                                  const AssetImage("assets/images/blood.png"),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: _kHealthMarginBottom * scale),
                              width: health > _kHealthLargeThreshold
                                  ? _kHealthWidthLarge * scale
                                  : _kHealthWidthSmall * scale,
                              alignment: Alignment.center,
                              child: Text(
                                textAlign: TextAlign.end,
                                "$health",
                                style: getWhiteShadowStyle(
                                    kFontSizeBody * scale, shadow,
                                    height: 1),
                              ),
                            )
                          ]),
                          SizedBox(
                            width: health > _kHealthLargeThreshold
                                ? _kSpacerWidthLarge * scale
                                : _kSpacerWidthSmall * scale,
                          ),
                          ValueListenableBuilder<List<Condition>>(
                              valueListenable: data.conditions,
                              builder: (context, value, child) {
                                return SizedBox(
                                    height: _kBoxHeight * scale,
                                    child: Wrap(
                                      spacing: 0,
                                      runSpacing: 0,
                                      direction: Axis.vertical,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: _createConditionList(),
                                    ));
                              }),
                        ])),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          bottom: _kProgressBarMarginBottom * scale,
                          left: _kProgressBarMarginLeft * scale,
                          right: _kProgressBarMarginRight * scale),
                      alignment: Alignment.bottomCenter,
                      width: _kProgressBarWidth * scale,
                      child: ValueListenableBuilder<int>(
                          valueListenable: data.maxHealth,
                          builder: (context, value, child) {
                            return FAProgressBar(
                              currentValue: data.health.value.toDouble(),
                              maxValue: data.maxHealth.value.toDouble(),
                              size: _kProgressBarSize * scale,
                              direction: Axis.horizontal,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(0)),
                              border: Border.all(
                                color: Colors.black,
                                width: _kProgressBarBorderWidth * scale,
                              ),
                              backgroundColor: Colors.black,
                              progressColor: Colors.red,
                              changeColorValue: (data.maxHealth.value).toInt(),
                              changeProgressColor: Colors.green,
                            );
                          }))
                ]))));
  }
}
