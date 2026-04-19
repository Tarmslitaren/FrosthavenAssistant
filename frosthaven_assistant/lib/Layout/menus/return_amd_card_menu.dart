import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/return_removed_amd_card_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class ReturnAMDCardMenu extends StatelessWidget {
  const ReturnAMDCardMenu({
    super.key,
    required this.index,
    required this.name,
    this.gameState,
  });

  final int index;
  final String name;

  final GameState? gameState;

  static const double _kDefaultScale = 6.0;
  static const double _kCardWidthFactor = 7.0;
  static const double _kCardWidthBase = 58.6666;
  static const double _kTopSpacing = 20.0;
  static const double _kModalWidth = 300.0;
  static const double _kModalHeight = 120.0;
  static const double _kInnerSpacing = 35.0;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    final card = deck.removedPileContents[index];
    final screenSize = MediaQuery.of(context).size;
    double scale = _kDefaultScale;
    final cardWidth = _kCardWidthFactor * _kCardWidthBase;
    if (screenSize.width < cardWidth) {
      scale = _kDefaultScale * (screenSize.width / cardWidth);
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModifierCardFront(card: card, name: name, scale: scale),
          const SizedBox(
            height: _kTopSpacing,
          ),
          ModalBackground(
              width: _kModalWidth,
              height: _kModalHeight,
              child: Column(children: [
                const SizedBox(
                  height: _kInnerSpacing,
                ),
                TextButton(
                    onPressed: () {
                      _gameState.action(ReturnRemovedAMDCardCommand(index, name,
                          gameState: _gameState));
                      Navigator.pop(context);
                    },
                    child: const Text("Return card to discard pile",
                        textAlign: TextAlign.center, style: kButtonLabelStyle)),
                const SizedBox(
                  height: _kTopSpacing,
                ),
              ]))
        ]);
  }
}
