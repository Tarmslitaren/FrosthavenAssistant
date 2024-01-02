import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';

import '../../Resource/commands/add_monster_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddMonsterMenu extends StatefulWidget {
  const AddMonsterMenu({super.key});

  @override
  AddMonsterMenuState createState() => AddMonsterMenuState();
}

class AddMonsterMenuState extends State<AddMonsterMenu> {
  // This list holds the data for the list view
  List<MonsterModel> _foundMonsters = [];
  final List<MonsterModel> _allMonsters = [];
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  bool _addAsAlly = false;
  bool _showSpecial = false;
  bool _showBoss = true;
  late String _currentCampaign;
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    // at the beginning, all users are shown
    for (String key in _gameData.modelData.value.keys) {
      _allMonsters.addAll(_gameData.modelData.value[key]!.monsters.values);
    }
    _currentCampaign = _gameState.currentCampaign.value;
    _setCampaign(_currentCampaign);

    super.initState();
  }

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

  void sortMonsters(List<MonsterModel> list) {
    list.sort((a, b) {
      if (a.edition != b.edition) {
        return compareEditions(a.edition, b.edition);
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
    _setCampaign(_currentCampaign);
    if (enteredKeyword.isEmpty) {
    } else {
      _foundMonsters = _foundMonsters
          .where((user) => user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
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
    } else if (getIt<Settings>().showCustomContent.value == false) {
      _foundMonsters.removeWhere((monster) => GameMethods.isCustomCampaign(monster.edition));
    }

    if (!_showSpecial) {
      _foundMonsters.removeWhere((element) => element.hidden == true);
    }
    if (!_showBoss) {
      _foundMonsters.removeWhere((element) => element.levels[0].boss != null);
    }

    sortMonsters(_foundMonsters);
  }

  List<DropdownMenuItem<String>> buildEditionDroopDownMenuItems() {
    List<DropdownMenuItem<String>> retVal = [];
    retVal.add(const DropdownMenuItem<String>(value: "All", child: Text("All Campaigns")));

    for (String item in _gameData.editions) {
      if (item != "na") {
        if (!GameMethods.isCustomCampaign(item) ||
            getIt<Settings>().showCustomContent.value == true) {
          retVal.add(DropdownMenuItem<String>(value: item, child: Text(item)));
        }
      }
    }

    return retVal;
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
                    const Text("      Show monsters from:   "),
                    DropdownButtonHideUnderline(
                        child: DropdownButton(
                            value: _currentCampaign,
                            items: buildEditionDroopDownMenuItems(),
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
                          labelText: 'Add Monster', suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _foundMonsters.isNotEmpty
                        ? Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _foundMonsters.length,
                              itemBuilder: (context, index) => ListTile(
                                leading: Image.asset(
                                  "assets/images/monsters/${_foundMonsters[index].gfx}.png",
                                  height: 35,
                                  cacheHeight: 75,
                                ),
                                //iconColor: _foundMonsters[index].color,
                                title: Text(
                                    _foundMonsters[index].hidden
                                        ? "${_foundMonsters[index].display} (special)"
                                        : _foundMonsters[index].display,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: _monsterAlreadyAdded(_foundMonsters[index].name)
                                            ? Colors.grey
                                            : Colors.black)),
                                trailing: Text("(${_foundMonsters[index].edition})",
                                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                onTap: () {
                                  if (!_monsterAlreadyAdded(_foundMonsters[index].name)) {
                                    setState(() {
                                      _gameState.action(AddMonsterCommand(
                                          _foundMonsters[index].name, null, _addAsAlly)); //
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
