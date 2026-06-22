import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @menuSetScenario.
  ///
  /// In en, this message translates to:
  /// **'Set Scenario'**
  String get menuSetScenario;

  /// No description provided for @menuAddCharacter.
  ///
  /// In en, this message translates to:
  /// **'Add Character'**
  String get menuAddCharacter;

  /// No description provided for @menuRemoveCharacters.
  ///
  /// In en, this message translates to:
  /// **'Remove Characters'**
  String get menuRemoveCharacters;

  /// No description provided for @menuSetLevel.
  ///
  /// In en, this message translates to:
  /// **'Set Level'**
  String get menuSetLevel;

  /// No description provided for @menuLootDeck.
  ///
  /// In en, this message translates to:
  /// **'Loot Deck Menu'**
  String get menuLootDeck;

  /// No description provided for @menuAddMonsters.
  ///
  /// In en, this message translates to:
  /// **'Add Monsters'**
  String get menuAddMonsters;

  /// No description provided for @menuRemoveMonsters.
  ///
  /// In en, this message translates to:
  /// **'Remove Monsters'**
  String get menuRemoveMonsters;

  /// No description provided for @menuShowAllyDeck.
  ///
  /// In en, this message translates to:
  /// **'Show Ally Attack Modifier Deck'**
  String get menuShowAllyDeck;

  /// No description provided for @menuHideAllyDeck.
  ///
  /// In en, this message translates to:
  /// **'Hide Ally Attack Modifier Deck'**
  String get menuHideAllyDeck;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get menuDocumentation;

  /// No description provided for @menuDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get menuDonate;

  /// No description provided for @menuExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get menuExit;

  /// No description provided for @menuAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add Section'**
  String get menuAddSection;

  /// No description provided for @menuAddRandomDungeonCard.
  ///
  /// In en, this message translates to:
  /// **'Add Random Dungeon Card'**
  String get menuAddRandomDungeonCard;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @undoWithDescription.
  ///
  /// In en, this message translates to:
  /// **'Undo: {description}'**
  String undoWithDescription(String description);

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @redoWithDescription.
  ///
  /// In en, this message translates to:
  /// **'Redo: {description}'**
  String redoWithDescription(String description);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @connectedAsClient.
  ///
  /// In en, this message translates to:
  /// **'Connected as Client'**
  String get connectedAsClient;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectAsClientWithIp.
  ///
  /// In en, this message translates to:
  /// **'Connect as Client ({ip})'**
  String connectAsClientWithIp(String ip);

  /// No description provided for @connectAsClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Connect as Client'**
  String get connectAsClientLabel;

  /// No description provided for @stopServerWithIp.
  ///
  /// In en, this message translates to:
  /// **'Stop Server {ip}'**
  String stopServerWithIp(String ip);

  /// No description provided for @startHostServerWithIp.
  ///
  /// In en, this message translates to:
  /// **'Start Host Server {ip}'**
  String startHostServerWithIp(String ip);

  /// No description provided for @stopServerButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get stopServerButton;

  /// No description provided for @startHostServerButton.
  ///
  /// In en, this message translates to:
  /// **'Start Host Server'**
  String get startHostServerButton;

  /// No description provided for @networkConnectLocal.
  ///
  /// In en, this message translates to:
  /// **'Connect devices on local wifi:'**
  String get networkConnectLocal;

  /// No description provided for @networkServerIpHint.
  ///
  /// In en, this message translates to:
  /// **'server ip address'**
  String get networkServerIpHint;

  /// No description provided for @networkPortHint.
  ///
  /// In en, this message translates to:
  /// **'port'**
  String get networkPortHint;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSoftNumpad.
  ///
  /// In en, this message translates to:
  /// **'Soft numpad for input'**
  String get settingsSoftNumpad;

  /// No description provided for @settingsNoInit.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask for initiative'**
  String get settingsNoInit;

  /// No description provided for @settingsExpireConditions.
  ///
  /// In en, this message translates to:
  /// **'Expire Conditions'**
  String get settingsExpireConditions;

  /// No description provided for @settingsNoStandees.
  ///
  /// In en, this message translates to:
  /// **'Don\'t track Standees'**
  String get settingsNoStandees;

  /// No description provided for @settingsAutoAddStandees.
  ///
  /// In en, this message translates to:
  /// **'Auto Add Standees'**
  String get settingsAutoAddStandees;

  /// No description provided for @settingsAutoAddSpawns.
  ///
  /// In en, this message translates to:
  /// **'Auto Add Timed Spawns'**
  String get settingsAutoAddSpawns;

  /// No description provided for @settingsRandomStandees.
  ///
  /// In en, this message translates to:
  /// **'Random Standees'**
  String get settingsRandomStandees;

  /// No description provided for @settingsNoCalculations.
  ///
  /// In en, this message translates to:
  /// **'No Calculations'**
  String get settingsNoCalculations;

  /// No description provided for @settingsHideLootDeck.
  ///
  /// In en, this message translates to:
  /// **'Hide Loot Deck'**
  String get settingsHideLootDeck;

  /// No description provided for @settingsShimmer.
  ///
  /// In en, this message translates to:
  /// **'Stat card text shimmers'**
  String get settingsShimmer;

  /// No description provided for @settingsFhHazTerrainCalc.
  ///
  /// In en, this message translates to:
  /// **'Use Frosthaven Hazardous Terrain Calculation in OG Gloomhaven'**
  String get settingsFhHazTerrainCalc;

  /// No description provided for @settingsAllyDeckOGGloom.
  ///
  /// In en, this message translates to:
  /// **'Use Ally Attack Modifier Deck in OG Gloomhaven'**
  String get settingsAllyDeckOGGloom;

  /// No description provided for @settingsShowScenarioNames.
  ///
  /// In en, this message translates to:
  /// **'Show Scenario names in list'**
  String get settingsShowScenarioNames;

  /// No description provided for @settingsShowBattleGoalReminder.
  ///
  /// In en, this message translates to:
  /// **'Show Battle Goal Reminder'**
  String get settingsShowBattleGoalReminder;

  /// No description provided for @settingsShowCustomContent.
  ///
  /// In en, this message translates to:
  /// **'Show Custom Content'**
  String get settingsShowCustomContent;

  /// No description provided for @settingsShowSections.
  ///
  /// In en, this message translates to:
  /// **'Show Sections in Main Screen'**
  String get settingsShowSections;

  /// No description provided for @settingsShowReminders.
  ///
  /// In en, this message translates to:
  /// **'Show Round Special Rule Reminders'**
  String get settingsShowReminders;

  /// No description provided for @settingsShowAmdDeck.
  ///
  /// In en, this message translates to:
  /// **'Show Attack Modifier Decks'**
  String get settingsShowAmdDeck;

  /// No description provided for @settingsShowCharacterAmd.
  ///
  /// In en, this message translates to:
  /// **'Show character Attack Modifier Decks'**
  String get settingsShowCharacterAmd;

  /// No description provided for @settingsHealthWheel.
  ///
  /// In en, this message translates to:
  /// **'Enable heath wheel: drag left-right to change health'**
  String get settingsHealthWheel;

  /// No description provided for @settingsFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get settingsFullscreen;

  /// No description provided for @settingsMainListScaling.
  ///
  /// In en, this message translates to:
  /// **'Main List Scaling:'**
  String get settingsMainListScaling;

  /// No description provided for @settingsAppBarScaling.
  ///
  /// In en, this message translates to:
  /// **'App Bar Scaling:'**
  String get settingsAppBarScaling;

  /// No description provided for @settingsStyleLabel.
  ///
  /// In en, this message translates to:
  /// **'Style:'**
  String get settingsStyleLabel;

  /// No description provided for @styleFrosthaven.
  ///
  /// In en, this message translates to:
  /// **'Frosthaven'**
  String get styleFrosthaven;

  /// No description provided for @styleOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get styleOriginal;

  /// No description provided for @settingsClearUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Clear unlocked characters and stuff'**
  String get settingsClearUnlocked;

  /// No description provided for @settingsUnlockSpecials.
  ///
  /// In en, this message translates to:
  /// **'Unlock specials'**
  String get settingsUnlockSpecials;

  /// No description provided for @settingsLoadSaveState.
  ///
  /// In en, this message translates to:
  /// **'Load/Save State'**
  String get settingsLoadSaveState;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @specialUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Special Unlocks'**
  String get specialUnlocks;

  /// No description provided for @loadSaveDeleteCharacters.
  ///
  /// In en, this message translates to:
  /// **'Load, Save or Delete Characters.'**
  String get loadSaveDeleteCharacters;

  /// No description provided for @loadAddDeleteSaves.
  ///
  /// In en, this message translates to:
  /// **'Load, Add or Delete save states.'**
  String get loadAddDeleteSaves;

  /// No description provided for @addNewSave.
  ///
  /// In en, this message translates to:
  /// **'Add new Save'**
  String get addNewSave;

  /// No description provided for @addNewSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Add new Save:'**
  String get addNewSaveLabel;

  /// No description provided for @loadButton.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @setSaveName.
  ///
  /// In en, this message translates to:
  /// **'Set save name:'**
  String get setSaveName;

  /// No description provided for @loadOrSaveCharacters.
  ///
  /// In en, this message translates to:
  /// **'Load or Save Characters'**
  String get loadOrSaveCharacters;

  /// No description provided for @loadCharacter.
  ///
  /// In en, this message translates to:
  /// **'Load Character:'**
  String get loadCharacter;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get removeAll;

  /// No description provided for @removeCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove card?'**
  String get removeCardQuestion;

  /// No description provided for @sendToBottom.
  ///
  /// In en, this message translates to:
  /// **'Send to Bottom'**
  String get sendToBottom;

  /// No description provided for @shuffleUndrawnCards.
  ///
  /// In en, this message translates to:
  /// **'Shuffle un-drawn Cards'**
  String get shuffleUndrawnCards;

  /// No description provided for @returnToDiscardPile.
  ///
  /// In en, this message translates to:
  /// **'Return card to discard pile'**
  String get returnToDiscardPile;

  /// No description provided for @returnToDrawPile.
  ///
  /// In en, this message translates to:
  /// **'Return card to draw pile'**
  String get returnToDrawPile;

  /// No description provided for @addExtraLootCard.
  ///
  /// In en, this message translates to:
  /// **'Add Extra Loot Card'**
  String get addExtraLootCard;

  /// No description provided for @addStandeeNr.
  ///
  /// In en, this message translates to:
  /// **'Add Standee Nr'**
  String get addStandeeNr;

  /// No description provided for @summonedLabel.
  ///
  /// In en, this message translates to:
  /// **'Summoned:'**
  String get summonedLabel;

  /// No description provided for @characterDecks.
  ///
  /// In en, this message translates to:
  /// **'Character Decks'**
  String get characterDecks;

  /// No description provided for @shuffleAndDraw.
  ///
  /// In en, this message translates to:
  /// **'Shuffle\n& Draw'**
  String get shuffleAndDraw;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **' Next Round'**
  String get nextRound;

  /// No description provided for @returnTopCard.
  ///
  /// In en, this message translates to:
  /// **'Return top card'**
  String get returnTopCard;

  /// No description provided for @removeCardWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}\n(card nr: {nr})'**
  String removeCardWithDetails(String title, int nr);

  /// No description provided for @tapCardToAddToDeck.
  ///
  /// In en, this message translates to:
  /// **'Tap Card to add to your deck'**
  String get tapCardToAddToDeck;

  /// No description provided for @removeCardFromDeckQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove card from your deck?'**
  String get removeCardFromDeckQuestion;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change name:'**
  String get changeName;

  /// No description provided for @showBosses.
  ///
  /// In en, this message translates to:
  /// **'Show Bosses'**
  String get showBosses;

  /// No description provided for @showScenarioSpecialMonsters.
  ///
  /// In en, this message translates to:
  /// **'Show Scenario Special Monsters'**
  String get showScenarioSpecialMonsters;

  /// No description provided for @addAsAlly.
  ///
  /// In en, this message translates to:
  /// **'Add as Ally'**
  String get addAsAlly;

  /// No description provided for @addMonsterLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Monster'**
  String get addMonsterLabel;

  /// No description provided for @allCampaigns.
  ///
  /// In en, this message translates to:
  /// **'All Campaigns'**
  String get allCampaigns;

  /// No description provided for @showMonstersFrom.
  ///
  /// In en, this message translates to:
  /// **'      Show monsters from:   '**
  String get showMonstersFrom;

  /// No description provided for @setMonsterLevel.
  ///
  /// In en, this message translates to:
  /// **'Set {name}\'s level'**
  String setMonsterLevel(String name);

  /// No description provided for @setSummonHealth.
  ///
  /// In en, this message translates to:
  /// **'Set {name}\'s max health'**
  String setSummonHealth(String name);

  /// No description provided for @setScenarioLevel.
  ///
  /// In en, this message translates to:
  /// **'Set Scenario Level'**
  String get setScenarioLevel;

  /// No description provided for @enhancedLevel.
  ///
  /// In en, this message translates to:
  /// **'Enhanced: {level}'**
  String enhancedLevel(String level);

  /// No description provided for @soloLabel.
  ///
  /// In en, this message translates to:
  /// **'Solo:'**
  String get soloLabel;

  /// No description provided for @automaticScenarioLevel.
  ///
  /// In en, this message translates to:
  /// **'Automatic Scenario Level:'**
  String get automaticScenarioLevel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty:'**
  String get difficultyLabel;

  /// No description provided for @lootCardEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Loot Card Enhancements'**
  String get lootCardEnhancements;

  /// No description provided for @addPerks.
  ///
  /// In en, this message translates to:
  /// **'Add Perks'**
  String get addPerks;

  /// No description provided for @useFrosthavenPerks.
  ///
  /// In en, this message translates to:
  /// **'Use Frosthaven Perks'**
  String get useFrosthavenPerks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
