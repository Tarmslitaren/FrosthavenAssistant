import 'package:flutter/material.dart';

import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../menus/add_summon_menu.dart';

class CharacterSummonsButton extends StatelessWidget {
  const CharacterSummonsButton(
      {super.key, required this.scale, required this.character});
  final double scale;
  final Character character;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50 * scale,
        height: 50 * scale,
        child: IconButton(
          focusNode: FocusNode(skipTraversal: true),
          padding: EdgeInsets.zero,
          icon: Image.asset(
              height: 30 * scale,
              fit: BoxFit.fitHeight,
              color: Colors.white24,
              colorBlendMode: BlendMode.modulate,
              'assets/images/psd/add.png'),
          onPressed: () {
            openDialog(
              context,
              AddSummonMenu(
                character: character,
              ),
            );
          },
        ));
  }
}
