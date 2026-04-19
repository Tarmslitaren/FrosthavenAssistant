import 'package:flutter/material.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../condition_icon.dart';

class ConditionButton extends StatelessWidget {
  static const double _kButtonSize = 42.0;
  static const double _kBorderRadius = 30.0;
  static const double _kIconSize = 24.0;
  static const double _kClassTokenScale = 0.65;
  static const double _kDisabledIconSize = 23.1;
  static const double _kImmuneLeft = 15.75;
  static const double _kImmuneTop = 7.35;
  static const double _kImmuneSize = 8.4;

  const ConditionButton(
      {super.key,
      required this.condition,
      required this.figureId,
      required this.ownerId,
      required this.immunities,
      required this.scale,
      this.gameState,
      this.settings});

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

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
    final gameState = this.gameState ?? getIt<GameState>();
    final settings = this.settings ?? getIt<Settings>();
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

          //todo: fix this logic (move to viewmodel))
          ListItemData owner = ListItemData();
          for (var item in gameState.currentList) {
            if (item.id == ownerId) {
              owner = item;
              break;
            }
          }

          bool isActive = _isConditionActive(condition, figure);
          if (isActive) {
            color = settings.darkMode.value ? Colors.white : Colors.black;
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

          Widget inactiveIcon = isCharacter
              ? Stack(alignment: Alignment.center, children: [
                  Image(
                      color: classColor,
                      colorBlendMode: BlendMode.modulate,
                      height: _kIconSize * scale,
                      filterQuality: FilterQuality.medium,
                      image: const AssetImage(
                          "assets/images/psd/class-token-bg.png")),
                  Image(
                      height: (_kIconSize * scale * _kClassTokenScale),
                      width: (_kIconSize * scale * _kClassTokenScale),
                      image: AssetImage(imagePath),
                      filterQuality: FilterQuality.medium),
                ])
              : Image.asset(
                  filterQuality: FilterQuality.medium,
                  //needed because of the edges
                  height: _kIconSize * scale,
                  width: _kIconSize * scale,
                  imagePath);
          Widget enabledIcon = isActive
              ? ConditionIcon(
                  condition,
                  _kIconSize * scale,
                  owner,
                  figure,
                  scale: scale,
                )
              : inactiveIcon;
          return Container(
              width: _kButtonSize * scale,
              height: _kButtonSize * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(1 * scale),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                  ),
                  borderRadius: BorderRadius.all(
                      Radius.circular(_kBorderRadius * scale))),
              child: IconButton(
                icon: enabled
                    ? enabledIcon
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                              left: 0,
                              top: 0,
                              child: Image(
                                height: _kDisabledIconSize * scale,
                                filterQuality: FilterQuality.medium,
                                //needed because of the edges
                                image: AssetImage(imagePath),
                              )),
                          Positioned(
                              //should be 19  but there is a clipping issue
                              left: _kImmuneLeft * scale,
                              top: _kImmuneTop * scale,
                              child: Image(
                                height: _kImmuneSize * scale,
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
                              condition, figureId, ownerId,
                              gameState: gameState));
                        } else {
                          gameState.action(RemoveConditionCommand(
                              condition, figureId, ownerId,
                              gameState: gameState));
                        }
                      }
                    : null,
              ));
        });
  }
}
