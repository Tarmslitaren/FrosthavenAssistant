import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/settings_menu.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../Resource/commands/hide_ally_deck_command.dart';
import '../../Resource/commands/show_ally_deck_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/network.dart';
import 'add_monster_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

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
    Settings settings = getIt<Settings>();

    final commandIndex = gameState.commandIndex.value;

    if (settings.client.value == ClientState.connected) {
      return true;
    }
    if (settings.server.value) {
      return commandIndex >= 0 &&
          commandIndex < gameState.commandDescriptions.length &&
          (commandIndex == 0 ||
              gameState.commandDescriptions[commandIndex - 1] != "");
    }
    return commandIndex >= 0 &&
        commandIndex < gameState.commands.length &&
        (commandIndex == 0 || gameState.commands[commandIndex - 1] != null);
  }

  bool redoEnabled() {
    GameState gameState = getIt<GameState>();
    if (getIt<Settings>().client.value == ClientState.connected) {
      return true;
    }
    if (getIt<Settings>().server.value) {
      return gameState.commandDescriptions.isNotEmpty &&
          gameState.gameSaveStates.length >=
              gameState.commandDescriptions.length &&
          gameState.commandIndex.value <
              gameState.commandDescriptions.length - 1;
    }
    return gameState.commandIndex.value <
        gameState.commandDescriptions.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    GameState gameState = getIt<GameState>();
    Settings settings = getIt<Settings>();
    return Drawer(
      child: ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          String undoText = "Undo";
          final clientState = settings.client.value;
          final commandIndex = gameState.commandIndex.value;
          final descriptionsAmount = gameState.commandDescriptions.length;
          if (clientState != ClientState.connected &&
              commandIndex >= 0 &&
              descriptionsAmount > commandIndex) {
            undoText += ": ${gameState.commandDescriptions[commandIndex]}";
          }
          String redoText = "Redo";
          if (clientState != ClientState.connected &&
              commandIndex < descriptionsAmount - 1) {
            redoText += ": ${gameState.commandDescriptions[commandIndex + 1]}";
          }

          return ListView(
// Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/images/icon.png"))),
                  child: Stack(
                    children: [
                      Positioned(
                          right: 6, bottom: 0, child: Text("Version 1.13.3"))
                    ],
                  ),
                ),
                ListTile(
                  title: Text(undoText),
                  enabled: undoEnabled(),
                  onTap: () {
                    gameState.undo();
                  },
                ),
                ListTile(
                  title: Text(redoText),
                  enabled: redoEnabled(),
                  onTap: () {
                    gameState.redo();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Set Scenario'),
                  onTap: () {
                    Navigator.pop(context);
                    openDialog(context, const SelectScenarioMenu());
                  },
                ),
                ListTile(
                  title: Text(
                      getIt<GameState>().scenario.value == "#Random Dungeon"
                          ? 'Add Random Dungeon Card'
                          : 'Add Section'),
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
                ListTile(
                  title: const Text('Set Level'),
                  onTap: () {
                    Navigator.pop(context);
                    openDialog(context, const SetLevelMenu());
                  },
                ),
                if (gameState.currentCampaign.value == "Frosthaven")
                  ListTile(
                    title: const Text('Loot Deck Menu'),
                    onTap: () {
                      Navigator.pop(context);
                      openDialog(context, const LootCardsMenu());
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
                if (!gameState.showAllyDeck.value &&
                    !GameMethods.shouldShowAlliesDeck() &&
                    settings.showAmdDeck.value)
                  ListTile(
                    title: const Text('Show Ally Attack Modifier Deck'),
                    onTap: () {
                      Navigator.pop(context);
                      gameState.action(ShowAllyDeckCommand());
                      getIt<GameState>().updateAllUI();
                    },
                  ),

                if (gameState.showAllyDeck.value && settings.showAmdDeck.value)
                  ListTile(
                    title: const Text('Hide Ally Attack Modifier Deck'),
                    onTap: () {
                      Navigator.pop(context);
                      gameState.action(HideAllyDeckCommand());
                      getIt<GameState>().updateAllUI();
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
                if (!settings.lastKnownConnection.endsWith('?'))
                  ValueListenableBuilder<ClientState>(
                      valueListenable: settings.client,
                      builder: (context, value, child) {
                        bool connected = false;
                        final clientState = settings.client.value;
                        String connectionText =
                            "Connect as Client (${settings.lastKnownConnection})";
                        if (clientState == ClientState.connected) {
                          connected = true;
                          connectionText = "Connected as Client";
                        }
                        if (clientState == ClientState.connecting) {
                          connectionText = "Connecting...";
                        }
                        return CheckboxListTile(
                            enabled: !settings.server.value &&
                                clientState != ClientState.connecting,
                            title: Text(connectionText),
                            value: connected,
                            onChanged: (bool? value) {
                              if (settings.client.value !=
                                  ClientState.connected) {
                                settings.client.value = ClientState.connecting;
                                getIt<Client>()
                                    .connect(settings.lastKnownConnection)
                                    .then((value) => null);
                                settings.saveToDisk();
                              } else {
                                getIt<Client>().disconnect(null);
                              }
                            });
                      }),
                ValueListenableBuilder<bool>(
                    valueListenable: settings.server,
                    builder: (context, value, child) {
                      return ValueListenableBuilder<String>(
                          valueListenable:
                              getIt<Network>().networkInfo.wifiIPv4,
                          builder: (context, value, child) {
                            String ip =
                                "(${getIt<Network>().networkInfo.wifiIPv4.value})";
                            String hostIPText = 'Start Host Server $ip';
                            return CheckboxListTile(
                                title: Text(settings.server.value
                                    ? "Stop Server $ip"
                                    : hostIPText),
                                value: settings.server.value,
                                onChanged: (bool? value) {
                                  settings.lastKnownHostIP =
                                      "(${getIt<Network>().networkInfo.wifiIPv4.value})";
                                  settings.saveToDisk();
                                  //do the thing
                                  if (!settings.server.value) {
                                    getIt<Network>().server.startServer();
                                  } else {
                                    //close server?
                                    getIt<Network>().server.stopServer(null);
                                  }
                                });
                          });
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
                ListTile(
                  title: const Text('Donate'),
                  onTap: () {
                    final Uri toLaunch = Uri(
                        scheme: 'https',
                        host: 'ko-fi.com',
                        path: 'tarmslitaren');
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
}
