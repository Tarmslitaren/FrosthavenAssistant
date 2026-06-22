// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get settingsLanguage => 'Language:';

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

  @override
  String currentCampaign(String campaign) {
    return 'Current Campaign: $campaign';
  }

  @override
  String get addCharacterHint =>
      'Add Character (type name for hidden character classes)';

  @override
  String get trapDamage => 'trap damage';

  @override
  String get hazardousTerrainDamage => 'hazardous terrain damage';

  @override
  String get experienceAdded => 'experience added';

  @override
  String get goldCoinValue => 'gold coin value';

  @override
  String get levelLegendLabel => 'level';

  @override
  String get saveStateNote =>
      'Please note that the app automatically saves your progress after every action. These are for backups or multiple campaigns.';

  @override
  String clientConnectedTo(String address) {
    return 'Client Connected to: $address';
  }

  @override
  String clientError(String error) {
    return 'Client error: $error';
  }

  @override
  String clientListenError(String error) {
    return 'Client listen error: $error';
  }

  @override
  String get lostConnectionToServer => 'Lost connection to server';

  @override
  String get stateMismatch => 'Your state was not up to date, try again.';

  @override
  String get serverUnresponsive => 'Server unresponsive. Client disconnected.';

  @override
  String get clientDisconnected => 'client disconnected';

  @override
  String get serverOffline => 'Server Offline';

  @override
  String get clientLeft => 'Client left.';

  @override
  String get clientTooOld =>
      'Old client attempted to connect. Please update the app.';

  @override
  String networkConnection(String status) {
    return 'Network connection: $status';
  }

  @override
  String get failedToGetWifiIp => 'Failed to get IP address';

  @override
  String get badOmen => 'Bad Omen';

  @override
  String badOmensLeft(int count) {
    return 'Bad Omens Left: $count';
  }

  @override
  String get corrosiveSpew => 'Corrosive Spew';

  @override
  String get empowersOnTop => 'Empowers on top';

  @override
  String addMinusOneCard(int count) {
    return 'Add -1 card (added: $count)';
  }

  @override
  String get removeMinusOneCard => 'Remove -1 card';

  @override
  String get removeMinusTwoCard => 'Remove -2 card';

  @override
  String get minusTwoCardRemoved => '-2 card removed';

  @override
  String get removePlusZeroCard => 'Remove +0 card';

  @override
  String get plusZeroCardRemoved => '+0 card removed';

  @override
  String get removeImbue => 'Remove Imbue';

  @override
  String get imbue => 'Imbue';

  @override
  String get advancedImbue => 'Advanced Imbue';

  @override
  String get removeHailPerk => 'Remove Hail Perk';

  @override
  String get addHailPerk => 'Add Hail Perk';

  @override
  String get removeCassandraPerk => 'Remove\nCassandra Perk';

  @override
  String get addCassandraPerk => 'Add\nCassandra Perk';

  @override
  String get dontSaveRevealedCards => 'Don\'t Save\nRevealed Cards';

  @override
  String get saveRevealedCards => 'Save\nRevealed Cards';

  @override
  String removedCountLabel(int count) {
    return 'Removed: $count';
  }

  @override
  String get removeDonation => 'Remove\nDonation';

  @override
  String get donateSanctuary => 'Donate to\nSanctuary';

  @override
  String get removePartyCard => 'Remove\nParty Card:';

  @override
  String get addPartyCard => 'Add Party\nCard:';

  @override
  String get perks => 'Perks';

  @override
  String get revealCards => 'Reveal\ncards:';

  @override
  String get revealAll => 'All';

  @override
  String get drawExtraCard => 'Draw extra card';

  @override
  String get extraShuffle => 'Extra Shuffle';

  @override
  String get inactivateMonster => 'Inactivate\nMonster';

  @override
  String get activateMonster => 'Activate\nMonster';

  @override
  String addEliteStandees(int count, String name) {
    return 'Add $count Elite $name';
  }

  @override
  String addNormalStandees(int count, String name) {
    return 'Add $count Normal $name';
  }

  @override
  String get characterLoot => 'Character loot';

  @override
  String addSpecialCard(int nr) {
    return 'Add card $nr';
  }

  @override
  String removeSpecialCard(int nr) {
    return 'Remove card $nr';
  }

  @override
  String get enhanceCards => 'Enhance cards';

  @override
  String get addLootCard => 'Add Card';

  @override
  String get returnToTop => 'Return to Top';

  @override
  String get returnToBottom => 'Return to Bottom';

  @override
  String characterLootTitle(String name) {
    return '$name\'s loot:';
  }

  @override
  String get setLootOwner => 'Set Loot Owner:';

  @override
  String get lootNameCoin => 'coin';

  @override
  String get lootNameHide => 'hide';

  @override
  String get lootNameLumber => 'lumber';

  @override
  String get lootNameMetal => 'metal';

  @override
  String get lootNameArrowvine => 'arrowvine';

  @override
  String get lootNameAxenut => 'axenut';

  @override
  String get lootNameCorpsecap => 'corpsecap';

  @override
  String get lootNameFlamefruit => 'flamefruit';

  @override
  String get lootNameRockroot => 'rockroot';

  @override
  String get lootNameSnowthistle => 'snowthistle';

  @override
  String get lootAmount2For2 => '2 for 2 characters';

  @override
  String get lootAmount2For23 => '2 for 2-3 characters';

  @override
  String cmdActivateMonster(String name) {
    return 'Activate $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return 'Deactivate $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return 'Add $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return 'Add condition: $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return 'Remove condition: $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character add party card $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character remove party card';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character add faction card';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character remove faction card';
  }

  @override
  String cmdAddLootCard(String type) {
    return 'Add $type Loot Card';
  }

  @override
  String cmdAddMonster(String name) {
    return 'Add $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return 'Add Special loot card $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return 'Remove Special loot card $nr';
  }

  @override
  String get cmdAddMinusOne => 'Add minus one';

  @override
  String get cmdRemoveMinusOne => 'Remove minus one';

  @override
  String get cmdRemoveMinusTwo => 'Remove minus two';

  @override
  String get cmdAddBackMinusTwo => 'Add back minus two';

  @override
  String get cmdRemovePlusZero => 'Remove plus zero';

  @override
  String get cmdAddBackPlusZero => 'Add back plus zero';

  @override
  String cmdRevealModifierCards(int count) {
    return 'Reveal $count modifier cards';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return 'Leave revealed cards on top of $deck deck';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return 'Cassandra Special turned off for $deck deck';
  }

  @override
  String get cmdImbueMonsterDeck => 'Imbue Monster Deck';

  @override
  String get cmdAdvancedImbueMonsterDeck => 'Advanced Imbue Monster Deck';

  @override
  String get cmdRemoveImbueMonsterDeck => 'Remove Imbuement';

  @override
  String get cmdChangeName => 'Change character name';

  @override
  String get cmdAddBless => 'Add a Bless';

  @override
  String get cmdRemoveBless => 'Remove a Bless';

  @override
  String get cmdAddCurse => 'Add a Curse';

  @override
  String get cmdRemoveCurse => 'Remove a Curse';

  @override
  String get cmdAddEmpower => 'Add Empower';

  @override
  String get cmdRemoveEmpower => 'Remove Empower';

  @override
  String get cmdAddEnfeeble => 'Add Enfeeble';

  @override
  String get cmdRemoveEnfeeble => 'Remove Enfeeble';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return 'Increase $owner\'s max health';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return 'Decrease $owner\'s max health';
  }

  @override
  String get cmdChangeStat => 'Change stat';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return 'Increase $figure\'s xp by $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return 'Decrease $figure\'s xp by $amount';
  }

  @override
  String get cmdClearUnlockedClasses => 'Clear unlocked classes';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character donate to sanctuary';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return 'Remove $character\'s donation';
  }

  @override
  String get cmdDrawExtraAbilityCard => 'Draw extra ability card';

  @override
  String get cmdDraw => 'Draw';

  @override
  String get cmdDrawLootCard => 'Draw loot card';

  @override
  String cmdDrawModifierCard(String name) {
    return 'Draw $name modifier card';
  }

  @override
  String get cmdRemoveLootEnhancement => 'Remove Loot Enhancement';

  @override
  String get cmdAddLootEnhancement => 'Add Loot Enhancement';

  @override
  String get cmdHideAllyDeck => 'Hide Ally Deck';

  @override
  String get cmdShowAllyDeck => 'Show Ally Deck';

  @override
  String get cmdIceWraithTurnNormal => 'Ice Wraith turn normal';

  @override
  String get cmdIceWraithTurnElite => 'Ice Wraith turn elite';

  @override
  String cmdImbueElement(String element) {
    return 'Imbue element $element';
  }

  @override
  String cmdUseElement(String element) {
    return 'Use Element $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return 'Load saved character: $name';
  }

  @override
  String cmdLoadGame(String name) {
    return 'Load saved game: $name';
  }

  @override
  String get cmdNextRound => 'Next Round';

  @override
  String get cmdRemoveAmdCard => 'Remove AMD card';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return 'Remove $deck card nr $nr';
  }

  @override
  String get cmdRemoveAllCharacters => 'Remove all characters';

  @override
  String cmdRemoveCharacter(String id) {
    return 'Remove $id';
  }

  @override
  String get cmdRemoveAllMonsters => 'Remove all monsters';

  @override
  String cmdRemoveMonster(String name) {
    return 'Remove $name';
  }

  @override
  String get cmdReorderAbilityCards => 'Reorder Ability Cards';

  @override
  String get cmdReorderList => 'Reorder List';

  @override
  String get cmdReorderModifierCards => 'Reorder Modifier Cards';

  @override
  String get cmdReturnLootCard => 'Return loot card';

  @override
  String get cmdReturnModifierCard => 'Return modifier card to top';

  @override
  String get cmdReturnRemovedAmdCard => 'Return removed AMD card';

  @override
  String get cmdNoAllyDeckInOgGloom =>
      'No ally deck in 1st edition Gloomhaven campaigns';

  @override
  String get cmdUseAllyDeckInOgGloom =>
      'Use Ally Deck in 1st edition Gloomhaven Campaigns';

  @override
  String cmdMarkAsSummon(String owner) {
    return 'Mark $owner as summon';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return 'Remove $owner\'s summon mark';
  }

  @override
  String get cmdAutoLevelOn => 'Turn automatic level update on';

  @override
  String get cmdAutoLevelOff => 'Turn automatic level update off';

  @override
  String cmdSetCampaign(String campaign) {
    return 'Set $campaign campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return 'Set $character\'s Level';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return 'Set difficulty level to $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return 'Set initiative of $character';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return 'Set $monster\'s level';
  }

  @override
  String get cmdSetLootOwner => 'Set loot card owner';

  @override
  String get cmdSetScenario => 'Set Scenario';

  @override
  String get cmdSetSoloOn => 'Set solo level recommendation on';

  @override
  String get cmdSetSoloOff => 'Set solo level recommendation off';

  @override
  String get cmdExtraAbilityShuffle => 'Extra ability deck shuffle';

  @override
  String get cmdExtraAmdShuffle => 'Extra AMD deck shuffle';

  @override
  String get cmdDrawnAbilityShuffle => 'Drawn ability deck shuffle';

  @override
  String get cmdDontTrackStandees => 'Don\'t track standees';

  @override
  String get cmdTrackStandees => 'Track standees';

  @override
  String cmdTurnDone(String id) {
    return '$id\'s turn done';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return 'Add \'$character\' Perk $index';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return 'Remove \'$character\' Perk $index';
  }

  @override
  String cmdUnlock(String id) {
    return 'Unlock $id';
  }

  @override
  String cmdLock(String id) {
    return 'Lock $id';
  }

  @override
  String get cmdSetLevel => 'Set Level';

  @override
  String get cmdAddSection => 'Add Section';

  @override
  String cmdAddStandee(String name, int nr) {
    return 'Add $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => 'Draw monster modifier card';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return 'Increase $figure\'s health by $amount';
  }

  @override
  String cmdKill(String owner) {
    return 'Kill $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return 'Decrease $owner\'s health by $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character use Frosthaven Perks';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character don\'t use Frosthaven Perks';
  }

  @override
  String get cmdRemoveNoCharacters => 'Remove no characters';

  @override
  String get cmdRemoveNoMonsters => 'Remove no monsters';
}
