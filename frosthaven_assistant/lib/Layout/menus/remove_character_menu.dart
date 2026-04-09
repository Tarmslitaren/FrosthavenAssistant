import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/components/menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_menu.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/remove_character_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
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
      //todo: ask if wanna save
      setState(() {
        int indexToRemove = currentCharacters.indexWhere(
            (character) => character.characterClass == characterClassToRemove);

        if (indexToRemove != -1) {
          _gameState.action(
              RemoveCharacterCommand([currentCharacters[indexToRemove]]));
        }
      });
    }

    return MenuCard(
        maxWidth: 400,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                //open remove card menu
                openDialog(context, SaveCharacterMenu());
              },
              child: Text(
                "Load or Save Characters",
                style: kTitleStyle,
              ),
            ),
            ListTile(
              title: const Text("Remove All", style: kTitleStyle),
              onTap: () {
                //todo: ask if wanna save
                _gameState.action(RemoveCharacterCommand(currentCharacters));
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
              height: kMenuCloseButtonSpacing,
            ),
          ],
        ));
  }
}
