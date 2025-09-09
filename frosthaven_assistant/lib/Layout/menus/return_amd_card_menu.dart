import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Resource/commands/return_removed_amd_card_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class ReturnAMDCardMenu extends StatefulWidget {
  const ReturnAMDCardMenu({super.key, required this.index, required this.name});

  final int index;
  final String name;

  @override
  RemoveAMDCardMenuState createState() => RemoveAMDCardMenuState();
}

class RemoveAMDCardMenuState extends State<ReturnAMDCardMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(widget.name, _gameState);
    final card = deck.removedPile.getList()[widget.index];
    final screenSize = MediaQuery.of(context).size;
    double scale = 6;
    final cardWidth = 7 * 58.6666;
    if (screenSize.width < cardWidth) {
      scale = 6 * (screenSize.width / cardWidth);
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModifierCardWidget.buildFront(card, widget.name, scale, 1),
          const SizedBox(
            height: 20,
          ),
          Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: AssetImage(getIt<Settings>().darkMode.value
                      ? 'assets/images/bg/dark_bg.png'
                      : 'assets/images/bg/white_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(children: [
                const SizedBox(
                  height: 35,
                ),
                TextButton(
                    onPressed: () {
                      _gameState.action(ReturnRemovedAMDCardCommand(
                          widget.index, widget.name));
                      Navigator.pop(context);
                    },
                    child: const Text("Return card to discard pile",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20))),
                const SizedBox(
                  height: 20,
                ),
              ]))
        ]);
  }
}
