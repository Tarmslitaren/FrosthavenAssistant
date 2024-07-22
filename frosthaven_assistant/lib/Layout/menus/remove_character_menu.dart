import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/remove_character_command.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import './character_tile.dart';

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

    void removeCharacter(CharacterClass characterClassToRemove) {
      setState(() {
        int indexToRemove = currentCharacters.indexWhere(
            (character) => character.characterClass == characterClassToRemove);

        if (indexToRemove != -1) {
          _gameState.action(
              RemoveCharacterCommand([currentCharacters[indexToRemove]]));
        }
      });
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
                  _gameState
                      .action(RemoveCharacterCommand(currentCharacters));
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: currentCharacters.length,
                    itemBuilder: (context, index) {
                      return CharacterTile(
                          character: currentCharacters[index].characterClass,
                          onSelect: removeCharacter);
                    }),
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
