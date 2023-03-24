import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/settings_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/web_server.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/network.dart';
import 'add_monster_menu.dart';

Future<void> launchUrlInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

bool undoEnabled() {
  GameState gameState = getIt<GameState>();
  if(getIt<Settings>().client.value == ClientState.connected) {
    return true;
  }
  if(getIt<Settings>().server.value == true) {
    //TDO make the logic
    return gameState.commandIndex.value >= 0 &&
        gameState.commandIndex.value < gameState.commandDescriptions.length &&
        (gameState.commandIndex.value == 0 ||
            gameState.commandDescriptions[gameState.commandIndex.value - 1] !=
                "");
  }
  return
      gameState.commandIndex.value >= 0 &&
      gameState.commandIndex.value < gameState.commands.length &&
      (gameState.commandIndex.value == 0 ||
          gameState.commands[gameState.commandIndex.value - 1] !=
              null);
}

bool redoEnabled() {
  GameState gameState = getIt<GameState>();
  if(getIt<Settings>().client.value == ClientState.connected) {
    return true;
  }
  if(getIt<Settings>().server.value == true) {
    return gameState.commandDescriptions.isNotEmpty &&
        gameState.gameSaveStates.length >= gameState.commandDescriptions.length &&
        gameState.commandIndex.value < gameState.commandDescriptions.length - 1;
  }
  return gameState.commandIndex.value < gameState.commandDescriptions.length - 1;
}

Drawer createMainMenu(BuildContext context) {
  GameState gameState = getIt<GameState>();
  Settings settings = getIt<Settings>();

  return Drawer(
    child: ValueListenableBuilder<int>(
      valueListenable: gameState.commandIndex,
      builder: (context, value, child) {
        String undoText = "Undo";
        if (settings.client.value != ClientState.connected && gameState.commandIndex.value >= 0 &&
            gameState.commandDescriptions.length >
                gameState.commandIndex.value) {
          undoText +=
              ": ${gameState.commandDescriptions[gameState.commandIndex.value]}";
        }
        String redoText = "Redo";
        if (settings.client.value != ClientState.connected && gameState.commandIndex.value <
            gameState.commandDescriptions.length - 1) {
          redoText +=
              ": ${gameState.commandDescriptions[gameState.commandIndex.value + 1]}";
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
                        image: AssetImage("assets/images/icon.png"))),
                child: Stack(
                  children: const [
                    Positioned(
                        right: 6, bottom: 0, child: Text("Version 1.8.1"))
                  ],
                ),
              ),
              ListTile(
                title: Text(undoText),
                enabled: undoEnabled(),
                onTap: () {
                  gameState.undo();
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(redoText),
                enabled: redoEnabled(),
                onTap: () {
                  gameState.redo();
                  //Navigator.pop(context);
                },
              ),
              const Divider(),
              gameState.modelData.value == null
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
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const SettingsMenu());
                },
              ),
              const Divider(),
              if(!settings.lastKnownConnection.endsWith('?')) ValueListenableBuilder<ClientState>(
                  valueListenable: settings.client,
                  builder: (context, value, child) {
                    bool connected = false;
                    String connectionText = "Connect as Client (${settings.lastKnownConnection})";
                    if (settings.client.value == ClientState.connected) {
                      connected = true;
                      connectionText = "Connected as Client";
                    }
                    if (settings.client.value == ClientState.connecting) {
                      connectionText = "Connecting...";
                    }
                    return CheckboxListTile(
                        enabled: settings.server.value == false &&
                            settings.client.value != ClientState.connecting,
                        title: Text(connectionText),
                        value: connected,
                        onChanged: (bool? value) {
                          if (settings.client.value != ClientState.connected) {
                            settings.client.value = ClientState.connecting;
                            getIt<Network>()
                                .client
                                .connect(settings.lastKnownConnection)
                                .then((value) => null);
                            settings.saveToDisk();
                          } else {
                            getIt<Network>().client.disconnect(null);
                          }
                        });
                  }),
              ValueListenableBuilder<bool>(
                  valueListenable: settings.server,
                  builder: (context, value, child) {
                    String hostIPText = 'Start Host Server ${settings.lastKnownHostIP}';
                    return CheckboxListTile(
                        title: Text(settings.server.value
                            ? "Stop Server ${settings.lastKnownHostIP}"
                            : hostIPText),
                        value: settings.server.value,
                        onChanged: (bool? value) {
                          settings.lastKnownHostIP =
                            "(${getIt<Network>()
                              .networkInfo
                              .wifiIPv4
                              .value})";
                          settings.saveToDisk();
                          //setState(() {
                          //do the thing
                          if (!settings.server.value) {
                            getIt<Network>().server.startServer();
                            getIt<Network>().webServer.startServer();
                          } else {
                            //close server?
                            getIt<Network>().server.stopServer(null);
                            getIt<Network>().webServer.stopServer(null);
                          }
                        });
                    //});
                  }),
              //checkbox client + host + port
              //checkbox server - show ip, port
              const Divider(),
              ListTile(
                title: const Text('Documentation'),
                onTap: () {
                  final Uri toLaunch = Uri(
                      scheme: 'https',
                      host: 'www.github.com',
                      path: 'Tarmslitaren/FrosthavenAssistant',
                      fragment: "#readme");
                  launchUrlInBrowser(toLaunch);
                  Navigator.pop(context);
                },
              ),
              Platform.isMacOS || Platform.isLinux || Platform.isWindows
                  ? ListTile(
                      title: const Text('Exit'),
                      enabled: true,
                      onTap: () {
                        Navigator.pop(context);
                        gameState.save();
                        windowManager.close();
                      },
                    )
                  : Container(),
            ]);
      },
    ),
  );
}
