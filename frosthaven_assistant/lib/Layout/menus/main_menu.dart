import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/LootCardsMenu/loot_cards_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/SelectScenarioMenu/select_scenario_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/SetLevelMenu/set_level_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/SettingsMenu/settings_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/add_section_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_character_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_monster_menu.dart';
import 'package:frosthaven_assistant/Layout/view_models/main_menu_view_model.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';
import 'package:frosthaven_assistant/services/network/client.dart';
import 'package:frosthaven_assistant/main.dart' show appVersion;
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/network.dart';
import 'add_monster_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    this.gameState,
    this.settings,
    this.client,
    this.network,
  });

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
      network: network,
    );
    return Drawer(
      child: ValueListenableBuilder<int>(
        valueListenable: vm.commandIndex,
        builder: (context, value, child) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage("assets/images/icon.png"),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 6,
                      bottom: 0,
                      child: Text(l10n.versionLabel(appVersion)),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(vm.undoDescription != null
                    ? l10n.undoWithDescription(vm.undoDescription!)
                    : l10n.undo),
                enabled: vm.undoEnabled,
                onTap: () {
                  vm.undo();
                },
              ),
              ListTile(
                title: Text(vm.redoDescription != null
                    ? l10n.redoWithDescription(vm.redoDescription!)
                    : l10n.redo),
                enabled: vm.redoEnabled,
                onTap: () {
                  vm.redo();
                },
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.menuSetScenario),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const SelectScenarioMenu());
                },
              ),
              ListTile(
                title: Text(vm.isRandomDungeon
                    ? l10n.menuAddRandomDungeonCard
                    : l10n.menuAddSection),
                enabled: true,
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddSectionMenu());
                },
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.menuAddCharacter),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddCharacterMenu());
                },
              ),
              ListTile(
                title: Text(l10n.menuRemoveCharacters),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const RemoveCharacterMenu());
                },
              ),
              ListTile(
                title: Text(l10n.menuSetLevel),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const SetLevelMenu());
                },
              ),
              if (vm.showLootDeckMenu)
                ListTile(
                  title: Text(l10n.menuLootDeck),
                  onTap: () {
                    Navigator.pop(context);
                    openDialog(context, const LootCardsMenu());
                  },
                ),
              const Divider(),
              ListTile(
                title: Text(l10n.menuAddMonsters),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const AddMonsterMenu());
                },
              ),
              ListTile(
                title: Text(l10n.menuRemoveMonsters),
                onTap: () {
                  Navigator.pop(context);
                  openDialog(context, const RemoveMonsterMenu());
                },
              ),
              if (vm.showShowAllyDeck)
                ListTile(
                  title: Text(l10n.menuShowAllyDeck),
                  onTap: () {
                    Navigator.pop(context);
                    vm.showAllyDeck();
                  },
                ),
              if (vm.showHideAllyDeck)
                ListTile(
                  title: Text(l10n.menuHideAllyDeck),
                  onTap: () {
                    Navigator.pop(context);
                    vm.hideAllyDeck();
                  },
                ),
              const Divider(),
              ListTile(
                title: Text(l10n.menuSettings),
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
                    final l10n = AppLocalizations.of(context)!;
                    return CheckboxListTile(
                      enabled: !vm.isServer && !vm.isConnecting,
                      title: Text(vm.isConnected
                          ? l10n.connectedAsClient
                          : vm.isConnecting
                              ? l10n.connecting
                              : l10n.connectAsClientWithIp(
                                  vm.lastKnownConnection)),
                      value: vm.isConnected,
                      onChanged: (bool? value) {
                        vm.toggleClientConnection();
                      },
                    );
                  },
                ),
              ValueListenableBuilder<bool>(
                valueListenable: vm.serverState,
                builder: (context, value, child) {
                  return ValueListenableBuilder<String>(
                    valueListenable: vm.wifiIPv6,
                    builder: (context, value, child) {
                      final l10n = AppLocalizations.of(context)!;
                      final ip = "(${vm.wifiIPv6.value})";
                      return CheckboxListTile(
                        title: Text(vm.isServer
                            ? l10n.stopServerWithIp(ip)
                            : l10n.startHostServerWithIp(ip)),
                        value: vm.isServer,
                        onChanged: (bool? value) {
                          vm.toggleServer();
                        },
                      );
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.menuDocumentation),
                onTap: () {
                  final Uri toLaunch = Uri(
                    scheme: 'https',
                    host: 'tarmslitaren.github.io',
                    path:
                        'FrosthavenAssistant/docs/manual', //https://tarmslitaren.github.io/FrosthavenAssistant/docs/manual/
                    fragment: "#readme",
                  );
                  _launchUrlInBrowser(toLaunch);
                  Navigator.pop(context);
                },
              ),
              if (!Platform.isIOS)
                ListTile(
                  title: Text(l10n.menuDonate),
                  onTap: () {
                    final Uri toLaunch = Uri(
                      scheme: 'https',
                      host: 'ko-fi.com',
                      path: 'tarmslitaren',
                    );
                    _launchUrlInBrowser(toLaunch);
                    Navigator.pop(context);
                  },
                ),
              Platform.isMacOS || Platform.isLinux || Platform.isWindows
                  ? ListTile(
                      title: Text(l10n.menuExit),
                      enabled: true,
                      onTap: () {
                        Navigator.pop(context);
                        vm.save();
                        windowManager.close();
                      },
                    )
                  : Container(),
            ],
          );
        },
      ),
    );
  }
}
