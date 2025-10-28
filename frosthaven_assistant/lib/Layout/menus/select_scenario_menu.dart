import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';

import '../../Model/character_class.dart';
import '../../Resource/commands/set_scenario_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/game_methods.dart';
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

  double? findNrFromScenarioName(String scenario) {
    String nr = scenario.substring(1);
    nr = nr.split(" ").first;
    if (nr.endsWith('A')) {
      nr = "${nr.substring(0, nr.length - 1)}.1";
    }
    if (nr.endsWith('B')) {
      nr = "${nr.substring(0, nr.length - 1)}.2";
    }
    return double.tryParse(nr);
  }

  void _sortList() {
    _foundScenarios.sort((a, b) {
      double? aNr = findNrFromScenarioName(a);
      double? bNr = findNrFromScenarioName(b);
      if (aNr != null && bNr != null) {
        return aNr.compareTo(bNr);
      }
      return a.compareTo(b);
    });
  }

  void setCampaign(String campaign) {
    //empty the search text
    _controller.clear();

    final modelData = _gameData.modelData.value;
    final currentCampaign = _gameState.currentCampaign.value;
    //check value ok
    if (modelData[campaign] == null) {
      campaign = "Jaws of the Lion";
    }

    if (currentCampaign != campaign) {
      _gameState.action(SetCampaignCommand(campaign));
    }
    _foundScenarios =
        modelData[_gameState.currentCampaign.value]!.scenarios.keys.toList();

    //special hack for solo BladeSwarm and Vanquisher
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

    if (campaign == "Solo" && !getIt<Settings>().showCustomContent.value) {
      _foundScenarios.removeWhere((scenario) {
        List<String> strings = scenario.split(':');
        strings[0] = strings.first.replaceFirst(" ", "Å");
        String characterName = strings.first.split("Å")[1];
        characterName = characterName.split("/").first;
        if (_gameData.modelData.value.entries.any((element) =>
            GameMethods.isCustomCampaign(element.value.edition) &&
            element.value.characters
                .any((element) => element.name == characterName))) {
          return true;
        }

        return false;
      });
    }

    _sortList();

    //sort random dungeon first for visibility of special feature
    if (_foundScenarios.first != "#Random Dungeon") {
      for (int i = _foundScenarios.length - 1; i > 0; i--) {
        if (_foundScenarios[i] == "#Random Dungeon") {
          _foundScenarios.removeAt(i);
          _foundScenarios.insert(0, "#Random Dungeon");
        }
      }
    }

    if (campaign != "Solo") {
      _foundScenarios.insert(0, "custom");
    }
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    final String campaign = _gameState.currentCampaign.value;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all
      results = _gameData.modelData.value[campaign]!.scenarios.keys.toList();
      if (campaign != "Solo") {
        results.insert(0, "custom");
      }
    } else {
      results = _gameData.modelData.value[campaign]!.scenarios.keys
          .toList()
          .where((user) =>
              user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      results.sort((a, b) {
        double? aNr = findNrFromScenarioName(a);
        double? bNr = findNrFromScenarioName(b);
        if (aNr != null && bNr != null) {
          return aNr.compareTo(bNr);
        }
        return a.compareTo(b);
      });
      // we use the toLowerCase() method to make it case-insensitive
      //special hack for solo BladeSwarm
      if (campaign == "Solo" || campaign == "Trail of Ashes") {
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
      _sortList();
    });
  }

  Widget buildSoloTile(String name) {
    List<String> strings = name.split(':');
    strings[0] = strings.first.replaceFirst(" ", "Å");
    String nameAndCampaign = strings.first.split("Å")[1];
    String characterName = nameAndCampaign.split("/")[0];
    String edition = nameAndCampaign.split("/")[1];

    String text = strings[1];
    for (String key in _gameData.modelData.value.keys) {
      for (CharacterClass character
          in _gameData.modelData.value[key]!.characters) {
        if (character.name == characterName) {
          if (character.hidden &&
              !_gameState.unlockedClasses.contains(character.id)) {
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
      trailing: Text("($edition)",
          softWrap: true,
          style: const TextStyle(fontSize: 14, color: Colors.grey)),
      onTap: () {
        Navigator.pop(context);
        _gameState.action(SetScenarioCommand(name, false));
      },
    );
  }

  Widget buildTile(String name) {
    String title = name;
    if (!getIt<Settings>().showScenarioNames.value) {
      title = name.split(' ').first;
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
      final scenarioList = _gameData.modelData.value[item]?.scenarios;
      if (scenarioList != null && scenarioList.isNotEmpty) {
        if (getIt<Settings>().showCustomContent.value ||
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
    return [
      Wrap(
        children: retVal,
      )
    ];
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
                  Column(children: [
                    const Text("Set Scenario", style: TextStyle(fontSize: 18)),
                    ExpansionTile(
                      key: UniqueKey(),
                      title: Text(
                          "Current Campaign: ${_gameState.currentCampaign.value}"),
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
                              _gameState.action(SetScenarioCommand(
                                  _foundScenarios.first, false));
                            }
                          },
                          decoration: const InputDecoration(
                              labelText: 'Set Scenario',
                              suffixIcon: Icon(Icons.search)),
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
