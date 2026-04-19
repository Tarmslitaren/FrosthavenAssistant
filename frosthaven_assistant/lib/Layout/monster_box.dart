import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
import 'package:frosthaven_assistant/Resource/app_constantscon.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Resource/color_matrices.dart';
import '../Resource/enums.dart';
import '../Resource/game_methods.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import 'health_wheel_controller.dart';
import 'menus/status_menu.dart';
import 'view_models/monster_box_view_model.dart';

class MonsterBox extends StatelessWidget {
  static const double conditionSize = 14;
  static const double _kBaseWidth = 47.0;
  static const double _kBoxHeight = 30.0;
  static const double _kShadowOffset = 0.4;
  static const double _kShadowBlur = 1.0;
  static const double _kBoxShadowBlur = 4.0;
  static const double _kBoxShadowOffsetX = 2.0;
  static const double _kBoxShadowOffsetY = 4.0;
  static const double _kImageMarginLeft = 3.0;
  static const double _kImageMarginTop = 3.0;
  static const double _kImageMarginBottom = 2.0;
  static const double _kImageHeight = 100.0;
  static const double _kImageWidth = 17.0;
  static const double _kStandeeWidth = 22.0;
  static const double _kStandeeTop = 1.0;
  static const double _kHealthLeftSmall = 23.0;
  static const double _kHealthLeftLarge = 22.0;
  static const double _kBloodIconHeight = 7.0;
  static const double _kHealthMarginBottom = 2.0;
  static const double _kHealthWidthLarge = 21.0;
  static const double _kHealthWidthSmall = 16.8;
  static const double _kSpacerWidthLarge = 4.5;
  static const double _kSpacerWidthSmall = 6.5;
  static const double _kProgressBarMarginBottom = 2.5;
  static const double _kProgressBarMarginLeft = 2.5;
  static const double _kProgressBarMarginRight = 2.7;
  static const double _kProgressBarWidth = 42.0;
  static const double _kProgressBarSize = 4.0;
  static const double _kProgressBarBorderWidth = 0.5;
  static const int _kHealthLargeThreshold = 99;
  static const double _kAnimationOffset = 30.0;
  static const int _kAnimationDurationMs = 300;
  static const int _kFlipAnimationDurationMs = 600;
  static const int _kConditionRowDivisor = 2;
  static const int _kHexRadix = 16;

  MonsterBox(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.displayStartAnimation,
      required this.blockInput,
      required this.scale,
      this.gameState,
      this.settings})
      : data = _resolveData(ownerId, figureId);

  static MonsterInstance _resolveData(String? ownerId, String figureId) {
    final figure = GameMethods.getFigure(ownerId, figureId);
    if (figure is! MonsterInstance) {
      throw StateError(
          'MonsterBox: expected MonsterInstance for $ownerId/$figureId, got ${figure.runtimeType}');
    }
    return figure;
  }

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  static double getWidth(double scale, MonsterInstance data) {
    double width = _kBaseWidth;
    final length = data.conditions.value.length;
    width += conditionSize * length / _kConditionRowDivisor;
    if (length % _kConditionRowDivisor != 0) {
      width += conditionSize / _kConditionRowDivisor;
    }
    width = width * scale;
    return width;
  }

  final String figureId;
  final String? ownerId;
  final String displayStartAnimation;
  final bool blockInput;
  final double scale;

  final MonsterInstance data;

  List<Widget> _createConditionList(double scale, MonsterBoxViewModel vm) {
    final owner = vm.ownerItem;
    if (owner == null) return [];
    return data.conditions.value
        .map((condition) => ConditionIcon(
              condition,
              MonsterBox.conditionSize,
              owner,
              data,
              scale: scale,
            ))
        .toList();
  }

  Widget _buildInternal(double scale, double width, MonsterBoxViewModel vm) {
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

    var shadow = Shadow(
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: _kShadowBlur * scale,
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
                      blurRadius: _kBoxShadowBlur * scale,
                      offset: Offset(_kBoxShadowOffsetX * scale,
                          _kBoxShadowOffsetY * scale),
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
                                style: TextStyle(
                                    height: 1,
                                    color: Colors.white,
                                    fontSize: kFontSizeBody * scale,
                                    shadows: [shadow]),
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
                                      children: _createConditionList(scale, vm),
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

  @override
  Widget build(BuildContext context) {
    final vm = MonsterBoxViewModel(data,
        ownerId: ownerId, gameState: gameState, settings: settings);
    final width = MonsterBox.getWidth(scale, data);

    Widget innerWidget = RepaintBoundary(
      child: AnimatedContainer(
          key: Key(data.getId()),
          width: width,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: _kAnimationDurationMs),
          child: ValueListenableBuilder<int>(
              valueListenable: data.health,
              builder: (context, value, child) {
                final alive = vm.isAlive;
                final double offset = -_kAnimationOffset * scale;
                final child = _buildInternal(scale, width, vm);

                if (displayStartAnimation != figureId) {
                  return TweenAnimationBuilder<Offset>(
                      tween: Tween(
                        begin: Offset.zero,
                        end: (!alive && !blockInput)
                            ? Offset(0, -offset)
                            : Offset.zero,
                      ),
                      duration: const Duration(
                          milliseconds: _kFlipAnimationDurationMs),
                      curve: Curves.linear,
                      builder: (context, translation, _) => Transform.translate(
                          offset: translation, child: child));
                }

                return TweenAnimationBuilder<Offset>(
                    tween: Tween(
                      begin: Offset(0, alive ? offset : 0),
                      end: Offset(0, alive ? 0 : -offset),
                    ),
                    duration:
                        const Duration(milliseconds: _kFlipAnimationDurationMs),
                    curve: Curves.linear,
                    builder: (context, translation, _) => Transform.translate(
                        offset: translation,
                        child: AnimatedOpacity(
                          opacity: alive ? 1.0 : 0.0,
                          duration: const Duration(
                              milliseconds: _kFlipAnimationDurationMs),
                          child: child,
                        )));
              })),
    );

    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              if (!blockInput) {
                openDialog(
                  context,
                  StatusMenu(
                      figureId: data.getId(),
                      monsterId: vm.monsterId,
                      characterId: vm.characterId),
                );
              }
            },
            child: vm.useHealthWheel
                ? HealthWheelController(
                    figureId: data.getId(),
                    ownerId: ownerId,
                    child: innerWidget)
                : innerWidget));
  }
}
