import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/components/menu_card.dart';
import 'package:frosthaven_assistant/Layout/menus/save_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_character_level_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/add_character_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import 'character_tile.dart';

class AddCharacterMenu extends StatefulWidget {
  const AddCharacterMenu({
    super.key,
    this.gameState,
    this.settings,
    this.gameData,
  });

  final GameState? gameState;
  // injected for testing
  final Settings? settings;
  final GameData? gameData;

  @override
  AddCharacterMenuState createState() => AddCharacterMenuState();
}

class AddCharacterMenuState extends State<AddCharacterMenu> {
  static const double _kMaxWidth = 400;
  // This list holds the data for the list view
  List<CharacterClass> _foundCharacters = [];
  final List<CharacterClass> _allCharacters = [];
  late CharacterClass bs; // ignore: avoid-late-keyword
  late CharacterClass vq; // ignore: avoid-late-keyword
  late final GameState _gameState; // ignore: avoid-late-keyword
  late final Settings _settings; // ignore: avoid-late-keyword
  late final GameData _gameData; // ignore: avoid-late-keyword
  final ScrollController _scrollController = ScrollController();

  int compareEditions(String a, String b) {
    //sort current edition to top
    String currentEdition = _gameState.currentCampaign.value;
    if (b == currentEdition && a != currentEdition && a != "na") {
      return 1;
    }
    if (a == currentEdition && b != currentEdition && b != "na") {
      return -1;
    }

    //sort by edition
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
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
    _gameData = widget.gameData ?? getIt<GameData>();
    // at the beginning, all users are shown
    final data = _gameData.modelData.value;
    for (String key in data.keys) {
      _allCharacters.addAll(data[key]!.characters); // ignore: avoid-non-null-assertion
    }

    for (var item in _allCharacters) {
      if (item.name == "Bladeswarm" && item.edition == "Gloomhaven") {
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

    if (!_settings.showCustomContent.value) {
      _allCharacters.removeWhere(
          (character) => GameMethods.isCustomCampaign(character.edition));
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
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      final keyWord = enteredKeyword.toLowerCase();
      if (keyWord == "bladeswarm") {
        //unlocked it!
        results = [bs];
      }
      if (keyWord == "vanquisher") {
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

    AddCharacterCommand command = AddCharacterCommand(
        character.id, character.edition, display, 1,
        gameState: _gameState);
    _gameState.action(command);

    //open level menu
    openDialog(context, SetCharacterLevelMenu(character: command.character));

    //update UI to disable added character
    setState(() => _foundCharacters = _foundCharacters);
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
    return MenuCard(
        maxWidth: _kMaxWidth,
        cardMargin: const EdgeInsets.all(2),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText:
                        'Add Character (type name for hidden character classes)',
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
                            disabled:
                                _characterAlreadyAdded(_foundCharacters[index]),
                          );
                        },
                      ))
                  : const Text(
                      'No results found',
                      style: kHeadingStyle,
                    ),
            ),
            const SizedBox(
              height: kMenuCloseButtonSpacing,
            ),
          ],
        ));
  }
}
