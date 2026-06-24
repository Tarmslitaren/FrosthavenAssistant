// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get menuSetScenario => 'Задать сценарий';

  @override
  String get menuAddCharacter => 'Добавить персонажа';

  @override
  String get menuRemoveCharacters => 'Убрать персонажей';

  @override
  String get menuSetLevel => 'Задать уровень';

  @override
  String get menuLootDeck => 'Меню колоды добычи';

  @override
  String get menuAddMonsters => 'Добавить монстров';

  @override
  String get menuRemoveMonsters => 'Убрать монстров';

  @override
  String get menuShowAllyDeck => 'Показать колоду модификаторов союзника';

  @override
  String get menuHideAllyDeck => 'Скрыть колоду модификаторов союзника';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuDocumentation => 'Документация';

  @override
  String get menuDonate => 'Пожертвовать';

  @override
  String get menuExit => 'Выход';

  @override
  String get menuAddSection => 'Добавить секцию';

  @override
  String get menuAddRandomDungeonCard => 'Добавить случайную карту подземелья';

  @override
  String get undo => 'Отменить';

  @override
  String undoWithDescription(String description) {
    return 'Отмена: $description';
  }

  @override
  String get redo => 'Повторить';

  @override
  String redoWithDescription(String description) {
    return 'Повтор: $description';
  }

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get connectedAsClient => 'Подключён как клиент';

  @override
  String get connecting => 'Подключение…';

  @override
  String connectAsClientWithIp(String ip) {
    return 'Подключиться ($ip)';
  }

  @override
  String get connectAsClientLabel => 'Подключиться как клиент';

  @override
  String stopServerWithIp(String ip) {
    return 'Остановить сервер $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'Запустить сервер $ip';
  }

  @override
  String get stopServerButton => 'Остановить сервер';

  @override
  String get startHostServerButton => 'Запустить сервер хоста';

  @override
  String get networkConnectLocal => 'Подключить устройства по локальной Wi-Fi:';

  @override
  String get networkServerIpHint => 'IP-адрес сервера';

  @override
  String get networkPortHint => 'порт';

  @override
  String get settingsLanguage => 'Язык:';

  @override
  String get settingsDarkMode => 'Тёмная тема';

  @override
  String get settingsSoftNumpad => 'Экранная цифровая клавиатура';

  @override
  String get settingsNoInit => 'Не запрашивать инициативу';

  @override
  String get settingsExpireConditions => 'Истечение состояний';

  @override
  String get settingsNoStandees => 'Не отслеживать фишки';

  @override
  String get settingsAutoAddStandees => 'Автодобавление фишек';

  @override
  String get settingsAutoAddSpawns => 'Автодобавление призывов';

  @override
  String get settingsRandomStandees => 'Случайные фишки';

  @override
  String get settingsNoCalculations => 'Без расчётов';

  @override
  String get settingsHideLootDeck => 'Скрыть колоду добычи';

  @override
  String get settingsShimmer => 'Мерцание текста на картах характеристик';

  @override
  String get settingsFhHazTerrainCalc =>
      'Расчёт опасной местности Frosthaven в оригинальном Gloomhaven';

  @override
  String get settingsAllyDeckOGGloom =>
      'Колода модификаторов союзника в оригинальном Gloomhaven';

  @override
  String get settingsShowScenarioNames => 'Показывать названия сценариев';

  @override
  String get settingsShowBattleGoalReminder =>
      'Показывать напоминание о цели битвы';

  @override
  String get settingsShowCustomContent => 'Показывать пользовательский контент';

  @override
  String get settingsShowSections => 'Показывать секции на главном экране';

  @override
  String get settingsShowReminders => 'Показывать напоминания особых правил';

  @override
  String get settingsShowAmdDeck => 'Показывать колоды модификаторов атаки';

  @override
  String get settingsShowCharacterAmd =>
      'Показывать колоды модификаторов персонажей';

  @override
  String get settingsHealthWheel =>
      'Колесо HP: тяните влево-вправо для изменения';

  @override
  String get settingsFullscreen => 'Полный экран';

  @override
  String get settingsMainListScaling => 'Масштаб основного списка:';

  @override
  String get settingsAppBarScaling => 'Масштаб панели приложения:';

  @override
  String get settingsStyleLabel => 'Стиль:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'Оригинальный';

  @override
  String get settingsClearUnlocked =>
      'Очистить разблокированных персонажей и контент';

  @override
  String get settingsUnlockSpecials => 'Разблокировать особые';

  @override
  String get settingsLoadSaveState => 'Загрузить/сохранить состояние';

  @override
  String get noResultsFound => 'Ничего не найдено';

  @override
  String get close => 'Закрыть';

  @override
  String get retry => 'ПОВТОР';

  @override
  String get specialUnlocks => 'Особые разблокировки';

  @override
  String get loadSaveDeleteCharacters =>
      'Загрузить, сохранить или удалить персонажей.';

  @override
  String get loadAddDeleteSaves =>
      'Загрузить, добавить или удалить сохранения.';

  @override
  String get addNewSave => 'Новое сохранение';

  @override
  String get addNewSaveLabel => 'Новое сохранение:';

  @override
  String get loadButton => 'Загрузить';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get setSaveName => 'Имя сохранения:';

  @override
  String get loadOrSaveCharacters => 'Загрузить или сохранить персонажей';

  @override
  String get loadCharacter => 'Загрузить персонажа:';

  @override
  String get removeAll => 'Убрать всё';

  @override
  String get removeCardQuestion => 'Убрать карту?';

  @override
  String get sendToBottom => 'Отправить вниз';

  @override
  String get shuffleUndrawnCards => 'Перемешать невзятые карты';

  @override
  String get returnToDiscardPile => 'Вернуть в сброс';

  @override
  String get returnToDrawPile => 'Вернуть в колоду';

  @override
  String get addExtraLootCard => 'Добавить дополнительную карту добычи';

  @override
  String get addStandeeNr => 'Добавить фишку №';

  @override
  String get summonedLabel => 'Призванные:';

  @override
  String get characterDecks => 'Колоды персонажей';

  @override
  String get shuffleAndDraw => 'Перемешать\nи взять';

  @override
  String get draw => 'Взять';

  @override
  String get nextRound => ' Следующий\nраунд';

  @override
  String get returnTopCard => 'Вернуть верхнюю карту';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'Убрать $title\n(карта №: $nr)';
  }

  @override
  String get tapCardToAddToDeck => 'Нажмите карту, чтобы добавить в колоду';

  @override
  String get removeCardFromDeckQuestion => 'Убрать карту из колоды?';

  @override
  String get changeName => 'Изменить имя:';

  @override
  String get showBosses => 'Показать боссов';

  @override
  String get showScenarioSpecialMonsters => 'Показать особых монстров сценария';

  @override
  String get addAsAlly => 'Добавить как союзника';

  @override
  String get addMonsterLabel => 'Добавить монстра';

  @override
  String get allCampaigns => 'Все кампании';

  @override
  String get showMonstersFrom => '      Показать монстров из:   ';

  @override
  String setMonsterLevel(String name) {
    return 'Уровень $name';
  }

  @override
  String setSummonHealth(String name) {
    return 'Макс. HP $name';
  }

  @override
  String get setScenarioLevel => 'Уровень сценария';

  @override
  String enhancedLevel(String level) {
    return 'Улучшено: $level';
  }

  @override
  String get soloLabel => 'Соло:';

  @override
  String get automaticScenarioLevel => 'Автоматический уровень сценария:';

  @override
  String get difficultyLabel => 'Сложность:';

  @override
  String get lootCardEnhancements => 'Улучшения карт добычи';

  @override
  String get addPerks => 'Добавить особенности';

  @override
  String get useFrosthavenPerks => 'Особенности Frosthaven';

  @override
  String currentCampaign(String campaign) {
    return 'Текущая кампания: $campaign';
  }

  @override
  String get addCharacterHint =>
      'Добавить персонажа (введите имя для скрытых классов)';

  @override
  String get trapDamage => 'урон от ловушки';

  @override
  String get hazardousTerrainDamage => 'урон от опасной местности';

  @override
  String get experienceAdded => 'добавлен опыт';

  @override
  String get goldCoinValue => 'ценность золотой монеты';

  @override
  String get levelLegendLabel => 'уровень';

  @override
  String get saveStateNote =>
      'Приложение автоматически сохраняет прогресс после каждого действия. Эти сохранения для резервных копий или нескольких кампаний.';

  @override
  String clientConnectedTo(String address) {
    return 'Клиент подключён к: $address';
  }

  @override
  String clientError(String error) {
    return 'Ошибка клиента: $error';
  }

  @override
  String clientListenError(String error) {
    return 'Ошибка прослушивания клиента: $error';
  }

  @override
  String get lostConnectionToServer => 'Соединение с сервером потеряно';

  @override
  String get stateMismatch =>
      'Ваше состояние было не актуальным, попробуйте снова.';

  @override
  String get serverUnresponsive => 'Сервер не отвечает. Клиент отключён.';

  @override
  String get clientDisconnected => 'клиент отключён';

  @override
  String get serverOffline => 'Сервер недоступен';

  @override
  String get clientLeft => 'Клиент вышел.';

  @override
  String get clientTooOld =>
      'Устаревший клиент попытался подключиться. Обновите приложение.';

  @override
  String networkConnection(String status) {
    return 'Сетевое соединение: $status';
  }

  @override
  String get failedToGetWifiIp => 'Не удалось получить IP-адрес';

  @override
  String get badOmen => 'Дурное предзнаменование';

  @override
  String badOmensLeft(int count) {
    return 'Осталось предзнаменований: $count';
  }

  @override
  String get corrosiveSpew => 'Разъедающий выброс';

  @override
  String get empowersOnTop => 'Усиления сверху';

  @override
  String addMinusOneCard(int count) {
    return 'Добавить карту -1 (добавлено: $count)';
  }

  @override
  String get removeMinusOneCard => 'Убрать карту -1';

  @override
  String get removeMinusTwoCard => 'Убрать карту -2';

  @override
  String get minusTwoCardRemoved => 'Карта -2 убрана';

  @override
  String get removePlusZeroCard => 'Убрать карту +0';

  @override
  String get plusZeroCardRemoved => 'Карта +0 убрана';

  @override
  String get removeImbue => 'Убрать пропитку';

  @override
  String get imbue => 'Пропитать';

  @override
  String get advancedImbue => 'Расширенная пропитка';

  @override
  String get removeHailPerk => 'Убрать особенность Град';

  @override
  String get addHailPerk => 'Добавить особенность Град';

  @override
  String get removeCassandraPerk => 'Убрать\nособенность Кассандры';

  @override
  String get addCassandraPerk => 'Добавить\nособенность Кассандры';

  @override
  String get dontSaveRevealedCards => 'Не хранить\nоткрытые карты';

  @override
  String get saveRevealedCards => 'Хранить\nоткрытые карты';

  @override
  String removedCountLabel(int count) {
    return 'Убрано: $count';
  }

  @override
  String get removeDonation => 'Убрать\nпожертвование';

  @override
  String get donateSanctuary => 'Пожертвовать\nв святилище';

  @override
  String get removePartyCard => 'Убрать\nкарту группы:';

  @override
  String get addPartyCard => 'Добавить\nкарту группы:';

  @override
  String get perks => 'Особенности';

  @override
  String get revealCards => 'Открыть\nкарты:';

  @override
  String get revealAll => 'Все';

  @override
  String get drawExtraCard => 'Взять дополнительную карту';

  @override
  String get extraShuffle => 'Дополнительное перемешивание';

  @override
  String get inactivateMonster => 'Деактивировать\nмонстра';

  @override
  String get activateMonster => 'Активировать\nмонстра';

  @override
  String addEliteStandees(int count, String name) {
    return 'Добавить $count элитных $name';
  }

  @override
  String addNormalStandees(int count, String name) {
    return 'Добавить $count обычных $name';
  }

  @override
  String get characterLoot => 'Добыча персонажа';

  @override
  String addSpecialCard(int nr) {
    return 'Добавить карту $nr';
  }

  @override
  String removeSpecialCard(int nr) {
    return 'Убрать карту $nr';
  }

  @override
  String get enhanceCards => 'Улучшить карты';

  @override
  String get addLootCard => 'Добавить карту';

  @override
  String get returnToTop => 'Вернуть наверх';

  @override
  String get returnToBottom => 'Вернуть вниз';

  @override
  String characterLootTitle(String name) {
    return 'Добыча $name:';
  }

  @override
  String get setLootOwner => 'Владелец добычи:';

  @override
  String get lootNameCoin => 'монета';

  @override
  String get lootNameHide => 'шкура';

  @override
  String get lootNameLumber => 'древесина';

  @override
  String get lootNameMetal => 'металл';

  @override
  String get lootNameArrowvine => 'стрела-лоза';

  @override
  String get lootNameAxenut => 'топор-орех';

  @override
  String get lootNameCorpsecap => 'труп-шляпка';

  @override
  String get lootNameFlamefruit => 'огне-плод';

  @override
  String get lootNameRockroot => 'камень-корень';

  @override
  String get lootNameSnowthistle => 'снежный чертополох';

  @override
  String get lootAmount2For2 => '2 для 2 игроков';

  @override
  String get lootAmount2For23 => '2 для 2-3 игроков';

  @override
  String cmdActivateMonster(String name) {
    return 'Активировать $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return 'Деактивировать $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return 'Добавить $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return 'Добавить состояние: $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return 'Убрать состояние: $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character добавить карту группы $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character убрать карту группы';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character добавить карту фракции';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character убрать карту фракции';
  }

  @override
  String cmdAddLootCard(String type) {
    return 'Добавить карту добычи $type';
  }

  @override
  String cmdAddMonster(String name) {
    return 'Добавить $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return 'Добавить особую карту добычи $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return 'Убрать особую карту добычи $nr';
  }

  @override
  String get cmdAddMinusOne => 'Добавить минус один';

  @override
  String get cmdRemoveMinusOne => 'Убрать минус один';

  @override
  String get cmdRemoveMinusTwo => 'Убрать минус два';

  @override
  String get cmdAddBackMinusTwo => 'Вернуть минус два';

  @override
  String get cmdRemovePlusZero => 'Убрать плюс ноль';

  @override
  String get cmdAddBackPlusZero => 'Вернуть плюс ноль';

  @override
  String cmdRevealModifierCards(int count) {
    return 'Открыть $count карт модификаторов';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return 'Оставить открытые карты поверх колоды $deck';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return 'Особенность Кассандры отключена для колоды $deck';
  }

  @override
  String get cmdImbueMonsterDeck => 'Пропитать колоду монстров';

  @override
  String get cmdAdvancedImbueMonsterDeck =>
      'Расширенная пропитка колоды монстров';

  @override
  String get cmdRemoveImbueMonsterDeck => 'Убрать пропитку';

  @override
  String get cmdChangeName => 'Изменить имя персонажа';

  @override
  String get cmdAddBless => 'Добавить благословение';

  @override
  String get cmdRemoveBless => 'Убрать благословение';

  @override
  String get cmdAddCurse => 'Добавить проклятие';

  @override
  String get cmdRemoveCurse => 'Убрать проклятие';

  @override
  String get cmdAddEmpower => 'Добавить усиление';

  @override
  String get cmdRemoveEmpower => 'Убрать усиление';

  @override
  String get cmdAddEnfeeble => 'Добавить ослабление';

  @override
  String get cmdRemoveEnfeeble => 'Убрать ослабление';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return 'Увеличить макс. HP $owner';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return 'Уменьшить макс. HP $owner';
  }

  @override
  String get cmdChangeStat => 'Изменить характеристику';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return 'Увеличить опыт $figure на $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return 'Уменьшить опыт $figure на $amount';
  }

  @override
  String get cmdClearUnlockedClasses => 'Очистить разблокированные классы';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character пожертвовать в святилище';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return 'Убрать пожертвование $character';
  }

  @override
  String get cmdDrawExtraAbilityCard =>
      'Взять дополнительную карту способности';

  @override
  String get cmdDraw => 'Взять';

  @override
  String get cmdDrawLootCard => 'Взять карту добычи';

  @override
  String cmdDrawModifierCard(String name) {
    return 'Взять карту модификатора $name';
  }

  @override
  String get cmdRemoveLootEnhancement => 'Убрать улучшение добычи';

  @override
  String get cmdAddLootEnhancement => 'Добавить улучшение добычи';

  @override
  String get cmdHideAllyDeck => 'Скрыть колоду союзника';

  @override
  String get cmdShowAllyDeck => 'Показать колоду союзника';

  @override
  String get cmdIceWraithTurnNormal => 'Ледяной призрак переходит в обычный';

  @override
  String get cmdIceWraithTurnElite => 'Ледяной призрак переходит в элитный';

  @override
  String cmdImbueElement(String element) {
    return 'Пропитать стихию $element';
  }

  @override
  String cmdUseElement(String element) {
    return 'Использовать стихию $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return 'Загрузить сохранённого персонажа: $name';
  }

  @override
  String cmdLoadGame(String name) {
    return 'Загрузить сохранённую игру: $name';
  }

  @override
  String get cmdNextRound => 'Следующий раунд';

  @override
  String get cmdRemoveAmdCard => 'Убрать карту AMD';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return 'Убрать карту $deck №$nr';
  }

  @override
  String get cmdRemoveAllCharacters => 'Убрать всех персонажей';

  @override
  String cmdRemoveCharacter(String id) {
    return 'Убрать $id';
  }

  @override
  String get cmdRemoveAllMonsters => 'Убрать всех монстров';

  @override
  String cmdRemoveMonster(String name) {
    return 'Убрать $name';
  }

  @override
  String get cmdReorderAbilityCards => 'Переупорядочить карты способностей';

  @override
  String get cmdReorderList => 'Переупорядочить список';

  @override
  String get cmdReorderModifierCards => 'Переупорядочить карты модификаторов';

  @override
  String get cmdReturnLootCard => 'Вернуть карту добычи';

  @override
  String get cmdReturnModifierCard => 'Вернуть карту модификатора наверх';

  @override
  String get cmdReturnRemovedAmdCard => 'Вернуть убранную карту AMD';

  @override
  String get cmdNoAllyDeckInOgGloom =>
      'Нет колоды союзника в оригинальном Gloomhaven';

  @override
  String get cmdUseAllyDeckInOgGloom =>
      'Использовать колоду союзника в оригинальном Gloomhaven';

  @override
  String cmdMarkAsSummon(String owner) {
    return 'Отметить $owner как призванного';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return 'Убрать метку призыва у $owner';
  }

  @override
  String get cmdAutoLevelOn => 'Включить автоматическое обновление уровня';

  @override
  String get cmdAutoLevelOff => 'Выключить автоматическое обновление уровня';

  @override
  String cmdSetCampaign(String campaign) {
    return 'Задать кампанию $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return 'Задать уровень $character';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return 'Задать сложность $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return 'Задать инициативу $character';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return 'Задать уровень $monster';
  }

  @override
  String get cmdSetLootOwner => 'Задать владельца добычи';

  @override
  String get cmdSetScenario => 'Задать сценарий';

  @override
  String get cmdSetSoloOn => 'Включить рекомендацию уровня для соло';

  @override
  String get cmdSetSoloOff => 'Выключить рекомендацию уровня для соло';

  @override
  String get cmdExtraAbilityShuffle =>
      'Дополнительное перемешивание колоды способностей';

  @override
  String get cmdExtraAmdShuffle => 'Дополнительное перемешивание колоды AMD';

  @override
  String get cmdDrawnAbilityShuffle =>
      'Перемешивание взятой колоды способностей';

  @override
  String get cmdDontTrackStandees => 'Не отслеживать фишки';

  @override
  String get cmdTrackStandees => 'Отслеживать фишки';

  @override
  String cmdTurnDone(String id) {
    return 'Ход $id завершён';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return 'Добавить особенность $index персонажа \'$character\'';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return 'Убрать особенность $index персонажа \'$character\'';
  }

  @override
  String cmdUnlock(String id) {
    return 'Разблокировать $id';
  }

  @override
  String cmdLock(String id) {
    return 'Заблокировать $id';
  }

  @override
  String get cmdSetLevel => 'Задать уровень';

  @override
  String get cmdAddSection => 'Добавить секцию';

  @override
  String cmdAddStandee(String name, int nr) {
    return 'Добавить $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => 'Взять карту модификатора монстра';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return 'Увеличить HP $figure на $amount';
  }

  @override
  String cmdKill(String owner) {
    return 'Устранить $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return 'Уменьшить HP $owner на $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character использует особенности Frosthaven';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character не использует особенности Frosthaven';
  }

  @override
  String get cmdRemoveNoCharacters => 'Персонажи не убраны';

  @override
  String get cmdRemoveNoMonsters => 'Монстры не убраны';
}
