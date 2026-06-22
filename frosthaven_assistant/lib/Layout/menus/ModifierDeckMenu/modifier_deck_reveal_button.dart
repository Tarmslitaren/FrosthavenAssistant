import 'package:flutter/material.dart';

import '../../../Resource/commands/amd_reveal_command.dart';
import '../../../Resource/state/game_state.dart';
import '../../../l10n/app_localizations.dart';

class ModifierDeckRevealButton extends StatelessWidget {
  static const double _kRevealButtonWidth = 32.0;

  const ModifierDeckRevealButton({
    super.key,
    required this.nrOfButtons,
    required this.nr,
    required this.gameState,
    required this.name,
  });

  final int nrOfButtons;
  final int nr;
  final GameState gameState;
  final String name;

  @override
  Widget build(BuildContext context) {
    final text = nr < nrOfButtons
        ? nr.toString()
        : AppLocalizations.of(context)!.revealAll;
    return SizedBox(
        width: _kRevealButtonWidth,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            gameState.action(
                AMDRevealCommand(amount: nr, name: name, gameState: gameState));
          },
        ));
  }
}
