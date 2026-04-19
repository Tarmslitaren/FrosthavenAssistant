import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/numpad_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/commands/set_scenario_command.dart';
import '../../Resource/game_data.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';

class AddSectionMenu extends StatefulWidget {
  const AddSectionMenu({
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
  AddSectionMenuState createState() => AddSectionMenuState();
}

class AddSectionMenuState extends State<AddSectionMenu> {
  static const int _kNumpadMaxLength = 3;
  // This list holds the data for the list view
  List<String> _foundScenarios = [];
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Settings get _settings => widget.settings ?? getIt<Settings>();
  GameData get _gameData => widget.gameData ?? getIt<GameData>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    // at the beginning, all items are shown
    var scenarios = _gameData.modelData.value[_gameState.currentCampaign.value]
        ?.scenarios[_gameState.scenario.value]?.sections
        .map((e) => e.name)
        .toList();
    if (scenarios != null) {
      _foundScenarios = scenarios;
    }
    _foundScenarios =
        _foundScenarios.where((element) => !element.contains("spawn")).toList();
    _foundScenarios.sort((a, b) {
      int? aNr = GameMethods.findNrFromScenarioName(a);
      int? bNr = GameMethods.findNrFromScenarioName(b);
      if (aNr != null && bNr != null) {
        return aNr.compareTo(bNr);
      }
      return a.compareTo(b);
    });

    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all
      results = _gameData.modelData.value[_gameState.currentCampaign.value]!
          .scenarios[_gameState.scenario.value]!.sections
          .map((e) => e.name)
          .toList();
      results = results.where((element) => !element.contains("spawn")).toList();
    } else {
      results = _gameData.modelData.value[_gameState.currentCampaign.value]!
          .scenarios[_gameState.scenario.value]!.sections
          .map((e) => e.name)
          .toList()
          .where((user) =>
              user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      results = results.where((element) => !element.contains("spawn")).toList();
      results.sort((a, b) {
        int? aNr = GameMethods.findNrFromScenarioName(a);
        int? bNr = GameMethods.findNrFromScenarioName(b);
        if (aNr != null && bNr != null) {
          return aNr.compareTo(bNr);
        }
        return a.compareTo(b);
      });
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundScenarios = results;
    });
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
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _controller,
                      keyboardType: _settings.softNumpadInput.value
                          ? TextInputType.none
                          : TextInputType.text,
                      onChanged: (value) => _runFilter(value),
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
                      decoration: InputDecoration(
                          labelText:
                              _gameState.scenario.value == "#Random Dungeon"
                                  ? 'Add Random Dungeon Card'
                                  : 'Add Section',
                          suffixIcon: const Icon(Icons.search)),
                    ),
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
                              itemBuilder: (context, index) => ListTile(
                                title: Text(_foundScenarios[index],
                                    style: TextStyle(
                                        color: _gameState.scenarioSectionsAdded
                                                .contains(
                                                    _foundScenarios[index])
                                            ? Colors.blueGrey
                                            : Colors.black,
                                        fontSize: kFontSizeTitle)),
                                onTap: () {
                                  if (!_gameState.scenarioSectionsAdded
                                      .contains(_foundScenarios[index])) {
                                    Navigator.pop(context);
                                    _gameState.action(SetScenarioCommand(
                                        _foundScenarios[index], true,
                                        gameState: _gameState));
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
