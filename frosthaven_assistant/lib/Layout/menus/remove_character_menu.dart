import 'package:flutter/material.dart';

import '../../Resource/commands/remove_character_command.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class RemoveCharacterMenu extends StatefulWidget {
  const RemoveCharacterMenu({super.key});

  @override
  RemoveCharacterMenuState createState() => RemoveCharacterMenuState();
}

class RemoveCharacterMenuState extends State<RemoveCharacterMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Character> currentCharacters = [];
    for (var data in _gameState.currentList) {
      if (data is Character) {
        currentCharacters.add(data);
      }
    }
    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                  _gameState.action(RemoveCharacterCommand(currentCharacters)); //
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentCharacters.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Image(
                      height: 30,
                      width: 30,
                      filterQuality: FilterQuality.medium,
                      fit: BoxFit.scaleDown,
                      color: currentCharacters[index].characterClass.name == "Escort" ||
                              currentCharacters[index].characterClass.name == "Objective"
                          ? null
                          : currentCharacters[index].characterClass.color,
                      image: AssetImage(
                          "assets/images/class-icons/${currentCharacters[index].characterClass.name}.png"),
                    ),
                    iconColor: currentCharacters[index].characterClass.color,
                    title: Text(currentCharacters[index].characterState.display.value,
                        style: const TextStyle(fontSize: 18)),
                    trailing: Text("(${currentCharacters[index].characterClass.edition})",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    onTap: () {
                      setState(() {
                        _gameState.action(RemoveCharacterCommand([currentCharacters[index]])); //
                      });
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
              height: 40,
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
