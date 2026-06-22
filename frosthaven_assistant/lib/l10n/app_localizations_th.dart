// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get menuSetScenario => 'ตั้งค่าฉาก';

  @override
  String get menuAddCharacter => 'เพิ่มตัวละคร';

  @override
  String get menuRemoveCharacters => 'นำตัวละครออก';

  @override
  String get menuSetLevel => 'ตั้งค่าระดับ';

  @override
  String get menuLootDeck => 'เมนูสำรับการปล้นสะดม';

  @override
  String get menuAddMonsters => 'เพิ่มมอนสเตอร์';

  @override
  String get menuRemoveMonsters => 'นำมอนสเตอร์ออก';

  @override
  String get menuShowAllyDeck => 'แสดงสำรับตัวปรับแต่งพันธมิตร';

  @override
  String get menuHideAllyDeck => 'ซ่อนสำรับตัวปรับแต่งพันธมิตร';

  @override
  String get menuSettings => 'การตั้งค่า';

  @override
  String get menuDocumentation => 'เอกสาร';

  @override
  String get menuDonate => 'บริจาค';

  @override
  String get menuExit => 'ออก';

  @override
  String get menuAddSection => 'เพิ่มส่วน';

  @override
  String get menuAddRandomDungeonCard => 'เพิ่มการ์ดดันเจี้ยนแบบสุ่ม';

  @override
  String get undo => 'เลิกทำ';

  @override
  String undoWithDescription(String description) {
    return 'เลิกทำ: $description';
  }

  @override
  String get redo => 'ทำซ้ำ';

  @override
  String redoWithDescription(String description) {
    return 'ทำซ้ำ: $description';
  }

  @override
  String versionLabel(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get connectedAsClient => 'เชื่อมต่อในฐานะไคลเอนต์แล้ว';

  @override
  String get connecting => 'กำลังเชื่อมต่อ…';

  @override
  String connectAsClientWithIp(String ip) {
    return 'เชื่อมต่อในฐานะไคลเอนต์ ($ip)';
  }

  @override
  String get connectAsClientLabel => 'เชื่อมต่อในฐานะไคลเอนต์';

  @override
  String stopServerWithIp(String ip) {
    return 'หยุดเซิร์ฟเวอร์ $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return 'เริ่มเซิร์ฟเวอร์ $ip';
  }

  @override
  String get stopServerButton => 'หยุดเซิร์ฟเวอร์';

  @override
  String get startHostServerButton => 'เริ่มเซิร์ฟเวอร์โฮสต์';

  @override
  String get networkConnectLocal => 'เชื่อมต่ออุปกรณ์ผ่าน Wi-Fi ท้องถิ่น:';

  @override
  String get networkServerIpHint => 'ที่อยู่ IP เซิร์ฟเวอร์';

  @override
  String get networkPortHint => 'พอร์ต';

  @override
  String get settingsLanguage => 'ภาษา:';

  @override
  String get settingsDarkMode => 'โหมดมืด';

  @override
  String get settingsSoftNumpad => 'แป้นตัวเลขซอฟต์แวร์';

  @override
  String get settingsNoInit => 'ไม่ถามค่าริเริ่ม';

  @override
  String get settingsExpireConditions => 'หมดอายุสถานะ';

  @override
  String get settingsNoStandees => 'ไม่ติดตามตัวยืน';

  @override
  String get settingsAutoAddStandees => 'เพิ่มตัวยืนอัตโนมัติ';

  @override
  String get settingsAutoAddSpawns => 'เพิ่มการเรียกอัตโนมัติ';

  @override
  String get settingsRandomStandees => 'ตัวยืนแบบสุ่ม';

  @override
  String get settingsNoCalculations => 'ไม่คำนวณอัตโนมัติ';

  @override
  String get settingsHideLootDeck => 'ซ่อนสำรับการปล้นสะดม';

  @override
  String get settingsShimmer => 'ข้อความระยิบระยับบนการ์ดสถิติ';

  @override
  String get settingsFhHazTerrainCalc =>
      'คำนวณพื้นที่อันตราย Frosthaven ใน Gloomhaven ดั้งเดิม';

  @override
  String get settingsAllyDeckOGGloom =>
      'สำรับตัวปรับแต่งพันธมิตรใน Gloomhaven ดั้งเดิม';

  @override
  String get settingsShowScenarioNames => 'แสดงชื่อฉาก';

  @override
  String get settingsShowBattleGoalReminder => 'แสดงตัวเตือนเป้าหมายการต่อสู้';

  @override
  String get settingsShowCustomContent => 'แสดงเนื้อหาที่กำหนดเอง';

  @override
  String get settingsShowSections => 'แสดงส่วนในหน้าจอหลัก';

  @override
  String get settingsShowReminders => 'แสดงตัวเตือนกฎพิเศษ';

  @override
  String get settingsShowAmdDeck => 'แสดงสำรับตัวปรับแต่งการโจมตี';

  @override
  String get settingsShowCharacterAmd => 'แสดงสำรับตัวปรับแต่งของตัวละคร';

  @override
  String get settingsHealthWheel => 'วงล้อ HP: ลากซ้าย-ขวาเพื่อเปลี่ยน';

  @override
  String get settingsFullscreen => 'เต็มหน้าจอ';

  @override
  String get settingsMainListScaling => 'ขนาดรายการหลัก:';

  @override
  String get settingsAppBarScaling => 'ขนาดแถบแอป:';

  @override
  String get settingsStyleLabel => 'สไตล์:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => 'ดั้งเดิม';

  @override
  String get settingsClearUnlocked => 'ล้างตัวละครและเนื้อหาที่ปลดล็อก';

  @override
  String get settingsUnlockSpecials => 'ปลดล็อกพิเศษ';

  @override
  String get settingsLoadSaveState => 'โหลด/บันทึกสถานะ';

  @override
  String get noResultsFound => 'ไม่พบผลลัพธ์';

  @override
  String get close => 'ปิด';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get specialUnlocks => 'การปลดล็อกพิเศษ';

  @override
  String get loadSaveDeleteCharacters => 'โหลด บันทึก หรือลบตัวละคร';

  @override
  String get loadAddDeleteSaves => 'โหลด เพิ่ม หรือลบการบันทึก';

  @override
  String get addNewSave => 'บันทึกใหม่';

  @override
  String get addNewSaveLabel => 'บันทึกใหม่:';

  @override
  String get loadButton => 'โหลด';

  @override
  String get saveButton => 'บันทึก';

  @override
  String get deleteButton => 'ลบ';

  @override
  String get setSaveName => 'ชื่อการบันทึก:';

  @override
  String get loadOrSaveCharacters => 'โหลดหรือบันทึกตัวละคร';

  @override
  String get loadCharacter => 'โหลดตัวละคร:';

  @override
  String get removeAll => 'นำออกทั้งหมด';

  @override
  String get removeCardQuestion => 'นำการ์ดออก?';

  @override
  String get sendToBottom => 'ส่งไปด้านล่าง';

  @override
  String get shuffleUndrawnCards => 'สับการ์ดที่ยังไม่ได้จั่ว';

  @override
  String get returnToDiscardPile => 'คืนสู่กองทิ้ง';

  @override
  String get returnToDrawPile => 'คืนสู่สำรับ';

  @override
  String get addExtraLootCard => 'เพิ่มการ์ดการปล้นสะดมพิเศษ';

  @override
  String get addStandeeNr => 'เพิ่มตัวยืนหมายเลข';

  @override
  String get summonedLabel => 'ที่ถูกเรียก:';

  @override
  String get characterDecks => 'สำรับตัวละคร';

  @override
  String get shuffleAndDraw => 'สับ\nและจั่ว';

  @override
  String get draw => 'จั่ว';

  @override
  String get nextRound => ' รอบถัดไป';

  @override
  String get returnTopCard => 'คืนการ์ดด้านบน';

  @override
  String removeCardWithDetails(String title, int nr) {
    return 'นำ $title ออก\n(การ์ดหมายเลข: $nr)';
  }

  @override
  String get tapCardToAddToDeck => 'แตะการ์ดเพื่อเพิ่มในสำรับ';

  @override
  String get removeCardFromDeckQuestion => 'นำการ์ดออกจากสำรับ?';

  @override
  String get changeName => 'เปลี่ยนชื่อ:';

  @override
  String get showBosses => 'แสดงบอส';

  @override
  String get showScenarioSpecialMonsters => 'แสดงมอนสเตอร์พิเศษของฉาก';

  @override
  String get addAsAlly => 'เพิ่มเป็นพันธมิตร';

  @override
  String get addMonsterLabel => 'เพิ่มมอนสเตอร์';

  @override
  String get allCampaigns => 'แคมเปญทั้งหมด';

  @override
  String get showMonstersFrom => '      แสดงมอนสเตอร์จาก:   ';

  @override
  String setMonsterLevel(String name) {
    return 'ระดับ $name';
  }

  @override
  String setSummonHealth(String name) {
    return 'HP สูงสุด $name';
  }

  @override
  String get setScenarioLevel => 'ระดับฉาก';

  @override
  String enhancedLevel(String level) {
    return 'เสริมแล้ว: $level';
  }

  @override
  String get soloLabel => 'เดี่ยว:';

  @override
  String get automaticScenarioLevel => 'ระดับฉากอัตโนมัติ:';

  @override
  String get difficultyLabel => 'ความยาก:';

  @override
  String get lootCardEnhancements => 'การเสริมการ์ดการปล้นสะดม';

  @override
  String get addPerks => 'เพิ่มสิทธิพิเศษ';

  @override
  String get useFrosthavenPerks => 'ใช้สิทธิพิเศษ Frosthaven';

  @override
  String currentCampaign(String campaign) {
    return 'แคมเปญปัจจุบัน: $campaign';
  }

  @override
  String get addCharacterHint => 'เพิ่มตัวละคร (พิมพ์ชื่อสำหรับคลาสที่ซ่อน)';

  @override
  String get trapDamage => 'ความเสียหายกับดัก';

  @override
  String get hazardousTerrainDamage => 'ความเสียหายพื้นที่อันตราย';

  @override
  String get experienceAdded => 'เพิ่มประสบการณ์';

  @override
  String get goldCoinValue => 'มูลค่าเหรียญทอง';

  @override
  String get levelLegendLabel => 'ระดับ';

  @override
  String get saveStateNote =>
      'แอปบันทึกอัตโนมัติหลังทุกการกระทำ การบันทึกเหล่านี้ใช้สำหรับสำรองข้อมูลหรือหลายแคมเปญ';

  @override
  String clientConnectedTo(String address) {
    return 'ไคลเอนต์เชื่อมต่อกับ: $address';
  }

  @override
  String clientError(String error) {
    return 'ข้อผิดพลาดไคลเอนต์: $error';
  }

  @override
  String clientListenError(String error) {
    return 'ข้อผิดพลาดการฟังไคลเอนต์: $error';
  }

  @override
  String get lostConnectionToServer => 'ขาดการเชื่อมต่อกับเซิร์ฟเวอร์';

  @override
  String get stateMismatch => 'สถานะของคุณไม่ทันสมัย กรุณาลองใหม่';

  @override
  String get serverUnresponsive =>
      'เซิร์ฟเวอร์ไม่ตอบสนอง ตัดการเชื่อมต่อไคลเอนต์';

  @override
  String get clientDisconnected => 'ตัดการเชื่อมต่อไคลเอนต์';

  @override
  String get serverOffline => 'เซิร์ฟเวอร์ออฟไลน์';

  @override
  String get clientLeft => 'ไคลเอนต์ออกไปแล้ว';

  @override
  String get clientTooOld =>
      'ไคลเอนต์เวอร์ชันเก่าพยายามเชื่อมต่อ กรุณาอัปเดตแอป';

  @override
  String networkConnection(String status) {
    return 'การเชื่อมต่อเครือข่าย: $status';
  }

  @override
  String get failedToGetWifiIp => 'ไม่สามารถรับที่อยู่ IP ได้';

  @override
  String get badOmen => 'ลางร้าย';

  @override
  String badOmensLeft(int count) {
    return 'ลางร้ายที่เหลือ: $count';
  }

  @override
  String get corrosiveSpew => 'การพ่นสารกัดกร่อน';

  @override
  String get empowersOnTop => 'การเสริมพลังอยู่ด้านบน';

  @override
  String addMinusOneCard(int count) {
    return 'เพิ่มการ์ด -1 (เพิ่มแล้ว: $count)';
  }

  @override
  String get removeMinusOneCard => 'นำการ์ด -1 ออก';

  @override
  String get removeMinusTwoCard => 'นำการ์ด -2 ออก';

  @override
  String get minusTwoCardRemoved => 'นำการ์ด -2 ออกแล้ว';

  @override
  String get removePlusZeroCard => 'นำการ์ด +0 ออก';

  @override
  String get plusZeroCardRemoved => 'นำการ์ด +0 ออกแล้ว';

  @override
  String get removeImbue => 'นำการซึมซับออก';

  @override
  String get imbue => 'ซึมซับ';

  @override
  String get advancedImbue => 'การซึมซับขั้นสูง';

  @override
  String get removeHailPerk => 'นำสิทธิพิเศษลูกเห็บออก';

  @override
  String get addHailPerk => 'เพิ่มสิทธิพิเศษลูกเห็บ';

  @override
  String get removeCassandraPerk => 'นำ\nสิทธิพิเศษแคสแซนดราออก';

  @override
  String get addCassandraPerk => 'เพิ่ม\nสิทธิพิเศษแคสแซนดรา';

  @override
  String get dontSaveRevealedCards => 'ไม่บันทึก\nการ์ดที่เปิดเผย';

  @override
  String get saveRevealedCards => 'บันทึก\nการ์ดที่เปิดเผย';

  @override
  String removedCountLabel(int count) {
    return 'นำออกแล้ว: $count';
  }

  @override
  String get removeDonation => 'นำ\nการบริจาคออก';

  @override
  String get donateSanctuary => 'บริจาคให้\nศาลเจ้า';

  @override
  String get removePartyCard => 'นำ\nการ์ดกลุ่มออก:';

  @override
  String get addPartyCard => 'เพิ่ม\nการ์ดกลุ่ม:';

  @override
  String get perks => 'สิทธิพิเศษ';

  @override
  String get revealCards => 'เปิดเผย\nการ์ด:';

  @override
  String get revealAll => 'ทั้งหมด';

  @override
  String get drawExtraCard => 'จั่วการ์ดพิเศษ';

  @override
  String get extraShuffle => 'สับพิเศษ';

  @override
  String get inactivateMonster => 'ปิดใช้งาน\nมอนสเตอร์';

  @override
  String get activateMonster => 'เปิดใช้งาน\nมอนสเตอร์';

  @override
  String addEliteStandees(int count, String name) {
    return 'เพิ่ม $name ชั้นยอด $count ตัว';
  }

  @override
  String addNormalStandees(int count, String name) {
    return 'เพิ่ม $name ธรรมดา $count ตัว';
  }

  @override
  String get characterLoot => 'การปล้นสะดมของตัวละคร';

  @override
  String addSpecialCard(int nr) {
    return 'เพิ่มการ์ด $nr';
  }

  @override
  String removeSpecialCard(int nr) {
    return 'นำการ์ด $nr ออก';
  }

  @override
  String get enhanceCards => 'เสริมการ์ด';

  @override
  String get addLootCard => 'เพิ่มการ์ด';

  @override
  String get returnToTop => 'คืนสู่ด้านบน';

  @override
  String get returnToBottom => 'คืนสู่ด้านล่าง';

  @override
  String characterLootTitle(String name) {
    return 'การปล้นสะดมของ $name:';
  }

  @override
  String get setLootOwner => 'เจ้าของการปล้นสะดม:';

  @override
  String get lootNameCoin => 'เหรียญ';

  @override
  String get lootNameHide => 'หนัง';

  @override
  String get lootNameLumber => 'ไม้';

  @override
  String get lootNameMetal => 'โลหะ';

  @override
  String get lootNameArrowvine => 'เถาลูกศร';

  @override
  String get lootNameAxenut => 'ถั่วขวาน';

  @override
  String get lootNameCorpsecap => 'เห็ดศพ';

  @override
  String get lootNameFlamefruit => 'ผลไม้เปลวเพลิง';

  @override
  String get lootNameRockroot => 'รากหิน';

  @override
  String get lootNameSnowthistle => 'หนามหิมะ';

  @override
  String get lootAmount2For2 => '2 สำหรับ 2 ผู้เล่น';

  @override
  String get lootAmount2For23 => '2 สำหรับ 2-3 ผู้เล่น';

  @override
  String cmdActivateMonster(String name) {
    return 'เปิดใช้งาน $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return 'ปิดใช้งาน $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return 'เพิ่ม $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return 'เพิ่มสถานะ: $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return 'นำสถานะออก: $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character เพิ่มการ์ดกลุ่ม $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character นำการ์ดกลุ่มออก';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character เพิ่มการ์ดฝ่าย';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character นำการ์ดฝ่ายออก';
  }

  @override
  String cmdAddLootCard(String type) {
    return 'เพิ่มการ์ดการปล้นสะดม $type';
  }

  @override
  String cmdAddMonster(String name) {
    return 'เพิ่ม $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return 'เพิ่มการ์ดการปล้นสะดมพิเศษ $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return 'นำการ์ดการปล้นสะดมพิเศษ $nr ออก';
  }

  @override
  String get cmdAddMinusOne => 'เพิ่มลบหนึ่ง';

  @override
  String get cmdRemoveMinusOne => 'นำลบหนึ่งออก';

  @override
  String get cmdRemoveMinusTwo => 'นำลบสองออก';

  @override
  String get cmdAddBackMinusTwo => 'คืนลบสอง';

  @override
  String get cmdRemovePlusZero => 'นำบวกศูนย์ออก';

  @override
  String get cmdAddBackPlusZero => 'คืนบวกศูนย์';

  @override
  String cmdRevealModifierCards(int count) {
    return 'เปิดเผยการ์ดปรับแต่ง $count ใบ';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return 'ทิ้งการ์ดที่เปิดเผยไว้บนสำรับ $deck';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return 'ปิดพิเศษแคสแซนดราสำหรับสำรับ $deck';
  }

  @override
  String get cmdImbueMonsterDeck => 'ซึมซับสำรับมอนสเตอร์';

  @override
  String get cmdAdvancedImbueMonsterDeck => 'การซึมซับขั้นสูงของสำรับมอนสเตอร์';

  @override
  String get cmdRemoveImbueMonsterDeck => 'นำการซึมซับออก';

  @override
  String get cmdChangeName => 'เปลี่ยนชื่อตัวละคร';

  @override
  String get cmdAddBless => 'เพิ่มพร';

  @override
  String get cmdRemoveBless => 'นำพรออก';

  @override
  String get cmdAddCurse => 'เพิ่มคำสาป';

  @override
  String get cmdRemoveCurse => 'นำคำสาปออก';

  @override
  String get cmdAddEmpower => 'เพิ่มการเสริมพลัง';

  @override
  String get cmdRemoveEmpower => 'นำการเสริมพลังออก';

  @override
  String get cmdAddEnfeeble => 'เพิ่มการอ่อนแอ';

  @override
  String get cmdRemoveEnfeeble => 'นำการอ่อนแอออก';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return 'เพิ่ม HP สูงสุดของ $owner';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return 'ลด HP สูงสุดของ $owner';
  }

  @override
  String get cmdChangeStat => 'เปลี่ยนสถิติ';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return 'เพิ่ม XP ของ $figure $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return 'ลด XP ของ $figure $amount';
  }

  @override
  String get cmdClearUnlockedClasses => 'ล้างคลาสที่ปลดล็อก';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character บริจาคให้ศาลเจ้า';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return 'นำการบริจาคของ $character ออก';
  }

  @override
  String get cmdDrawExtraAbilityCard => 'จั่วการ์ดความสามารถพิเศษ';

  @override
  String get cmdDraw => 'จั่ว';

  @override
  String get cmdDrawLootCard => 'จั่วการ์ดการปล้นสะดม';

  @override
  String cmdDrawModifierCard(String name) {
    return 'จั่วการ์ดปรับแต่ง $name';
  }

  @override
  String get cmdRemoveLootEnhancement => 'นำการเสริมการปล้นสะดมออก';

  @override
  String get cmdAddLootEnhancement => 'เพิ่มการเสริมการปล้นสะดม';

  @override
  String get cmdHideAllyDeck => 'ซ่อนสำรับพันธมิตร';

  @override
  String get cmdShowAllyDeck => 'แสดงสำรับพันธมิตร';

  @override
  String get cmdIceWraithTurnNormal => 'ผีน้ำแข็งเปลี่ยนเป็นธรรมดา';

  @override
  String get cmdIceWraithTurnElite => 'ผีน้ำแข็งเปลี่ยนเป็นชั้นยอด';

  @override
  String cmdImbueElement(String element) {
    return 'ซึมซับธาตุ $element';
  }

  @override
  String cmdUseElement(String element) {
    return 'ใช้ธาตุ $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return 'โหลดตัวละครที่บันทึกไว้: $name';
  }

  @override
  String cmdLoadGame(String name) {
    return 'โหลดเกมที่บันทึกไว้: $name';
  }

  @override
  String get cmdNextRound => 'รอบถัดไป';

  @override
  String get cmdRemoveAmdCard => 'นำการ์ด AMD ออก';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return 'นำการ์ด $deck หมายเลข $nr ออก';
  }

  @override
  String get cmdRemoveAllCharacters => 'นำตัวละครทั้งหมดออก';

  @override
  String cmdRemoveCharacter(String id) {
    return 'นำ $id ออก';
  }

  @override
  String get cmdRemoveAllMonsters => 'นำมอนสเตอร์ทั้งหมดออก';

  @override
  String cmdRemoveMonster(String name) {
    return 'นำ $name ออก';
  }

  @override
  String get cmdReorderAbilityCards => 'จัดเรียงการ์ดความสามารถใหม่';

  @override
  String get cmdReorderList => 'จัดเรียงรายการใหม่';

  @override
  String get cmdReorderModifierCards => 'จัดเรียงการ์ดปรับแต่งใหม่';

  @override
  String get cmdReturnLootCard => 'คืนการ์ดการปล้นสะดม';

  @override
  String get cmdReturnModifierCard => 'คืนการ์ดปรับแต่งขึ้นด้านบน';

  @override
  String get cmdReturnRemovedAmdCard => 'คืนการ์ด AMD ที่นำออก';

  @override
  String get cmdNoAllyDeckInOgGloom =>
      'ไม่มีสำรับพันธมิตรใน Gloomhaven ดั้งเดิม';

  @override
  String get cmdUseAllyDeckInOgGloom =>
      'ใช้สำรับพันธมิตรใน Gloomhaven ดั้งเดิม';

  @override
  String cmdMarkAsSummon(String owner) {
    return 'ทำเครื่องหมาย $owner เป็นสิ่งที่ถูกเรียก';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return 'นำเครื่องหมายการเรียกของ $owner ออก';
  }

  @override
  String get cmdAutoLevelOn => 'เปิดใช้งานการอัปเดตระดับอัตโนมัติ';

  @override
  String get cmdAutoLevelOff => 'ปิดใช้งานการอัปเดตระดับอัตโนมัติ';

  @override
  String cmdSetCampaign(String campaign) {
    return 'ตั้งค่าแคมเปญ $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return 'ตั้งค่าระดับ $character';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return 'ตั้งค่าความยาก $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return 'ตั้งค่าค่าริเริ่ม $character';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return 'ตั้งค่าระดับ $monster';
  }

  @override
  String get cmdSetLootOwner => 'ตั้งค่าเจ้าของการปล้นสะดม';

  @override
  String get cmdSetScenario => 'ตั้งค่าฉาก';

  @override
  String get cmdSetSoloOn => 'เปิดใช้งานคำแนะนำระดับโซโล';

  @override
  String get cmdSetSoloOff => 'ปิดใช้งานคำแนะนำระดับโซโล';

  @override
  String get cmdExtraAbilityShuffle => 'สับสำรับความสามารถพิเศษ';

  @override
  String get cmdExtraAmdShuffle => 'สับสำรับ AMD พิเศษ';

  @override
  String get cmdDrawnAbilityShuffle => 'สับสำรับความสามารถที่จั่ว';

  @override
  String get cmdDontTrackStandees => 'ไม่ติดตามตัวยืน';

  @override
  String get cmdTrackStandees => 'ติดตามตัวยืน';

  @override
  String cmdTurnDone(String id) {
    return 'เทิร์น $id เสร็จสิ้น';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return 'เพิ่มสิทธิพิเศษ $index ของ \'$character\'';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return 'นำสิทธิพิเศษ $index ของ \'$character\' ออก';
  }

  @override
  String cmdUnlock(String id) {
    return 'ปลดล็อก $id';
  }

  @override
  String cmdLock(String id) {
    return 'ล็อก $id';
  }

  @override
  String get cmdSetLevel => 'ตั้งค่าระดับ';

  @override
  String get cmdAddSection => 'เพิ่มส่วน';

  @override
  String cmdAddStandee(String name, int nr) {
    return 'เพิ่ม $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => 'จั่วการ์ดปรับแต่งมอนสเตอร์';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return 'เพิ่ม HP ของ $figure $amount';
  }

  @override
  String cmdKill(String owner) {
    return 'กำจัด $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return 'ลด HP ของ $owner $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character ใช้สิทธิพิเศษ Frosthaven';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character ไม่ใช้สิทธิพิเศษ Frosthaven';
  }

  @override
  String get cmdRemoveNoCharacters => 'ไม่ได้นำตัวละครออก';

  @override
  String get cmdRemoveNoMonsters => 'ไม่ได้นำมอนสเตอร์ออก';
}
