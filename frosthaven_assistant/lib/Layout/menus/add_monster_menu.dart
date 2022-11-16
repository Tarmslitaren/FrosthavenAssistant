import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';

import '../../Resource/commands/add_monster_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class AddMonsterMenu extends StatefulWidget {
  const AddMonsterMenu({Key? key}) : super(key: key);

  @override
  AddMonsterMenuState createState() => AddMonsterMenuState();
}

class AddMonsterMenuState extends State<AddMonsterMenu> {
  // This list holds the data for the list view
  List<MonsterModel> _foundMonsters = [];
  final List<MonsterModel> _allMonsters = [];
  final GameState _gameState = getIt<GameState>();
  bool _addAsAlly = false;
  bool _showSpecial = false;
  bool _showBoss = true;
  late String _currentCampaign;
  bool _enableFullScroll = false;

  @override
  initState() {
    // at the beginning, all users are shown
    for (String key in _gameState.modelData.value.keys) {
      _allMonsters.addAll(_gameState.modelData.value[key]!.monsters.values);
    }
    _currentCampaign = _gameState.currentCampaign.value;
    _setCampaign(_currentCampaign);

    super.initState();
  }

  int compareEditions(String a, String b) {
    if (a.startsWith("S") && !b.startsWith("S")) {
      return 1;
    }
    if (b.startsWith("S") && !a.startsWith("S")) {
      return -1;
    }
    return -a.compareTo(b);
  }

