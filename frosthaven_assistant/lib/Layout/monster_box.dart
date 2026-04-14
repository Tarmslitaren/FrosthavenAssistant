import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:frosthaven_assistant/Layout/condition_icon.dart';
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
  MonsterBox(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.displayStartAnimation,
      required this.blockInput,
      required this.scale,
      this.gameState,
      this.settings}) {
    data = GameMethods.getFigure(ownerId, figureId) as MonsterInstance;
  }

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  static const double conditionSize = 14;

  static double getWidth(double scale, MonsterInstance data) {
    double width = 47;
    final length = data.conditions.value.length;
    width += conditionSize * length / 2;
    if (length % 2 != 0) {
      width += conditionSize / 2;
    }
    width = width * scale;
    return width;
  }

  final String figureId;
  final String? ownerId;
  final String displayStartAnimation;
  final bool blockInput;
  final double scale;

  late final MonsterInstance data;

  List<Widget> _createConditionList(
      double scale, MonsterBoxViewModel vm) {
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

  Widget _buildInternal(
      double scale, double width, MonsterBoxViewModel vm) {
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
      offset: Offset(0.4 * scale, 0.4 * scale),
      color: Colors.black87,
      blurRadius: 1 * scale,
    );

    final health = data.health.value;

    return RepaintBoundary(
        child: ColorFiltered(
            colorFilter: vm.isSummonedThisTurn
                ? ColorFilter.matrix(grayScale)
                : ColorFilter.matrix(identity),
            child: Container(
                padding: EdgeInsets.zero,
                height: 30 * scale,
                width: width,
                decoration: BoxDecoration(
                  color: Color(int.parse("7A000000", radix: 16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4 * scale,
                      offset: Offset(2 * scale, 4 * scale),
                    ),
                  ],
                ),
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Image(
                    height: 30 * scale,
                    width: 47 * scale,
                    fit: BoxFit.fill,
                    color: borderColor,
                    colorBlendMode: blendMode,
                    image:
                        const AssetImage("assets/images/psd/monster-box.png"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 3 * scale, top: 3 * scale, bottom: 2 * scale),
                    child: Image(
                      height: 100 * scale,
                      width: 17 * scale,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      image: AssetImage(imagePath),
                    ),
                  ),
                  Positioned(
                    width: 22 * scale,
                    top: 1 * scale,
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
                    left: health > 99 ? 22 * scale : 23 * scale,
                    top: 0,
                    child: Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: Row(children: [
                          Column(children: [
                            Image(
                              color: Colors.red,
                              height: 7 * scale,
                              image: const AssetImage(
                                  "assets/images/blood.png"),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 2 * scale),
                              width: health > 99
                                  ? 21 * scale
                                  : 16.8 * scale,
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
                            width: health > 99
                                ? 4.5 * scale
                                : 6.5 * scale,
                          ),
                          ValueListenableBuilder<List<Condition>>(
                              valueListenable: data.conditions,
                              builder: (context, value, child) {
                                return SizedBox(
                                    height: 30 * scale,
                                    child: Wrap(
                                      spacing: 0,
                                      runSpacing: 0,
                                      direction: Axis.vertical,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: _createConditionList(
                                          scale, vm),
                                    ));
                              }),
                        ])),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          bottom: 2.5 * scale,
                          left: 2.5 * scale,
                          right: 2.7 * scale),
                      alignment: Alignment.bottomCenter,
                      width: 42 * scale,
                      child: ValueListenableBuilder<int>(
                          valueListenable: data.maxHealth,
                          builder: (context, value, child) {
                            return FAProgressBar(
                              currentValue:
                                  data.health.value.toDouble(),
                              maxValue: data.maxHealth.value.toDouble(),
                              size: 4.0 * scale,
                              direction: Axis.horizontal,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(0)),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5 * scale,
                              ),
                              backgroundColor: Colors.black,
                              progressColor: Colors.red,
                              changeColorValue:
                                  (data.maxHealth.value).toInt(),
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
          duration: const Duration(milliseconds: 300),
          child: ValueListenableBuilder<int>(
              valueListenable: data.health,
              builder: (context, value, child) {
                final alive = vm.isAlive;
                final double offset = -30 * scale;
                final child = _buildInternal(scale, width, vm);

                if (displayStartAnimation != figureId) {
                  return TranslationAnimatedWidget.tween(
                      enabled: !alive && !blockInput,
                      translationDisabled: const Offset(0, 0),
                      translationEnabled: Offset(0, alive ? 0 : -offset),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.linear,
                      child: child);
                }

                return TranslationAnimatedWidget.tween(
                    enabled: true,
                    translationDisabled:
                        Offset(0, alive ? offset : 0),
                    translationEnabled: Offset(0, alive ? 0 : -offset),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.linear,
                    child: OpacityAnimatedWidget.tween(
                        enabled: alive,
                        opacityDisabled: 0,
                        opacityEnabled: 1,
                        child: child));
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
