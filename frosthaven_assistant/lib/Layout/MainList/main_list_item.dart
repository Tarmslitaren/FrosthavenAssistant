import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../CharacterWidget/character_widget.dart';
import '../MonsterBox/monster_box.dart';
import '../MonsterWidget/monster_widget.dart';

class MainListItem extends StatelessWidget {
  static const double _kCharacterHeight = 60.0;
  static const double _kBoxSpacing = 2.0;
  static const double _kRowHeight = 32.0;
  static const double _kMonsterBodyHeight = 97.6;
  static const int _k2Columns = 2;
  static const int _k3Rows = 3;

  const MainListItem({super.key, required this.data});

  final ListItemData data;

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    Widget child = const SizedBox.shrink();
    double height;
    double listWidth = getMainListWidth(context);
    if (data is Character) {
      Character character = data as Character;
      int? initPreset;
      if (GameMethods.isObjectiveOrEscort(character.characterClass)) {
        initPreset = character.characterState.initiative.value;
      }
      child = CharacterWidget(
          key: Key(character.id),
          characterId: character.id,
          initPreset: initPreset);
      height = _kCharacterHeight * scale;
      final summonList = character.characterState.summonList;
      if (summonList.isNotEmpty) {
        double summonsTotalWidth = 0;
        for (final monsterInstance in summonList) {
          summonsTotalWidth += MonsterBox.getWidth(scale, monsterInstance) +
              _kBoxSpacing * scale;
        }
        double rows = summonsTotalWidth / listWidth;
        height += _kRowHeight * rows.ceil() * scale;
      }
    } else if (data is Monster) {
      Monster monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
      int standeeRows = 0;
      if (monster.monsterInstances.isNotEmpty) {
        standeeRows = 1;
      }
      double totalWidthOfMonsterBoxes = 0;
      for (final item in monster.monsterInstances) {
        totalWidthOfMonsterBoxes +=
            MonsterBox.getWidth(scale, item) + _kBoxSpacing * scale;
      }
      if (totalWidthOfMonsterBoxes > listWidth) {
        standeeRows = _k2Columns;
      }
      if (totalWidthOfMonsterBoxes > _k2Columns * listWidth) {
        standeeRows = _k3Rows;
      }
      height = _kMonsterBodyHeight * scale + standeeRows * _kRowHeight * scale;
    } else {
      height = 0;
    }

    return RepaintBoundary(
        child: AnimatedContainer(
      key: child.key,
      height: height,
      duration: const Duration(milliseconds: 500),
      child: child,
    ));
  }
}
