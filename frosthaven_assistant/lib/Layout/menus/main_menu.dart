import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:search_choices/search_choices.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Model/campaign.dart';
import '../../Resource/ui_utils.dart';
import '../bottom_bar.dart';
import 'add_monster_menu.dart';

Future<void> launchUrlInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

Drawer createMainMenu(BuildContext context) {
  GameState _gameState = getIt<GameState>();

  return Drawer(
    child: ValueListenableBuilder<int>(
      valueListenable: _gameState.commandIndex,
      builder: (context, value, child) {

        String undoText = "Undo";
        if (_gameState.commandIndex.value >= 0){
          undoText += ": ${_gameState.commands[_gameState.commandIndex.value].toString()}";
        }
        String redoText = "Redo";
        if (_gameState.commandIndex.value < _gameState.commands.length-1) {
          redoText += ": ${_gameState.commands[_gameState.commandIndex.value+1].toString()}";
        }

        return ListView(
// Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                      image: AssetImage("assets/images/icon.png"))
                ),
                child: Column(children: [
                  //const Text('Main Menu'),
                 // createLevelWidget(context),
                ]),
              ),
              ListTile(
                title: Text(undoText ),
                enabled: _gameState.commandIndex.value >= 0,
                onTap: () {
                  _gameState.undo();
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(redoText),
                enabled: _gameState.commandIndex.value < _gameState.commands.length-1,
                onTap: () {
                  _gameState.redo();
                  //Navigator.pop(context);
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
                enabled: true,
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddSectionMenu());
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
                title: const Text('Add Monsters'),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddMonsterMenu());
                },
              ),
              ListTile(
                title: const Text('Remove Monsters'),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const RemoveMonsterMenu());
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
                onTap: () {
                    final Uri toLaunch =
                    Uri(scheme: 'https', host: 'www.github.com', path: 'Tarmslitaren/FrosthavenAssistant', fragment: "#readme" );
                    launchUrlInBrowser(toLaunch);
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    ),
  );
}
