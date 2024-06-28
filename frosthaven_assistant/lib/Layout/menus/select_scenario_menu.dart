import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/set_scenario_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import 'numpad_menu.dart';

class SelectScenarioMenu extends StatefulWidget {
  const SelectScenarioMenu({super.key});

  @override
  SelectScenarioMenuState createState() => SelectScenarioMenuState();
}

class SelectScenarioMenuState extends State<SelectScenarioMenu> {
  // This list holds the data for the list view
  List<String> _foundScenarios = [];
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    // at the beginning, all items are shown
    setCampaign(_gameState.currentCampaign.value);
    super.initState();
  }

  int? findNrFromScenarioName(String scenario) {
    String nr = scenario.substring(1);
    for (int i = 0; i < nr.length; i++) {
      if (nr[i] == ' ' || nr[i] == 'A' || nr[i] == 'B') {
        nr = nr.substring(0, i);
        int? number = int.tryParse(nr);
        return number;
      }
    }

    return null;
  }

  void setCampaign(String campaign) {
    //TODO: clear search

    //check value ok
    if (_gameData.modelData.value[campaign] == null) {
      campaign = "Jaws of the Lion";
    }

    if (_gameState.currentCampaign.value != campaign) {
      _gameState.action(SetCampaignCommand(campaign));
    }
    _foundScenarios =
        _gameData.modelData.value[_gameState.currentCampaign.value]!.scenarios.keys.toList();

    //special hack for solo BladeSwarm
    if (campaign == "Solo" || campaign == "Trail of Ashes") {
      if (!_gameState.unlockedClasses.contains("Bladeswarm")) {
        for (var item in _foundScenarios) {
          if (item.contains("Bladeswarm")) {
            _foundScenarios.remove(item);
            break;
          }
        }
      }
      if (!_gameState.unlockedClasses.contains("Vanquisher")) {
        for (var item in _foundScenarios) {
          if (item.contains("Vanquisher")) {
            _foundScenarios.remove(item);
            break;
          }
        }
      }
    }

    if (campaign == "Solo" && getIt<Settings>().showCustomContent.value == false) {
      _foundScenarios.removeWhere((scenario) {
        List<String> strings = scenario.split(':');
        strings[0] = strings[0].replaceFirst(" ", "Å");
        String characterName = strings[0].split("Å")[1];
        if (_gameData.modelData.value.entries.any((element) =>
            GameMethods.isCustomCampaign(element.value.edition) &&
            element.value.characters.any((element) => element.name == characterName))) {
          return true;
        }

        return false;
      });
    }

    _foundScenarios.sort((a, b) {
      int? aNr = findNrFromScenarioName(a);
      int? bNr = findNrFromScenarioName(b);
      if (aNr != null && bNr != null) {
        return aNr.compareTo(bNr);
      }
      return a.compareTo(b);
    });

    //sort random dungeon first for visibility of special feature
    if(_foundScenarios.last == "#Random Dungeon") {
      _foundScenarios.insert(0, _foundScenarios.last);
      _foundScenarios.removeAt(_foundScenarios.length-1);
    }

    if (campaign != "Solo") {
      _foundScenarios.insert(0, "custom");
    }
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all
      results =
          _gameData.modelData.value[_gameState.currentCampaign.value]!.scenarios.keys.toList();
      if (_gameState.currentCampaign.value != "Solo") {
        results.insert(0, "custom");
      }
    } else {
      results = _gameData.modelData.value[_gameState.currentCampaign.value]!.scenarios.keys
          .toList()
          .where((user) => user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      results.sort((a, b) {
        int? aNr = findNrFromScenarioName(a);
        int? bNr = findNrFromScenarioName(b);
        if (aNr != null && bNr != null) {
          return aNr.compareTo(bNr);
        }
        return a.compareTo(b);
      });
      // we use the toLowerCase() method to make it case-insensitive
      //special hack for solo BladeSwarm
      if (_gameState.currentCampaign.value == "Solo" ||
          _gameState.currentCampaign.value == "Trail of Ashes") {
        if (!_gameState.unlockedClasses.contains("Bladeswarm")) {
          for (var item in results) {
            if (item.contains("Bladeswarm")) {
              results.remove(item);
              break;
            }
          }
        }
        if (!_gameState.unlockedClasses.contains("Vanquisher")) {
          for (var item in results) {
            if (item.contains("Vanquisher")) {
              results.remove(item);
              break;
            }
          }
        }
      }
    }

    // Refresh the UI
    setState(() {
      _foundScenarios = results;
    });
  }

  Widget buildSoloTile(String name) {
    List<String> strings = name.split(':');
    strings[0] = strings[0].replaceFirst(" ", "Å");
    String characterName = strings[0].split("Å")[1];

    String text = strings[1];
    for (String key in _gameData.modelData.value.keys) {
      for (CharacterClass character in _gameData.modelData.value[key]!.characters) {
        if (character.name == characterName) {
          if (character.hidden && !_gameState.unlockedClasses.contains(character.id)) {
            text = "???";
          }
          break;
        }
      }
    }

    return ListTile(
      leading: Image(
        height: 30,
        width: 30,
        fit: BoxFit.scaleDown,
        image: AssetImage("assets/images/class-icons/$characterName.png"),
      ),
      title: Text(text, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        _gameState.action(SetScenarioCommand(name, false));
        //Navigator.pop(context);
      },
    );
  }

  Widget buildTile(String name) {
    String title = name;
    if (getIt<Settings>().showScenarioNames.value == false) {
      title = name.split(' ')[0];
    }

    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        _gameState.action(SetScenarioCommand(name, false));
      },
    );
  }

  List<Widget> buildCampaignButtons() {
    List<Widget> retVal = [];
    for (String item in _gameData.editions) {
      if (item != "na" && item != "CCUG") {
        if (getIt<Settings>().showCustomContent.value == true ||
            !GameMethods.isCustomCampaign(item)) {
          retVal.add(TextButton(
              onPressed: () {
                setState(() {
                  setCampaign(item);
                });
              },
              child: Text(item)));
        }
      }
    }
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
            //color: Colors.transparent,
            // shadowColor: Colors.transparent,
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Column(children: [
                    const Text("Set Scenario", style: TextStyle(fontSize: 18)),
                    ExpansionTile(
                      key: UniqueKey(),
                      title: Text("Current Campaign: ${_gameState.currentCampaign.value}"),
                      children: buildCampaignButtons(),
                    ),
                  ]),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: RawKeyboardListener(
                        //needed to trigger onEditingComplete on enter
                        //TODO: add this to the other menus
                        focusNode: FocusNode(),
                        onKey: (event) {
                          if (kDebugMode) {
                            print(event.data.logicalKey.keyId);
                          }
                          if (event.runtimeType == RawKeyDownEvent &&
                              (event.logicalKey.keyId == 13)) {
                            if (_foundScenarios.isNotEmpty) {
                              //_gameState.action(
                              //    SetScenarioCommand(_foundScenarios[0], false));
                              //Navigator.pop(context);
                            }
                            //Navigator.pop(context, this._textController.text);
                          }
                        },
                        child: TextField(
                          onChanged: (value) => _runFilter(value),
                          controller: _controller,
                          onTap: () {
                            _controller.clear();
                            if (getIt<Settings>().softNumpadInput.value) {
                              openDialog(
                                  context,
                                  NumpadMenu(
                                      controller: _controller,
                                      maxLength: 3,
                                      onChange: (String value) {
                                        _runFilter(value);
                                      }));
                            }
                          },
                          onEditingComplete: () {
                            if (_foundScenarios.isNotEmpty) {
                              Navigator.pop(context);
                              _gameState.action(SetScenarioCommand(_foundScenarios[0], false));
                            }
                          },
                          decoration: const InputDecoration(
                              labelText: 'Set Scenario', suffixIcon: Icon(Icons.search)),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _foundScenarios.isNotEmpty
                        ? Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _foundScenarios.length,
                                itemBuilder: (context, index) =>
                                    _gameState.currentCampaign.value == "Solo"
                                        ? buildSoloTile(_foundScenarios[index])
                                        : buildTile(_foundScenarios[index])))
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
