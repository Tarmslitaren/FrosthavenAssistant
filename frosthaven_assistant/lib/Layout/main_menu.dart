import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/select_scenario_popup.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:search_choices/search_choices.dart';

import '../Model/campaign.dart';
import '../Resource/commands.dart';

void openDialog(BuildContext context, Widget widget) {
  showDialog(context: context,
      builder: (BuildContext context) => widget
  );
  /*Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (BuildContext context) {
      return widget;
    },
  ));*/
}

Drawer createMainMenu(BuildContext context) {
  String? _currentSelectedScenario;
  GameState _gameState = getIt<GameState>();

  return Drawer(
    child: ValueListenableBuilder<CampaignModel?>(
      valueListenable: _gameState.modelData,
      builder: (context, value, child) {
        return ListView(
// Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                    'Main Menu'), //add more useful stuff here (set level stuff maybe?)
              ),
              ListTile(
                title: const Text('Undo'),
                onTap: () {
// Update the state of the app
// ...
// Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Redo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _gameState.modelData.value == null
                  ? Container()
                  : ListTile(
                      title: const Text('Set Scenario'),
                      onTap: () {
                        Navigator.pop(context);
                        openDialog(context, const SelectScenarioMenu());
                        //Navigator.pop(context);
                      },
                    ),
              ListTile(
                title: const Text('Add Section'),
                onTap: () {
                  //TODO: of no section for current scenario, gray out the button and do nothing
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _gameState.modelData.value == null
                  ? Container()
                  : SearchChoices.single(
                      items: _gameState.modelData.value?.scenarios.keys
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: _currentSelectedScenario,
                      hint: "Add Character",
                      searchHint: "Add Character",
                      onChanged: (value) {
                        _currentSelectedScenario = value;
                        _gameState.action(
                            AddCharacterCommand(_currentSelectedScenario!, 1));
                      },
                      isExpanded: true,
                      displayClearIcon: false,
                    ),
              ListTile(
                title: const Text('Remove Characters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Add Monsters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove Monsters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Documentation'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    ),
  );
}
