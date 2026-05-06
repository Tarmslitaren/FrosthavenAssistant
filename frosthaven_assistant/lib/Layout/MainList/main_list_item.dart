import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../CharacterWidget/character_widget.dart';
import '../MonsterWidget/monster_widget.dart';
import '../view_models/main_list_item_view_model.dart';

class MainListItem extends StatelessWidget {
  const MainListItem({super.key, required this.data});

  final ListItemData data;

  @override
  Widget build(BuildContext context) {
    final double scale = getScaleByReference(context);
    final double listWidth = getMainListWidth(context);
    final vm = MainListItemViewModel(data: data, scale: scale, listWidth: listWidth);

    Widget child;
    if (data is Character) {
      final character = data as Character;
      child = CharacterWidget(
          key: Key(character.id),
          characterId: character.id,
          initPreset: vm.initPreset);
    } else if (data is Monster) {
      final monster = data as Monster;
      child = MonsterWidget(key: Key(monster.id), data: monster);
    } else {
      child = const SizedBox.shrink();
    }

    return RepaintBoundary(
        child: AnimatedContainer(
      key: child.key,
      height: vm.height,
      duration: const Duration(milliseconds: 500),
      child: child,
    ));
  }
}
