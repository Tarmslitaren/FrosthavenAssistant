import 'package:flutter/material.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/add_character_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class AddCharacterMenu extends StatefulWidget {
  const AddCharacterMenu({Key? key}) : super(key: key);

  @override
  _AddCharacterMenuState createState() => _AddCharacterMenuState();
}

class _AddCharacterMenuState extends State<AddCharacterMenu> {
  // This list holds the data for the list view
  List<CharacterClass> _foundCharacters = [];
  List<CharacterClass> _allCharacters = [];
  late CharacterClass bs;
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all users are shown
    for (String key in _gameState.modelData.value.keys){
      _allCharacters.addAll(
          _gameState.modelData.value[key]!.characters
      );
    }
    for (var item in _allCharacters) {
      if(item.name == "Bladeswarm") {
        _allCharacters.remove(item);
        bs = item;
        break;
      }
    }
    _foundCharacters = _allCharacters;
    _foundCharacters.sort((a, b) {
      if(a.edition != b.edition) {
        return -a.edition.compareTo(b.edition);
        //NOTE: this - here is a bit silly. it just so happens that the order makes more sense backards: Jotl, gloom, FC, FH, CS
      }
      if(a.hidden && !b.hidden){
        return 1;
      }
      if(b.hidden && !a.hidden){
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
      if(enteredKeyword.toLowerCase() == "bladeswarm") {
        //unlocked it!
        results = [bs];
      }
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundCharacters = results;
    });
  }

  bool _characterAlreadyAdded(String newCharacter) {
    var characters = GameMethods.getCurrentCharacters();
    for (var character in characters) {
      if (character.id == "Escort" || character.id == "Objective") {
        return false;
      }
      if (character.id == newCharacter){
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        //color: Colors.transparent,
        // shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(20),
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
                    ? ListView.builder(
                        itemCount: _foundCharacters.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: Image(
                            height: 50,
                            width: 50,
                            fit: BoxFit.scaleDown,
                            image: AssetImage(
                                "assets/images/class-icons/${_foundCharacters[index].name}.png"),
                          ),
                          iconColor: _foundCharacters[index].color,
                          title: Text(_foundCharacters[index].hidden
                              ? "???"
                              : _foundCharacters[index].name,
                          style: TextStyle(
                              fontSize: 18,

                              color: _characterAlreadyAdded(_foundCharacters[index].name)?
                                  Colors.grey : Colors.black
                          )),
                          trailing: Text("(${_foundCharacters[index].edition})",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey
                              )),
                          onTap: () {
                            //TODO: add level selection menu  (1-9) on top in this here menu.
                            if (!_characterAlreadyAdded(_foundCharacters[index].name)){
                              setState(() {

                                String display = _foundCharacters[index].name;
                                int count = 1;
                                if(_foundCharacters[index].name == "Objective" || _foundCharacters[index].name == "Escort") {
                                  //add a number to name if already exists
                                  for (var item in _gameState.currentList) {
                                    if (item.id == _foundCharacters[index].name ){
                                      count++;
                                    }
                                  }
                                  if (count > 1) {
                                    display += " $count";
                                  }
                                }
                                _gameState.action(AddCharacterCommand(
                                    _foundCharacters[index].name, display, 1)); //
                              });

                            }
                          },
                        ),
                      )
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
          Positioned(
              width: 100,
              right: 2,
              bottom: 2,
              child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }))
        ]));
  }
}
