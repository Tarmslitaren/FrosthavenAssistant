import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/components/menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/commands/remove_monster_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveMonsterMenu extends StatefulWidget {
  const RemoveMonsterMenu({super.key});

  @override
  RemoveMonsterMenuState createState() => RemoveMonsterMenuState();
}

class RemoveMonsterMenuState extends State<RemoveMonsterMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Monster> currentMonsters = GameMethods.getCurrentMonsters();
    return MenuCard(
        maxWidth: 450,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              title: const Text("Remove All", style: TextStyle(fontSize: kFontSizeTitle)),
              onTap: () {
                _gameState.action(RemoveMonsterCommand(currentMonsters)); //
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentMonsters.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Image.asset(
                    cacheHeight: kMonsterImageCacheHeight,
                    height: 30,
                    "assets/images/monsters/${currentMonsters[index].type.gfx}.png",
                  ),
                  title: Text(currentMonsters[index].type.display,
                      style: const TextStyle(fontSize: kFontSizeTitle)),
                  trailing: Text("(${currentMonsters[index].type.edition})",
                      style:
                          const TextStyle(fontSize: kFontSizeSmall, color: Colors.grey)),
                  onTap: () {
                    setState(() {
                      _gameState.action(
                          RemoveMonsterCommand([currentMonsters[index]]));
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: kMenuCloseButtonSpacing,
            ),
          ],
        ));
  }
}
