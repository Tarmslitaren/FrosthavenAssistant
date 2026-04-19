import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/color_matrices.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../health_wheel_controller.dart';
import '../monster_box.dart';
import '../view_models/character_view_model.dart';
import 'character_widget_internal.dart';

class CharacterWidget extends StatefulWidget {
  static const int _kAnimationDurationMs = 300;
  static const double _kSpacing = 2.0;
  static const double _kElevation = 8.0;
  static const double _kMarginH = 3.2;
  static const int _kBothSides = 2;

  const CharacterWidget(
      {required this.characterId,
      super.key,
      this.initPreset,
      this.gameState,
      this.settings});

  final String characterId;
  final int? initPreset;

  final GameState? gameState;
  // injected for testing
  final Settings? settings;

  @override
  CharacterWidgetState createState() => CharacterWidgetState();
}

class CharacterWidgetState extends State<CharacterWidget> {
  bool isCharacter = true;
  List<MonsterInstance> lastList = [];

  @override
  void initState() {
    final character = GameMethods.getCharacterByName(widget.characterId);
    if (character != null) {
      lastList = character.characterState.summonList.toList();
    }
    super.initState();
  }

  Widget _buildCharacterContent(CharacterViewModel vm, Character character,
      bool isCharacter, Widget inner) {
    if (vm.isChooseInitiative) {
      return CharacterWidgetInternal(
          character: character,
          isCharacter: isCharacter,
          characterId: character.id,
          initPreset: widget.initPreset);
    }
    if (vm.showHealthWheel) {
      return HealthWheelController(
          figureId: widget.characterId,
          ownerId: widget.characterId,
          child: inner);
    }
    return inner;
  }

  Widget buildMonsterBoxGrid(double scale, Character character) {
    String displayStartAnimation = "";

    final summonList = character.characterState.summonList;
    if (lastList.length < summonList.length) {
      //find which is new - always the last one
      displayStartAnimation =
          summonList.last.getId(); //issue: if several with same id?
    }

    final generatedChildren = List<Widget>.generate(
        summonList.length,
        (index) => AnimatedSize(
              //not really needed now
              key: Key(index.toString()),
              duration: const Duration(
                  milliseconds: CharacterWidget._kAnimationDurationMs),
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
      runSpacing: CharacterWidget._kSpacing * scale,
      spacing: CharacterWidget._kSpacing * scale,
      children: generatedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = GameMethods.getCharacterByName(widget.characterId);
    if (character == null) return Container();

    final vm = CharacterViewModel(character,
        gameState: widget.gameState, settings: widget.settings);

    return InkWell(
        onTap: () => vm.openStatusMenu(context),
        child: ListenableBuilder(
            listenable: vm.updateList,
            builder: (context, child) {
              final double scale = getScaleByReference(context);

              Widget inner = PhysicalShape(
                  color:
                      vm.isCurrentTurn ? Colors.tealAccent : Colors.transparent,
                  shadowColor: Colors.black,
                  elevation: CharacterWidget._kElevation,
                  clipper:
                      const ShapeBorderClipper(shape: RoundedRectangleBorder()),
                  child: CharacterWidgetInternal(
                    character: character,
                    isCharacter: isCharacter,
                    characterId: character.id,
                    initPreset: widget.initPreset,
                  ));

              return Column(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  margin: EdgeInsets.only(
                      left: CharacterWidget._kMarginH * scale,
                      right: CharacterWidget._kMarginH * scale),
                  width: getMainListWidth(context) -
                      CharacterWidget._kMarginH *
                          CharacterWidget._kBothSides *
                          scale,
                  child: ValueListenableBuilder<BuiltList<MonsterInstance>>(
                      valueListenable: vm.summonListNotifier,
                      builder: (context, value, child) {
                        return buildMonsterBoxGrid(scale, character);
                      }),
                ),
                ColorFiltered(
                    colorFilter: vm.notGrayScale
                        ? ColorFilter.matrix(identity)
                        : ColorFilter.matrix(grayScale),
                    child: _buildCharacterContent(
                        vm, character, isCharacter, inner))
              ]);
            }));
  }
}
