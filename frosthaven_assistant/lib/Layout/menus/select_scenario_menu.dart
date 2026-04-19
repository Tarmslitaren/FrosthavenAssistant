import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
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
  const SelectScenarioMenu({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
  });

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;

  @override
  SelectScenarioMenuState createState() => SelectScenarioMenuState();
}

class SelectScenarioMenuState extends State<SelectScenarioMenu> {
  static const double _kCardMargin = 2.0;
  static const double _kSearchPadding = 10.0;
  static const int _kNumpadMaxLength = 3;
  static const double _kTopSpacing = 20.0;

  // This list holds the data for the list view
  List<String> _foundScenarios = [];
  late final GameState _gameState; // ignore: avoid-late-keyword
  late final GameData _gameData; // ignore: avoid-late-keyword
  late final Settings _settings; // ignore: avoid-late-keyword
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    _gameData = widget.gameData ?? getIt<GameData>();
    _settings = widget.settings ?? getIt<Settings>();
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
        modelData[_gameState.currentCampaign.value]!.scenarios.keys.toList(); // ignore: avoid-non-null-assertion

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

    if (campaign == "Solo" && !_settings.showCustomContent.value) {
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
      results = _gameData.modelData.value[campaign]!.scenarios.keys.toList(); // ignore: avoid-non-null-assertion
      if (campaign != "Solo") {
        results.insert(0, "custom");
      }
    } else {
      results = _gameData.modelData.value[campaign]!.scenarios.keys // ignore: avoid-non-null-assertion
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

  List<Widget> buildCampaignButtons() {
    List<Widget> retVal = [];
    for (String item in _gameData.editions) {
      final scenarioList = _gameData.modelData.value[item]?.scenarios;
      if (scenarioList != null && scenarioList.isNotEmpty) {
        if (_settings.showCustomContent.value ||
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
            margin: const EdgeInsets.all(_kCardMargin),
            child: Stack(children: [
              Column(
                children: [
                  const SizedBox(
                    height: _kTopSpacing,
                  ),
                  Column(children: [
                    const Text("Set Scenario", style: kTitleStyle),
                    ExpansionTile(
                      key: UniqueKey(),
                      title: Text(
                          "Current Campaign: ${_gameState.currentCampaign.value}"),
                      children: buildCampaignButtons(), // ignore: avoid-returning-widgets, list-returning helper for Column children
                    ),
                  ]),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: _kSearchPadding),
                    child: KeyboardListener(
                        //needed to trigger onEditingComplete on enter
                        //TODO: add this to the other menus
                        focusNode: FocusNode(),
                        child: TextField(
                          onChanged: (value) => _runFilter(value),
                          controller: _controller,
                          onTap: () {
                            _controller.clear();
                            if (_settings.softNumpadInput.value) {
                              openDialog(
                                  context,
                                  NumpadMenu(
                                      controller: _controller,
                                      maxLength: _kNumpadMaxLength,
                                      onChange: (String value) {
                                        _runFilter(value);
                                      }));
                            }
                          },
                          onEditingComplete: () {
                            if (_foundScenarios.isNotEmpty) {
                              Navigator.pop(context);
                              _gameState.action(SetScenarioCommand(
                                  _foundScenarios.first, false,
                                  gameState: _gameState));
                            }
                          },
                          decoration: const InputDecoration(
                              labelText: 'Set Scenario',
                              suffixIcon: Icon(Icons.search)),
                        )),
                  ),
                  const SizedBox(
                    height: _kTopSpacing,
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
                                        ? _SoloTile(name: _foundScenarios[index], gameState: _gameState, gameData: _gameData)
                                        : _ScenarioTile(name: _foundScenarios[index], gameState: _gameState, settings: _settings)))
                        : const Text(
                            'No results found',
                            style: kHeadingStyle,
                          ),
                  ),
                  const SizedBox(
                    height: kMenuCloseButtonSpacing,
                  ),
                ],
              ),
              Positioned(
                  width: kCloseButtonWidth,
                  height: kButtonSize,
                  right: 0,
                  bottom: 0,
                  child: TextButton(
                      child: const Text(
                        'Close',
                        style: kButtonLabelStyle,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }))
            ])));
  }
}

class _SoloTile extends StatelessWidget {
  static const int _kSoloNameIndex = 0;
  static const int _kSoloTextIndex = 1;
  static const double _kIconSize = 30.0;

  const _SoloTile({
    required this.name,
    required this.gameState,
    required this.gameData,
  });

  final String name;
  final GameState gameState;
  final GameData gameData;

  @override
  Widget build(BuildContext context) {
    List<String> strings = name.split(':');
    strings[0] = strings.first.replaceFirst(" ", "Å");
    String nameAndCampaign = strings.first.split("Å")[1];
    String characterName = nameAndCampaign.split("/")[_kSoloNameIndex];
    String edition = nameAndCampaign.split("/")[_kSoloTextIndex];

    String text = strings[_kSoloTextIndex];
    for (String key in gameData.modelData.value.keys) {
      for (CharacterClass character in gameData.modelData.value[key]!.characters) { // ignore: avoid-non-null-assertion
        if (character.name == characterName) {
          if (character.hidden && !gameState.unlockedClasses.contains(character.id)) {
            text = "???";
          }
          break;
        }
      }
    }

    return ListTile(
      leading: Image(
        height: _kIconSize,
        width: _kIconSize,
        fit: BoxFit.scaleDown,
        image: AssetImage("assets/images/class-icons/$characterName.png"),
      ),
      title: Text(text, style: kTitleStyle),
      trailing: Text("($edition)", softWrap: true, style: kSubtitleStyle),
      onTap: () {
        Navigator.pop(context);
        gameState.action(SetScenarioCommand(name, false, gameState: gameState));
      },
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.name,
    required this.gameState,
    required this.settings,
  });

  final String name;
  final GameState gameState;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    String title = settings.showScenarioNames.value ? name : name.split(' ').first;
    return ListTile(
      title: Text(title, style: kTitleStyle),
      onTap: () {
        Navigator.pop(context);
        gameState.action(SetScenarioCommand(name, false, gameState: gameState));
      },
    );
  }
}
