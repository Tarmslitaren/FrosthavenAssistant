import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_card_command.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class RemoveCardMenu extends StatefulWidget {
  final MonsterAbilityCardModel card;

  const RemoveCardMenu({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  RemoveCardMenuState createState() => RemoveCardMenuState();
}

class RemoveCardMenuState extends State<RemoveCardMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 20,),
          Text(
            "Remove ${widget.card.title} Card? (nr: ${widget.card.nr})",
            style: getTitleTextStyle(),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
            TextButton(

                onPressed: (){
                  _gameState.action(RemoveCardCommand(widget.card));

                  Navigator.pop(context);
                },
                child: const Text("OK",style: TextStyle(fontSize: 20))),

            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text("Cancel",style: TextStyle(fontSize: 20))),
          ])
        ]));
  }
}
