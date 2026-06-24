import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ko'),
    Locale('pl'),
    Locale('ru'),
    Locale('th'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

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

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get settingsLanguage;

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
  /// **' Next\nRound'**
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

  /// No description provided for @currentCampaign.
  ///
  /// In en, this message translates to:
  /// **'Current Campaign: {campaign}'**
  String currentCampaign(String campaign);

  /// No description provided for @addCharacterHint.
  ///
  /// In en, this message translates to:
  /// **'Add Character (type name for hidden character classes)'**
  String get addCharacterHint;

  /// No description provided for @trapDamage.
  ///
  /// In en, this message translates to:
  /// **'trap damage'**
  String get trapDamage;

  /// No description provided for @hazardousTerrainDamage.
  ///
  /// In en, this message translates to:
  /// **'hazardous terrain damage'**
  String get hazardousTerrainDamage;

  /// No description provided for @experienceAdded.
  ///
  /// In en, this message translates to:
  /// **'experience added'**
  String get experienceAdded;

  /// No description provided for @goldCoinValue.
  ///
  /// In en, this message translates to:
  /// **'gold coin value'**
  String get goldCoinValue;

  /// No description provided for @levelLegendLabel.
  ///
  /// In en, this message translates to:
  /// **'level'**
  String get levelLegendLabel;

  /// No description provided for @saveStateNote.
  ///
  /// In en, this message translates to:
  /// **'Please note that the app automatically saves your progress after every action. These are for backups or multiple campaigns.'**
  String get saveStateNote;

  /// No description provided for @clientConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Client Connected to: {address}'**
  String clientConnectedTo(String address);

  /// No description provided for @clientError.
  ///
  /// In en, this message translates to:
  /// **'Client error: {error}'**
  String clientError(String error);

  /// No description provided for @clientListenError.
  ///
  /// In en, this message translates to:
  /// **'Client listen error: {error}'**
  String clientListenError(String error);

  /// No description provided for @lostConnectionToServer.
  ///
  /// In en, this message translates to:
  /// **'Lost connection to server'**
  String get lostConnectionToServer;

  /// No description provided for @stateMismatch.
  ///
  /// In en, this message translates to:
  /// **'Your state was not up to date, try again.'**
  String get stateMismatch;

  /// No description provided for @serverUnresponsive.
  ///
  /// In en, this message translates to:
  /// **'Server unresponsive. Client disconnected.'**
  String get serverUnresponsive;

  /// No description provided for @clientDisconnected.
  ///
  /// In en, this message translates to:
  /// **'client disconnected'**
  String get clientDisconnected;

  /// No description provided for @serverOffline.
  ///
  /// In en, this message translates to:
  /// **'Server Offline'**
  String get serverOffline;

  /// No description provided for @clientLeft.
  ///
  /// In en, this message translates to:
  /// **'Client left.'**
  String get clientLeft;

  /// No description provided for @clientTooOld.
  ///
  /// In en, this message translates to:
  /// **'Old client attempted to connect. Please update the app.'**
  String get clientTooOld;

  /// No description provided for @networkConnection.
  ///
  /// In en, this message translates to:
  /// **'Network connection: {status}'**
  String networkConnection(String status);

  /// No description provided for @failedToGetWifiIp.
  ///
  /// In en, this message translates to:
  /// **'Failed to get IP address'**
  String get failedToGetWifiIp;

  /// No description provided for @badOmen.
  ///
  /// In en, this message translates to:
  /// **'Bad Omen'**
  String get badOmen;

  /// No description provided for @badOmensLeft.
  ///
  /// In en, this message translates to:
  /// **'Bad Omens Left: {count}'**
  String badOmensLeft(int count);

  /// No description provided for @corrosiveSpew.
  ///
  /// In en, this message translates to:
  /// **'Corrosive Spew'**
  String get corrosiveSpew;

  /// No description provided for @empowersOnTop.
  ///
  /// In en, this message translates to:
  /// **'Empowers on top'**
  String get empowersOnTop;

  /// No description provided for @addMinusOneCard.
  ///
  /// In en, this message translates to:
  /// **'Add -1 card (added: {count})'**
  String addMinusOneCard(int count);

  /// No description provided for @removeMinusOneCard.
  ///
  /// In en, this message translates to:
  /// **'Remove -1 card'**
  String get removeMinusOneCard;

  /// No description provided for @removeMinusTwoCard.
  ///
  /// In en, this message translates to:
  /// **'Remove -2 card'**
  String get removeMinusTwoCard;

  /// No description provided for @minusTwoCardRemoved.
  ///
  /// In en, this message translates to:
  /// **'-2 card removed'**
  String get minusTwoCardRemoved;

  /// No description provided for @removePlusZeroCard.
  ///
  /// In en, this message translates to:
  /// **'Remove +0 card'**
  String get removePlusZeroCard;

  /// No description provided for @plusZeroCardRemoved.
  ///
  /// In en, this message translates to:
  /// **'+0 card removed'**
  String get plusZeroCardRemoved;

  /// No description provided for @removeImbue.
  ///
  /// In en, this message translates to:
  /// **'Remove Imbue'**
  String get removeImbue;

  /// No description provided for @imbue.
  ///
  /// In en, this message translates to:
  /// **'Imbue'**
  String get imbue;

  /// No description provided for @advancedImbue.
  ///
  /// In en, this message translates to:
  /// **'Advanced Imbue'**
  String get advancedImbue;

  /// No description provided for @removeHailPerk.
  ///
  /// In en, this message translates to:
  /// **'Remove Hail Perk'**
  String get removeHailPerk;

  /// No description provided for @addHailPerk.
  ///
  /// In en, this message translates to:
  /// **'Add Hail Perk'**
  String get addHailPerk;

  /// No description provided for @removeCassandraPerk.
  ///
  /// In en, this message translates to:
  /// **'Remove\nCassandra Perk'**
  String get removeCassandraPerk;

  /// No description provided for @addCassandraPerk.
  ///
  /// In en, this message translates to:
  /// **'Add\nCassandra Perk'**
  String get addCassandraPerk;

  /// No description provided for @dontSaveRevealedCards.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Save\nRevealed Cards'**
  String get dontSaveRevealedCards;

  /// No description provided for @saveRevealedCards.
  ///
  /// In en, this message translates to:
  /// **'Save\nRevealed Cards'**
  String get saveRevealedCards;

  /// No description provided for @removedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Removed: {count}'**
  String removedCountLabel(int count);

  /// No description provided for @removeDonation.
  ///
  /// In en, this message translates to:
  /// **'Remove\nDonation'**
  String get removeDonation;

  /// No description provided for @donateSanctuary.
  ///
  /// In en, this message translates to:
  /// **'Donate to\nSanctuary'**
  String get donateSanctuary;

  /// No description provided for @removePartyCard.
  ///
  /// In en, this message translates to:
  /// **'Remove\nParty Card:'**
  String get removePartyCard;

  /// No description provided for @addPartyCard.
  ///
  /// In en, this message translates to:
  /// **'Add Party\nCard:'**
  String get addPartyCard;

  /// No description provided for @perks.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get perks;

  /// No description provided for @revealCards.
  ///
  /// In en, this message translates to:
  /// **'Reveal\ncards:'**
  String get revealCards;

  /// No description provided for @revealAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get revealAll;

  /// No description provided for @drawExtraCard.
  ///
  /// In en, this message translates to:
  /// **'Draw extra card'**
  String get drawExtraCard;

  /// No description provided for @extraShuffle.
  ///
  /// In en, this message translates to:
  /// **'Extra Shuffle'**
  String get extraShuffle;

  /// No description provided for @inactivateMonster.
  ///
  /// In en, this message translates to:
  /// **'Inactivate\nMonster'**
  String get inactivateMonster;

  /// No description provided for @activateMonster.
  ///
  /// In en, this message translates to:
  /// **'Activate\nMonster'**
  String get activateMonster;

  /// No description provided for @addEliteStandees.
  ///
  /// In en, this message translates to:
  /// **'Add {count} Elite {name}'**
  String addEliteStandees(int count, String name);

  /// No description provided for @addNormalStandees.
  ///
  /// In en, this message translates to:
  /// **'Add {count} Normal {name}'**
  String addNormalStandees(int count, String name);

  /// No description provided for @characterLoot.
  ///
  /// In en, this message translates to:
  /// **'Character loot'**
  String get characterLoot;

  /// No description provided for @addSpecialCard.
  ///
  /// In en, this message translates to:
  /// **'Add card {nr}'**
  String addSpecialCard(int nr);

  /// No description provided for @removeSpecialCard.
  ///
  /// In en, this message translates to:
  /// **'Remove card {nr}'**
  String removeSpecialCard(int nr);

  /// No description provided for @enhanceCards.
  ///
  /// In en, this message translates to:
  /// **'Enhance cards'**
  String get enhanceCards;

  /// No description provided for @addLootCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addLootCard;

  /// No description provided for @returnToTop.
  ///
  /// In en, this message translates to:
  /// **'Return to Top'**
  String get returnToTop;

  /// No description provided for @returnToBottom.
  ///
  /// In en, this message translates to:
  /// **'Return to Bottom'**
  String get returnToBottom;

  /// No description provided for @characterLootTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s loot:'**
  String characterLootTitle(String name);

  /// No description provided for @setLootOwner.
  ///
  /// In en, this message translates to:
  /// **'Set Loot Owner:'**
  String get setLootOwner;

  /// No description provided for @lootNameCoin.
  ///
  /// In en, this message translates to:
  /// **'coin'**
  String get lootNameCoin;

  /// No description provided for @lootNameHide.
  ///
  /// In en, this message translates to:
  /// **'hide'**
  String get lootNameHide;

  /// No description provided for @lootNameLumber.
  ///
  /// In en, this message translates to:
  /// **'lumber'**
  String get lootNameLumber;

  /// No description provided for @lootNameMetal.
  ///
  /// In en, this message translates to:
  /// **'metal'**
  String get lootNameMetal;

  /// No description provided for @lootNameArrowvine.
  ///
  /// In en, this message translates to:
  /// **'arrowvine'**
  String get lootNameArrowvine;

  /// No description provided for @lootNameAxenut.
  ///
  /// In en, this message translates to:
  /// **'axenut'**
  String get lootNameAxenut;

  /// No description provided for @lootNameCorpsecap.
  ///
  /// In en, this message translates to:
  /// **'corpsecap'**
  String get lootNameCorpsecap;

  /// No description provided for @lootNameFlamefruit.
  ///
  /// In en, this message translates to:
  /// **'flamefruit'**
  String get lootNameFlamefruit;

  /// No description provided for @lootNameRockroot.
  ///
  /// In en, this message translates to:
  /// **'rockroot'**
  String get lootNameRockroot;

  /// No description provided for @lootNameSnowthistle.
  ///
  /// In en, this message translates to:
  /// **'snowthistle'**
  String get lootNameSnowthistle;

  /// No description provided for @lootAmount2For2.
  ///
  /// In en, this message translates to:
  /// **'2 for 2 characters'**
  String get lootAmount2For2;

  /// No description provided for @lootAmount2For23.
  ///
  /// In en, this message translates to:
  /// **'2 for 2-3 characters'**
  String get lootAmount2For23;

  /// No description provided for @cmdActivateMonster.
  ///
  /// In en, this message translates to:
  /// **'Activate {name}'**
  String cmdActivateMonster(String name);

  /// No description provided for @cmdDeactivateMonster.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}'**
  String cmdDeactivateMonster(String name);

  /// No description provided for @cmdAddCharacter.
  ///
  /// In en, this message translates to:
  /// **'Add {id}'**
  String cmdAddCharacter(String id);

  /// No description provided for @cmdAddCondition.
  ///
  /// In en, this message translates to:
  /// **'Add condition: {condition}'**
  String cmdAddCondition(String condition);

  /// No description provided for @cmdRemoveCondition.
  ///
  /// In en, this message translates to:
  /// **'Remove condition: {condition}'**
  String cmdRemoveCondition(String condition);

  /// No description provided for @cmdAddPartyCard.
  ///
  /// In en, this message translates to:
  /// **'{character} add party card {type}'**
  String cmdAddPartyCard(String character, String type);

  /// No description provided for @cmdRemovePartyCard.
  ///
  /// In en, this message translates to:
  /// **'{character} remove party card'**
  String cmdRemovePartyCard(String character);

  /// No description provided for @cmdAddFactionCard.
  ///
  /// In en, this message translates to:
  /// **'{character} add faction card'**
  String cmdAddFactionCard(String character);

  /// No description provided for @cmdRemoveFactionCard.
  ///
  /// In en, this message translates to:
  /// **'{character} remove faction card'**
  String cmdRemoveFactionCard(String character);

  /// No description provided for @cmdAddLootCard.
  ///
  /// In en, this message translates to:
  /// **'Add {type} Loot Card'**
  String cmdAddLootCard(String type);

  /// No description provided for @cmdAddMonster.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String cmdAddMonster(String name);

  /// No description provided for @cmdAddSpecialLootCard.
  ///
  /// In en, this message translates to:
  /// **'Add Special loot card {nr}'**
  String cmdAddSpecialLootCard(int nr);

  /// No description provided for @cmdRemoveSpecialLootCard.
  ///
  /// In en, this message translates to:
  /// **'Remove Special loot card {nr}'**
  String cmdRemoveSpecialLootCard(int nr);

  /// No description provided for @cmdAddMinusOne.
  ///
  /// In en, this message translates to:
  /// **'Add minus one'**
  String get cmdAddMinusOne;

  /// No description provided for @cmdRemoveMinusOne.
  ///
  /// In en, this message translates to:
  /// **'Remove minus one'**
  String get cmdRemoveMinusOne;

  /// No description provided for @cmdRemoveMinusTwo.
  ///
  /// In en, this message translates to:
  /// **'Remove minus two'**
  String get cmdRemoveMinusTwo;

  /// No description provided for @cmdAddBackMinusTwo.
  ///
  /// In en, this message translates to:
  /// **'Add back minus two'**
  String get cmdAddBackMinusTwo;

  /// No description provided for @cmdRemovePlusZero.
  ///
  /// In en, this message translates to:
  /// **'Remove plus zero'**
  String get cmdRemovePlusZero;

  /// No description provided for @cmdAddBackPlusZero.
  ///
  /// In en, this message translates to:
  /// **'Add back plus zero'**
  String get cmdAddBackPlusZero;

  /// No description provided for @cmdRevealModifierCards.
  ///
  /// In en, this message translates to:
  /// **'Reveal {count} modifier cards'**
  String cmdRevealModifierCards(int count);

  /// No description provided for @cmdCassandraLeaveRevealed.
  ///
  /// In en, this message translates to:
  /// **'Leave revealed cards on top of {deck} deck'**
  String cmdCassandraLeaveRevealed(String deck);

  /// No description provided for @cmdCassandraSpecialOff.
  ///
  /// In en, this message translates to:
  /// **'Cassandra Special turned off for {deck} deck'**
  String cmdCassandraSpecialOff(String deck);

  /// No description provided for @cmdImbueMonsterDeck.
  ///
  /// In en, this message translates to:
  /// **'Imbue Monster Deck'**
  String get cmdImbueMonsterDeck;

  /// No description provided for @cmdAdvancedImbueMonsterDeck.
  ///
  /// In en, this message translates to:
  /// **'Advanced Imbue Monster Deck'**
  String get cmdAdvancedImbueMonsterDeck;

  /// No description provided for @cmdRemoveImbueMonsterDeck.
  ///
  /// In en, this message translates to:
  /// **'Remove Imbuement'**
  String get cmdRemoveImbueMonsterDeck;

  /// No description provided for @cmdChangeName.
  ///
  /// In en, this message translates to:
  /// **'Change character name'**
  String get cmdChangeName;

  /// No description provided for @cmdAddBless.
  ///
  /// In en, this message translates to:
  /// **'Add a Bless'**
  String get cmdAddBless;

  /// No description provided for @cmdRemoveBless.
  ///
  /// In en, this message translates to:
  /// **'Remove a Bless'**
  String get cmdRemoveBless;

  /// No description provided for @cmdAddCurse.
  ///
  /// In en, this message translates to:
  /// **'Add a Curse'**
  String get cmdAddCurse;

  /// No description provided for @cmdRemoveCurse.
  ///
  /// In en, this message translates to:
  /// **'Remove a Curse'**
  String get cmdRemoveCurse;

  /// No description provided for @cmdAddEmpower.
  ///
  /// In en, this message translates to:
  /// **'Add Empower'**
  String get cmdAddEmpower;

  /// No description provided for @cmdRemoveEmpower.
  ///
  /// In en, this message translates to:
  /// **'Remove Empower'**
  String get cmdRemoveEmpower;

  /// No description provided for @cmdAddEnfeeble.
  ///
  /// In en, this message translates to:
  /// **'Add Enfeeble'**
  String get cmdAddEnfeeble;

  /// No description provided for @cmdRemoveEnfeeble.
  ///
  /// In en, this message translates to:
  /// **'Remove Enfeeble'**
  String get cmdRemoveEnfeeble;

  /// No description provided for @cmdIncreaseMaxHealth.
  ///
  /// In en, this message translates to:
  /// **'Increase {owner}\'s max health'**
  String cmdIncreaseMaxHealth(String owner);

  /// No description provided for @cmdDecreaseMaxHealth.
  ///
  /// In en, this message translates to:
  /// **'Decrease {owner}\'s max health'**
  String cmdDecreaseMaxHealth(String owner);

  /// No description provided for @cmdChangeStat.
  ///
  /// In en, this message translates to:
  /// **'Change stat'**
  String get cmdChangeStat;

  /// No description provided for @cmdIncreaseXp.
  ///
  /// In en, this message translates to:
  /// **'Increase {figure}\'s xp by {amount}'**
  String cmdIncreaseXp(String figure, int amount);

  /// No description provided for @cmdDecreaseXp.
  ///
  /// In en, this message translates to:
  /// **'Decrease {figure}\'s xp by {amount}'**
  String cmdDecreaseXp(String figure, int amount);

  /// No description provided for @cmdClearUnlockedClasses.
  ///
  /// In en, this message translates to:
  /// **'Clear unlocked classes'**
  String get cmdClearUnlockedClasses;

  /// No description provided for @cmdDonateSanctuary.
  ///
  /// In en, this message translates to:
  /// **'{character} donate to sanctuary'**
  String cmdDonateSanctuary(String character);

  /// No description provided for @cmdRemoveSanctuaryDonation.
  ///
  /// In en, this message translates to:
  /// **'Remove {character}\'s donation'**
  String cmdRemoveSanctuaryDonation(String character);

  /// No description provided for @cmdDrawExtraAbilityCard.
  ///
  /// In en, this message translates to:
  /// **'Draw extra ability card'**
  String get cmdDrawExtraAbilityCard;

  /// No description provided for @cmdDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get cmdDraw;

  /// No description provided for @cmdDrawLootCard.
  ///
  /// In en, this message translates to:
  /// **'Draw loot card'**
  String get cmdDrawLootCard;

  /// No description provided for @cmdDrawModifierCard.
  ///
  /// In en, this message translates to:
  /// **'Draw {name} modifier card'**
  String cmdDrawModifierCard(String name);

  /// No description provided for @cmdRemoveLootEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Remove Loot Enhancement'**
  String get cmdRemoveLootEnhancement;

  /// No description provided for @cmdAddLootEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Add Loot Enhancement'**
  String get cmdAddLootEnhancement;

  /// No description provided for @cmdHideAllyDeck.
  ///
  /// In en, this message translates to:
  /// **'Hide Ally Deck'**
  String get cmdHideAllyDeck;

  /// No description provided for @cmdShowAllyDeck.
  ///
  /// In en, this message translates to:
  /// **'Show Ally Deck'**
  String get cmdShowAllyDeck;

  /// No description provided for @cmdIceWraithTurnNormal.
  ///
  /// In en, this message translates to:
  /// **'Ice Wraith turn normal'**
  String get cmdIceWraithTurnNormal;

  /// No description provided for @cmdIceWraithTurnElite.
  ///
  /// In en, this message translates to:
  /// **'Ice Wraith turn elite'**
  String get cmdIceWraithTurnElite;

  /// No description provided for @cmdImbueElement.
  ///
  /// In en, this message translates to:
  /// **'Imbue element {element}'**
  String cmdImbueElement(String element);

  /// No description provided for @cmdUseElement.
  ///
  /// In en, this message translates to:
  /// **'Use Element {element}'**
  String cmdUseElement(String element);

  /// No description provided for @cmdLoadCharacter.
  ///
  /// In en, this message translates to:
  /// **'Load saved character: {name}'**
  String cmdLoadCharacter(String name);

  /// No description provided for @cmdLoadGame.
  ///
  /// In en, this message translates to:
  /// **'Load saved game: {name}'**
  String cmdLoadGame(String name);

  /// No description provided for @cmdNextRound.
  ///
  /// In en, this message translates to:
  /// **'Next Round'**
  String get cmdNextRound;

  /// No description provided for @cmdRemoveAmdCard.
  ///
  /// In en, this message translates to:
  /// **'Remove AMD card'**
  String get cmdRemoveAmdCard;

  /// No description provided for @cmdRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Remove {deck} card nr {nr}'**
  String cmdRemoveCard(String deck, int nr);

  /// No description provided for @cmdRemoveAllCharacters.
  ///
  /// In en, this message translates to:
  /// **'Remove all characters'**
  String get cmdRemoveAllCharacters;

  /// No description provided for @cmdRemoveCharacter.
  ///
  /// In en, this message translates to:
  /// **'Remove {id}'**
  String cmdRemoveCharacter(String id);

  /// No description provided for @cmdRemoveAllMonsters.
  ///
  /// In en, this message translates to:
  /// **'Remove all monsters'**
  String get cmdRemoveAllMonsters;

  /// No description provided for @cmdRemoveMonster.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String cmdRemoveMonster(String name);

  /// No description provided for @cmdReorderAbilityCards.
  ///
  /// In en, this message translates to:
  /// **'Reorder Ability Cards'**
  String get cmdReorderAbilityCards;

  /// No description provided for @cmdReorderList.
  ///
  /// In en, this message translates to:
  /// **'Reorder List'**
  String get cmdReorderList;

  /// No description provided for @cmdReorderModifierCards.
  ///
  /// In en, this message translates to:
  /// **'Reorder Modifier Cards'**
  String get cmdReorderModifierCards;

  /// No description provided for @cmdReturnLootCard.
  ///
  /// In en, this message translates to:
  /// **'Return loot card'**
  String get cmdReturnLootCard;

  /// No description provided for @cmdReturnModifierCard.
  ///
  /// In en, this message translates to:
  /// **'Return modifier card to top'**
  String get cmdReturnModifierCard;

  /// No description provided for @cmdReturnRemovedAmdCard.
  ///
  /// In en, this message translates to:
  /// **'Return removed AMD card'**
  String get cmdReturnRemovedAmdCard;

  /// No description provided for @cmdNoAllyDeckInOgGloom.
  ///
  /// In en, this message translates to:
  /// **'No ally deck in 1st edition Gloomhaven campaigns'**
  String get cmdNoAllyDeckInOgGloom;

  /// No description provided for @cmdUseAllyDeckInOgGloom.
  ///
  /// In en, this message translates to:
  /// **'Use Ally Deck in 1st edition Gloomhaven Campaigns'**
  String get cmdUseAllyDeckInOgGloom;

  /// No description provided for @cmdMarkAsSummon.
  ///
  /// In en, this message translates to:
  /// **'Mark {owner} as summon'**
  String cmdMarkAsSummon(String owner);

  /// No description provided for @cmdRemoveSummonMark.
  ///
  /// In en, this message translates to:
  /// **'Remove {owner}\'s summon mark'**
  String cmdRemoveSummonMark(String owner);

  /// No description provided for @cmdAutoLevelOn.
  ///
  /// In en, this message translates to:
  /// **'Turn automatic level update on'**
  String get cmdAutoLevelOn;

  /// No description provided for @cmdAutoLevelOff.
  ///
  /// In en, this message translates to:
  /// **'Turn automatic level update off'**
  String get cmdAutoLevelOff;

  /// No description provided for @cmdSetCampaign.
  ///
  /// In en, this message translates to:
  /// **'Set {campaign} campaign'**
  String cmdSetCampaign(String campaign);

  /// No description provided for @cmdSetCharacterLevel.
  ///
  /// In en, this message translates to:
  /// **'Set {character}\'s Level'**
  String cmdSetCharacterLevel(String character);

  /// No description provided for @cmdSetDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Set difficulty level to {difficulty}'**
  String cmdSetDifficulty(String difficulty);

  /// No description provided for @cmdSetInitiative.
  ///
  /// In en, this message translates to:
  /// **'Set initiative of {character}'**
  String cmdSetInitiative(String character);

  /// No description provided for @cmdSetMonsterLevel.
  ///
  /// In en, this message translates to:
  /// **'Set {monster}\'s level'**
  String cmdSetMonsterLevel(String monster);

  /// No description provided for @cmdSetLootOwner.
  ///
  /// In en, this message translates to:
  /// **'Set loot card owner'**
  String get cmdSetLootOwner;

  /// No description provided for @cmdSetScenario.
  ///
  /// In en, this message translates to:
  /// **'Set Scenario'**
  String get cmdSetScenario;

  /// No description provided for @cmdSetSoloOn.
  ///
  /// In en, this message translates to:
  /// **'Set solo level recommendation on'**
  String get cmdSetSoloOn;

  /// No description provided for @cmdSetSoloOff.
  ///
  /// In en, this message translates to:
  /// **'Set solo level recommendation off'**
  String get cmdSetSoloOff;

  /// No description provided for @cmdExtraAbilityShuffle.
  ///
  /// In en, this message translates to:
  /// **'Extra ability deck shuffle'**
  String get cmdExtraAbilityShuffle;

  /// No description provided for @cmdExtraAmdShuffle.
  ///
  /// In en, this message translates to:
  /// **'Extra AMD deck shuffle'**
  String get cmdExtraAmdShuffle;

  /// No description provided for @cmdDrawnAbilityShuffle.
  ///
  /// In en, this message translates to:
  /// **'Drawn ability deck shuffle'**
  String get cmdDrawnAbilityShuffle;

  /// No description provided for @cmdDontTrackStandees.
  ///
  /// In en, this message translates to:
  /// **'Don\'t track standees'**
  String get cmdDontTrackStandees;

  /// No description provided for @cmdTrackStandees.
  ///
  /// In en, this message translates to:
  /// **'Track standees'**
  String get cmdTrackStandees;

  /// No description provided for @cmdTurnDone.
  ///
  /// In en, this message translates to:
  /// **'{id}\'s turn done'**
  String cmdTurnDone(String id);

  /// No description provided for @cmdAddPerk.
  ///
  /// In en, this message translates to:
  /// **'Add \'{character}\' Perk {index}'**
  String cmdAddPerk(String character, int index);

  /// No description provided for @cmdRemovePerk.
  ///
  /// In en, this message translates to:
  /// **'Remove \'{character}\' Perk {index}'**
  String cmdRemovePerk(String character, int index);

  /// No description provided for @cmdUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock {id}'**
  String cmdUnlock(String id);

  /// No description provided for @cmdLock.
  ///
  /// In en, this message translates to:
  /// **'Lock {id}'**
  String cmdLock(String id);

  /// No description provided for @cmdSetLevel.
  ///
  /// In en, this message translates to:
  /// **'Set Level'**
  String get cmdSetLevel;

  /// No description provided for @cmdAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add Section'**
  String get cmdAddSection;

  /// No description provided for @cmdAddStandee.
  ///
  /// In en, this message translates to:
  /// **'Add {name} {nr}'**
  String cmdAddStandee(String name, int nr);

  /// No description provided for @cmdDrawMonsterModifierCard.
  ///
  /// In en, this message translates to:
  /// **'Draw monster modifier card'**
  String get cmdDrawMonsterModifierCard;

  /// No description provided for @cmdIncreaseHealth.
  ///
  /// In en, this message translates to:
  /// **'Increase {figure}\'s health by {amount}'**
  String cmdIncreaseHealth(String figure, int amount);

  /// No description provided for @cmdKill.
  ///
  /// In en, this message translates to:
  /// **'Kill {owner}'**
  String cmdKill(String owner);

  /// No description provided for @cmdDecreaseHealth.
  ///
  /// In en, this message translates to:
  /// **'Decrease {owner}\'s health by {amount}'**
  String cmdDecreaseHealth(String owner, int amount);

  /// No description provided for @cmdUseFhPerks.
  ///
  /// In en, this message translates to:
  /// **'{character} use Frosthaven Perks'**
  String cmdUseFhPerks(String character);

  /// No description provided for @cmdDontUseFhPerks.
  ///
  /// In en, this message translates to:
  /// **'{character} don\'t use Frosthaven Perks'**
  String cmdDontUseFhPerks(String character);

  /// No description provided for @cmdRemoveNoCharacters.
  ///
  /// In en, this message translates to:
  /// **'Remove no characters'**
  String get cmdRemoveNoCharacters;

  /// No description provided for @cmdRemoveNoMonsters.
  ///
  /// In en, this message translates to:
  /// **'Remove no monsters'**
  String get cmdRemoveNoMonsters;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ko',
    'pl',
    'ru',
    'th',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
