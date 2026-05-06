import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/enhance_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

const double _kCounterPadding = 3.0;
const double _kCounterBorderRadius = 5.0;
const double _kIconSize = 32.0;
const double _kValuePaddingH = 6.0;
const double _kValuePaddingV = 4.0;
const double _kValueBorderRadius = 1.0;

class EnhancementCounterButton extends StatelessWidget {
  const EnhancementCounterButton(
      {super.key, required this.card, required this.gameState});

  final LootCard card;
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, _, child) {
          return Container(
            padding: const EdgeInsets.all(_kCounterPadding),
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.circular(_kCounterBorderRadius)),
                color: Theme.of(context).colorScheme.secondary),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      if (card.enhanced > 0) {
                        gameState.action(EnhanceLootCardCommand(
                            card.id, card.enhanced - 1, card.gfx,
                            gameState: gameState));
                      }
                    },
                    child: const Icon(Icons.remove,
                        color: Colors.white, size: _kIconSize)),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: _kCounterPadding),
                  padding: const EdgeInsets.symmetric(
                      horizontal: _kValuePaddingH, vertical: _kValuePaddingV),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(_kValueBorderRadius)),
                      color: Colors.white),
                  child: Text(
                    card.enhanced.toString(),
                    style: const TextStyle(
                        color: Colors.black, fontSize: kFontSizeTitle),
                  ),
                ),
                InkWell(
                    onTap: () {
                      gameState.action(EnhanceLootCardCommand(
                          card.id, card.enhanced + 1, card.gfx,
                          gameState: gameState));
                    },
                    child: const Icon(Icons.add,
                        color: Colors.white, size: _kIconSize)),
              ],
            ),
          );
        });
  }
}
