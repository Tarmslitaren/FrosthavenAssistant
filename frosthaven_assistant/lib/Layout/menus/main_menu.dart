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
import 'package:frosthaven_assistant/Layout/view_models/main_menu_view_model.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/network.dart';
import 'add_monster_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu(
      {super.key, this.gameState, this.settings, this.client, this.network});

  // injected for testing
  final GameState? gameState;
  final Settings? settings;
  final Client? client;
  final Network? network;

  Future<void> _launchUrlInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = MainMenuViewModel(
        gameState: gameState,
        settings: settings,
        client: client,
        network: network);
    return Drawer(
      child: ValueListenableBuilder<int>(
        valueListenable: vm.commandIndex,
        builder: (context, value, child) {
          return ListView(
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
                          right: 6, bottom: 0, child: Text("Version 1.13.8"))
                    ],
                  ),
                ),
                ListTile(
                  title: Text(vm.undoText),
                  enabled: vm.undoEnabled,
                  onTap: () {
                    vm.undo();
                  },
                ),
                ListTile(
                  title: Text(vm.redoText),
                  enabled: vm.redoEnabled,
                  onTap: () {
                    vm.redo();
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
                  title: Text(vm.addSectionText),
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
                if (vm.showLootDeckMenu)
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
                if (vm.showShowAllyDeck)
                  ListTile(
                    title: const Text('Show Ally Attack Modifier Deck'),
                    onTap: () {
                      Navigator.pop(context);
                      vm.showAllyDeck();
                    },
                  ),
                if (vm.showHideAllyDeck)
                  ListTile(
                    title: const Text('Hide Ally Attack Modifier Deck'),
                    onTap: () {
                      Navigator.pop(context);
                      vm.hideAllyDeck();
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
                if (vm.showClientTile)
                  ValueListenableBuilder<ClientState>(
                      valueListenable: vm.clientState,
                      builder: (context, value, child) {
                        return CheckboxListTile(
                            enabled: !vm.isServer && !vm.isConnecting,
                            title: Text(vm.connectionText(
                                vm.lastKnownConnection)),
                            value: vm.isConnected,
                            onChanged: (bool? value) {
                              vm.toggleClientConnection();
                            });
                      }),
                ValueListenableBuilder<bool>(
                    valueListenable: vm.serverState,
                    builder: (context, value, child) {
                      return ValueListenableBuilder<String>(
                          valueListenable: vm.wifiIPv6,
                          builder: (context, value, child) {
                            final ip =
                                "(${vm.wifiIPv6.value})";
                            return CheckboxListTile(
                                title: Text(vm.isServer
                                    ? "Stop Server $ip"
                                    : 'Start Host Server $ip'),
                                value: vm.isServer,
                                onChanged: (bool? value) {
                                  vm.toggleServer();
                                });
                          });
                    }),
                const Divider(),
                ListTile(
                  title: const Text('Documentation'),
                  onTap: () {
                    final Uri toLaunch = Uri(
                        scheme: 'https',
                        host: 'www.github.com',
                        path: 'Tarmslitaren/FrosthavenAssistant',
                        fragment: "#readme");
                    _launchUrlInBrowser(toLaunch);
                    Navigator.pop(context);
                  },
                ),
                if (!Platform.isIOS)
                  ListTile(
                    title: const Text('Donate'),
                    onTap: () {
                      final Uri toLaunch = Uri(
                          scheme: 'https',
                          host: 'ko-fi.com',
                          path: 'tarmslitaren');
                      _launchUrlInBrowser(toLaunch);
                      Navigator.pop(context);
                    },
                  ),
                Platform.isMacOS || Platform.isLinux || Platform.isWindows
                    ? ListTile(
                        title: const Text('Exit'),
                        enabled: true,
                        onTap: () {
                          Navigator.pop(context);
                          vm.save();
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
