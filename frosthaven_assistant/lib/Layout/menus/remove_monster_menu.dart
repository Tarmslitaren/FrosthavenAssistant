import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/remove_monster_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class RemoveMonsterMenu extends StatefulWidget {
  const RemoveMonsterMenu({Key? key}) : super(key: key);

  @override
  _RemoveMonsterMenuState createState() => _RemoveMonsterMenuState();
}

class _RemoveMonsterMenuState extends State<RemoveMonsterMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Monster> currentMonsters = GameMethods.getCurrentMonsters();
    return Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Card(
            child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              ListTile(
                title: const Text("Remove All", style: TextStyle(fontSize: 18)),
                onTap: () {
                  _gameState.action(RemoveMonsterCommand(currentMonsters)); //
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonsters.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Image(
                      height: 30,
                      image: AssetImage(
                          "assets/images/monsters/${currentMonsters[index].type.gfx}.png"),
                    ),
                    //iconColor: currentCharacters[index].characterClass.color,
                    title: Text(currentMonsters[index].type.display,
                        style: const TextStyle(fontSize: 18)),
                    trailing: Text("(${currentMonsters[index].type.edition})",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    onTap: () {
                      setState(() {
                        _gameState.action(
                            RemoveMonsterCommand([currentMonsters[index]])); //
                      });

                      //Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 34,
              ),
            ],
          ),
          Positioned(
              width: 100,
              right: 0,
              bottom: 0,
              child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }))
        ])));
  }
}
