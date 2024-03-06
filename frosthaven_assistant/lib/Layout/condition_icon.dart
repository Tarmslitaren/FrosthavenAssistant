import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';

import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class ConditionIcon extends StatefulWidget {
  ConditionIcon(this.condition, this.size, this.owner, this.figure,
      {super.key, required this.scale}) {
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
    gfx = imagePath;
  }

  final Condition condition;
  final double size;
  final double scale;
  final ListItemData owner;
  final FigureState figure;
  late final String gfx;

  @override
  ConditionIconState createState() => ConditionIconState();
}

class ConditionIconState extends State<ConditionIcon> {
  final animate = ValueNotifier<bool>(
      false); //this needs to exist outside of this class to apply when parent rebuilds. :(

  @override
  void dispose() {
    getIt<GameState>().commandIndex.removeListener(_animateListener);
    super.dispose();
  }

  @override
  void initState() {
    GameState gameState = getIt<GameState>();
    gameState.commandIndex.addListener(_animateListener);
    super.initState();
  }

  void _runAnimation() {
    animate.value = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      animate.value = false;
    });
  }

  void _animateListener() {
    GameState gameState = getIt<GameState>();
    GameState oldState = GameState();
    int offset = 1;
    if(gameState.gameSaveStates.length <= offset ||
        gameState.gameSaveStates[gameState.gameSaveStates.length-offset] == null) {
      return;
    }

    String oldSave = gameState.gameSaveStates[gameState.gameSaveStates.length-offset]!.getState();
    oldState.loadFromData(oldSave);
    GameState currentState = gameState;
    bool turnChanged = false;
    late int turnIndex;
    int healthChangedValue = 0;
    late String changeHealthId;
    //find if turn state changed one step
    if(oldState.round.value == currentState.round.value &&
        oldState.roundState.value == currentState.roundState.value &&
    oldState.currentList.length == currentState.currentList.length
    ) {
      //todo: pretty heavy to do for every icon, when calc only needed once = put it in game state?
      for (int i = 0; i < oldState.currentList.length; i++) {
        ListItemData oldItem = oldState.currentList[i];
        ListItemData currentItem = currentState.currentList[i];
          if (oldItem.id == currentItem.id) {
            if (oldItem.turnState != currentItem.turnState) {
              turnChanged = true;
              turnIndex = i;
              break;
          }
        }
      }

      for (int i = 0; i < oldState.currentList.length; i++) {
        ListItemData oldItem = oldState.currentList[i];
        ListItemData currentItem = currentState.currentList[i];
        if (oldItem.id == currentItem.id) {
          if (oldItem is Character) {
            int diff = (currentItem as Character).characterState.health.value - oldItem.characterState.health.value;
            if(diff != 0) {
              healthChangedValue = diff;
              changeHealthId = oldItem.id;
              break;
            }
          } else if (oldItem is Monster) {
            final newMonster = currentItem as Monster;
            if (oldItem.monsterInstances.length == newMonster.monsterInstances.length) {
              for( int j = 0; j < oldItem.monsterInstances.length; j++) {
                MonsterInstance old = oldItem.monsterInstances[j];
                MonsterInstance current = newMonster.monsterInstances[j];
                if(old.getId() == current.getId()) {
                  int diff =  current.health.value - old.health.value;
                  if(diff != 0) {
                    healthChangedValue = diff;
                    changeHealthId = old.getId();
                    break;
                  }
                }
              }
              if(healthChangedValue != 0) {
                break;
              }
            }
          }
        }
      }
    }

    if (turnChanged == true) {
      if (widget.owner.turnState == TurnsState.current) {
        //this turn started! play animation for wound and regenerate
        if (widget.condition == Condition.regenerate ||
            widget.condition == Condition.wound ||
            widget.condition == Condition.wound2) {
          _runAnimation();
        }
      }
      if (widget.owner.turnState == TurnsState.done &&
          currentState.currentList[turnIndex].id == widget.owner.id) {

        if(widget.condition == Condition.bane && !widget.figure.conditionsAddedThisTurn.contains(widget.condition)) {
          _runAnimation();
        }

        //was current last round but is no more
        if (widget.figure.conditionsAddedPreviousTurn
            .contains(widget.condition)) {

          //only run these if not automatically taken off. TODO: maybe run animations before removing is good?
          if (getIt<Settings>().expireConditions.value == false) {
            if (widget.condition == Condition.chill ||
                widget.condition == Condition.stun ||
                widget.condition == Condition.disarm ||
                widget.condition == Condition.immobilize ||
                widget.condition == Condition.invisible ||
                widget.condition == Condition.strengthen ||
                widget.condition == Condition.muddle ||
                widget.condition == Condition.impair) {
              _runAnimation();
            }
          }
        }
      }
    } else if (healthChangedValue != 0) {
      if (changeHealthId == widget.owner.id || widget.figure is MonsterInstance && (widget.figure as MonsterInstance).getId() == changeHealthId) {
        if (healthChangedValue < 0) {
          if (widget.condition.name.contains("poison") ||
              widget.condition == Condition.regenerate ||
              widget.condition == Condition.ward ||
              widget.condition == Condition.brittle) {
            _runAnimation();
          }
        } else if (healthChangedValue >= 1) {
          if (widget.condition == Condition.rupture ||
              widget.condition == Condition.wound ||
              widget.condition == Condition.bane ||
              widget.condition.name.contains("poison") ||
              widget.condition == Condition.infect ||
              widget.condition == Condition.brittle) {
            _runAnimation();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double scale = widget.scale;

    return ValueListenableBuilder<bool>(
        valueListenable: animate,
        builder: (context, value, child) {
          bool isCharacter = widget.condition.name.contains("character");
          Color classColor = Colors.transparent;
          if (isCharacter) {
            var characters = GameMethods.getCurrentCharacters();
            classColor = characters
                .where((element) =>
                    element.characterClass.name == widget.condition.getName())
                .first
                .characterClass
                .color;
          }
          return ShakeAnimatedWidget(
              duration: const Duration(milliseconds: 333),
              enabled: animate.value,
              alignment: Alignment.center,
              shakeAngle: Rotation.deg(x: 0, y: 0, z: 30),
              child: isCharacter
                  ? Stack(alignment: Alignment.center, children: [
                      Image(
                          color: classColor,
                          colorBlendMode: BlendMode.modulate,
                          height: widget.size * scale,
                          filterQuality: FilterQuality.medium,
                          image: const AssetImage(
                              "assets/images/psd/class-token-bg.png")),
                      Image(
                          height: widget.size * scale * 0.45,
                          filterQuality: FilterQuality.medium,
                          image: AssetImage(widget.gfx)),
                    ])
                  : Image(
                      height: widget.size * scale,
                      filterQuality: FilterQuality.medium,
                      image: AssetImage(widget.gfx),
                    ));
        });
  }
}
