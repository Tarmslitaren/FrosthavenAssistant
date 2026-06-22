// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuSetScenario => 'Definir escenario';

  @override
  String get menuAddCharacter => 'Añadir personaje';

  @override
  String get menuRemoveCharacters => 'Retirar personajes';

  @override
  String get menuSetLevel => 'Definir nivel';

  @override
  String get menuLootDeck => 'Menú mazo de botín';

  @override
  String get menuAddMonsters => 'Añadir monstruos';

  @override
  String get menuRemoveMonsters => 'Retirar monstruos';

  @override
  String get menuShowAllyDeck => 'Mostrar mazo de modificadores aliado';

  @override
  String get menuHideAllyDeck => 'Ocultar mazo de modificadores aliado';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuDocumentation => 'Documentación';

  @override
  String get menuDonate => 'Donar';

  @override
  String get menuExit => 'Salir';

  @override
  String get menuAddSection => 'Añadir sección';

  @override
  String get menuAddRandomDungeonCard => 'Añadir carta de mazmorra aleatoria';

  @override
  String get undo => 'Deshacer';

  @override
  String undoWithDescription(String description) {
    return 'Deshacer: $description';
  }

  @override
  String get redo => 'Rehacer';

  @override
  String redoWithDescription(String description) {
    return 'Rehacer: $description';
  }

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get connectedAsClient => 'Conectado como cliente';

  @override
  String get connecting => 'Conectando…';

  @override
  String connectAsClientWithIp(String ip) {
    return 'Conectar como cliente ($ip)';
  }

  @override
  String get connectAsClientLabel => 'Conectar como cliente';

  @override
  String stopServerWithIp(String ip) {
    return 'Detener servidor $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'Iniciar servidor $ip';
  }

  @override
  String get stopServerButton => 'Detener servidor';

  @override
  String get startHostServerButton => 'Iniciar servidor anfitrión';

  @override
  String get networkConnectLocal => 'Conectar dispositivos en Wi-Fi local:';

  @override
  String get networkServerIpHint => 'IP del servidor';

  @override
  String get networkPortHint => 'puerto';

  @override
  String get settingsLanguage => 'Idioma:';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsSoftNumpad => 'Teclado numérico en pantalla';

  @override
  String get settingsNoInit => 'No pedir iniciativa';

  @override
  String get settingsExpireConditions => 'Expirar condiciones';

  @override
  String get settingsNoStandees => 'No rastrear figurines';

  @override
  String get settingsAutoAddStandees => 'Añadir figurines automáticamente';

  @override
  String get settingsAutoAddSpawns => 'Añadir apariciones automáticamente';

  @override
  String get settingsRandomStandees => 'Figurines aleatorios';

  @override
  String get settingsNoCalculations => 'Sin cálculos';

  @override
  String get settingsHideLootDeck => 'Ocultar mazo de botín';

  @override
  String get settingsShimmer => 'Texto brillante en cartas de estadísticas';

  @override
  String get settingsFhHazTerrainCalc =>
      'Cálculo terreno peligroso Frosthaven en Gloomhaven orig.';

  @override
  String get settingsAllyDeckOGGloom =>
      'Mazo modificadores aliado en Gloomhaven orig.';

  @override
  String get settingsShowScenarioNames => 'Mostrar nombres de escenarios';

  @override
  String get settingsShowBattleGoalReminder =>
      'Mostrar recordatorio de objetivo de batalla';

  @override
  String get settingsShowCustomContent => 'Mostrar contenido personalizado';

  @override
  String get settingsShowSections =>
      'Mostrar secciones en la pantalla principal';

  @override
  String get settingsShowReminders =>
      'Mostrar recordatorios de reglas especiales';

  @override
  String get settingsShowAmdDeck => 'Mostrar mazos de modificadores de ataque';

  @override
  String get settingsShowCharacterAmd =>
      'Mostrar mazos de modificadores de personajes';

  @override
  String get settingsHealthWheel =>
      'Rueda de vida: arrastrar izquierda-derecha';

  @override
  String get settingsFullscreen => 'Pantalla completa';

  @override
  String get settingsMainListScaling => 'Escala de la lista principal:';

  @override
  String get settingsAppBarScaling => 'Escala de la barra de la app:';

  @override
  String get settingsStyleLabel => 'Estilo:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'Original';

  @override
  String get settingsClearUnlocked =>
      'Borrar personajes y contenido desbloqueados';

  @override
  String get settingsUnlockSpecials => 'Desbloquear especiales';

  @override
  String get settingsLoadSaveState => 'Cargar/Guardar estado';

  @override
  String get noResultsFound => 'Sin resultados';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get specialUnlocks => 'Desbloqueos especiales';

  @override
  String get loadSaveDeleteCharacters =>
      'Cargar, guardar o eliminar personajes.';

  @override
  String get loadAddDeleteSaves =>
      'Cargar, añadir o eliminar estados guardados.';

  @override
  String get addNewSave => 'Nuevo guardado';

  @override
  String get addNewSaveLabel => 'Nuevo guardado:';

  @override
  String get loadButton => 'Cargar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get setSaveName => 'Nombre del guardado:';

  @override
  String get loadOrSaveCharacters => 'Cargar o guardar personajes';

  @override
  String get loadCharacter => 'Cargar personaje:';

  @override
  String get removeAll => 'Retirar todo';

  @override
  String get removeCardQuestion => '¿Retirar la carta?';

  @override
  String get sendToBottom => 'Enviar al fondo';

  @override
  String get shuffleUndrawnCards => 'Barajar cartas no robadas';

  @override
  String get returnToDiscardPile => 'Devolver al descarte';

  @override
  String get returnToDrawPile => 'Devolver al mazo';

  @override
  String get addExtraLootCard => 'Añadir carta de botín extra';

  @override
  String get addStandeeNr => 'Añadir figurín n.º';

  @override
  String get summonedLabel => 'Invocados:';

  @override
  String get characterDecks => 'Mazos de personajes';

  @override
  String get shuffleAndDraw => 'Barajar\ny robar';

  @override
  String get draw => 'Robar';

  @override
  String get nextRound => ' Siguiente ronda';

  @override
  String get returnTopCard => 'Devolver carta superior';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'Retirar $title\n(carta n.º: $nr)';
  }

  @override
  String get tapCardToAddToDeck => 'Toca una carta para añadirla al mazo';

  @override
  String get removeCardFromDeckQuestion => '¿Retirar carta del mazo?';

  @override
  String get changeName => 'Cambiar nombre:';

  @override
  String get showBosses => 'Mostrar jefes';

  @override
  String get showScenarioSpecialMonsters =>
      'Mostrar monstruos especiales del escenario';

  @override
  String get addAsAlly => 'Añadir como aliado';

  @override
  String get addMonsterLabel => 'Añadir monstruo';

  @override
  String get allCampaigns => 'Todas las campañas';

  @override
  String get showMonstersFrom => '      Mostrar monstruos de:   ';

  @override
  String setMonsterLevel(String name) {
    return 'Nivel de $name';
  }

  @override
  String setSummonHealth(String name) {
    return 'Vida máx. de $name';
  }

  @override
  String get setScenarioLevel => 'Nivel del escenario';

  @override
  String enhancedLevel(String level) {
    return 'Mejorado: $level';
  }

  @override
  String get soloLabel => 'Solo:';

  @override
  String get automaticScenarioLevel => 'Nivel de escenario automático:';

  @override
  String get difficultyLabel => 'Dificultad:';

  @override
  String get lootCardEnhancements => 'Mejoras de cartas de botín';

  @override
  String get addPerks => 'Añadir ventajas';

  @override
  String get useFrosthavenPerks => 'Ventajas Frosthaven';

  @override
  String currentCampaign(String campaign) {
    return 'Campaña actual: $campaign';
  }

  @override
  String get addCharacterHint =>
      'Añadir personaje (escribir nombre para clases ocultas)';

  @override
  String get trapDamage => 'daño de trampa';

  @override
  String get hazardousTerrainDamage => 'daño de terreno peligroso';

  @override
  String get experienceAdded => 'experiencia añadida';

  @override
  String get goldCoinValue => 'valor de moneda de oro';

  @override
  String get levelLegendLabel => 'nivel';

  @override
  String get saveStateNote =>
      'La app guarda automáticamente tras cada acción. Estos son para copias de seguridad o varias campañas.';

  @override
  String clientConnectedTo(String address) {
    return 'Cliente conectado a: $address';
  }

  @override
  String clientError(String error) {
    return 'Error de cliente: $error';
  }

  @override
  String clientListenError(String error) {
    return 'Error de escucha de cliente: $error';
  }

  @override
  String get lostConnectionToServer => 'Conexión con el servidor perdida';

  @override
  String get stateMismatch =>
      'Tu estado no estaba actualizado, inténtalo de nuevo.';

  @override
  String get serverUnresponsive =>
      'Servidor sin respuesta. Cliente desconectado.';

  @override
  String get clientDisconnected => 'cliente desconectado';

  @override
  String get serverOffline => 'Servidor sin conexión';

  @override
  String get clientLeft => 'Cliente se fue.';

  @override
  String get clientTooOld =>
      'Cliente antiguo intentó conectarse. Actualiza la app.';

  @override
  String networkConnection(String status) {
    return 'Conexión de red: $status';
  }

  @override
  String get failedToGetWifiIp => 'Error al obtener la dirección IP';

  @override
  String get badOmen => 'Mal augurio';

  @override
  String badOmensLeft(int count) {
    return 'Malos augurios restantes: $count';
  }

  @override
  String get corrosiveSpew => 'Escupitajo corrosivo';

  @override
  String get empowersOnTop => 'Potenciados encima';

  @override
  String addMinusOneCard(int count) {
    return 'Añadir carta -1 (añadidas: $count)';
  }

  @override
  String get removeMinusOneCard => 'Retirar carta -1';

  @override
  String get removeMinusTwoCard => 'Retirar carta -2';

  @override
  String get minusTwoCardRemoved => 'Carta -2 retirada';

  @override
  String get removePlusZeroCard => 'Retirar carta +0';

  @override
  String get plusZeroCardRemoved => 'Carta +0 retirada';

  @override
  String get removeImbue => 'Retirar imbuido';

  @override
  String get imbue => 'Imbuir';

  @override
  String get advancedImbue => 'Imbuido avanzado';

  @override
  String get removeHailPerk => 'Retirar ventaja Granizo';

  @override
  String get addHailPerk => 'Añadir ventaja Granizo';

  @override
  String get removeCassandraPerk => 'Retirar\nventaja Cassandra';

  @override
  String get addCassandraPerk => 'Añadir\nventaja Cassandra';

  @override
  String get dontSaveRevealedCards => 'No guardar\ncartas reveladas';

  @override
  String get saveRevealedCards => 'Guardar\ncartas reveladas';

  @override
  String removedCountLabel(int count) {
    return 'Retiradas: $count';
  }

  @override
  String get removeDonation => 'Retirar\ndonación';

  @override
  String get donateSanctuary => 'Donar al\nsantuario';

  @override
  String get removePartyCard => 'Retirar\ncarta de grupo:';

  @override
  String get addPartyCard => 'Añadir\ncarta de grupo:';

  @override
  String get perks => 'Ventajas';

  @override
  String get revealCards => 'Revelar\ncartas:';

  @override
  String get revealAll => 'Todas';

  @override
  String get drawExtraCard => 'Robar carta extra';

  @override
  String get extraShuffle => 'Barajada extra';

  @override
  String get inactivateMonster => 'Inactivar\nmonstruo';

  @override
  String get activateMonster => 'Activar\nmonstruo';

  @override
  String addEliteStandees(int count, String name) {
    return 'Añadir $count $name élite';
  }

  @override
  String addNormalStandees(int count, String name) {
    return 'Añadir $count $name normal';
  }

  @override
  String get characterLoot => 'Botín del personaje';

  @override
  String addSpecialCard(int nr) {
    return 'Añadir carta $nr';
  }

  @override
  String removeSpecialCard(int nr) {
    return 'Retirar carta $nr';
  }

  @override
  String get enhanceCards => 'Mejorar cartas';

  @override
  String get addLootCard => 'Añadir carta';

  @override
  String get returnToTop => 'Devolver arriba';

  @override
  String get returnToBottom => 'Devolver abajo';

  @override
  String characterLootTitle(String name) {
    return 'Botín de $name:';
  }

  @override
  String get setLootOwner => 'Propietario del botín:';

  @override
  String get lootNameCoin => 'moneda';

  @override
  String get lootNameHide => 'piel';

  @override
  String get lootNameLumber => 'madera';

  @override
  String get lootNameMetal => 'metal';

  @override
  String get lootNameArrowvine => 'vid-flecha';

  @override
  String get lootNameAxenut => 'nuez-hacha';

  @override
  String get lootNameCorpsecap => 'gorro-cadáver';

  @override
  String get lootNameFlamefruit => 'fruta-llama';

  @override
  String get lootNameRockroot => 'raíz-roca';

  @override
  String get lootNameSnowthistle => 'cardo-nieve';

  @override
  String get lootAmount2For2 => '2 para 2 jugadores';

  @override
  String get lootAmount2For23 => '2 para 2-3 jugadores';

  @override
  String cmdActivateMonster(String name) {
    return 'Activar $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return 'Desactivar $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return 'Añadir $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return 'Añadir condición: $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return 'Retirar condición: $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character añadir carta de grupo $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character retirar carta de grupo';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character añadir carta de facción';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character retirar carta de facción';
  }

  @override
  String cmdAddLootCard(String type) {
    return 'Añadir carta de botín $type';
  }

  @override
  String cmdAddMonster(String name) {
    return 'Añadir $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return 'Añadir carta de botín especial $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return 'Retirar carta de botín especial $nr';
  }

  @override
  String get cmdAddMinusOne => 'Añadir menos uno';

  @override
  String get cmdRemoveMinusOne => 'Retirar menos uno';

  @override
  String get cmdRemoveMinusTwo => 'Retirar menos dos';

  @override
  String get cmdAddBackMinusTwo => 'Devolver menos dos';

  @override
  String get cmdRemovePlusZero => 'Retirar más cero';

  @override
  String get cmdAddBackPlusZero => 'Devolver más cero';

  @override
  String cmdRevealModifierCards(int count) {
    return 'Revelar $count cartas modificadoras';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return 'Dejar cartas reveladas encima del mazo $deck';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return 'Especial Cassandra desactivado para mazo $deck';
  }

  @override
  String get cmdImbueMonsterDeck => 'Imbuir mazo de monstruos';

  @override
  String get cmdAdvancedImbueMonsterDeck =>
      'Imbuido avanzado del mazo de monstruos';

  @override
  String get cmdRemoveImbueMonsterDeck => 'Retirar imbuido';

  @override
  String get cmdChangeName => 'Cambiar nombre del personaje';

  @override
  String get cmdAddBless => 'Añadir bendición';

  @override
  String get cmdRemoveBless => 'Retirar bendición';

  @override
  String get cmdAddCurse => 'Añadir maldición';

  @override
  String get cmdRemoveCurse => 'Retirar maldición';

  @override
  String get cmdAddEmpower => 'Añadir potenciación';

  @override
  String get cmdRemoveEmpower => 'Retirar potenciación';

  @override
  String get cmdAddEnfeeble => 'Añadir debilitación';

  @override
  String get cmdRemoveEnfeeble => 'Retirar debilitación';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return 'Aumentar vida máx. de $owner';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return 'Reducir vida máx. de $owner';
  }

  @override
  String get cmdChangeStat => 'Modificar estadística';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return 'Aumentar XP de $figure en $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return 'Reducir XP de $figure en $amount';
  }

  @override
  String get cmdClearUnlockedClasses => 'Borrar clases desbloqueadas';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character donar al santuario';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return 'Retirar donación de $character';
  }

  @override
  String get cmdDrawExtraAbilityCard => 'Robar carta de habilidad extra';

  @override
  String get cmdDraw => 'Robar';

  @override
  String get cmdDrawLootCard => 'Robar carta de botín';

  @override
  String cmdDrawModifierCard(String name) {
    return 'Robar carta modificadora $name';
  }

  @override
  String get cmdRemoveLootEnhancement => 'Retirar mejora de botín';

  @override
  String get cmdAddLootEnhancement => 'Añadir mejora de botín';

  @override
  String get cmdHideAllyDeck => 'Ocultar mazo aliado';

  @override
  String get cmdShowAllyDeck => 'Mostrar mazo aliado';

  @override
  String get cmdIceWraithTurnNormal => 'Espectro de hielo pasa a normal';

  @override
  String get cmdIceWraithTurnElite => 'Espectro de hielo pasa a élite';

  @override
  String cmdImbueElement(String element) {
    return 'Imbuir elemento $element';
  }

  @override
  String cmdUseElement(String element) {
    return 'Usar elemento $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return 'Cargar personaje guardado: $name';
  }

  @override
  String cmdLoadGame(String name) {
    return 'Cargar partida guardada: $name';
  }

  @override
  String get cmdNextRound => 'Siguiente ronda';

  @override
  String get cmdRemoveAmdCard => 'Retirar carta AMD';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return 'Retirar carta $deck n.º $nr';
  }

  @override
  String get cmdRemoveAllCharacters => 'Retirar todos los personajes';

  @override
  String cmdRemoveCharacter(String id) {
    return 'Retirar $id';
  }

  @override
  String get cmdRemoveAllMonsters => 'Retirar todos los monstruos';

  @override
  String cmdRemoveMonster(String name) {
    return 'Retirar $name';
  }

  @override
  String get cmdReorderAbilityCards => 'Reordenar cartas de habilidad';

  @override
  String get cmdReorderList => 'Reordenar lista';

  @override
  String get cmdReorderModifierCards => 'Reordenar cartas modificadoras';

  @override
  String get cmdReturnLootCard => 'Devolver carta de botín';

  @override
  String get cmdReturnModifierCard => 'Devolver carta modificadora arriba';

  @override
  String get cmdReturnRemovedAmdCard => 'Devolver carta AMD retirada';

  @override
  String get cmdNoAllyDeckInOgGloom =>
      'Sin mazo aliado en Gloomhaven 1.ª edición';

  @override
  String get cmdUseAllyDeckInOgGloom =>
      'Usar mazo aliado en Gloomhaven 1.ª edición';

  @override
  String cmdMarkAsSummon(String owner) {
    return 'Marcar $owner como invocado';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return 'Retirar marca de invocación de $owner';
  }

  @override
  String get cmdAutoLevelOn => 'Activar actualización automática de nivel';

  @override
  String get cmdAutoLevelOff => 'Desactivar actualización automática de nivel';

  @override
  String cmdSetCampaign(String campaign) {
    return 'Definir campaña $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return 'Definir nivel de $character';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return 'Definir dificultad a $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return 'Definir iniciativa de $character';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return 'Definir nivel de $monster';
  }

  @override
  String get cmdSetLootOwner => 'Definir propietario de botín';

  @override
  String get cmdSetScenario => 'Definir escenario';

  @override
  String get cmdSetSoloOn => 'Activar recomendación nivel solo';

  @override
  String get cmdSetSoloOff => 'Desactivar recomendación nivel solo';

  @override
  String get cmdExtraAbilityShuffle => 'Barajada extra del mazo de habilidades';

  @override
  String get cmdExtraAmdShuffle => 'Barajada extra del mazo AMD';

  @override
  String get cmdDrawnAbilityShuffle =>
      'Barajada del mazo de habilidades robadas';

  @override
  String get cmdDontTrackStandees => 'No rastrear figurines';

  @override
  String get cmdTrackStandees => 'Rastrear figurines';

  @override
  String cmdTurnDone(String id) {
    return 'Turno de $id terminado';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return 'Añadir ventaja $index de \'$character\'';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return 'Retirar ventaja $index de \'$character\'';
  }

  @override
  String cmdUnlock(String id) {
    return 'Desbloquear $id';
  }

  @override
  String cmdLock(String id) {
    return 'Bloquear $id';
  }

  @override
  String get cmdSetLevel => 'Definir nivel';

  @override
  String get cmdAddSection => 'Añadir sección';

  @override
  String cmdAddStandee(String name, int nr) {
    return 'Añadir $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard =>
      'Robar carta modificadora de monstruo';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return 'Aumentar vida de $figure en $amount';
  }

  @override
  String cmdKill(String owner) {
    return 'Eliminar $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return 'Reducir vida de $owner en $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character usar ventajas Frosthaven';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character no usar ventajas Frosthaven';
  }

  @override
  String get cmdRemoveNoCharacters => 'Sin personajes retirados';

  @override
  String get cmdRemoveNoMonsters => 'Sin monstruos retirados';
}
