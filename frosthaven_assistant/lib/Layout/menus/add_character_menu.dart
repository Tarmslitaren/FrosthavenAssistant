import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/add_character_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import 'character_tile.dart';

class AddCharacterMenu extends StatefulWidget {
  const AddCharacterMenu({super.key});

  @override
  AddCharacterMenuState createState() => AddCharacterMenuState();
}

class AddCharacterMenuState extends State<AddCharacterMenu> {
  // This list holds the data for the list view
  List<CharacterClass> _foundCharacters = [];
  final List<CharacterClass> _allCharacters = [];
  late CharacterClass bs;
  late CharacterClass vq;
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  final ScrollController _scrollController = ScrollController();

  int compareEditions(String a, String b) {
    for (String item in _gameData.editions) {
      if (b == item && a != item) {
        return 1;
      }
      if (a == item && b != item) {
        return -1;
      }
    }
    return a.compareTo(b);
  }

  @override
  initState() {
    // at the beginning, all users are shown
    for (String key in _gameData.modelData.value.keys) {
      _allCharacters.addAll(_gameData.modelData.value[key]!.characters);
    }

    for (var item in _allCharacters) {
      if (item.name == "Bladeswarm") {
        _allCharacters.remove(item);
        bs = item;
        break;
      }
    }
    for (var item in _allCharacters) {
      if (item.name == "Vanquisher") {
        _allCharacters.remove(item);
        vq = item;
        break;
      }
    }

    if (getIt<Settings>().showCustomContent.value == false) {
      _allCharacters.removeWhere((character) => GameMethods.isCustomCampaign(character.edition));
    }

    _foundCharacters = _allCharacters;
    _foundCharacters.sort((a, b) {
      if (a.edition != b.edition) {
        return compareEditions(a.edition, b.edition);
      }
      if (a.hidden && !b.hidden) {
        return 1;
      }
      if (b.hidden && !a.hidden) {
        return -1;
      }
      return a.name.compareTo(b.name);
    });
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<CharacterClass> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allCharacters;
    } else {
      results = _allCharacters
          .where((user) => user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      if (enteredKeyword.toLowerCase() == "bladeswarm") {
        //unlocked it!
        results = [bs];
      }
      if (enteredKeyword.toLowerCase() == "vanquisher") {
        //unlocked it!
        results = [vq];
      }
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundCharacters = results;
    });
  }

  void _addCharacter(CharacterClass character) {
    String display = character.name;
    int count = 1;

    if (GameMethods.isObjectiveOrEscort(character)) {
      //add a number to name if already exists
      for (var item in _gameState.currentList) {
        if (item is Character && item.characterClass.name == character.name) {
          count++;
        }
      }
      if (count > 1) {
        display += " $count";
      }
    }

    AddCharacterCommand command =
        AddCharacterCommand(character.id, display, 1);
    _gameState.action(command);

    //open level menu
    openDialog(context, SetCharacterLevelMenu(character: command.character));

    //update UI to disable added character
    setState(() {});
  }

  bool _characterAlreadyAdded(CharacterClass newCharacter) {
    if (GameMethods.isObjectiveOrEscort(newCharacter)) {
      return false;
    }
    var characters = GameMethods.getCurrentCharacters();
    for (var character in characters) {
      if (character.characterClass.id == newCharacter.id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      onChanged: (value) => _runFilter(value),
                      decoration: const InputDecoration(
                          labelText: 'Add Character (type name for hidden character classes)',
                          suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _foundCharacters.isNotEmpty
                        ? Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _foundCharacters.length,
                              itemBuilder: (context, index) {
                                return CharacterTile(
                                  character: _foundCharacters[index],
                                  onSelect: _addCharacter,
                                  disabled: _characterAlreadyAdded(
                                      _foundCharacters[index]),
                                );
                              },
                            ))
                        : const Text(
                            'No results found',
                            style: TextStyle(fontSize: 24),
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
