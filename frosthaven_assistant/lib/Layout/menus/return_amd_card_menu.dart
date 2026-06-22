import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/ModifierCardWidget/modifier_card_front.dart';

import '../../Layout/widgets/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/return_removed_amd_card_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../l10n/app_localizations.dart';
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

  static const double _kModalHeight = 220.0;
  static const double _kInnerSpacing = 35.0;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    final card = deck.removedPileContents[index];
    final screenSize = MediaQuery.of(context).size;
    double scale = kCardZoomDefaultScale;
    final cardWidth = kCardZoomWidthFactor * kModifierCardBaseWidth;
    if (screenSize.width < cardWidth) {
      scale = kCardZoomDefaultScale * (screenSize.width / cardWidth);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ModifierCardFront(card: card, name: name, scale: scale),
        const SizedBox(height: kMenuTopPadding),
        ModalBackground(
          width: kMenuNarrowWidth,
          height: _kModalHeight,
          child: Column(
            children: [
              const SizedBox(height: _kInnerSpacing),
              TextButton(
                onPressed: () {
                  _gameState.action(
                    ReturnRemovedAMDCardCommand(
                      index: index,
                      name: name,
                      gameState: _gameState,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.returnToDiscardPile,
                  textAlign: TextAlign.center,
                  style: kButtonLabelStyle,
                ),
              ),
              const SizedBox(height: _kInnerSpacing),
              TextButton(
                onPressed: () {
                  _gameState.action(
                    ReturnRemovedAMDCardCommand(
                      index: index,
                      name: name,
                      toDrawPile: true,
                      gameState: _gameState,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.returnToDrawPile,
                  textAlign: TextAlign.center,
                  style: kButtonLabelStyle,
                ),
              ),
              const SizedBox(height: kMenuTopPadding),
            ],
          ),
        ),
      ],
    );
  }
}
