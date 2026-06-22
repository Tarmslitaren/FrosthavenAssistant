// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuSetScenario => 'Set Scenario';

  @override
  String get menuAddCharacter => 'Add Character';

  @override
  String get menuRemoveCharacters => 'Remove Characters';

  @override
  String get menuSetLevel => 'Set Level';

  @override
  String get menuLootDeck => 'Loot Deck Menu';

  @override
  String get menuAddMonsters => 'Add Monsters';

  @override
  String get menuRemoveMonsters => 'Remove Monsters';

  @override
  String get menuShowAllyDeck => 'Show Ally Attack Modifier Deck';

  @override
  String get menuHideAllyDeck => 'Hide Ally Attack Modifier Deck';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuDocumentation => 'Documentation';

  @override
  String get menuDonate => 'Donate';

  @override
  String get menuExit => 'Exit';

  @override
  String get menuAddSection => 'Add Section';

  @override
  String get menuAddRandomDungeonCard => 'Add Random Dungeon Card';

  @override
  String get undo => 'Undo';

  @override
  String undoWithDescription(String description) {
    return 'Undo: $description';
  }

  @override
  String get redo => 'Redo';

  @override
  String redoWithDescription(String description) {
    return 'Redo: $description';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get connectedAsClient => 'Connected as Client';

  @override
  String get connecting => 'Connecting...';

  @override
  String connectAsClientWithIp(String ip) {
    return 'Connect as Client ($ip)';
  }

  @override
  String get connectAsClientLabel => 'Connect as Client';

  @override
  String stopServerWithIp(String ip) {
    return 'Stop Server $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'Start Host Server $ip';
  }

  @override
  String get stopServerButton => 'Stop Server';

  @override
  String get startHostServerButton => 'Start Host Server';

  @override
  String get networkConnectLocal => 'Connect devices on local wifi:';

  @override
  String get networkServerIpHint => 'server ip address';

  @override
  String get networkPortHint => 'port';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsSoftNumpad => 'Soft numpad for input';

  @override
  String get settingsNoInit => 'Don\'t ask for initiative';

  @override
  String get settingsExpireConditions => 'Expire Conditions';

  @override
  String get settingsNoStandees => 'Don\'t track Standees';

  @override
  String get settingsAutoAddStandees => 'Auto Add Standees';

  @override
  String get settingsAutoAddSpawns => 'Auto Add Timed Spawns';

  @override
  String get settingsRandomStandees => 'Random Standees';

  @override
  String get settingsNoCalculations => 'No Calculations';

  @override
  String get settingsHideLootDeck => 'Hide Loot Deck';

  @override
  String get settingsShimmer => 'Stat card text shimmers';

  @override
  String get settingsFhHazTerrainCalc =>
      'Use Frosthaven Hazardous Terrain Calculation in OG Gloomhaven';

  @override
  String get settingsAllyDeckOGGloom =>
      'Use Ally Attack Modifier Deck in OG Gloomhaven';

  @override
  String get settingsShowScenarioNames => 'Show Scenario names in list';

  @override
  String get settingsShowBattleGoalReminder => 'Show Battle Goal Reminder';

  @override
  String get settingsShowCustomContent => 'Show Custom Content';

  @override
  String get settingsShowSections => 'Show Sections in Main Screen';

  @override
  String get settingsShowReminders => 'Show Round Special Rule Reminders';

  @override
  String get settingsShowAmdDeck => 'Show Attack Modifier Decks';

  @override
  String get settingsShowCharacterAmd => 'Show character Attack Modifier Decks';

  @override
  String get settingsHealthWheel =>
      'Enable heath wheel: drag left-right to change health';

  @override
  String get settingsFullscreen => 'Fullscreen';

  @override
  String get settingsMainListScaling => 'Main List Scaling:';

  @override
  String get settingsAppBarScaling => 'App Bar Scaling:';

  @override
  String get settingsStyleLabel => 'Style:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'Original';

  @override
  String get settingsClearUnlocked => 'Clear unlocked characters and stuff';

  @override
  String get settingsUnlockSpecials => 'Unlock specials';

  @override
  String get settingsLoadSaveState => 'Load/Save State';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get close => 'Close';

  @override
  String get retry => 'RETRY';

  @override
  String get specialUnlocks => 'Special Unlocks';

  @override
  String get loadSaveDeleteCharacters => 'Load, Save or Delete Characters.';

  @override
  String get loadAddDeleteSaves => 'Load, Add or Delete save states.';

  @override
  String get addNewSave => 'Add new Save';

  @override
  String get addNewSaveLabel => 'Add new Save:';

  @override
  String get loadButton => 'Load';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteButton => 'Delete';

  @override
  String get setSaveName => 'Set save name:';

  @override
  String get loadOrSaveCharacters => 'Load or Save Characters';

  @override
  String get loadCharacter => 'Load Character:';

  @override
  String get removeAll => 'Remove All';

  @override
  String get removeCardQuestion => 'Remove card?';

  @override
  String get sendToBottom => 'Send to Bottom';

  @override
  String get shuffleUndrawnCards => 'Shuffle un-drawn Cards';

  @override
  String get returnToDiscardPile => 'Return card to discard pile';

  @override
  String get returnToDrawPile => 'Return card to draw pile';

  @override
  String get addExtraLootCard => 'Add Extra Loot Card';

  @override
  String get addStandeeNr => 'Add Standee Nr';

  @override
  String get summonedLabel => 'Summoned:';

  @override
  String get characterDecks => 'Character Decks';

  @override
  String get shuffleAndDraw => 'Shuffle\n& Draw';

  @override
  String get draw => 'Draw';

  @override
  String get nextRound => ' Next Round';

  @override
  String get returnTopCard => 'Return top card';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'Remove $title\n(card nr: $nr)';
  }

  @override
  String get tapCardToAddToDeck => 'Tap Card to add to your deck';

  @override
  String get removeCardFromDeckQuestion => 'Remove card from your deck?';

  @override
  String get changeName => 'Change name:';

  @override
  String get showBosses => 'Show Bosses';

  @override
  String get showScenarioSpecialMonsters => 'Show Scenario Special Monsters';

  @override
  String get addAsAlly => 'Add as Ally';

  @override
  String get addMonsterLabel => 'Add Monster';

  @override
  String get allCampaigns => 'All Campaigns';

  @override
  String get showMonstersFrom => '      Show monsters from:   ';

  @override
  String setMonsterLevel(String name) {
    return 'Set $name\'s level';
  }

  @override
  String setSummonHealth(String name) {
    return 'Set $name\'s max health';
  }

  @override
  String get setScenarioLevel => 'Set Scenario Level';

  @override
  String enhancedLevel(String level) {
    return 'Enhanced: $level';
  }

  @override
  String get soloLabel => 'Solo:';

  @override
  String get automaticScenarioLevel => 'Automatic Scenario Level:';

  @override
  String get difficultyLabel => 'Difficulty:';

  @override
  String get lootCardEnhancements => 'Loot Card Enhancements';

  @override
  String get addPerks => 'Add Perks';

  @override
  String get useFrosthavenPerks => 'Use Frosthaven Perks';
}
