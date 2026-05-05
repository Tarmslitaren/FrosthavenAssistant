import 'package:flutter/material.dart';

import '../../../Resource/enums.dart';
import '../condition_button.dart';

class StatusMenuExtraConditionRow extends StatelessWidget {
  const StatusMenuExtraConditionRow({
    super.key,
    required this.isCharacter,
    required this.isSummon,
    required this.hasMireFoot,
    required this.showCustomContent,
    required this.figureId,
    required this.ownerId,
    required this.immunities,
    required this.scale,
  });

  final bool isCharacter;
  final bool isSummon;
  final bool hasMireFoot;
  final bool showCustomContent;
  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final double scale;

  @override
  Widget build(BuildContext context) {
    Widget btn(Condition c) => ConditionButton(
          condition: c,
          figureId: figureId,
          ownerId: ownerId,
          immunities: immunities,
          scale: scale,
        );

    if (isCharacter || isSummon) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (showCustomContent) btn(Condition.infect),
        if (!isSummon) btn(Condition.impair),
        if (showCustomContent) btn(Condition.rupture),
      ]);
    }
    if (!hasMireFoot) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (showCustomContent) btn(Condition.poison2),
        if (showCustomContent) btn(Condition.rupture),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      btn(Condition.wound2),
      btn(Condition.poison2),
      btn(Condition.poison3),
      btn(Condition.poison4),
      btn(Condition.rupture),
    ]);
  }
}
