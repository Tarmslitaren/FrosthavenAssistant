import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';

import '../../Resource/commands/shuffle_amd_card_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../modifier_card_widget.dart';

class SendToBottomMenu extends StatefulWidget {
  const SendToBottomMenu(
      {super.key,
      required this.currentIndex,
      required this.length,
      required this.name,
      required this.revealed});
  //it's for modifier deck
  final int currentIndex;
  final int length;
  final String name;
  final bool revealed;

  @override
  SendToBottomMenuState createState() => SendToBottomMenuState();
}

class SendToBottomMenuState extends State<SendToBottomMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deck = GameMethods.getModifierDeck(widget.name, _gameState);
    final card =
        deck.drawPile.getList()[widget.length - 1 - widget.currentIndex];
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (widget.revealed) ModifierCardWidget.buildFront(card, widget.name, 6),
      const SizedBox(
        height: 20,
      ),
      Container(
          width: 300,
          height: 140,
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
                  int oldIndex = widget.length - 1 - widget.currentIndex;
                  _gameState.action(
                      ReorderModifierListCommand(0, oldIndex, widget.name));
                  Navigator.pop(context);
                },
                child: const Text("Send to Bottom",
                    style: TextStyle(fontSize: 20))),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  _gameState.action(ShuffleAMDCardCommand(widget.name));
                  Navigator.pop(context);
                },
                child: const Text("Shuffle un-drawn Cards",
                    style: TextStyle(fontSize: 20))),
          ]))
    ]);
  }
}
