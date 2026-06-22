import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../Layout/widgets/standee_nr_button.dart';
import '../../../Resource/enums.dart';
import '../../../Resource/ui_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/service_locator.dart';
import '../../../services/translation_service.dart';

const double _kButtonSpacerHeight = 20.0;
const int _kButtonRowSize = 4;

class StandeeButtonGrid extends StatelessWidget {
  const StandeeButtonGrid({
    super.key,
    required this.scale,
    required this.monster,
    required this.elite,
    required this.nrOfStandees,
    required this.nrLeft,
    required this.nrOfElite,
    required this.nrOfNormal,
    required this.isStandeeOut,
    required this.onStandeePress,
  });

  final double scale;
  final Monster monster;
  final bool elite;
  final int nrOfStandees;
  final int nrLeft;
  final int nrOfElite;
  final int nrOfNormal;
  final bool Function(int nr, Monster monster, bool elite, int nrOfElite,
      int nrOfNormal) isStandeeOut;
  final void Function(int nr, Monster monster, MonsterType type, bool elite,
      bool isOut, int nrOfElite, int nrOfNormal) onStandeePress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = getIt<TranslationService>().t(monster.type.display);
    final text = elite
        ? l10n.addEliteStandees(nrLeft, displayName)
        : l10n.addNormalStandees(nrLeft, displayName);

    final rows = <Widget>[];
    for (int start = 1; start <= nrOfStandees; start += _kButtonRowSize) {
      final end = (start + _kButtonRowSize - 1).clamp(1, nrOfStandees);
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          end - start + 1,
          (i) {
            final nr = start + i;
            bool boss = monster.type.levels.first.boss != null;
            MonsterType type = elite
                ? MonsterType.elite
                : (boss ? MonsterType.boss : MonsterType.normal);
            Color color =
                elite ? Colors.yellow : (boss ? Colors.red : Colors.white);
            bool isOut = isStandeeOut(nr, monster, elite, nrOfElite, nrOfNormal);
            if (isOut) color = Colors.grey;
            return StandeeNrButton(
              nr: nr,
              scale: scale,
              color: color,
              onPressed: () => onStandeePress(
                  nr, monster, type, elite, isOut, nrOfElite, nrOfNormal),
            );
          },
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: _kButtonSpacerHeight * scale),
        Text(text, style: getTitleTextStyle(scale)),
        ...rows,
      ],
    );
  }
}
