import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/status_menu.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/color_matrices.dart';
import '../../Resource/enums.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../health_wheel_controller.dart';
import '../monster_box.dart';
import 'character_widget_internal.dart';

class CharacterWidget extends StatefulWidget {
  const CharacterWidget(
      {required this.characterId, super.key, this.initPreset});

  final String characterId;
  final int? initPreset;

  @override
  CharacterWidgetState createState() => CharacterWidgetState();
}

class CharacterWidgetState extends State<CharacterWidget> {
  final GameState _gameState = getIt<GameState>();
  bool isCharacter = true;
  late List<MonsterInstance> lastList = [];
  late Character character;

  Widget buildWithHealthWheel() {
    return HealthWheelController(
        figureId: widget.characterId,
        ownerId: widget.characterId,
        child: PhysicalShape(
            color: character.turnState.value == TurnsState.current
                ? Colors.tealAccent
                : Colors.transparent,
            shadowColor: Colors.black,
            elevation: 8,
            clipper: const ShapeBorderClipper(shape: RoundedRectangleBorder()),
            child: CharacterWidgetInternal(
              character: character,
              isCharacter: isCharacter,
              characterId: character.id,
              initPreset: widget.initPreset,
            )));
  }

  Widget buildMonsterBoxGrid(double scale) {
    String displayStartAnimation = "";

    final summonList = character.characterState.summonList;
    if (lastList.length < summonList.length) {
      //find which is new - always the last one
      displayStartAnimation = summonList.last.getId();
    }

    final generatedChildren = List<Widget>.generate(
        summonList.length,
        (index) => AnimatedSize(
              //not really needed now
              key: Key(index.toString()),
              duration: const Duration(milliseconds: 300),
              child: MonsterBox(
                  key: Key(summonList[index].getId()),
                  figureId: summonList[index].name +
                      summonList[index].gfx +
                      summonList[index].standeeNr.toString(),
                  ownerId: character.id,
                  displayStartAnimation: displayStartAnimation,
                  blockInput: false,
                  scale: scale),
            ));
    lastList = summonList.toList();
    return Wrap(
      runSpacing: 2.0 * scale,
      spacing: 2.0 * scale,
      children: generatedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    for (var item in _gameState.currentList) {
      if (item.id == widget.characterId && item is Character) {
        character = item;
      }
    }

    return InkWell(
        canRequestFocus: false,
        onTap: () {
          //open stats menu
          openDialog(
            context,
            StatusMenu(figureId: character.id, characterId: character.id),
          );
        },
        child: ValueListenableBuilder<int>(
            valueListenable: getIt<GameState>().updateList,
            builder: (context, value, child) {
              bool notGrayScale = character.characterState.health.value != 0 &&
                  (character.turnState.value != TurnsState.done ||
                      getIt<GameState>().roundState.value ==
                          RoundState.chooseInitiative);
              double scale = getScaleByReference(context);
              return Column(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  margin:
                      EdgeInsets.only(left: 3.2 * scale, right: 3.2 * scale),
                  width: getMainListWidth(context) - 6.4 * scale,
                  child: ValueListenableBuilder<int>(
                      valueListenable: getIt<GameState>().killMonsterStandee,
                      builder: (context, value, child) {
                        return buildMonsterBoxGrid(scale);
                      }),
                ),
                ColorFiltered(
                    colorFilter: notGrayScale
                        ? ColorFilter.matrix(identity)
                        : ColorFilter.matrix(grayScale),
                    child: _gameState.roundState.value ==
                            RoundState.chooseInitiative
                        ? CharacterWidgetInternal(
                            character: character,
                            isCharacter: isCharacter,
                            characterId: character.id,
                            initPreset: widget.initPreset)
                        : buildWithHealthWheel())
              ]);
            }));
  }
}
