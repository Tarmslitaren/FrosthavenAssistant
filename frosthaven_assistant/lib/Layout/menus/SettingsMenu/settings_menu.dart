import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/save_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/special_unlocks_menu.dart';
import 'package:frosthaven_assistant/Layout/widgets/scrollable_menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/clear_unlocked_classes_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_ally_deck_in_og_gloom_command.dart';
import 'package:frosthaven_assistant/Resource/commands/track_standees_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../Resource/enums.dart';
import '../../../Resource/scaling.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/ui_utils.dart';
import '../../../services/network/client.dart';
import '../../../services/network/network.dart';
import '../../../services/service_locator.dart';
import 'settings_checkbox.dart';
import 'settings_network_section.dart';

class SettingsMenu extends StatefulWidget {
  static const double _kBarWidthBase = 40.0;
  static const double _kBarWidthMultiplier = 6.5;
  static const double _kScaleMin = 0.2;
  static const double _kScaleMax = 3.0;
  static const double _kBarScaleMin = 0.8;
  static const double _kLabelPaddingLeft = 16.0;
  static const double _kLabelPaddingTop = 10.0;

  const SettingsMenu(
      {super.key, this.gameState, this.network, this.client, this.settings});

  final GameState? gameState;
  final Network? network;
  final Client? client;
  final Settings? settings;

