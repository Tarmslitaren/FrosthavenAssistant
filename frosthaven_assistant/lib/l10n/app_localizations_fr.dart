// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get menuSetScenario => 'Définir le scénario';

  @override
  String get menuAddCharacter => 'Ajouter un personnage';

  @override
  String get menuRemoveCharacters => 'Retirer des personnages';

  @override
  String get menuSetLevel => 'Définir le niveau';

  @override
  String get menuLootDeck => 'Menu pioche de butin';

  @override
  String get menuAddMonsters => 'Ajouter des monstres';

  @override
  String get menuRemoveMonsters => 'Retirer des monstres';

  @override
  String get menuShowAllyDeck => 'Afficher le deck modificateurs allié';

  @override
  String get menuHideAllyDeck => 'Masquer le deck modificateurs allié';

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get menuDocumentation => 'Documentation';

  @override
  String get menuDonate => 'Faire un don';

  @override
  String get menuExit => 'Quitter';

  @override
  String get menuAddSection => 'Ajouter une section';

  @override
  String get menuAddRandomDungeonCard => 'Ajouter une carte donjon aléatoire';

  @override
  String get undo => 'Annuler';

  @override
  String undoWithDescription(String description) {
    return 'Annuler : $description';
  }

  @override
  String get redo => 'Rétablir';

  @override
  String redoWithDescription(String description) {
    return 'Rétablir : $description';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get connectedAsClient => 'Connecté en tant que client';

  @override
  String get connecting => 'Connexion en cours…';

  @override
  String connectAsClientWithIp(String ip) {
    return 'Se connecter ($ip)';
  }

  @override
  String get connectAsClientLabel => 'Se connecter en tant que client';

  @override
  String stopServerWithIp(String ip) {
    return 'Arrêter serveur $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'Démarrer serveur $ip';
  }

  @override
  String get stopServerButton => 'Arrêter le serveur';

  @override
  String get startHostServerButton => 'Démarrer le serveur hôte';

  @override
  String get networkConnectLocal => 'Connecter des appareils en Wi-Fi local :';

  @override
  String get networkServerIpHint => 'adresse IP du serveur';

  @override
  String get networkPortHint => 'port';

  @override
  String get settingsLanguage => 'Langue :';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsSoftNumpad => 'Pavé numérique logiciel';

  @override
  String get settingsNoInit => 'Ne pas demander l\'initiative';

  @override
  String get settingsExpireConditions => 'Expirer les conditions';

  @override
  String get settingsNoStandees => 'Ne pas suivre les figurines';

  @override
  String get settingsAutoAddStandees => 'Ajouter les figurines automatiquement';

  @override
  String get settingsAutoAddSpawns => 'Ajouter les apparitions automatiquement';

  @override
  String get settingsRandomStandees => 'Figurines aléatoires';

  @override
  String get settingsNoCalculations => 'Pas de calculs automatiques';

  @override
  String get settingsHideLootDeck => 'Masquer la pioche de butin';

  @override
  String get settingsShimmer => 'Texte scintillant sur cartes de stats';

  @override
  String get settingsFhHazTerrainCalc =>
      'Calcul terrain dangereux Frosthaven dans Gloomhaven orig.';

  @override
  String get settingsAllyDeckOGGloom =>
      'Deck modificateurs allié dans Gloomhaven orig.';

  @override
  String get settingsShowScenarioNames => 'Afficher les noms de scénarios';

  @override
  String get settingsShowBattleGoalReminder =>
      'Afficher le rappel d\'objectif de combat';

  @override
  String get settingsShowCustomContent => 'Afficher le contenu personnalisé';

  @override
  String get settingsShowSections =>
      'Afficher les sections dans l\'écran principal';

  @override
  String get settingsShowReminders =>
      'Afficher les rappels de règles spéciales';

  @override
  String get settingsShowAmdDeck =>
      'Afficher les decks modificateurs d\'attaque';

  @override
  String get settingsShowCharacterAmd =>
      'Afficher les decks modificateurs des personnages';

  @override
  String get settingsHealthWheel =>
      'Roue de vie : glisser gauche-droite pour changer';

  @override
  String get settingsFullscreen => 'Plein écran';

  @override
  String get settingsMainListScaling => 'Échelle de la liste principale :';

  @override
  String get settingsAppBarScaling => 'Échelle de la barre d\'app :';

  @override
  String get settingsStyleLabel => 'Style :';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'Original';

  @override
  String get settingsClearUnlocked =>
      'Réinitialiser personnages et contenus débloqués';

  @override
  String get settingsUnlockSpecials => 'Débloquer les spéciaux';

  @override
  String get settingsLoadSaveState => 'Charger/Sauvegarder état';

  @override
  String get noResultsFound => 'Aucun résultat';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get specialUnlocks => 'Déverrouillages spéciaux';

  @override
  String get loadSaveDeleteCharacters =>
      'Charger, sauvegarder ou supprimer des personnages.';

  @override
  String get loadAddDeleteSaves =>
      'Charger, ajouter ou supprimer des sauvegardes.';

  @override
  String get addNewSave => 'Nouvelle sauvegarde';

  @override
  String get addNewSaveLabel => 'Nouvelle sauvegarde :';

  @override
  String get loadButton => 'Charger';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get setSaveName => 'Nom de la sauvegarde :';

  @override
  String get loadOrSaveCharacters => 'Charger ou sauvegarder des personnages';

  @override
  String get loadCharacter => 'Charger un personnage :';

  @override
  String get removeAll => 'Tout retirer';

  @override
  String get removeCardQuestion => 'Retirer la carte ?';

  @override
  String get sendToBottom => 'Envoyer en bas';

  @override
  String get shuffleUndrawnCards => 'Mélanger les cartes non piochées';

  @override
  String get returnToDiscardPile => 'Remettre dans la défausse';

  @override
  String get returnToDrawPile => 'Remettre dans la pioche';

  @override
  String get addExtraLootCard => 'Ajouter une carte de butin supplémentaire';

  @override
  String get addStandeeNr => 'Ajouter figurine n°';

  @override
  String get summonedLabel => 'Invoqués :';

  @override
  String get characterDecks => 'Decks des personnages';

  @override
  String get shuffleAndDraw => 'Mélanger\net piocher';

  @override
  String get draw => 'Piocher';

  @override
  String get nextRound => ' Tour\nsuivant';

  @override
  String get returnTopCard => 'Remettre la carte du dessus';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'Retirer $title\n(carte n° : $nr)';
  }

  @override
  String get tapCardToAddToDeck =>
      'Appuyer sur une carte pour l\'ajouter au deck';

  @override
  String get removeCardFromDeckQuestion => 'Retirer la carte du deck ?';

  @override
  String get changeName => 'Changer le nom :';

  @override
  String get showBosses => 'Afficher les boss';

  @override
  String get showScenarioSpecialMonsters =>
      'Afficher les monstres spéciaux du scénario';

  @override
  String get addAsAlly => 'Ajouter comme allié';

  @override
  String get addMonsterLabel => 'Ajouter un monstre';

  @override
  String get allCampaigns => 'Toutes les campagnes';

  @override
  String get showMonstersFrom => '      Afficher monstres de :   ';

  @override
  String setMonsterLevel(String name) {
    return 'Niveau de $name';
  }

  @override
  String setSummonHealth(String name) {
    return 'Vie max de $name';
  }

  @override
  String get setScenarioLevel => 'Niveau du scénario';

  @override
  String enhancedLevel(String level) {
    return 'Amélioré : $level';
  }

  @override
  String get soloLabel => 'Solo :';

  @override
  String get automaticScenarioLevel => 'Niveau de scénario automatique :';

  @override
  String get difficultyLabel => 'Difficulté :';

  @override
  String get lootCardEnhancements => 'Améliorations cartes de butin';

  @override
  String get addPerks => 'Ajouter des avantages';

  @override
  String get useFrosthavenPerks => 'Avantages Frosthaven';

  @override
  String currentCampaign(String campaign) {
    return 'Campagne actuelle : $campaign';
  }

  @override
  String get addCharacterHint =>
      'Ajouter un personnage (taper le nom pour les classes cachées)';

  @override
  String get trapDamage => 'dégâts de piège';

  @override
  String get hazardousTerrainDamage => 'dégâts de terrain dangereux';

  @override
  String get experienceAdded => 'expérience ajoutée';

  @override
  String get goldCoinValue => 'valeur des pièces d\'or';

  @override
  String get levelLegendLabel => 'niveau';

  @override
  String get saveStateNote =>
      'L\'app sauvegarde automatiquement après chaque action. Celles-ci servent de sauvegarde ou pour plusieurs campagnes.';

  @override
  String clientConnectedTo(String address) {
    return 'Client connecté à : $address';
  }

  @override
  String clientError(String error) {
    return 'Erreur client : $error';
  }

  @override
  String clientListenError(String error) {
    return 'Erreur d\'écoute client : $error';
  }

  @override
  String get lostConnectionToServer => 'Connexion au serveur perdue';

  @override
  String get stateMismatch => 'Votre état n\'était pas à jour, réessayez.';

  @override
  String get serverUnresponsive => 'Serveur ne répond pas. Client déconnecté.';

  @override
  String get clientDisconnected => 'client déconnecté';

  @override
  String get serverOffline => 'Serveur hors ligne';

  @override
  String get clientLeft => 'Client parti.';

  @override
  String get clientTooOld =>
      'Ancien client a tenté de se connecter. Mettez l\'app à jour.';

  @override
  String networkConnection(String status) {
    return 'Connexion réseau : $status';
  }

  @override
  String get failedToGetWifiIp => 'Impossible d\'obtenir l\'adresse IP';

  @override
  String get badOmen => 'Mauvais présage';

  @override
  String badOmensLeft(int count) {
    return 'Mauvais présages restants : $count';
  }

  @override
  String get corrosiveSpew => 'Crachat corrosif';

  @override
  String get empowersOnTop => 'Renforcés au dessus';

  @override
  String addMinusOneCard(int count) {
    return 'Ajouter carte -1 (ajoutées : $count)';
  }

  @override
  String get removeMinusOneCard => 'Retirer carte -1';

  @override
  String get removeMinusTwoCard => 'Retirer carte -2';

  @override
  String get minusTwoCardRemoved => 'Carte -2 retirée';

  @override
  String get removePlusZeroCard => 'Retirer carte +0';

  @override
  String get plusZeroCardRemoved => 'Carte +0 retirée';

  @override
  String get removeImbue => 'Retirer l\'imprégnation';

  @override
  String get imbue => 'Imprégner';

  @override
  String get advancedImbue => 'Imprégnation avancée';

  @override
  String get removeHailPerk => 'Retirer avantage Grêle';

  @override
  String get addHailPerk => 'Ajouter avantage Grêle';

  @override
  String get removeCassandraPerk => 'Retirer\navantage Cassandra';

  @override
  String get addCassandraPerk => 'Ajouter\navantage Cassandra';

  @override
  String get dontSaveRevealedCards => 'Ne pas garder\nles cartes révélées';

  @override
  String get saveRevealedCards => 'Garder\nles cartes révélées';

  @override
  String removedCountLabel(int count) {
    return 'Retirées : $count';
  }

  @override
  String get removeDonation => 'Retirer\nle don';

  @override
  String get donateSanctuary => 'Donner au\nsanctuaire';

  @override
  String get removePartyCard => 'Retirer\nla carte groupe :';

  @override
  String get addPartyCard => 'Ajouter\ncarte groupe :';

  @override
  String get perks => 'Avantages';

  @override
  String get revealCards => 'Révéler\nles cartes :';

  @override
  String get revealAll => 'Tout';

  @override
  String get drawExtraCard => 'Piocher une carte supplémentaire';

  @override
  String get extraShuffle => 'Mélange supplémentaire';

  @override
  String get inactivateMonster => 'Désactiver\nle monstre';

  @override
  String get activateMonster => 'Activer\nle monstre';

  @override
  String addEliteStandees(int count, String name) {
    return 'Ajouter $count $name élite';
  }

  @override
  String addNormalStandees(int count, String name) {
    return 'Ajouter $count $name normal';
  }

  @override
  String get characterLoot => 'Butin du personnage';

  @override
  String addSpecialCard(int nr) {
    return 'Ajouter carte $nr';
  }

  @override
  String removeSpecialCard(int nr) {
    return 'Retirer carte $nr';
  }

  @override
  String get enhanceCards => 'Améliorer les cartes';

  @override
  String get addLootCard => 'Ajouter une carte';

  @override
  String get returnToTop => 'Remettre en haut';

  @override
  String get returnToBottom => 'Remettre en bas';

  @override
  String characterLootTitle(String name) {
    return 'Butin de $name :';
  }

  @override
  String get setLootOwner => 'Propriétaire du butin :';

  @override
  String get lootNameCoin => 'pièce';

  @override
  String get lootNameHide => 'peau';

  @override
  String get lootNameLumber => 'bois';

  @override
  String get lootNameMetal => 'métal';

  @override
  String get lootNameArrowvine => 'liane-flèche';

  @override
  String get lootNameAxenut => 'noix-hache';

  @override
  String get lootNameCorpsecap => 'chapeau-cadavre';

  @override
  String get lootNameFlamefruit => 'fruit-flamme';

  @override
  String get lootNameRockroot => 'racine-roc';

  @override
  String get lootNameSnowthistle => 'chardon des neiges';

  @override
  String get lootAmount2For2 => '2 pour 2 joueurs';

  @override
  String get lootAmount2For23 => '2 pour 2-3 joueurs';

  @override
  String cmdActivateMonster(String name) {
    return 'Activer $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return 'Désactiver $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return 'Ajouter $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return 'Ajouter condition : $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return 'Retirer condition : $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character ajouter carte groupe $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character retirer carte groupe';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character ajouter carte faction';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character retirer carte faction';
  }

  @override
  String cmdAddLootCard(String type) {
    return 'Ajouter carte butin $type';
  }

  @override
  String cmdAddMonster(String name) {
    return 'Ajouter $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return 'Ajouter carte butin spéciale $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return 'Retirer carte butin spéciale $nr';
  }

  @override
  String get cmdAddMinusOne => 'Ajouter moins un';

  @override
  String get cmdRemoveMinusOne => 'Retirer moins un';

  @override
  String get cmdRemoveMinusTwo => 'Retirer moins deux';

  @override
  String get cmdAddBackMinusTwo => 'Remettre moins deux';

  @override
  String get cmdRemovePlusZero => 'Retirer plus zéro';

  @override
  String get cmdAddBackPlusZero => 'Remettre plus zéro';

  @override
  String cmdRevealModifierCards(int count) {
    return 'Révéler $count cartes modificateurs';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return 'Laisser les cartes révélées sur le deck $deck';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return 'Spécial Cassandra désactivé pour deck $deck';
  }

  @override
  String get cmdImbueMonsterDeck => 'Imprégner le deck monstres';

  @override
  String get cmdAdvancedImbueMonsterDeck =>
      'Imprégnation avancée du deck monstres';

  @override
  String get cmdRemoveImbueMonsterDeck => 'Retirer l\'imprégnation';

  @override
  String get cmdChangeName => 'Changer le nom du personnage';

  @override
  String get cmdAddBless => 'Ajouter une bénédiction';

  @override
  String get cmdRemoveBless => 'Retirer une bénédiction';

  @override
  String get cmdAddCurse => 'Ajouter une malédiction';

  @override
  String get cmdRemoveCurse => 'Retirer une malédiction';

  @override
  String get cmdAddEmpower => 'Ajouter renforcement';

  @override
  String get cmdRemoveEmpower => 'Retirer renforcement';

  @override
  String get cmdAddEnfeeble => 'Ajouter affaiblissement';

  @override
  String get cmdRemoveEnfeeble => 'Retirer affaiblissement';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return 'Augmenter la vie max de $owner';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return 'Diminuer la vie max de $owner';
  }

  @override
  String get cmdChangeStat => 'Modifier une statistique';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return 'Augmenter l\'XP de $figure de $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return 'Diminuer l\'XP de $figure de $amount';
  }

  @override
  String get cmdClearUnlockedClasses => 'Réinitialiser les classes débloquées';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character faire un don au sanctuaire';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return 'Retirer le don de $character';
  }

  @override
  String get cmdDrawExtraAbilityCard =>
      'Piocher une carte capacité supplémentaire';

  @override
  String get cmdDraw => 'Piocher';

  @override
  String get cmdDrawLootCard => 'Piocher une carte butin';

  @override
  String cmdDrawModifierCard(String name) {
    return 'Piocher carte modificateur $name';
  }

  @override
  String get cmdRemoveLootEnhancement => 'Retirer amélioration butin';

  @override
  String get cmdAddLootEnhancement => 'Ajouter amélioration butin';

  @override
  String get cmdHideAllyDeck => 'Masquer deck allié';

  @override
  String get cmdShowAllyDeck => 'Afficher deck allié';

  @override
  String get cmdIceWraithTurnNormal => 'Spectre des glaces passe en normal';

  @override
  String get cmdIceWraithTurnElite => 'Spectre des glaces passe en élite';

  @override
  String cmdImbueElement(String element) {
    return 'Imprégner élément $element';
  }

  @override
  String cmdUseElement(String element) {
    return 'Utiliser élément $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return 'Charger personnage sauvegardé : $name';
  }

  @override
  String cmdLoadGame(String name) {
    return 'Charger partie sauvegardée : $name';
  }

  @override
  String get cmdNextRound => 'Tour suivant';

  @override
  String get cmdRemoveAmdCard => 'Retirer carte AMD';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return 'Retirer carte $deck n° $nr';
  }

  @override
  String get cmdRemoveAllCharacters => 'Retirer tous les personnages';

  @override
  String cmdRemoveCharacter(String id) {
    return 'Retirer $id';
  }

  @override
  String get cmdRemoveAllMonsters => 'Retirer tous les monstres';

  @override
  String cmdRemoveMonster(String name) {
    return 'Retirer $name';
  }

  @override
  String get cmdReorderAbilityCards => 'Réordonner les cartes capacités';

  @override
  String get cmdReorderList => 'Réordonner la liste';

  @override
  String get cmdReorderModifierCards => 'Réordonner les cartes modificateurs';

  @override
  String get cmdReturnLootCard => 'Remettre la carte butin';

  @override
  String get cmdReturnModifierCard => 'Remettre la carte modificateur en haut';

  @override
  String get cmdReturnRemovedAmdCard => 'Remettre la carte AMD retirée';

  @override
  String get cmdNoAllyDeckInOgGloom =>
      'Pas de deck allié dans Gloomhaven 1re édition';

  @override
  String get cmdUseAllyDeckInOgGloom =>
      'Utiliser deck allié dans Gloomhaven 1re édition';

  @override
  String cmdMarkAsSummon(String owner) {
    return 'Marquer $owner comme invoqué';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return 'Retirer la marque d\'invocation de $owner';
  }

  @override
  String get cmdAutoLevelOn => 'Activer la mise à jour automatique du niveau';

  @override
  String get cmdAutoLevelOff =>
      'Désactiver la mise à jour automatique du niveau';

  @override
  String cmdSetCampaign(String campaign) {
    return 'Définir campagne $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return 'Définir le niveau de $character';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return 'Définir la difficulté à $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return 'Définir l\'initiative de $character';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return 'Définir le niveau de $monster';
  }

  @override
  String get cmdSetLootOwner => 'Définir le propriétaire du butin';

  @override
  String get cmdSetScenario => 'Définir le scénario';

  @override
  String get cmdSetSoloOn => 'Activer la recommandation niveau solo';

  @override
  String get cmdSetSoloOff => 'Désactiver la recommandation niveau solo';

  @override
  String get cmdExtraAbilityShuffle => 'Mélange supplémentaire deck capacités';

  @override
  String get cmdExtraAmdShuffle => 'Mélange supplémentaire deck AMD';

  @override
  String get cmdDrawnAbilityShuffle => 'Mélange deck capacités piochées';

  @override
  String get cmdDontTrackStandees => 'Ne pas suivre les figurines';

  @override
  String get cmdTrackStandees => 'Suivre les figurines';

  @override
  String cmdTurnDone(String id) {
    return 'Tour de $id terminé';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return 'Ajouter avantage $index de \'$character\'';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return 'Retirer avantage $index de \'$character\'';
  }

  @override
  String cmdUnlock(String id) {
    return 'Débloquer $id';
  }

  @override
  String cmdLock(String id) {
    return 'Verrouiller $id';
  }

  @override
  String get cmdSetLevel => 'Définir le niveau';

  @override
  String get cmdAddSection => 'Ajouter une section';

  @override
  String cmdAddStandee(String name, int nr) {
    return 'Ajouter $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => 'Piocher carte modificateur monstre';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return 'Augmenter la vie de $figure de $amount';
  }

  @override
  String cmdKill(String owner) {
    return 'Éliminer $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return 'Diminuer la vie de $owner de $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character utiliser avantages Frosthaven';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character ne pas utiliser avantages Frosthaven';
  }

  @override
  String get cmdRemoveNoCharacters => 'Aucun personnage retiré';

  @override
  String get cmdRemoveNoMonsters => 'Aucun monstre retiré';
}
