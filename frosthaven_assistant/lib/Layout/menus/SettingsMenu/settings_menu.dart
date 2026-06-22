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
import '../../../l10n/app_localizations.dart';
import '../../../services/network/client.dart';
import '../../../services/network/network.dart';
import '../../../services/service_locator.dart';
import '../../../services/translation_service.dart';
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

  // Maps locale code → native display name. Extend when adding translations.
  static const Map<String, String> _kLocales = {
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'pl': 'Polski',
    'ko': '한국어',
    'ru': 'Русский',
    'zh': '中文',
    'zh_Hant': '中文 (繁體)',
    'th': 'ภาษาไทย',
  };

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

    final l10n = AppLocalizations.of(context)!;
    return ScrollableMenuCard(
        maxWidth: kMenuNarrowWidth,
        onClose: settings.saveToDisk,
        child: Column(
          children: [
            Text(l10n.menuSettings, style: kTitleStyle),
            Padding(
              padding: const EdgeInsets.only(
                  left: SettingsMenu._kLabelPaddingLeft,
                  top: SettingsMenu._kLabelPaddingTop),
              child: Row(
                children: [
                  Text(l10n.settingsLanguage),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: settings.locale.value,
                    items: SettingsMenu._kLocales.entries
                        .map((e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (String? newLocale) {
                      if (newLocale == null) return;
                      setState(() {
                        settings.locale.value = newLocale;
                      });
                      getIt<TranslationService>().load(newLocale);
                      settings.saveToDisk();
                    },
                  ),
                ],
              ),
            ),
            SettingsCheckbox(
                title: l10n.settingsDarkMode,
                notifier: settings.darkMode,
                onChanged: (v) {
                  settings.darkMode.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsSoftNumpad,
                notifier: settings.softNumpadInput,
                onChanged: (v) {
                  settings.softNumpadInput.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsNoInit,
                notifier: settings.noInit,
                onChanged: (v) {
                  settings.noInit.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsExpireConditions,
                notifier: settings.expireConditions,
                onChanged: (v) {
                  settings.expireConditions.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsNoStandees,
                notifier: settings.noStandees,
                onChanged: (v) {
                  _gameState.action(TrackStandeesCommand(!v,
                      gameState: _gameState, settings: settings));
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsAutoAddStandees,
                notifier: settings.autoAddStandees,
                onChanged: (v) {
                  settings.autoAddStandees.value = v;
                  settings.saveToDisk();
                  _gameState.updateList.notify();
                }),
            SettingsCheckbox(
                title: l10n.settingsAutoAddSpawns,
                notifier: settings.autoAddSpawns,
                onChanged: (v) {
                  settings.autoAddSpawns.value = v;
                  settings.saveToDisk();
                  _gameState.updateList.notify();
                }),
            SettingsCheckbox(
                title: l10n.settingsRandomStandees,
                notifier: settings.randomStandees,
                onChanged: (v) {
                  settings.randomStandees.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsNoCalculations,
                notifier: settings.noCalculation,
                onChanged: (v) {
                  settings.noCalculation.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsHideLootDeck,
                notifier: settings.hideLootDeck,
                onChanged: (v) {
                  settings.hideLootDeck.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShimmer,
                notifier: settings.shimmer,
                onChanged: (v) {
                  settings.shimmer.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsFhHazTerrainCalc,
                notifier: settings.fhHazTerrainCalcInOGGloom,
                onChanged: (v) {
                  settings.fhHazTerrainCalcInOGGloom.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsAllyDeckOGGloom,
                notifier: _gameState.allyDeckInOGGloom,
                onChanged: (v) {
                  _gameState.action(
                      SetAllyDeckInOgGloomCommand(v, gameState: _gameState));
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowScenarioNames,
                notifier: settings.showScenarioNames,
                onChanged: (v) {
                  settings.showScenarioNames.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowBattleGoalReminder,
                notifier: settings.showBattleGoalReminder,
                onChanged: (v) {
                  settings.showBattleGoalReminder.value = v;
                  settings.saveToDisk();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowCustomContent,
                notifier: settings.showCustomContent,
                onChanged: (v) {
                  settings.showCustomContent.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowSections,
                notifier: settings.showSectionsInMainView,
                onChanged: (v) {
                  settings.showSectionsInMainView.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowReminders,
                notifier: settings.showReminders,
                onChanged: (v) {
                  settings.showReminders.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowAmdDeck,
                notifier: settings.showAmdDeck,
                onChanged: (v) {
                  settings.showAmdDeck.value = v;
                  if (!v) settings.showCharacterAMD.value = false;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsShowCharacterAmd,
                notifier: settings.showCharacterAMD,
                onChanged: (v) {
                  settings.showCharacterAMD.value = v;
                  if (v) settings.showAmdDeck.value = true;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            SettingsCheckbox(
                title: l10n.settingsHealthWheel,
                notifier: settings.enableHeathWheel,
                onChanged: (v) {
                  settings.enableHeathWheel.value = v;
                  settings.saveToDisk();
                  _gameState.updateAllUI();
                }),
            if (!Platform.isIOS)
              SettingsCheckbox(
                  title: l10n.settingsFullscreen,
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
              child: Text(l10n.settingsMainListScaling),
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
              child: Text(l10n.settingsAppBarScaling),
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
            Text(l10n.settingsStyleLabel, style: kTitleStyle),
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
                      Text(l10n.styleFrosthaven),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<Style>(value: Style.original),
                      Text(l10n.styleOriginal),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
                title: Text(l10n.settingsClearUnlocked),
                onTap: () {
                  setState(() {
                    _gameState.action(ClearUnlockedClassesCommand());
                  });
                }),
            ListTile(
                title: Text(l10n.settingsUnlockSpecials),
                onTap: () {
                  openDialog(context, SpecialUnlocksMenu());
                }),
            SettingsNetworkSection(
                settings: settings, network: _network, client: _client),
            ListTile(
                title: Text(l10n.settingsLoadSaveState),
                onTap: () {
                  openDialog(context, const SaveMenu());
                }),
          ],
        ));
  }
}
