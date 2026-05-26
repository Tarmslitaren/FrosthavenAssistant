import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';

import '../../Layout/widgets/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/remove_amd_card_command.dart';
import '../../Resource/commands/shuffle_amd_card_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../ModifierCardWidget/modifier_card_front.dart';

class SendToBottomMenu extends StatelessWidget {
  const SendToBottomMenu({
    super.key,
    required this.currentIndex,
    required this.length,
    required this.name,
    required this.revealed,
    this.gameState,
  });
  //it's for modifier deck
  final int currentIndex;
  final int length;
  final String name;
  final bool revealed;

  final GameState? gameState;

  static const double _kModalHeight = 240.0;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    final card = deck.drawPileContents[length - 1 - currentIndex];
    double scale = kCardZoomDefaultScale;
    final cardWidth = kCardZoomWidthFactor * kModifierCardBaseWidth;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < cardWidth) {
      scale = kCardZoomDefaultScale * (screenWidth / cardWidth);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (revealed) ModifierCardFront(card: card, name: name, scale: scale),
        const SizedBox(height: kMenuTopPadding),
        ModalBackground(
          width: kMenuNarrowWidth,
          height: _kModalHeight,
          child: Column(
            children: [
              const SizedBox(height: kMenuTopPadding),
              TextButton(
                onPressed: () {
                  int oldIndex = length - 1 - currentIndex;
                  _gameState.action(
                    ReorderModifierListCommand(
                      0,
                      oldIndex,
                      name,
                      gameState: _gameState,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Send to Bottom", style: kButtonLabelStyle),
              ),
              const SizedBox(height: kMenuTopPadding),
              TextButton(
                onPressed: () {
                  _gameState.action(
                    ShuffleAMDCardCommand(name, gameState: _gameState),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Shuffle un-drawn Cards",
                  style: kButtonLabelStyle,
                ),
              ),
              const SizedBox(height: kMenuTopPadding),
              TextButton(
                onPressed: () {
                  _gameState.action(
                    RemoveAMDCardCommand(
                      index: length - 1 - currentIndex,
                      name: name,
                      gameState: _gameState,
                      fromDrawPile: true,
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  "Remove card?",
                  textAlign: TextAlign.center,
                  style: kButtonLabelStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
