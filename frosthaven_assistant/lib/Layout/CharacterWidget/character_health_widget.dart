import 'package:flutter/material.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../../services/translation_service.dart';
import '../condition_icon.dart';
import '../health_wheel_controller.dart';
import '../view_models/character_health_widget_view_model.dart';

class CharacterHealthWidget extends StatelessWidget {
  static const double _kMarginTop = 10.0;
  static const double _kMarginLeft = 10.0;
  static const double _kFontSizeFH = 15.0;
  static const double _kFontSizeOrig = 16.0;
  static const double _kConditionIconSize = 16.0;
  static const double _kBloodHeightRatio = 0.2;

  const CharacterHealthWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow,
      required this.scaledHeight,
      this.settings});
  final Character character;
  final double scale;
  final double scaledHeight;
  final Shadow shadow;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final vm = CharacterHealthWidgetViewModel(settings: settings);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //align children to the left
        children: [
          Container(
            margin: EdgeInsets.only(
                top: CharacterHealthWidget._kMarginTop * scale,
                left: CharacterHealthWidget._kMarginLeft * scale),
            child: ValueListenableBuilder<String>(
                valueListenable: character.characterState.display,
                builder: (context, value, child) {
                  return Text(
                    getIt<TranslationService>().t(value),
                    style: getCardTitleStyle(
                        vm.frosthavenStyle
                            ? CharacterHealthWidget._kFontSizeFH * scale
                            : CharacterHealthWidget._kFontSizeOrig * scale,
                        shadow,
                        vm.frosthavenStyle),
                  );
                }),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: vm.enableHealthWheel,
              builder: (context, value, child) {
                return Container(
                    margin: EdgeInsets.only(
                        left: CharacterHealthWidget._kMarginLeft * scale),
                    child: value
                        ? HealthWheelController(
                            figureId: character.id,
                            ownerId: character.id,
                            child: CharacterHealthInnerWidget(
                                character: character,
                                scale: scale,
                                shadow: shadow,
                                scaledHeight: scaledHeight))
                        : CharacterHealthInnerWidget(
                            character: character,
                            scale: scale,
                            shadow: shadow,
                            scaledHeight: scaledHeight));
              })
        ]);
  }
}

class CharacterHealthInnerWidget extends StatelessWidget {
  const CharacterHealthInnerWidget(
      {super.key,
      required this.character,
      required this.scale,
      required this.shadow,
      required this.scaledHeight});
  final Character character;
  final double scale;
  final double scaledHeight;
  final Shadow shadow;

  List<Widget> createConditionList(double scale) {
    List<Widget> conditions = [];
    final characterConditions = character.characterState.conditions.value;
    for (int i = conditions.length; i < characterConditions.length; i++) {
      conditions.add(ConditionIcon(
        characterConditions[i],
        CharacterHealthWidget._kConditionIconSize,
        character,
        character.characterState,
        scale: scale,
      ));
    }
    return conditions;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image(
        fit: BoxFit.contain,
        height: scaledHeight * CharacterHealthWidget._kBloodHeightRatio,
        image: const AssetImage("assets/images/blood.png"),
      ),
      ValueListenableBuilder<int>(
        valueListenable: character.characterState.health,
        builder: (context, healthValue, child) {
          return ValueListenableBuilder<int>(
            valueListenable: character.characterState.maxHealth,
            builder: (context, maxHealthValue, child) {
              final frosthavenStyle = GameMethods.isFrosthavenStyle(null);
              return Text(
                frosthavenStyle
                    ? '$healthValue/$maxHealthValue'
                    : '$healthValue / $maxHealthValue',
                style: getCardTitleStyle(
                    kFontSizeBody * scale, shadow, frosthavenStyle),
              );
            },
          );
        },
      ),
      //add conditions here
      ValueListenableBuilder<List<Condition>>(
          valueListenable: character.characterState.conditions,
          builder: (context, value, child) {
            return Row(
              children: createConditionList(scale),
            );
          }),
    ]);
  }
}
