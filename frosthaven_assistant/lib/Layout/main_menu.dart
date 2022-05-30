import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:search_choices/search_choices.dart';

import '../Model/campaign.dart';
import '../Resource/commands.dart';

Drawer createMainMenu(BuildContext context) {
  String? _currentSelectedValue;
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
                  : SearchChoices.single(
                      items: _gameState.modelData.value?.scenarios.keys
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: _currentSelectedValue,
                      hint: "Set Scenario",
                      searchHint: "Select Scenario",
                      onChanged: (value) {
                        _currentSelectedValue = value;
                        _gameState
                            .action(SetScenarioCommand(_currentSelectedValue!));
                      },
                      isExpanded: true,
                      displayClearIcon: false,
                    ),
              ListTile(
                title: const Text('Add Section'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Add Characters'),
                onTap: () {
                  Navigator.pop(context);
                },
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
