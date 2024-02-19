import 'package:flutter/material.dart';

import '../../Resource/commands/remove_amd_card_command.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveAMDCardMenu extends StatefulWidget {
  final int index;
  final bool allyDeck;

  const RemoveAMDCardMenu({super.key, required this.index, required this.allyDeck});

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
    return Container(
        width: 300,
        height: 180,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
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
                _gameState.action(RemoveAMDCardCommand(widget.index, widget.allyDeck));

                Navigator.pop(context);
              },
              child: const Text("Remove card?",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20))),
          const SizedBox(
            height: 20,
          ),
        ]));
  }
}
