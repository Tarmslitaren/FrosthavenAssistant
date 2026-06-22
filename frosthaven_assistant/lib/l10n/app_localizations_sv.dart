// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get menuSetScenario => 'Välj scenario';

  @override
  String get menuAddCharacter => 'Lägg till karaktär';

  @override
  String get menuRemoveCharacters => 'Ta bort karaktärer';

  @override
  String get menuSetLevel => 'Sätt nivå';

  @override
  String get menuLootDeck => 'Plundringslek';

  @override
  String get menuAddMonsters => 'Lägg till monster';

  @override
  String get menuRemoveMonsters => 'Ta bort monster';

  @override
  String get menuShowAllyDeck => 'Visa allierades anfallsmodifikationsdeck';

  @override
  String get menuHideAllyDeck => 'Dölj allierades anfallsmodifikationsdeck';

  @override
  String get menuSettings => 'Inställningar';

  @override
  String get menuDocumentation => 'Dokumentation';

  @override
  String get menuDonate => 'Donera';

  @override
  String get menuExit => 'Avsluta';

  @override
  String get menuAddSection => 'Lägg till sektion';

  @override
  String get menuAddRandomDungeonCard =>
      'Lägg till slumpmässigt fängelsekortet';

  @override
  String get undo => 'Ångra';

  @override
  String undoWithDescription(String description) {
    return 'Ångra: $description';
  }

  @override
  String get redo => 'Gör om';

  @override
  String redoWithDescription(String description) {
    return 'Gör om: $description';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get connectedAsClient => 'Ansluten som klient';

  @override
  String get connecting => 'Ansluter...';

  @override
  String connectAsClientWithIp(String ip) {
    return 'Anslut som klient ($ip)';
  }

  @override
  String get connectAsClientLabel => 'Anslut som klient';

  @override
  String stopServerWithIp(String ip) {
    return 'Stoppa server $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'Starta värdserver $ip';
  }

  @override
  String get stopServerButton => 'Stoppa server';

  @override
  String get startHostServerButton => 'Starta värdserver';

  @override
  String get networkConnectLocal => 'Anslut enheter via lokalt wifi:';

  @override
  String get networkServerIpHint => 'serverns ip-adress';

  @override
  String get networkPortHint => 'port';

  @override
  String get settingsLanguage => 'Språk:';

  @override
  String get settingsDarkMode => 'Mörkt läge';

  @override
  String get settingsSoftNumpad => 'Mjukt siffertangentbord';

  @override
  String get settingsNoInit => 'Fråga inte om initiativ';

  @override
  String get settingsExpireConditions => 'Förfalla tillstånd';

  @override
  String get settingsNoStandees => 'Spåra inte figurer';

  @override
  String get settingsAutoAddStandees => 'Lägg automatiskt till figurer';

  @override
  String get settingsAutoAddSpawns => 'Lägg automatiskt till tidsstyrda spawns';

  @override
  String get settingsRandomStandees => 'Slumpmässiga figurer';

  @override
  String get settingsNoCalculations => 'Inga beräkningar';

  @override
  String get settingsHideLootDeck => 'Dölj plundringslek';

  @override
  String get settingsShimmer => 'Skimmer på statistikkorttext';

  @override
  String get settingsFhHazTerrainCalc =>
      'Använd FH-regler för farlig terräng i OG Gloomhaven';

  @override
  String get settingsAllyDeckOGGloom => 'Använd allierades AMD i OG Gloomhaven';

  @override
  String get settingsShowScenarioNames => 'Visa scenarionamn i listan';

  @override
  String get settingsShowBattleGoalReminder => 'Visa påminnelse om stridsmål';

  @override
  String get settingsShowCustomContent => 'Visa anpassat innehåll';

  @override
  String get settingsShowSections => 'Visa sektioner på huvudskärmen';

  @override
  String get settingsShowReminders => 'Visa påminnelser för speciella regler';

  @override
  String get settingsShowAmdDeck => 'Visa anfallsmodifikationsdeck';

  @override
  String get settingsShowCharacterAmd =>
      'Visa karaktärers anfallsmodifikationsdeck';

  @override
  String get settingsHealthWheel =>
      'Aktivera hälsohjul: dra vänster/höger för att ändra hälsa';

  @override
  String get settingsFullscreen => 'Helskärm';

  @override
  String get settingsMainListScaling => 'Skalning av huvudlista:';

  @override
  String get settingsAppBarScaling => 'Skalning av appfält:';

  @override
  String get settingsStyleLabel => 'Stil:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'Original';

  @override
  String get settingsClearUnlocked => 'Rensa upplåsta karaktärer';

  @override
  String get settingsUnlockSpecials => 'Lås upp specials';

  @override
  String get settingsLoadSaveState => 'Ladda/Spara tillstånd';

  @override
  String get noResultsFound => 'Inga resultat hittades';

  @override
  String get close => 'Stäng';

  @override
  String get retry => 'FÖRSÖK IGEN';

  @override
  String get specialUnlocks => 'Speciella upplåsningar';

  @override
  String get loadSaveDeleteCharacters =>
      'Ladda, spara eller radera karaktärer.';

  @override
  String get loadAddDeleteSaves =>
      'Ladda, lägg till eller radera sparade tillstånd.';

  @override
  String get addNewSave => 'Ny sparning';

  @override
  String get addNewSaveLabel => 'Ny sparning:';

  @override
  String get loadButton => 'Ladda';

  @override
  String get saveButton => 'Spara';

  @override
  String get deleteButton => 'Radera';

  @override
  String get setSaveName => 'Ange sparnamn:';

  @override
  String get loadOrSaveCharacters => 'Ladda eller spara karaktärer';

  @override
  String get loadCharacter => 'Ladda karaktär:';

  @override
  String get removeAll => 'Ta bort alla';

  @override
  String get removeCardQuestion => 'Ta bort kortet?';

  @override
  String get sendToBottom => 'Skicka till botten';

  @override
  String get shuffleUndrawnCards => 'Blanda odragen stack';

  @override
  String get returnToDiscardPile => 'Lägg tillbaka till avkastningshögen';

  @override
  String get returnToDrawPile => 'Lägg tillbaka till dragstapeln';

  @override
  String get addExtraLootCard => 'Lägg till extra plundringskort';

  @override
  String get addStandeeNr => 'Lägg till figurnummer';

  @override
  String get summonedLabel => 'Framkallad:';

  @override
  String get characterDecks => 'Karaktärsdeck';

  @override
  String get shuffleAndDraw => 'Blanda\n& Dra';

  @override
  String get draw => 'Dra';

  @override
  String get nextRound => ' Nästa runda';

  @override
  String get returnTopCard => 'Lägg tillbaka toppkortet';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'Ta bort $title\n(kortnr: $nr)';
  }

  @override
  String get tapCardToAddToDeck => 'Tryck för att lägga till i ditt deck';

  @override
  String get removeCardFromDeckQuestion => 'Ta bort kort från ditt deck?';

  @override
  String get changeName => 'Ändra namn:';

  @override
  String get showBosses => 'Visa bossar';

  @override
  String get showScenarioSpecialMonsters => 'Visa speciella scenariomonster';

  @override
  String get addAsAlly => 'Lägg till som allierad';

  @override
  String get addMonsterLabel => 'Lägg till monster';

  @override
  String get allCampaigns => 'Alla kampanjer';

  @override
  String get showMonstersFrom => '      Visa monster från:   ';

  @override
  String setMonsterLevel(String name) {
    return 'Sätt ${name}s nivå';
  }

  @override
  String setSummonHealth(String name) {
    return 'Sätt ${name}s max-hälsa';
  }

  @override
  String get setScenarioLevel => 'Sätt scenarionivå';

  @override
  String enhancedLevel(String level) {
    return 'Förbättrad: $level';
  }

  @override
  String get soloLabel => 'Solo:';

  @override
  String get automaticScenarioLevel => 'Automatisk scenarionivå:';

  @override
  String get difficultyLabel => 'Svårighetsgrad:';

  @override
  String get lootCardEnhancements => 'Förbättringar av plundringskort';

  @override
  String get addPerks => 'Lägg till förmåner';

  @override
  String get useFrosthavenPerks => 'Använd Frosthaven-förmåner';

  @override
  String currentCampaign(String campaign) {
    return 'Nuvarande kampanj: $campaign';
  }

  @override
  String get addCharacterHint =>
      'Lägg till karaktär (skriv namn för dolda karaktärsklasser)';

  @override
  String get trapDamage => 'fällskada';

  @override
  String get hazardousTerrainDamage => 'skada av farlig terräng';

  @override
  String get experienceAdded => 'erfarenhet lagd till';

  @override
  String get goldCoinValue => 'guldmyntvärde';

  @override
  String get levelLegendLabel => 'nivå';

  @override
  String get saveStateNote =>
      'Observera att appen automatiskt sparar ditt framsteg efter varje åtgärd. Dessa är för säkerhetskopior eller flera kampanjer.';

  @override
  String clientConnectedTo(String address) {
    return 'Klient ansluten till: $address';
  }

  @override
  String clientError(String error) {
    return 'Klientfel: $error';
  }

  @override
  String clientListenError(String error) {
    return 'Klientlyssnarfel: $error';
  }

  @override
  String get lostConnectionToServer => 'Förlorade anslutningen till servern';

  @override
  String get stateMismatch =>
      'Ditt tillstånd var inte uppdaterat, försök igen.';

  @override
  String get serverUnresponsive => 'Servern svarar inte. Klient frånkopplad.';

  @override
  String get clientDisconnected => 'klient frånkopplad';

  @override
  String get serverOffline => 'Server offline';

  @override
  String get clientLeft => 'Klient lämnade.';

  @override
  String get clientTooOld =>
      'En gammal klient försökte ansluta. Uppdatera appen.';

  @override
  String networkConnection(String status) {
    return 'Nätverksanslutning: $status';
  }

  @override
  String get failedToGetWifiIp => 'Kunde inte hämta IP-adress';
}
