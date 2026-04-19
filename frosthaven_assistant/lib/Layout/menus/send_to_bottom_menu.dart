import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';

import '../../Layout/components/modal_background.dart';
import '../../Resource/app_constants.dart';
import '../../Resource/commands/shuffle_amd_card_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../modifier_card_widget.dart';

class SendToBottomMenu extends StatelessWidget {
  const SendToBottomMenu(
      {super.key,
      required this.currentIndex,
      required this.length,
      required this.name,
      required this.revealed,
      this.gameState});
  //it's for modifier deck
  final int currentIndex;
  final int length;
  final String name;
  final bool revealed;

  final GameState? gameState;

  static const double _kDefaultScale = 6.0;
  static const double _kCardWidthFactor = 7.0;
  static const double _kCardWidthBase = 58.6666;
  static const double _kSpacing = 20.0;
  static const double _kModalWidth = 300.0;
  static const double _kModalHeight = 140.0;

  GameState get _gameState => gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    final card = deck.drawPileContents[length - 1 - currentIndex];
    double scale = _kDefaultScale;
    final cardWidth = _kCardWidthFactor * _kCardWidthBase;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < cardWidth) {
      scale = _kDefaultScale * (screenWidth / cardWidth);
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (revealed) ModifierCardFront(card: card, name: name, scale: scale),
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
                      int oldIndex = length - 1 - currentIndex;
                      _gameState.action(ReorderModifierListCommand(
                          0, oldIndex, name,
                          gameState: _gameState));
                      Navigator.pop(context);
                    },
                    child:
                        const Text("Send to Bottom", style: kButtonLabelStyle)),
                const SizedBox(
                  height: _kSpacing,
                ),
                TextButton(
                    onPressed: () {
                      _gameState.action(
                          ShuffleAMDCardCommand(name, gameState: _gameState));
                      Navigator.pop(context);
                    },
                    child: const Text("Shuffle un-drawn Cards",
                        style: kButtonLabelStyle)),
              ]))
        ]);
  }
}