  @override
  SettingsMenuState createState() => SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {
  Settings get settings => widget.settings ?? getIt<Settings>();
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Network get _network => widget.network ?? getIt<Network>();
  Client get _client => widget.client ?? getIt<Client>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double referenceMinBarWidth =
        SettingsMenu._kBarWidthBase * SettingsMenu._kBarWidthMultiplier;
    double maxBarScale = screenWidth / referenceMinBarWidth;

    return ScrollableMenuCard(
        maxWidth: kMenuNarrowWidth,
        onClose: settings.saveToDisk,
        child: Column(
          children: [
            const Text("Settings", style: kTitleStyle),
            SettingsCheckbox(
                title: "Dark mode",
                notifier: settings.darkMode,
                onChanged: (v) {
                  settings.darkMode.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Soft numpad for input",
                notifier: settings.softNumpadInput,
                onChanged: (v) {
                  settings.softNumpadInput.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Don't ask for initiative",
                notifier: settings.noInit,
                onChanged: (v) {
                  settings.noInit.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Expire Conditions",
                notifier: settings.expireConditions,
                onChanged: (v) {
                  settings.expireConditions.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Don't track Standees",
                notifier: settings.noStandees,
                onChanged: (v) {
                  _gameState.action(TrackStandeesCommand(!v,
                      gameState: _gameState, settings: settings));
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Auto Add Standees",
                notifier: settings.autoAddStandees,
                onChanged: (v) {
                  settings.autoAddStandees.value = v;
                  settings.saveToDisk();
                  _gameState.updateList.notify();
                }),
            SettingsCheckbox(
                title: "Auto Add Timed Spawns",
                notifier: settings.autoAddSpawns,
                onChanged: (v) {
                  settings.autoAddSpawns.value = v;
                  settings.saveToDisk();
                  _gameState.updateList.notify();
                }),
            SettingsCheckbox(
                title: "Random Standees",
                notifier: settings.randomStandees,
                onChanged: (v) {
                  settings.randomStandees.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "No Calculations",
                notifier: settings.noCalculation,
                onChanged: (v) {
                  settings.noCalculation.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Hide Loot Deck",
                notifier: settings.hideLootDeck,
                onChanged: (v) {
                  settings.hideLootDeck.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Stat card text shimmers",
                notifier: settings.shimmer,
                onChanged: (v) {
                  settings.shimmer.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title:
                    "Use Frosthaven Hazardous Terrain Calculation in OG Gloomhaven",
                notifier: settings.fhHazTerrainCalcInOGGloom,
                onChanged: (v) {
                  settings.fhHazTerrainCalcInOGGloom.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Use Ally Attack Modifier Deck in OG Gloomhaven",
                notifier: _gameState.allyDeckInOGGloom,
                onChanged: (v) {
                  _gameState.action(
                      SetAllyDeckInOgGloomCommand(v, gameState: _gameState));
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show Scenario names in list",
                notifier: settings.showScenarioNames,
                onChanged: (v) {
                  settings.showScenarioNames.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show Battle Goal Reminder",
                notifier: settings.showBattleGoalReminder,
                onChanged: (v) {
                  settings.showBattleGoalReminder.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: "Show Custom Content",
                notifier: settings.showCustomContent,
                onChanged: (v) {
                  settings.showCustomContent.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show Sections in Main Screen",
                notifier: settings.showSectionsInMainView,
                onChanged: (v) {
                  settings.showSectionsInMainView.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show Round Special Rule Reminders",
                notifier: settings.showReminders,
                onChanged: (v) {
                  settings.showReminders.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show Attack Modifier Decks",
                notifier: settings.showAmdDeck,
                onChanged: (v) {
                  settings.showAmdDeck.value = v;
                  if (!v) settings.showCharacterAMD.value = false;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Show character Attack Modifier Decks",
                notifier: settings.showCharacterAMD,
                onChanged: (v) {
                  settings.showCharacterAMD.value = v;
                  if (v) settings.showAmdDeck.value = true;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: "Enable heath wheel: drag left-right to change health",
                notifier: settings.enableHeathWheel,
                onChanged: (v) {
                  settings.enableHeathWheel.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            if (!Platform.isIOS)
              SettingsCheckbox(
                  title: "Fullscreen",
                  notifier: settings.fullScreen,
                  onChanged: (v) {
                    settings.setFullscreen(v);
                    settings.saveToDisk();
                  }),
            Container(
              constraints: const BoxConstraints(minWidth: double.infinity),
              padding: const EdgeInsets.only(
                  left: SettingsMenu._kLabelPaddingLeft,
                  top: SettingsMenu._kLabelPaddingTop),
              alignment: Alignment.bottomLeft,
              child: const Text("Main List Scaling:"),
            ),
            Slider(
              min: SettingsMenu._kScaleMin,
              max: SettingsMenu._kScaleMax,
              value: settings.userScalingMainList.value,
              onChanged: (value) {
                setState(() {
                  settings.userScalingMainList.value = value;
                  setMaxWidth();
                  settings.saveToDisk();
                });
              },
            ),
            Container(
              constraints: const BoxConstraints(minWidth: double.infinity),
              padding: const EdgeInsets.only(
                  left: SettingsMenu._kLabelPaddingLeft,
                  top: SettingsMenu._kLabelPaddingTop),
              alignment: Alignment.bottomLeft,
              child: const Text("App Bar Scaling:"),
            ),
            Slider(
              min: min(SettingsMenu._kBarScaleMin, maxBarScale),
              max: min(maxBarScale, SettingsMenu._kScaleMax),
              value: min(settings.userScalingBars.value, maxBarScale),
              onChanged: (value) {
                setState(() {
                  settings.userScalingBars.value = value;
                  settings.saveToDisk();
                });
              },
            ),
            const Text("Style:", style: kTitleStyle),
            RadioGroup<Style>(
              groupValue: settings.style.value,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  settings.style.value = value;
                  settings.saveToDisk();
                  _gameState.updateList.notify();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Radio<Style>(value: Style.frosthaven),
                      const Text('Frosthaven'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<Style>(value: Style.original),
                      const Text('Original'),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
                title: const Text("Clear unlocked characters and stuff"),
                onTap: () {
                  setState(() {
                    _gameState.action(ClearUnlockedClassesCommand());
                  });
                }),
            ListTile(
                title: const Text("Unlock specials"),
                onTap: () {
                  openDialog(context, SpecialUnlocksMenu());
                }),
            SettingsNetworkSection(
                settings: settings, network: _network, client: _client),
            ListTile(
                title: const Text("Load/Save State"),
                onTap: () {
                  openDialog(context, const SaveMenu());
                }),
          ],
        ));
  }
}
