import 'package:flutter/material.dart';

import '../../../Resource/enums.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../condition_button.dart';
import 'status_menu_extra_condition_row.dart';
import 'status_menu_summon_button.dart';

class StatusMenuConditionPanel extends StatelessWidget {
  static const double _kTopSpacing = 2.0;
  static const int _kChar2Min = 1;
  static const int _kChar3Min = 2;
  static const int _kChar4Min = 3;

  const StatusMenuConditionPanel({
    super.key,
    required this.figureId,
    required this.ownerId,
    required this.immunities,
    required this.scale,
    required this.isMonster,
    required this.isCharacter,
    required this.isSummon,
    required this.nrOfCharacters,
    required this.showCustomContent,
    required this.hasMireFoot,
    required this.gameState,
    required this.settings,
  });

  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final double scale;
  final bool isMonster;
  final bool isCharacter;
  final bool isSummon;
  final int nrOfCharacters;
  final bool showCustomContent;
  final bool hasMireFoot;
  final GameState gameState;
  final Settings settings;

  Widget _btn(Condition condition) => ConditionButton(
        condition: condition,
        figureId: figureId,
        ownerId: ownerId,
        immunities: immunities,
        scale: scale,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: _kTopSpacing * scale),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(Condition.stun),
          _btn(Condition.immobilize),
          _btn(Condition.disarm),
          _btn(Condition.wound),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(Condition.muddle),
          _btn(Condition.poison),
          _btn(Condition.bane),
          _btn(Condition.brittle),
          _btn(Condition.safeguard),
        ]),
        StatusMenuExtraConditionRow(
            isCharacter: isCharacter,
            isSummon: isSummon,
            hasMireFoot: hasMireFoot,
            showCustomContent: showCustomContent,
            figureId: figureId,
            ownerId: ownerId,
            immunities: immunities,
            scale: scale),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(Condition.strengthen),
          _btn(Condition.invisible),
          _btn(Condition.regenerate),
          _btn(Condition.ward),
          if (showCustomContent) _btn(Condition.dodge),
        ]),
        if (isMonster)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (nrOfCharacters > 0) _btn(Condition.character1),
            if (nrOfCharacters > _kChar2Min) _btn(Condition.character2),
            if (nrOfCharacters > _kChar3Min) _btn(Condition.character3),
            if (nrOfCharacters > _kChar4Min) _btn(Condition.character4),
            StatusMenuSummonButton(
                figureId: figureId,
                ownerId: ownerId,
                scale: scale,
                gameState: gameState,
                settings: settings),
          ]),
      ],
    );
  }
}
