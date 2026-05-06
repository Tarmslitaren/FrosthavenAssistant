import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_ability_list_command.dart';
import 'package:frosthaven_assistant/Resource/commands/shuffle_drawn_ability_card_command.dart';

import '../../Layout/view_models/remove_card_menu_view_model.dart';
import '../../Layout/widgets/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveCardMenu extends StatelessWidget {
  final MonsterAbilityCardModel card;

  const RemoveCardMenu({
    super.key,
    required this.card,
    this.gameState,
  });

  final GameState? gameState;

  static const double _kModalHeight = 210;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final vm = RemoveCardMenuViewModel(card, gameState: _gameState);

    return ModalBackground(
        width: kMenuNarrowWidth,
        height: _kModalHeight,
        child: Column(children: [
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {
                _gameState
                    .action(RemoveCardCommand(card, gameState: _gameState));
                Navigator.pop(context);
              },
              child: Text("Remove ${card.title}\n(card nr: ${card.nr})",
                  textAlign: TextAlign.center, style: kButtonLabelStyle)),
          const SizedBox(height: 10),
          if (vm.isInDrawPile)
            TextButton(
                onPressed: () {
                  _gameState.action(ReorderAbilityListCommand(
                      card.deck, 0, vm.drawPileIndex,
                      gameState: _gameState));
                  Navigator.pop(context);
                },
                child: const Text("Send to Bottom", style: kButtonLabelStyle)),
          if (vm.isInDrawPile) const SizedBox(height: 10),
          if (vm.isInDrawPile)
            TextButton(
                onPressed: () {
                  _gameState.action(ShuffleDrawnAbilityCardCommand(card.deck));
                  Navigator.pop(context);
                },
                child: const Text("Shuffle un-drawn Cards",
                    style: kButtonLabelStyle)),
        ]));
  }
}
