import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:search_choices/search_choices.dart';

import '../../Model/campaign.dart';
import '../../Resource/commands.dart';
import '../bottom_bar.dart';

void openDialog(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
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
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(children: [
                  const Text('Main Menu'),
                  createLevelWidget(context),
                  //const SetLevelMenu()
                ]),
              ),
              ListTile(
                title: const Text('Undo'),
                enabled: false,
                onTap: () {
// Update the state of the app
// ...
// Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Redo'),
                enabled: false,
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
                      },
                    ),
              ListTile(
                title: const Text('Add Section'),
                enabled: false,
                onTap: () {
                  //TODO: of no section for current scenario, gray out the button and do nothing
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Add Character'),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddCharacterMenu());
                },
              ),
              ListTile(
                title: const Text('Remove Characters'),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const RemoveCharacterMenu());
                },
              ),
              const Divider(),
              ListTile(
                enabled: false,
                title: const Text('Add Monsters'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove Monsters'),
                enabled: false,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Settings'),
                enabled: false,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Documentation'),
                enabled: false,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    ),
  );
}
