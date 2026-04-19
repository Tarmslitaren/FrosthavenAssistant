import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/components/menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/commands/remove_monster_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveMonsterMenu extends StatefulWidget {
  const RemoveMonsterMenu({
    super.key,
    this.gameState,
  });

  final GameState? gameState;

  @override
  RemoveMonsterMenuState createState() => RemoveMonsterMenuState();
}

class RemoveMonsterMenuState extends State<RemoveMonsterMenu> {
  static const double _kMaxWidth = 450;
  static const double _kIconHeight = 30;

  GameState get _gameState => widget.gameState ?? getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Monster> currentMonsters = GameMethods.getCurrentMonsters();
    return MenuCard(
        maxWidth: _kMaxWidth,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              title: const Text("Remove All", style: kTitleStyle),
              onTap: () {
                _gameState.action(RemoveMonsterCommand(currentMonsters,
                    gameState: _gameState)); //
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentMonsters.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Image.asset(
                    cacheHeight: kMonsterImageCacheHeight,
                    height: _kIconHeight,
                    "assets/images/monsters/${currentMonsters[index].type.gfx}.png",
                  ),
                  title: Text(currentMonsters[index].type.display,
                      style: kTitleStyle),
                  trailing: Text("(${currentMonsters[index].type.edition})",
                      style: kSubtitleStyle),
                  onTap: () {
                    setState(() {
                      _gameState.action(RemoveMonsterCommand(
                          [currentMonsters[index]],
                          gameState: _gameState));
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
