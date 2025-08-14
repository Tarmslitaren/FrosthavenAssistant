import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Resource/commands/remove_amd_card_command.dart';
import '../../Resource/commands/return_modifier_card_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveAMDCardMenu extends StatefulWidget {
  const RemoveAMDCardMenu({super.key, required this.index, required this.name});

  final int index;
  final String name;

  @override
  RemoveAMDCardMenuState createState() => RemoveAMDCardMenuState();
}

class RemoveAMDCardMenuState extends State<RemoveAMDCardMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(widget.name, _gameState);
    final card = deck.discardPile.getList()[widget.index];
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ModifierCardWidget.buildFront(card, widget.name, 6),
      const SizedBox(
        height: 20,
      ),
      Container(
          width: 300,
          height: 180,
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
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  _gameState
                      .action(RemoveAMDCardCommand(widget.index, widget.name));

                  Navigator.pop(context);
                },
                child: const Text("Remove card?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20))),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                _gameState.action(ReturnModifierCardCommand(widget.name));
                final deck =
                    GameMethods.getModifierDeck(widget.name, _gameState);
                //if last card, remove modal
                if (deck.discardPile.isEmpty) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Return top card",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(
              height: 20,
            ),
          ]))
    ]);
  }
}
