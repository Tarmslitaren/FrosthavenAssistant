import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/remove_amd_card_command.dart';
import '../../Resource/commands/return_modifier_card_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveAMDCardMenu extends StatelessWidget {
  const RemoveAMDCardMenu({
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
  static const double _kSpacing = 20.0;
  static const double _kModalWidth = 300.0;
  static const double _kModalHeight = 180.0;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    final card = deck.discardPileContents[index];
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
            height: _kSpacing,
          ),
          ModalBackground(
              width: _kModalWidth,
              height: _kModalHeight,
              child: Column(children: [
                const SizedBox(
                  height: _kSpacing,
                ),
                TextButton(
                    onPressed: () {
                      _gameState.action(RemoveAMDCardCommand(index, name,
                          gameState: _gameState));

                      Navigator.pop(context);
                    },
                    child: const Text("Remove card?",
                        textAlign: TextAlign.center, style: kButtonLabelStyle)),
                const SizedBox(
                  height: _kSpacing,
                ),
                TextButton(
                  onPressed: () {
                    _gameState.action(ReturnModifierCardCommand(name));
                    final deck = GameMethods.getModifierDeck(name, _gameState);
                    //if last card, remove modal
                    if (deck.discardPileIsEmpty) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Return top card",
                      textAlign: TextAlign.center, style: kButtonLabelStyle),
                ),
                const SizedBox(
                  height: _kSpacing,
                ),
              ]))
        ]);
  }
}
