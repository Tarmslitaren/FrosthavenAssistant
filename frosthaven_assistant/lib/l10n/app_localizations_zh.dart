// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get menuSetScenario => '设置场景';

  @override
  String get menuAddCharacter => '添加角色';

  @override
  String get menuRemoveCharacters => '移除角色';

  @override
  String get menuSetLevel => '设置等级';

  @override
  String get menuLootDeck => '战利品牌堆菜单';

  @override
  String get menuAddMonsters => '添加怪物';

  @override
  String get menuRemoveMonsters => '移除怪物';

  @override
  String get menuShowAllyDeck => '显示盟友修改牌堆';

  @override
  String get menuHideAllyDeck => '隐藏盟友修改牌堆';

  @override
  String get menuSettings => '设置';

  @override
  String get menuDocumentation => '文档';

  @override
  String get menuDonate => '捐赠';

  @override
  String get menuExit => '退出';

  @override
  String get menuAddSection => '添加章节';

  @override
  String get menuAddRandomDungeonCard => '添加随机地下城卡牌';

  @override
  String get undo => '撤销';

  @override
  String undoWithDescription(String description) {
    return '撤销：$description';
  }

  @override
  String get redo => '重做';

  @override
  String redoWithDescription(String description) {
    return '重做：$description';
  }

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get connectedAsClient => '已作为客户端连接';

  @override
  String get connecting => '连接中…';

  @override
  String connectAsClientWithIp(String ip) {
    return '作为客户端连接（$ip）';
  }

  @override
  String get connectAsClientLabel => '作为客户端连接';

  @override
  String stopServerWithIp(String ip) {
    return '停止服务器 $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return '启动服务器 $ip';
  }

  @override
  String get stopServerButton => '停止服务器';

  @override
  String get startHostServerButton => '启动主机服务器';

  @override
  String get networkConnectLocal => '通过本地 Wi-Fi 连接设备：';

  @override
  String get networkServerIpHint => '服务器 IP 地址';

  @override
  String get networkPortHint => '端口';

  @override
  String get settingsLanguage => '语言：';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsSoftNumpad => '软数字键盘';

  @override
  String get settingsNoInit => '不询问先攻';

  @override
  String get settingsExpireConditions => '状态效果过期';

  @override
  String get settingsNoStandees => '不追踪立牌';

  @override
  String get settingsAutoAddStandees => '自动添加立牌';

  @override
  String get settingsAutoAddSpawns => '自动添加召唤物';

  @override
  String get settingsRandomStandees => '随机立牌';

  @override
  String get settingsNoCalculations => '无自动计算';

  @override
  String get settingsHideLootDeck => '隐藏战利品牌堆';

  @override
  String get settingsShimmer => '属性卡文字闪烁效果';

  @override
  String get settingsFhHazTerrainCalc => '原版Gloomhaven中使用Frosthaven危险地形计算';

  @override
  String get settingsAllyDeckOGGloom => '原版Gloomhaven中的盟友修改牌堆';

  @override
  String get settingsShowScenarioNames => '显示场景名称';

  @override
  String get settingsShowBattleGoalReminder => '显示战斗目标提醒';

  @override
  String get settingsShowCustomContent => '显示自定义内容';

  @override
  String get settingsShowSections => '在主界面显示章节';

  @override
  String get settingsShowReminders => '显示特殊规则提醒';

  @override
  String get settingsShowAmdDeck => '显示攻击修改牌堆';

  @override
  String get settingsShowCharacterAmd => '显示角色修改牌堆';

  @override
  String get settingsHealthWheel => '生命值滚轮：左右拖动更改';

  @override
  String get settingsFullscreen => '全屏';

  @override
  String get settingsMainListScaling => '主列表缩放：';

  @override
  String get settingsAppBarScaling => '应用栏缩放：';

  @override
  String get settingsStyleLabel => '风格：';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => '原版';

  @override
  String get settingsClearUnlocked => '清除已解锁角色和内容';

  @override
  String get settingsUnlockSpecials => '解锁特殊内容';

  @override
  String get settingsLoadSaveState => '加载/保存状态';

  @override
  String get noResultsFound => '无结果';

  @override
  String get close => '关闭';

  @override
  String get retry => '重试';

  @override
  String get specialUnlocks => '特殊解锁';

  @override
  String get loadSaveDeleteCharacters => '加载、保存或删除角色。';

  @override
  String get loadAddDeleteSaves => '加载、添加或删除存档。';

  @override
  String get addNewSave => '新存档';

  @override
  String get addNewSaveLabel => '新存档：';

  @override
  String get loadButton => '加载';

  @override
  String get saveButton => '保存';

  @override
  String get deleteButton => '删除';

  @override
  String get setSaveName => '存档名称：';

  @override
  String get loadOrSaveCharacters => '加载或保存角色';

  @override
  String get loadCharacter => '加载角色：';

  @override
  String get removeAll => '全部移除';

  @override
  String get removeCardQuestion => '移除卡牌？';

  @override
  String get sendToBottom => '发送到底部';

  @override
  String get shuffleUndrawnCards => '洗混未抽卡牌';

  @override
  String get returnToDiscardPile => '返回弃牌堆';

  @override
  String get returnToDrawPile => '返回牌堆';

  @override
  String get addExtraLootCard => '添加额外战利品卡牌';

  @override
  String get addStandeeNr => '添加立牌编号';

  @override
  String get summonedLabel => '已召唤：';

  @override
  String get characterDecks => '角色牌堆';

  @override
  String get shuffleAndDraw => '洗牌\n并抽牌';

  @override
  String get draw => '抽牌';

  @override
  String get nextRound => ' 下一回合';

  @override
  String get returnTopCard => '返回顶部卡牌';

  @override
  String removeCardWithDetails(String title, int nr) {
    return '移除 $title\n（卡牌编号：$nr）';
  }

  @override
  String get tapCardToAddToDeck => '点击卡牌添加到牌堆';

  @override
  String get removeCardFromDeckQuestion => '从牌堆移除卡牌？';

  @override
  String get changeName => '更改名称：';

  @override
  String get showBosses => '显示首领';

  @override
  String get showScenarioSpecialMonsters => '显示场景特殊怪物';

  @override
  String get addAsAlly => '添加为盟友';

  @override
  String get addMonsterLabel => '添加怪物';

  @override
  String get allCampaigns => '所有战役';

  @override
  String get showMonstersFrom => '      显示怪物来自：   ';

  @override
  String setMonsterLevel(String name) {
    return '$name 等级';
  }

  @override
  String setSummonHealth(String name) {
    return '$name 最大生命值';
  }

  @override
  String get setScenarioLevel => '场景等级';

  @override
  String enhancedLevel(String level) {
    return '已强化：$level';
  }

  @override
  String get soloLabel => '单人：';

  @override
  String get automaticScenarioLevel => '自动场景等级：';

  @override
  String get difficultyLabel => '难度：';

  @override
  String get lootCardEnhancements => '战利品卡牌强化';

  @override
  String get addPerks => '添加特权';

  @override
  String get useFrosthavenPerks => '使用Frosthaven特权';

  @override
  String currentCampaign(String campaign) {
    return '当前战役：$campaign';
  }

  @override
  String get addCharacterHint => '添加角色（输入名称以查看隐藏职业）';

  @override
  String get trapDamage => '陷阱伤害';

  @override
  String get hazardousTerrainDamage => '危险地形伤害';

  @override
  String get experienceAdded => '已添加经验值';

  @override
  String get goldCoinValue => '金币价值';

  @override
  String get levelLegendLabel => '等级';

  @override
  String get saveStateNote => '应用在每次操作后自动保存。这些存档用于备份或多个战役。';

  @override
  String clientConnectedTo(String address) {
    return '客户端已连接至：$address';
  }

  @override
  String clientError(String error) {
    return '客户端错误：$error';
  }

  @override
  String clientListenError(String error) {
    return '客户端监听错误：$error';
  }

  @override
  String get lostConnectionToServer => '已失去与服务器的连接';

  @override
  String get stateMismatch => '您的状态不是最新的，请重试。';

  @override
  String get serverUnresponsive => '服务器无响应。客户端已断开。';

  @override
  String get clientDisconnected => '客户端已断开';

  @override
  String get serverOffline => '服务器离线';

  @override
  String get clientLeft => '客户端已离开。';

  @override
  String get clientTooOld => '旧版客户端尝试连接。请更新应用。';

  @override
  String networkConnection(String status) {
    return '网络连接：$status';
  }

  @override
  String get failedToGetWifiIp => '无法获取IP地址';

  @override
  String get badOmen => '凶兆';

  @override
  String badOmensLeft(int count) {
    return '剩余凶兆：$count';
  }

  @override
  String get corrosiveSpew => '腐蚀喷射';

  @override
  String get empowersOnTop => '强化卡在顶部';

  @override
  String addMinusOneCard(int count) {
    return '添加-1卡牌（已添加：$count）';
  }

  @override
  String get removeMinusOneCard => '移除-1卡牌';

  @override
  String get removeMinusTwoCard => '移除-2卡牌';

  @override
  String get minusTwoCardRemoved => '-2卡牌已移除';

  @override
  String get removePlusZeroCard => '移除+0卡牌';

  @override
  String get plusZeroCardRemoved => '+0卡牌已移除';

  @override
  String get removeImbue => '移除注魔';

  @override
  String get imbue => '注魔';

  @override
  String get advancedImbue => '高级注魔';

  @override
  String get removeHailPerk => '移除冰雹特权';

  @override
  String get addHailPerk => '添加冰雹特权';

  @override
  String get removeCassandraPerk => '移除\n卡桑德拉特权';

  @override
  String get addCassandraPerk => '添加\n卡桑德拉特权';

  @override
  String get dontSaveRevealedCards => '不保留\n已揭示卡牌';

  @override
  String get saveRevealedCards => '保留\n已揭示卡牌';

  @override
  String removedCountLabel(int count) {
    return '已移除：$count';
  }

  @override
  String get removeDonation => '移除\n捐赠';

  @override
  String get donateSanctuary => '捐赠给\n圣所';

  @override
  String get removePartyCard => '移除\n队伍卡牌：';

  @override
  String get addPartyCard => '添加\n队伍卡牌：';

  @override
  String get perks => '特权';

  @override
  String get revealCards => '揭示\n卡牌：';

  @override
  String get revealAll => '全部';

  @override
  String get drawExtraCard => '抽取额外卡牌';

  @override
  String get extraShuffle => '额外洗牌';

  @override
  String get inactivateMonster => '停用\n怪物';

  @override
  String get activateMonster => '激活\n怪物';

  @override
  String addEliteStandees(int count, String name) {
    return '添加 $count 个精英 $name';
  }

  @override
  String addNormalStandees(int count, String name) {
    return '添加 $count 个普通 $name';
  }

  @override
  String get characterLoot => '角色战利品';

  @override
  String addSpecialCard(int nr) {
    return '添加 $nr 号卡牌';
  }

  @override
  String removeSpecialCard(int nr) {
    return '移除 $nr 号卡牌';
  }

  @override
  String get enhanceCards => '强化卡牌';

  @override
  String get addLootCard => '添加卡牌';

  @override
  String get returnToTop => '返回顶部';

  @override
  String get returnToBottom => '返回底部';

  @override
  String characterLootTitle(String name) {
    return '$name 的战利品：';
  }

  @override
  String get setLootOwner => '战利品所有者：';

  @override
  String get lootNameCoin => '金币';

  @override
  String get lootNameHide => '皮革';

  @override
  String get lootNameLumber => '木材';

  @override
  String get lootNameMetal => '金属';

  @override
  String get lootNameArrowvine => '箭藤';

  @override
  String get lootNameAxenut => '斧坚果';

  @override
  String get lootNameCorpsecap => '尸盖菇';

  @override
  String get lootNameFlamefruit => '火焰果';

  @override
  String get lootNameRockroot => '岩根';

  @override
  String get lootNameSnowthistle => '雪蓟';

  @override
  String get lootAmount2For2 => '2人游戏2个';

  @override
  String get lootAmount2For23 => '2-3人游戏2个';

  @override
  String cmdActivateMonster(String name) {
    return '激活 $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return '停用 $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return '添加 $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return '添加状态：$condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return '移除状态：$condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character 添加队伍卡牌 $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character 移除队伍卡牌';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character 添加派系卡牌';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character 移除派系卡牌';
  }

  @override
  String cmdAddLootCard(String type) {
    return '添加战利品卡牌 $type';
  }

  @override
  String cmdAddMonster(String name) {
    return '添加 $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return '添加特殊战利品卡牌 $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return '移除特殊战利品卡牌 $nr';
  }

  @override
  String get cmdAddMinusOne => '添加负一';

  @override
  String get cmdRemoveMinusOne => '移除负一';

  @override
  String get cmdRemoveMinusTwo => '移除负二';

  @override
  String get cmdAddBackMinusTwo => '归还负二';

  @override
  String get cmdRemovePlusZero => '移除正零';

  @override
  String get cmdAddBackPlusZero => '归还正零';

  @override
  String cmdRevealModifierCards(int count) {
    return '揭示 $count 张修改卡牌';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return '在 $deck 牌堆顶保留已揭示卡牌';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return '$deck 牌堆的卡桑德拉特殊效果已关闭';
  }

  @override
  String get cmdImbueMonsterDeck => '注魔怪物牌堆';

  @override
  String get cmdAdvancedImbueMonsterDeck => '高级注魔怪物牌堆';

  @override
  String get cmdRemoveImbueMonsterDeck => '移除注魔';

  @override
  String get cmdChangeName => '更改角色名称';

  @override
  String get cmdAddBless => '添加祝福';

  @override
  String get cmdRemoveBless => '移除祝福';

  @override
  String get cmdAddCurse => '添加诅咒';

  @override
  String get cmdRemoveCurse => '移除诅咒';

  @override
  String get cmdAddEmpower => '添加强化';

  @override
  String get cmdRemoveEmpower => '移除强化';

  @override
  String get cmdAddEnfeeble => '添加削弱';

  @override
  String get cmdRemoveEnfeeble => '移除削弱';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return '增加 $owner 最大生命值';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return '减少 $owner 最大生命值';
  }

  @override
  String get cmdChangeStat => '修改属性';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return '增加 $figure 经验值 $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return '减少 $figure 经验值 $amount';
  }

  @override
  String get cmdClearUnlockedClasses => '清除已解锁职业';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character 向圣所捐赠';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return '移除 $character 的捐赠';
  }

  @override
  String get cmdDrawExtraAbilityCard => '抽取额外技能卡牌';

  @override
  String get cmdDraw => '抽牌';

  @override
  String get cmdDrawLootCard => '抽取战利品卡牌';

  @override
  String cmdDrawModifierCard(String name) {
    return '抽取 $name 修改卡牌';
  }

  @override
  String get cmdRemoveLootEnhancement => '移除战利品强化';

  @override
  String get cmdAddLootEnhancement => '添加战利品强化';

  @override
  String get cmdHideAllyDeck => '隐藏盟友牌堆';

  @override
  String get cmdShowAllyDeck => '显示盟友牌堆';

  @override
  String get cmdIceWraithTurnNormal => '冰幽灵转为普通';

  @override
  String get cmdIceWraithTurnElite => '冰幽灵转为精英';

  @override
  String cmdImbueElement(String element) {
    return '注魔元素 $element';
  }

  @override
  String cmdUseElement(String element) {
    return '使用元素 $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return '加载已保存角色：$name';
  }

  @override
  String cmdLoadGame(String name) {
    return '加载已保存游戏：$name';
  }

  @override
  String get cmdNextRound => '下一回合';

  @override
  String get cmdRemoveAmdCard => '移除AMD卡牌';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return '移除 $deck $nr 号卡牌';
  }

  @override
  String get cmdRemoveAllCharacters => '移除所有角色';

  @override
  String cmdRemoveCharacter(String id) {
    return '移除 $id';
  }

  @override
  String get cmdRemoveAllMonsters => '移除所有怪物';

  @override
  String cmdRemoveMonster(String name) {
    return '移除 $name';
  }

  @override
  String get cmdReorderAbilityCards => '重新排列技能卡牌';

  @override
  String get cmdReorderList => '重新排列列表';

  @override
  String get cmdReorderModifierCards => '重新排列修改卡牌';

  @override
  String get cmdReturnLootCard => '归还战利品卡牌';

  @override
  String get cmdReturnModifierCard => '将修改卡牌归还到顶部';

  @override
  String get cmdReturnRemovedAmdCard => '归还已移除AMD卡牌';

  @override
  String get cmdNoAllyDeckInOgGloom => '原版Gloomhaven无盟友牌堆';

  @override
  String get cmdUseAllyDeckInOgGloom => '在原版Gloomhaven中使用盟友牌堆';

  @override
  String cmdMarkAsSummon(String owner) {
    return '将 $owner 标记为召唤物';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return '移除 $owner 的召唤标记';
  }

  @override
  String get cmdAutoLevelOn => '启用自动等级更新';

  @override
  String get cmdAutoLevelOff => '禁用自动等级更新';

  @override
  String cmdSetCampaign(String campaign) {
    return '设置战役 $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return '设置 $character 等级';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return '设置难度为 $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return '设置 $character 先攻';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return '设置 $monster 等级';
  }

  @override
  String get cmdSetLootOwner => '设置战利品所有者';

  @override
  String get cmdSetScenario => '设置场景';

  @override
  String get cmdSetSoloOn => '启用单人等级推荐';

  @override
  String get cmdSetSoloOff => '禁用单人等级推荐';

  @override
  String get cmdExtraAbilityShuffle => '额外洗技能牌堆';

  @override
  String get cmdExtraAmdShuffle => '额外洗AMD牌堆';

  @override
  String get cmdDrawnAbilityShuffle => '洗已抽技能牌堆';

  @override
  String get cmdDontTrackStandees => '不追踪立牌';

  @override
  String get cmdTrackStandees => '追踪立牌';

  @override
  String cmdTurnDone(String id) {
    return '$id 回合结束';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return '添加 \'$character\' 的第 $index 个特权';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return '移除 \'$character\' 的第 $index 个特权';
  }

  @override
  String cmdUnlock(String id) {
    return '解锁 $id';
  }

  @override
  String cmdLock(String id) {
    return '锁定 $id';
  }

  @override
  String get cmdSetLevel => '设置等级';

  @override
  String get cmdAddSection => '添加章节';

  @override
  String cmdAddStandee(String name, int nr) {
    return '添加 $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => '抽取怪物修改卡牌';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return '增加 $figure 生命值 $amount';
  }

  @override
  String cmdKill(String owner) {
    return '消灭 $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return '减少 $owner 生命值 $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character 使用Frosthaven特权';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character 不使用Frosthaven特权';
  }

  @override
  String get cmdRemoveNoCharacters => '未移除任何角色';

  @override
  String get cmdRemoveNoMonsters => '未移除任何怪物';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get menuSetScenario => '設定場景';

  @override
  String get menuAddCharacter => '新增角色';

  @override
  String get menuRemoveCharacters => '移除角色';

  @override
  String get menuSetLevel => '設定等級';

  @override
  String get menuLootDeck => '戰利品牌堆選單';

  @override
  String get menuAddMonsters => '新增怪物';

  @override
  String get menuRemoveMonsters => '移除怪物';

  @override
  String get menuShowAllyDeck => '顯示盟友修改牌堆';

  @override
  String get menuHideAllyDeck => '隱藏盟友修改牌堆';

  @override
  String get menuSettings => '設定';

  @override
  String get menuDocumentation => '說明文件';

  @override
  String get menuDonate => '捐贈';

  @override
  String get menuExit => '退出';

  @override
  String get menuAddSection => '新增章節';

  @override
  String get menuAddRandomDungeonCard => '新增隨機地下城卡牌';

  @override
  String get undo => '撤銷';

  @override
  String undoWithDescription(String description) {
    return '撤銷：$description';
  }

  @override
  String get redo => '重做';

  @override
  String redoWithDescription(String description) {
    return '重做：$description';
  }

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get connectedAsClient => '已作為客戶端連線';

  @override
  String get connecting => '連線中…';

  @override
  String connectAsClientWithIp(String ip) {
    return '作為客戶端連線（$ip）';
  }

  @override
  String get connectAsClientLabel => '作為客戶端連線';

  @override
  String stopServerWithIp(String ip) {
    return '停止伺服器 $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return '啟動伺服器 $ip';
  }

  @override
  String get stopServerButton => '停止伺服器';

  @override
  String get startHostServerButton => '啟動主機伺服器';

  @override
  String get networkConnectLocal => '透過本地 Wi-Fi 連接裝置：';

  @override
  String get networkServerIpHint => '伺服器 IP 位址';

  @override
  String get networkPortHint => '連接埠';

  @override
  String get settingsLanguage => '語言：';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsSoftNumpad => '軟體數字鍵盤';

  @override
  String get settingsNoInit => '不詢問先攻';

  @override
  String get settingsExpireConditions => '狀態效果到期';

  @override
  String get settingsNoStandees => '不追蹤立牌';

  @override
  String get settingsAutoAddStandees => '自動新增立牌';

  @override
  String get settingsAutoAddSpawns => '自動新增召喚物';

  @override
  String get settingsRandomStandees => '隨機立牌';

  @override
  String get settingsNoCalculations => '無自動計算';

  @override
  String get settingsHideLootDeck => '隱藏戰利品牌堆';

  @override
  String get settingsShimmer => '屬性卡文字閃爍效果';

  @override
  String get settingsFhHazTerrainCalc => '原版Gloomhaven中使用Frosthaven危險地形計算';

  @override
  String get settingsAllyDeckOGGloom => '原版Gloomhaven中的盟友修改牌堆';

  @override
  String get settingsShowScenarioNames => '顯示場景名稱';

  @override
  String get settingsShowBattleGoalReminder => '顯示戰鬥目標提醒';

  @override
  String get settingsShowCustomContent => '顯示自訂內容';

  @override
  String get settingsShowSections => '在主介面顯示章節';

  @override
  String get settingsShowReminders => '顯示特殊規則提醒';

  @override
  String get settingsShowAmdDeck => '顯示攻擊修改牌堆';

  @override
  String get settingsShowCharacterAmd => '顯示角色修改牌堆';

  @override
  String get settingsHealthWheel => '生命值滾輪：左右拖動更改';

  @override
  String get settingsFullscreen => '全螢幕';

  @override
  String get settingsMainListScaling => '主清單縮放：';

  @override
  String get settingsAppBarScaling => '應用程式列縮放：';

  @override
  String get settingsStyleLabel => '風格：';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => '原版';

  @override
  String get settingsClearUnlocked => '清除已解鎖角色和內容';

  @override
  String get settingsUnlockSpecials => '解鎖特殊內容';

  @override
  String get settingsLoadSaveState => '載入/儲存狀態';

  @override
  String get noResultsFound => '無結果';

  @override
  String get close => '關閉';

  @override
  String get retry => '重試';

  @override
  String get specialUnlocks => '特殊解鎖';

  @override
  String get loadSaveDeleteCharacters => '載入、儲存或刪除角色。';

  @override
  String get loadAddDeleteSaves => '載入、新增或刪除存檔。';

  @override
  String get addNewSave => '新存檔';

  @override
  String get addNewSaveLabel => '新存檔：';

  @override
  String get loadButton => '載入';

  @override
  String get saveButton => '儲存';

  @override
  String get deleteButton => '刪除';

  @override
  String get setSaveName => '存檔名稱：';

  @override
  String get loadOrSaveCharacters => '載入或儲存角色';

  @override
  String get loadCharacter => '載入角色：';

  @override
  String get removeAll => '全部移除';

  @override
  String get removeCardQuestion => '移除卡牌？';

  @override
  String get sendToBottom => '傳送到底部';

  @override
  String get shuffleUndrawnCards => '洗混未抽卡牌';

  @override
  String get returnToDiscardPile => '返回棄牌堆';

  @override
  String get returnToDrawPile => '返回牌堆';

  @override
  String get addExtraLootCard => '新增額外戰利品卡牌';

  @override
  String get addStandeeNr => '新增立牌編號';

  @override
  String get summonedLabel => '已召喚：';

  @override
  String get characterDecks => '角色牌堆';

  @override
  String get shuffleAndDraw => '洗牌\n並抽牌';

  @override
  String get draw => '抽牌';

  @override
  String get nextRound => ' 下一回合';

  @override
  String get returnTopCard => '返回頂部卡牌';

  @override
  String removeCardWithDetails(String title, int nr) {
    return '移除 $title\n（卡牌編號：$nr）';
  }

  @override
  String get tapCardToAddToDeck => '點擊卡牌新增到牌堆';

  @override
  String get removeCardFromDeckQuestion => '從牌堆移除卡牌？';

  @override
  String get changeName => '更改名稱：';

  @override
  String get showBosses => '顯示首領';

  @override
  String get showScenarioSpecialMonsters => '顯示場景特殊怪物';

  @override
  String get addAsAlly => '新增為盟友';

  @override
  String get addMonsterLabel => '新增怪物';

  @override
  String get allCampaigns => '所有戰役';

  @override
  String get showMonstersFrom => '      顯示怪物來自：   ';

  @override
  String setMonsterLevel(String name) {
    return '$name 等級';
  }

  @override
  String setSummonHealth(String name) {
    return '$name 最大生命值';
  }

  @override
  String get setScenarioLevel => '場景等級';

  @override
  String enhancedLevel(String level) {
    return '已強化：$level';
  }

  @override
  String get soloLabel => '單人：';

  @override
  String get automaticScenarioLevel => '自動場景等級：';

  @override
  String get difficultyLabel => '難度：';

  @override
  String get lootCardEnhancements => '戰利品卡牌強化';

  @override
  String get addPerks => '新增特權';

  @override
  String get useFrosthavenPerks => '使用Frosthaven特權';

  @override
  String currentCampaign(String campaign) {
    return '目前戰役：$campaign';
  }

  @override
  String get addCharacterHint => '新增角色（輸入名稱以查看隱藏職業）';

  @override
  String get trapDamage => '陷阱傷害';

  @override
  String get hazardousTerrainDamage => '危險地形傷害';

  @override
  String get experienceAdded => '已新增經驗值';

  @override
  String get goldCoinValue => '金幣價值';

  @override
  String get levelLegendLabel => '等級';

  @override
  String get saveStateNote => '應用程式在每次操作後自動儲存。這些存檔用於備份或多個戰役。';

  @override
  String clientConnectedTo(String address) {
    return '客戶端已連線至：$address';
  }

  @override
  String clientError(String error) {
    return '客戶端錯誤：$error';
  }

  @override
  String clientListenError(String error) {
    return '客戶端監聽錯誤：$error';
  }

  @override
  String get lostConnectionToServer => '已失去與伺服器的連線';

  @override
  String get stateMismatch => '您的狀態不是最新的，請重試。';

  @override
  String get serverUnresponsive => '伺服器無回應。客戶端已中斷連線。';

  @override
  String get clientDisconnected => '客戶端已中斷連線';

  @override
  String get serverOffline => '伺服器離線';

  @override
  String get clientLeft => '客戶端已離開。';

  @override
  String get clientTooOld => '舊版客戶端嘗試連線。請更新應用程式。';

  @override
  String networkConnection(String status) {
    return '網路連線：$status';
  }

  @override
  String get failedToGetWifiIp => '無法取得IP位址';

  @override
  String get badOmen => '凶兆';

  @override
  String badOmensLeft(int count) {
    return '剩餘凶兆：$count';
  }

  @override
  String get corrosiveSpew => '腐蝕噴射';

  @override
  String get empowersOnTop => '強化卡在頂部';

  @override
  String addMinusOneCard(int count) {
    return '新增-1卡牌（已新增：$count）';
  }

  @override
  String get removeMinusOneCard => '移除-1卡牌';

  @override
  String get removeMinusTwoCard => '移除-2卡牌';

  @override
  String get minusTwoCardRemoved => '-2卡牌已移除';

  @override
  String get removePlusZeroCard => '移除+0卡牌';

  @override
  String get plusZeroCardRemoved => '+0卡牌已移除';

  @override
  String get removeImbue => '移除注魔';

  @override
  String get imbue => '注魔';

  @override
  String get advancedImbue => '高級注魔';

  @override
  String get removeHailPerk => '移除冰雹特權';

  @override
  String get addHailPerk => '新增冰雹特權';

  @override
  String get removeCassandraPerk => '移除\n卡珊卓特權';

  @override
  String get addCassandraPerk => '新增\n卡珊卓特權';

  @override
  String get dontSaveRevealedCards => '不保留\n已揭示卡牌';

  @override
  String get saveRevealedCards => '保留\n已揭示卡牌';

  @override
  String removedCountLabel(int count) {
    return '已移除：$count';
  }

  @override
  String get removeDonation => '移除\n捐贈';

  @override
  String get donateSanctuary => '捐贈給\n聖所';

  @override
  String get removePartyCard => '移除\n隊伍卡牌：';

  @override
  String get addPartyCard => '新增\n隊伍卡牌：';

  @override
  String get perks => '特權';

  @override
  String get revealCards => '揭示\n卡牌：';

  @override
  String get revealAll => '全部';

  @override
  String get drawExtraCard => '抽取額外卡牌';

  @override
  String get extraShuffle => '額外洗牌';

  @override
  String get inactivateMonster => '停用\n怪物';

  @override
  String get activateMonster => '啟動\n怪物';

  @override
  String addEliteStandees(int count, String name) {
    return '新增 $count 個精英 $name';
  }

  @override
  String addNormalStandees(int count, String name) {
    return '新增 $count 個普通 $name';
  }

  @override
  String get characterLoot => '角色戰利品';

  @override
  String addSpecialCard(int nr) {
    return '新增 $nr 號卡牌';
  }

  @override
  String removeSpecialCard(int nr) {
    return '移除 $nr 號卡牌';
  }

  @override
  String get enhanceCards => '強化卡牌';

  @override
  String get addLootCard => '新增卡牌';

  @override
  String get returnToTop => '返回頂部';

  @override
  String get returnToBottom => '返回底部';

  @override
  String characterLootTitle(String name) {
    return '$name 的戰利品：';
  }

  @override
  String get setLootOwner => '戰利品所有者：';

  @override
  String get lootNameCoin => '金幣';

  @override
  String get lootNameHide => '皮革';

  @override
  String get lootNameLumber => '木材';

  @override
  String get lootNameMetal => '金屬';

  @override
  String get lootNameArrowvine => '箭藤';

  @override
  String get lootNameAxenut => '斧堅果';

  @override
  String get lootNameCorpsecap => '屍蓋菇';

  @override
  String get lootNameFlamefruit => '火焰果';

  @override
  String get lootNameRockroot => '岩根';

  @override
  String get lootNameSnowthistle => '雪薊';

  @override
  String get lootAmount2For2 => '2人遊戲2個';

  @override
  String get lootAmount2For23 => '2-3人遊戲2個';

  @override
  String cmdActivateMonster(String name) {
    return '啟動 $name';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return '停用 $name';
  }

  @override
  String cmdAddCharacter(String id) {
    return '新增 $id';
  }

  @override
  String cmdAddCondition(String condition) {
    return '新增狀態：$condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return '移除狀態：$condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character 新增隊伍卡牌 $type';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character 移除隊伍卡牌';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character 新增派系卡牌';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character 移除派系卡牌';
  }

  @override
  String cmdAddLootCard(String type) {
    return '新增戰利品卡牌 $type';
  }

  @override
  String cmdAddMonster(String name) {
    return '新增 $name';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return '新增特殊戰利品卡牌 $nr';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return '移除特殊戰利品卡牌 $nr';
  }

  @override
  String get cmdAddMinusOne => '新增負一';

  @override
  String get cmdRemoveMinusOne => '移除負一';

  @override
  String get cmdRemoveMinusTwo => '移除負二';

  @override
  String get cmdAddBackMinusTwo => '歸還負二';

  @override
  String get cmdRemovePlusZero => '移除正零';

  @override
  String get cmdAddBackPlusZero => '歸還正零';

  @override
  String cmdRevealModifierCards(int count) {
    return '揭示 $count 張修改卡牌';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return '在 $deck 牌堆頂保留已揭示卡牌';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return '$deck 牌堆的卡珊卓特殊效果已關閉';
  }

  @override
  String get cmdImbueMonsterDeck => '注魔怪物牌堆';

  @override
  String get cmdAdvancedImbueMonsterDeck => '高級注魔怪物牌堆';

  @override
  String get cmdRemoveImbueMonsterDeck => '移除注魔';

  @override
  String get cmdChangeName => '更改角色名稱';

  @override
  String get cmdAddBless => '新增祝福';

  @override
  String get cmdRemoveBless => '移除祝福';

  @override
  String get cmdAddCurse => '新增詛咒';

  @override
  String get cmdRemoveCurse => '移除詛咒';

  @override
  String get cmdAddEmpower => '新增強化';

  @override
  String get cmdRemoveEmpower => '移除強化';

  @override
  String get cmdAddEnfeeble => '新增削弱';

  @override
  String get cmdRemoveEnfeeble => '移除削弱';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return '增加 $owner 最大生命值';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return '減少 $owner 最大生命值';
  }

  @override
  String get cmdChangeStat => '修改屬性';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return '增加 $figure 經驗值 $amount';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return '減少 $figure 經驗值 $amount';
  }

  @override
  String get cmdClearUnlockedClasses => '清除已解鎖職業';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character 向聖所捐贈';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return '移除 $character 的捐贈';
  }

  @override
  String get cmdDrawExtraAbilityCard => '抽取額外技能卡牌';

  @override
  String get cmdDraw => '抽牌';

  @override
  String get cmdDrawLootCard => '抽取戰利品卡牌';

  @override
  String cmdDrawModifierCard(String name) {
    return '抽取 $name 修改卡牌';
  }

  @override
  String get cmdRemoveLootEnhancement => '移除戰利品強化';

  @override
  String get cmdAddLootEnhancement => '新增戰利品強化';

  @override
  String get cmdHideAllyDeck => '隱藏盟友牌堆';

  @override
  String get cmdShowAllyDeck => '顯示盟友牌堆';

  @override
  String get cmdIceWraithTurnNormal => '冰幽靈轉為普通';

  @override
  String get cmdIceWraithTurnElite => '冰幽靈轉為精英';

  @override
  String cmdImbueElement(String element) {
    return '注魔元素 $element';
  }

  @override
  String cmdUseElement(String element) {
    return '使用元素 $element';
  }

  @override
  String cmdLoadCharacter(String name) {
    return '載入已儲存角色：$name';
  }

  @override
  String cmdLoadGame(String name) {
    return '載入已儲存遊戲：$name';
  }

  @override
  String get cmdNextRound => '下一回合';

  @override
  String get cmdRemoveAmdCard => '移除AMD卡牌';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return '移除 $deck $nr 號卡牌';
  }

  @override
  String get cmdRemoveAllCharacters => '移除所有角色';

  @override
  String cmdRemoveCharacter(String id) {
    return '移除 $id';
  }

  @override
  String get cmdRemoveAllMonsters => '移除所有怪物';

  @override
  String cmdRemoveMonster(String name) {
    return '移除 $name';
  }

  @override
  String get cmdReorderAbilityCards => '重新排列技能卡牌';

  @override
  String get cmdReorderList => '重新排列清單';

  @override
  String get cmdReorderModifierCards => '重新排列修改卡牌';

  @override
  String get cmdReturnLootCard => '歸還戰利品卡牌';

  @override
  String get cmdReturnModifierCard => '將修改卡牌歸還到頂部';

  @override
  String get cmdReturnRemovedAmdCard => '歸還已移除AMD卡牌';

  @override
  String get cmdNoAllyDeckInOgGloom => '原版Gloomhaven無盟友牌堆';

  @override
  String get cmdUseAllyDeckInOgGloom => '在原版Gloomhaven中使用盟友牌堆';

  @override
  String cmdMarkAsSummon(String owner) {
    return '將 $owner 標記為召喚物';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return '移除 $owner 的召喚標記';
  }

  @override
  String get cmdAutoLevelOn => '啟用自動等級更新';

  @override
  String get cmdAutoLevelOff => '停用自動等級更新';

  @override
  String cmdSetCampaign(String campaign) {
    return '設定戰役 $campaign';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return '設定 $character 等級';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return '設定難度為 $difficulty';
  }

  @override
  String cmdSetInitiative(String character) {
    return '設定 $character 先攻';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return '設定 $monster 等級';
  }

  @override
  String get cmdSetLootOwner => '設定戰利品所有者';

  @override
  String get cmdSetScenario => '設定場景';

  @override
  String get cmdSetSoloOn => '啟用單人等級推薦';

  @override
  String get cmdSetSoloOff => '停用單人等級推薦';

  @override
  String get cmdExtraAbilityShuffle => '額外洗技能牌堆';

  @override
  String get cmdExtraAmdShuffle => '額外洗AMD牌堆';

  @override
  String get cmdDrawnAbilityShuffle => '洗已抽技能牌堆';

  @override
  String get cmdDontTrackStandees => '不追蹤立牌';

  @override
  String get cmdTrackStandees => '追蹤立牌';

  @override
  String cmdTurnDone(String id) {
    return '$id 回合結束';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return '新增 \'$character\' 的第 $index 個特權';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return '移除 \'$character\' 的第 $index 個特權';
  }

  @override
  String cmdUnlock(String id) {
    return '解鎖 $id';
  }

  @override
  String cmdLock(String id) {
    return '鎖定 $id';
  }

  @override
  String get cmdSetLevel => '設定等級';

  @override
  String get cmdAddSection => '新增章節';

  @override
  String cmdAddStandee(String name, int nr) {
    return '新增 $name $nr';
  }

  @override
  String get cmdDrawMonsterModifierCard => '抽取怪物修改卡牌';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return '增加 $figure 生命值 $amount';
  }

  @override
  String cmdKill(String owner) {
    return '消滅 $owner';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return '減少 $owner 生命值 $amount';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character 使用Frosthaven特權';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character 不使用Frosthaven特權';
  }

  @override
  String get cmdRemoveNoCharacters => '未移除任何角色';

  @override
  String get cmdRemoveNoMonsters => '未移除任何怪物';
}
