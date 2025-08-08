import 'package:flutter/material.dart';

import '../../Resource/enums.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../condition_icon.dart';
import '../health_wheel_controller.dart';

class CharacterHealthWidget extends StatelessWidget {
  const CharacterHealthWidget(
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
        16,
        character,
        character.characterState,
        scale: scale,
      ));
    }
    return conditions;
  }

  @override
  Widget build(BuildContext context) {
    final frosthavenStyle = GameMethods.isFrosthavenStyle(null);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //align children to the left
        children: [
          Container(
            margin: EdgeInsets.only(top: 10 * scale, left: 10 * scale),
            child: ValueListenableBuilder<String>(
                valueListenable: character.characterState.display,
                builder: (context, value, child) {
                  return Text(
                    character.characterState.display.value,
                    style: TextStyle(
                        fontFamily: frosthavenStyle ? 'GermaniaOne' : 'Pirata',
                        color: Colors.white,
                        fontSize: frosthavenStyle ? 15 * scale : 16 * scale,
                        shadows: [shadow]),
                  );
                }),
          ),
          ValueListenableBuilder<int>(
              valueListenable: getIt<GameState>().commandIndex,
              builder: (context, value, child) {
                final health = character.characterState.health.value.toString();
                final maxHealth =
                    character.characterState.maxHealth.value.toString();
                return Container(
                    margin: EdgeInsets.only(left: 10 * scale),
                    child: HealthWheelController(
                        figureId: character.id,
                        ownerId: character.id,
                        child: Row(children: [
                          Image(
                            fit: BoxFit.contain,
                            height: scaledHeight * 0.2,
                            image: const AssetImage("assets/images/blood.png"),
                          ),
                          Text(
                            frosthavenStyle
                                ? '$health/$maxHealth'
                                : '$health / $maxHealth',
                            style: TextStyle(
                                fontFamily:
                                    frosthavenStyle ? 'GermaniaOne' : 'Pirata',
                                color: Colors.white,
                                fontSize: 16 * scale,
                                shadows: [shadow]),
                          ),
                          //add conditions here
                          ValueListenableBuilder<List<Condition>>(
                              valueListenable:
                                  character.characterState.conditions,
                              builder: (context, value, child) {
                                return Row(
                                  children: createConditionList(scale),
                                );
                              }),
                        ])));
              })
        ]);
  }
}
