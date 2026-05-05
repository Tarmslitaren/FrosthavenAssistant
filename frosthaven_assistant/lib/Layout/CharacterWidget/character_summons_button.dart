import 'package:flutter/material.dart';

import '../../Resource/app_constants.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../menus/AddSummonMenu/add_summon_menu.dart';

class CharacterSummonsButton extends StatelessWidget {
  static const double _kButtonSize = 50.0;

  const CharacterSummonsButton(
      {super.key, required this.scale, required this.character});
  final double scale;
  final Character character;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: CharacterSummonsButton._kButtonSize * scale,
        height: CharacterSummonsButton._kButtonSize * scale,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Image.asset(
              height: kIconSize * scale,
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
