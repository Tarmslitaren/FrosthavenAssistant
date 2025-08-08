import 'package:flutter/material.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../condition_icon.dart';

class ConditionButton extends StatelessWidget {
  const ConditionButton(
      {super.key,
      required this.condition,
      required this.figureId,
      required this.ownerId,
      required this.immunities,
      required this.scale});

  final Condition condition;
  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final double scale;

  bool _isConditionActive(Condition condition, FigureState figure) {
    bool isActive = false;
    for (var item in figure.conditions.value) {
      if (item == condition) {
        isActive = true;
        break;
      }
    }
    return isActive;
  }

  @override
  Widget build(BuildContext context) {
    bool enabled = true;
    String suffix = "";
    if (GameMethods.isFrosthavenStyle(null)) {
      suffix = "_fh";
    }
    String imagePath = "assets/images/abilities/${condition.name}.png";
    if (condition.name.contains("character")) {
      imagePath = "assets/images/class-icons/${condition.getName()}.png";
    } else if (suffix.isNotEmpty && hasGHVersion(condition.name)) {
      imagePath = "assets/images/abilities/${condition.getName()}$suffix.png";
    }
    for (var item in immunities) {
      if (condition.name.contains(item.substring(1, item.length - 1))) {
        enabled = false;
      }
      final immunity = item.substring(1, item.length - 1);
      if (immunity == "poison" && condition == Condition.infect) {
        enabled = false;
      }
      if (immunity == "wound" && condition == Condition.rupture) {
        enabled = false;
      }
      //immobilize or muddle: also chill - doesn't matter: monster can't be chilled and players don't have immunities.
    }
    final gameState = getIt<GameState>();
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          Color color = Colors.transparent;
          FigureState? figure = GameMethods.getFigure(ownerId, figureId);
          if (figure == null) {
            return const SizedBox(
              width: 0,
              height: 0,
            );
          }
          ListItemData? owner;
          for (var item in gameState.currentList) {
            if (item.id == ownerId) {
              owner = item;
              break;
            }
          }

          bool isActive = _isConditionActive(condition, figure);
          if (isActive) {
            color =
                getIt<Settings>().darkMode.value ? Colors.white : Colors.black;
          }

          bool isCharacter = condition.name.contains("character");
          Color classColor = Colors.transparent;
          if (isCharacter) {
            var characters = GameMethods.getCurrentCharacters();
            classColor = characters
                .where((element) =>
                    element.characterClass.name == condition.getName())
                .first
                .characterClass
                .color;
          }

          return Container(
              width: 42 * scale,
              height: 42 * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(1 * scale),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30 * scale))),
              child: IconButton(
                icon: enabled
                    ? isActive
                        ? ConditionIcon(
                            condition,
                            24 * scale,
                            owner!,
                            figure,
                            scale: scale,
                          )
                        : isCharacter
                            ? Stack(alignment: Alignment.center, children: [
                                Image(
                                    color: classColor,
                                    colorBlendMode: BlendMode.modulate,
                                    height: 24 * scale,
                                    filterQuality: FilterQuality.medium,
                                    image: const AssetImage(
                                        "assets/images/psd/class-token-bg.png")),
                                Image.asset(
                                    filterQuality: FilterQuality.medium,
                                    height: 24 * scale * 0.65,
                                    width: 24 * scale * 0.65,
                                    //color: classColor,
                                    //colorBlendMode: BlendMode.colorBurn,
                                    imagePath),
                              ])
                            : Image.asset(
                                filterQuality: FilterQuality.medium,
                                //needed because of the edges
                                height: 24 * scale,
                                width: 24 * scale,
                                imagePath)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                              left: 0,
                              top: 0,
                              child: Image(
                                height: 23.1 * scale,
                                filterQuality: FilterQuality.medium,
                                //needed because of the edges
                                image: AssetImage(imagePath),
                              )),
                          Positioned(
                              //should be 19  but there is a clipping issue
                              left: 15.75 * scale,
                              top: 7.35 * scale,
                              child: Image(
                                height: 8.4 * scale,
                                filterQuality: FilterQuality.medium,
                                //needed because of the edges
                                image: const AssetImage(
                                    "assets/images/psd/immune.png"),
                              )),
                        ],
                      ),
                onPressed: enabled
                    ? () {
                        if (!isActive) {
                          gameState.action(AddConditionCommand(
                              condition, figureId, ownerId));
                        } else {
                          gameState.action(RemoveConditionCommand(
                              condition, figureId, ownerId));
                        }
                      }
                    : null,
              ));
        });
  }
}