  void sortMonsters(List<MonsterModel> list) {
    list.sort((a, b) {
      if (a.edition != b.edition) {
        return compareEditions(a.edition, b.edition);
        //TODO: have an actual order in data
        //NOTE: this - here is a bit silly. it just so happens that the order makes more sense backwards: Jotl, gloom, FC, FH, CS
      }
      if (a.hidden && !b.hidden) {
        return 1;
      }
      if (b.hidden && !a.hidden) {
        return -1;
      }
      if (a.levels[0].boss != null && b.levels[0].boss == null) {
        return 1;
      }
      if (b.levels[0].boss != null && a.levels[0].boss == null) {
        return -1;
      }
      return a.name.compareTo(b.name);
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<MonsterModel> results = [];
    _setCampaign(_currentCampaign);
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allMonsters.toList();
      // _setCampaign(_currentCampaign);
      // results = _foundMonsters;
    } else {
      _foundMonsters = _foundMonsters
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {});
  }

  bool _monsterAlreadyAdded(String id) {
    var monsters = GameMethods.getCurrentMonsters();
    for (var monster in monsters) {
      if (monster.id == id) {
        return true;
      }
    }
    return false;
  }

  void _setCampaign(String campaign) {
    _currentCampaign = campaign;
    _foundMonsters = _allMonsters.toList();
    if (campaign != "All") {
      _foundMonsters.removeWhere((monster) => monster.edition != campaign);
    }

    if (!_showSpecial) {
      _foundMonsters.removeWhere((element) => element.hidden == true);
    }
    if (!_showBoss) {
      _foundMonsters.removeWhere((element) => element.levels[0].boss != null);
    }

    sortMonsters(_foundMonsters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Card(
            //color: Colors.transparent,
            // shadowColor: Colors.transparent,
            margin: const EdgeInsets.all(2),
            child: Stack(children: [
              Column(
                children: [
                  Row(children: [
                    Text("      Show monsters from:   "),
                    DropdownButtonHideUnderline(
                        child: DropdownButton(
                            value: _currentCampaign,
                            items: const [
                              DropdownMenuItem<String>(
                                  value: "All", child: Text("All Campaigns")),
                              DropdownMenuItem<String>(
                                  value: "Jaws of the Lion",
                                  child: Text("Jaws of the Lion")),
                              DropdownMenuItem<String>(
                                  value: "Gloomhaven",
                                  child: Text("Gloomhaven")),
                              DropdownMenuItem<String>(
                                  value: "Forgotten Circles",
                                  child: Text("Forgotten Circles")),
                              DropdownMenuItem<String>(
                                  value: "Frosthaven",
                                  child: Text("Frosthaven")),
                              DropdownMenuItem<String>(
                                  value: "Crimson Scales",
                                  child: Text("Crimson Scales")),
                              DropdownMenuItem<String>(
                                  value: "Solo", child: Text("Solo")),
                              DropdownMenuItem<String>(
                                  value: "Seeker of Xorn",
                                  child: Text("Seeker of Xorn")),
                            ],
                            onChanged: (value) {
                              if (value is String) {
                                setState(() {
                                  _setCampaign(value);
                                });
                              }
                            }))
                  ]),
                  CheckboxListTile(
                      title: const Text("Show Bosses"),
                      value: _showBoss,
                      onChanged: (bool? value) {
                        setState(() {
                          _showBoss = value!;
                          _runFilter("");
                        });
                      }),
                  CheckboxListTile(
                      title: const Text("Show Scenario Special Monsters"),
                      value: _showSpecial,
                      onChanged: (bool? value) {
                        setState(() {
                          _showSpecial = value!;
                          _runFilter("");
                        });
                      }),
                  /*child:ExpansionTile(
              onExpansionChanged: (opened) {
                _enableFullScroll = opened;
              },
              title: Text("Show Monsters from: $_currentCampaign"),
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("All");
                          });
                        },
                        child: const Text("All"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("JotL");
                          });
                        },
                        child: const Text("Jaws of the Lion"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Gloomhaven");
                          });
                        },
                        child: const Text("Gloomhaven"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Forgotten Circles");
                          });
                        },
                        child: const Text("Forgotten Circles"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Frosthaven");
                          });
                        },
                        child: const Text("Frosthaven"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Crimson Scales");
                          });
                        },
                        child: const Text("Crimson Scales"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Seeker of Xorn");
                          });
                        },
                        child: const Text("Seeker of Xorn"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setCampaign("Solo");
                          });
                        },
                        child: const Text("Solo Scenarios"),
                      ),
                      CheckboxListTile(
                          title: const Text("Show Bosses"),
                          value: _showBoss,
                          onChanged: (bool? value) {
                            setState(() {
                              _showBoss = value!;
                              _runFilter("");
                            });
                          }),
                      CheckboxListTile(
                          title: const Text("Show Scenario Special Monsters"),
                          value: _showSpecial,
                          onChanged: (bool? value) {
                            setState(() {
                              _showSpecial = value!;
                              _runFilter("");
                            });
                          }),
                    ],
                  )),*/
                  CheckboxListTile(
                      title: const Text("Add as Ally"),
                      value: _addAsAlly,
                      onChanged: (bool? value) {
                        setState(() {
                          _addAsAlly = value!;
                        });
                      }),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      onChanged: (value) => _runFilter(value),
                      decoration: const InputDecoration(
                          labelText: 'Add Monster',
                          suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _foundMonsters.isNotEmpty
                        ? Scrollbar(
                            child: ListView.builder(
                            itemCount: _foundMonsters.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: Image(
                                height: 35,
                                image: AssetImage(
                                    "assets/images/monsters/${_foundMonsters[index].gfx}.png"),
                              ),
                              //iconColor: _foundMonsters[index].color,
                              title: Text(
                                  _foundMonsters[index].hidden
                                      ? "${_foundMonsters[index].display} (special)"
                                      : _foundMonsters[index].display,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: _monsterAlreadyAdded(
                                              _foundMonsters[index].name)
                                          ? Colors.grey
                                          : Colors.black)),
                              trailing: Text(
                                  "(${_foundMonsters[index].edition})",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              onTap: () {
                                if (!_monsterAlreadyAdded(
                                    _foundMonsters[index].name)) {
                                  setState(() {
                                    _gameState.action(AddMonsterCommand(
                                        _foundMonsters[index].name,
                                        null,
                                        _addAsAlly)); //
                                  });

                                  //Navigator.pop(context);
                                }
                              },
                            ),
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
