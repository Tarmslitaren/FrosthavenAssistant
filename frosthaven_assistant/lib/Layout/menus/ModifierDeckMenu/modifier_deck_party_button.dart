import 'package:flutter/material.dart';

import '../../../Resource/commands/add_cs_party_card_command.dart';
import '../../../Resource/state/game_state.dart';

class ModifierDeckPartyButton extends StatelessWidget {
  static const double _kButtonWidth = 32.0;

  const ModifierDeckPartyButton({
    super.key,
    required this.nr,
    required this.gameState,
    required this.name,
  });

  final int nr;
  final GameState gameState;
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: _kButtonWidth,
        child: TextButton(
          child: Text(nr.toString()),
          onPressed: () {
            gameState
                .action(AddCSPartyCardCommand(name, 1, gameState: gameState));
          },
        ));
  }
}
