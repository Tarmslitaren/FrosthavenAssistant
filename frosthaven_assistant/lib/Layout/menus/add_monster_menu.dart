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
  bool addAsAlly = false;
  bool showSpecial = false;
  bool showBoss = true;

  @override
  initState() {
    // at the beginning, all users are shown
    for (String key in _gameState.modelData.value.keys) {
      _allMonsters.addAll(_gameState.modelData.value[key]!.monsters.values);
    }
    _foundMonsters = _allMonsters.toList();

    if (!showSpecial) {
      _foundMonsters.removeWhere((element) => element.hidden == true);
    }
    if (!showBoss) {
      _foundMonsters.removeWhere((element) => element.levels[0].boss != null);
    }

    sortMonsters(_foundMonsters);
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
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allMonsters.toList();
    } else {
      results = _allMonsters
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    if (!showSpecial) {
      results.removeWhere((element) => element.hidden == true);
    }
    if (!showBoss) {
      results.removeWhere((element) => element.levels[0].boss != null);
    }
    sortMonsters(results);

    // Refresh the UI
    setState(() {
      _foundMonsters = results;
    });
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
                  const SizedBox(
                    height: 20,
                  ),
                  CheckboxListTile(
                      title: const Text("Add as Ally"),
                      value: addAsAlly,
                      onChanged: (bool? value) {
                        setState(() {
                          addAsAlly = value!;
                        });
                      }),
                  CheckboxListTile(
                      title: const Text("Show Bosses"),
                      value: showBoss,
                      onChanged: (bool? value) {
                        setState(() {
                          showBoss = value!;
                          _runFilter("");
                        });
                      }),
                  CheckboxListTile(
                      title: const Text("Show Scenario Special Monsters"),
                      value: showSpecial,
                      onChanged: (bool? value) {
                        setState(() {
                          showSpecial = value!;
                          _runFilter("");
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
                                        addAsAlly)); //
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
