import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../MonsterBox/monster_box.dart';

const double _kCharacterHeight = 60.0;
const double _kBoxSpacing = 2.0;
const double _kRowHeight = 32.0;
const double _kMonsterBodyHeight = 97.6;
const int _k2Columns = 2;
const int _k3Rows = 3;

class MainListItemViewModel {
  const MainListItemViewModel({
    required this.data,
    required this.scale,
    required this.listWidth,
  });

  final ListItemData data;
  final double scale;
  final double listWidth;

  int? get initPreset {
    if (data is Character) {
      final character = data as Character;
      if (GameMethods.isObjectiveOrEscort(character.characterClass)) {
        return character.characterState.initiative.value;
      }
    }
    return null;
  }

  double get height {
    if (data is Character) {
      final character = data as Character;
      double h = _kCharacterHeight * scale;
      final summonList = character.characterState.summonList;
      if (summonList.isNotEmpty) {
        double summonsTotalWidth = 0;
        for (final monsterInstance in summonList) {
          summonsTotalWidth +=
              MonsterBox.getWidth(scale, monsterInstance) + _kBoxSpacing * scale;
        }
        final double rows = summonsTotalWidth / listWidth;
        h += _kRowHeight * rows.ceil() * scale;
      }
      return h;
    } else if (data is Monster) {
      final monster = data as Monster;
      int standeeRows = monster.monsterInstances.isNotEmpty ? 1 : 0;
      double totalWidthOfMonsterBoxes = 0;
      for (final item in monster.monsterInstances) {
        totalWidthOfMonsterBoxes +=
            MonsterBox.getWidth(scale, item) + _kBoxSpacing * scale;
      }
      if (totalWidthOfMonsterBoxes > listWidth) standeeRows = _k2Columns;
      if (totalWidthOfMonsterBoxes > _k2Columns * listWidth) standeeRows = _k3Rows;
      return _kMonsterBodyHeight * scale + standeeRows * _kRowHeight * scale;
    }
    return 0;
  }
}
