import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/components/menu_card.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/commands/add_monster_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddMonsterMenu extends StatefulWidget {
  static const double _kMaxWidth = 450.0;
  static const double _kCardMargin = 2.0;
  static const double _kSearchMarginH = 10.0;
  static const double _kTopSpacing = 20.0;
  static const double _kImageHeight = 35.0;

  const AddMonsterMenu({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
  });

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  AddMonsterMenuState createState() => AddMonsterMenuState();
}

class AddMonsterMenuState extends State<AddMonsterMenu> {
  // This list holds the data for the list view
  List<MonsterModel> _foundMonsters = [];
  final List<MonsterModel> _allMonsters = [];
  late final GameState _gameState; // ignore: avoid-late-keyword
  late final GameData _gameData; // ignore: avoid-late-keyword
  late final Settings _settings; // ignore: avoid-late-keyword
  bool _addAsAlly = false;
  bool _showSpecial = false;
  bool _showBoss = true;
  late String _currentCampaign; // ignore: avoid-late-keyword
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    _settings = widget.settings ?? getIt<Settings>();
    _gameData = widget.gameData ?? getIt<GameData>();
    // at the beginning, all users are shown
    for (String key in _gameData.modelData.value.keys) {
      _allMonsters.addAll(_gameData.modelData.value[key]!.monsters.values); // ignore: avoid-non-null-assertion
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
      if (a.levels.first.boss != null && b.levels.first.boss == null) {
        return 1;
      }
      if (b.levels.first.boss != null && a.levels.first.boss == null) {
        return -1;
      }
      return a.name.compareTo(b.name);
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    _setCampaign(_currentCampaign);
    if (enteredKeyword.isNotEmpty) {
      _foundMonsters = _foundMonsters
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() => _foundMonsters = _foundMonsters);
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
    } else if (!_settings.showCustomContent.value) {
      _foundMonsters.removeWhere(
          (monster) => GameMethods.isCustomCampaign(monster.edition));
    }

    if (!_showSpecial) {
      _foundMonsters.removeWhere((element) => element.hidden);
    }
    if (!_showBoss) {
      _foundMonsters.removeWhere((element) => element.levels.first.boss != null);
    }

    sortMonsters(_foundMonsters);
  }

  List<DropdownMenuItem<String>> buildEditionDroopDownMenuItems() {
    List<DropdownMenuItem<String>> retVal = [];
    retVal.add(const DropdownMenuItem<String>(
        value: "All", child: Text("All Campaigns")));

    for (String item in _gameData.editions) {
      if (item != "na") {
        if (!GameMethods.isCustomCampaign(item) ||
            _settings.showCustomContent.value) {
          retVal.add(DropdownMenuItem<String>(value: item, child: Text(item)));
        }
      }
    }

    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    return MenuCard(
        maxWidth: AddMonsterMenu._kMaxWidth,
        cardMargin: const EdgeInsets.all(AddMonsterMenu._kCardMargin),
        child: Column(
          children: [
            Row(children: [
              const Text("      Show monsters from:   "),
              DropdownButtonHideUnderline(
                  child: DropdownButton(
                      value: _currentCampaign,
                      items: buildEditionDroopDownMenuItems(), // ignore: avoid-returning-widgets, returns List<DropdownMenuItem> for DropdownButton items
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
                    _showBoss = value!; // ignore: avoid-non-null-assertion
                    _runFilter("");
                  });
                }),
            CheckboxListTile(
                title: const Text("Show Scenario Special Monsters"),
                value: _showSpecial,
                onChanged: (bool? value) {
                  setState(() {
                    _showSpecial = value!; // ignore: avoid-non-null-assertion
                    _runFilter("");
                  });
                }),
            CheckboxListTile(
                title: const Text("Add as Ally"),
                value: _addAsAlly,
                onChanged: (bool? value) {
                  setState(() {
                    _addAsAlly = value!; // ignore: avoid-non-null-assertion
                  });
                }),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AddMonsterMenu._kSearchMarginH),
              child: TextField(
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText: 'Add Monster', suffixIcon: Icon(Icons.search)),
              ),
            ),
            const SizedBox(
              height: AddMonsterMenu._kTopSpacing,
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
                            height: AddMonsterMenu._kImageHeight,
                            cacheHeight: kMonsterImageCacheHeight,
                          ),
                          title: Text(
                              _foundMonsters[index].hidden
                                  ? "${_foundMonsters[index].display} (special)"
                                  : _foundMonsters[index].display,
                              style: TextStyle(
                                  fontSize: kFontSizeTitle,
                                  color: _monsterAlreadyAdded(
                                          _foundMonsters[index].name)
                                      ? Colors.grey
                                      : Colors.black)),
                          trailing: Text("(${_foundMonsters[index].edition})",
                              style: const TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: Colors.grey)),
                          onTap: () {
                            if (!_monsterAlreadyAdded(
                                _foundMonsters[index].name)) {
                              setState(() {
                                _gameState.action(AddMonsterCommand(
                                    _foundMonsters[index].name,
                                    null,
                                    _addAsAlly,
                                    gameState: _gameState));
                              });
                            }
                          },
                        ),
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
