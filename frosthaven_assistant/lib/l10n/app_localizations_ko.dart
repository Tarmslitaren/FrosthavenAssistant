// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get menuSetScenario => '시나리오 설정';

  @override
  String get menuAddCharacter => '캐릭터 추가';

  @override
  String get menuRemoveCharacters => '캐릭터 제거';

  @override
  String get menuSetLevel => '레벨 설정';

  @override
  String get menuLootDeck => '전리품 덱 메뉴';

  @override
  String get menuAddMonsters => '몬스터 추가';

  @override
  String get menuRemoveMonsters => '몬스터 제거';

  @override
  String get menuShowAllyDeck => '동맹 수정 덱 표시';

  @override
  String get menuHideAllyDeck => '동맹 수정 덱 숨기기';

  @override
  String get menuSettings => '설정';

  @override
  String get menuDocumentation => '도움말';

  @override
  String get menuDonate => '기부';

  @override
  String get menuExit => '종료';

  @override
  String get menuAddSection => '섹션 추가';

  @override
  String get menuAddRandomDungeonCard => '무작위 던전 카드 추가';

  @override
  String get undo => '실행 취소';

  @override
  String undoWithDescription(String description) {
    return '실행 취소: $description';
  }

  @override
  String get redo => '다시 실행';

  @override
  String redoWithDescription(String description) {
    return '다시 실행: $description';
  }

  @override
  String versionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get connectedAsClient => '클라이언트로 연결됨';

  @override
  String get connecting => '연결 중…';

  @override
  String connectAsClientWithIp(String ip) {
    return '클라이언트로 연결 ($ip)';
  }

  @override
  String get connectAsClientLabel => '클라이언트로 연결';

  @override
  String stopServerWithIp(String ip) {
    return '서버 중지 $ip';
  }

  @override
  String startHostServerWithIp(String ip) {
    return '서버 시작 $ip';
  }

  @override
  String get stopServerButton => '서버 중지';

  @override
  String get startHostServerButton => '호스트 서버 시작';

  @override
  String get networkConnectLocal => '로컬 Wi-Fi로 기기 연결:';

  @override
  String get networkServerIpHint => '서버 IP 주소';

  @override
  String get networkPortHint => '포트';

  @override
  String get settingsLanguage => '언어:';

  @override
  String get settingsDarkMode => '다크 모드';

  @override
  String get settingsSoftNumpad => '소프트 숫자 키패드';

  @override
  String get settingsNoInit => '선제권 묻지 않기';

  @override
  String get settingsExpireConditions => '상태 이상 만료';

  @override
  String get settingsNoStandees => '스탠디 추적 안 함';

  @override
  String get settingsAutoAddStandees => '스탠디 자동 추가';

  @override
  String get settingsAutoAddSpawns => '소환물 자동 추가';

  @override
  String get settingsRandomStandees => '무작위 스탠디';

  @override
  String get settingsNoCalculations => '자동 계산 없음';

  @override
  String get settingsHideLootDeck => '전리품 덱 숨기기';

  @override
  String get settingsShimmer => '스탯 카드 텍스트 반짝임';

  @override
  String get settingsFhHazTerrainCalc => '원본 Gloomhaven에서 Frosthaven 위험 지형 계산';

  @override
  String get settingsAllyDeckOGGloom => '원본 Gloomhaven 동맹 수정 덱';

  @override
  String get settingsShowScenarioNames => '시나리오 이름 표시';

  @override
  String get settingsShowBattleGoalReminder => '전투 목표 알림 표시';

  @override
  String get settingsShowCustomContent => '커스텀 컨텐츠 표시';

  @override
  String get settingsShowSections => '메인 화면 섹션 표시';

  @override
  String get settingsShowReminders => '특수 규칙 알림 표시';

  @override
  String get settingsShowAmdDeck => '공격 수정 덱 표시';

  @override
  String get settingsShowCharacterAmd => '캐릭터 수정 덱 표시';

  @override
  String get settingsHealthWheel => 'HP 휠: 좌우로 드래그하여 변경';

  @override
  String get settingsFullscreen => '전체 화면';

  @override
  String get settingsMainListScaling => '메인 목록 크기:';

  @override
  String get settingsAppBarScaling => '앱 바 크기:';

  @override
  String get settingsStyleLabel => '스타일:';

  @override
  String get styleFrosthaven => 'Frosthaven';

  @override
  String get styleOriginal => '오리지널';

  @override
  String get settingsClearUnlocked => '해금된 캐릭터 및 컨텐츠 초기화';

  @override
  String get settingsUnlockSpecials => '특수 잠금 해제';

  @override
  String get settingsLoadSaveState => '상태 불러오기/저장';

  @override
  String get noResultsFound => '결과 없음';

  @override
  String get close => '닫기';

  @override
  String get retry => '재시도';

  @override
  String get specialUnlocks => '특수 잠금 해제';

  @override
  String get loadSaveDeleteCharacters => '캐릭터를 불러오거나 저장하거나 삭제합니다.';

  @override
  String get loadAddDeleteSaves => '저장 상태를 불러오거나 추가하거나 삭제합니다.';

  @override
  String get addNewSave => '새 저장';

  @override
  String get addNewSaveLabel => '새 저장:';

  @override
  String get loadButton => '불러오기';

  @override
  String get saveButton => '저장';

  @override
  String get deleteButton => '삭제';

  @override
  String get setSaveName => '저장 이름:';

  @override
  String get loadOrSaveCharacters => '캐릭터 불러오기 또는 저장';

  @override
  String get loadCharacter => '캐릭터 불러오기:';

  @override
  String get removeAll => '모두 제거';

  @override
  String get removeCardQuestion => '카드를 제거할까요?';

  @override
  String get sendToBottom => '아래로 보내기';

  @override
  String get shuffleUndrawnCards => '미사용 카드 섞기';

  @override
  String get returnToDiscardPile => '버린 카드 더미로 반환';

  @override
  String get returnToDrawPile => '덱으로 반환';

  @override
  String get addExtraLootCard => '추가 전리품 카드 추가';

  @override
  String get addStandeeNr => '스탠디 번호 추가';

  @override
  String get summonedLabel => '소환물:';

  @override
  String get characterDecks => '캐릭터 덱';

  @override
  String get shuffleAndDraw => '섞기\n및 뽑기';

  @override
  String get draw => '뽑기';

  @override
  String get nextRound => ' 다음 라운드';

  @override
  String get returnTopCard => '맨 위 카드 반환';

  @override
  String removeCardWithDetails(String title, int nr) {
    return '$title 제거\n(카드 번호: $nr)';
  }

  @override
  String get tapCardToAddToDeck => '카드를 탭하여 덱에 추가';

  @override
  String get removeCardFromDeckQuestion => '덱에서 카드를 제거할까요?';

  @override
  String get changeName => '이름 변경:';

  @override
  String get showBosses => '보스 표시';

  @override
  String get showScenarioSpecialMonsters => '시나리오 특수 몬스터 표시';

  @override
  String get addAsAlly => '동맹으로 추가';

  @override
  String get addMonsterLabel => '몬스터 추가';

  @override
  String get allCampaigns => '모든 캠페인';

  @override
  String get showMonstersFrom => '      다음에서 몬스터 표시:   ';

  @override
  String setMonsterLevel(String name) {
    return '$name 레벨';
  }

  @override
  String setSummonHealth(String name) {
    return '$name 최대 HP';
  }

  @override
  String get setScenarioLevel => '시나리오 레벨';

  @override
  String enhancedLevel(String level) {
    return '강화됨: $level';
  }

  @override
  String get soloLabel => '솔로:';

  @override
  String get automaticScenarioLevel => '자동 시나리오 레벨:';

  @override
  String get difficultyLabel => '난이도:';

  @override
  String get lootCardEnhancements => '전리품 카드 강화';

  @override
  String get addPerks => '특전 추가';

  @override
  String get useFrosthavenPerks => 'Frosthaven 특전 사용';

  @override
  String currentCampaign(String campaign) {
    return '현재 캠페인: $campaign';
  }

  @override
  String get addCharacterHint => '캐릭터 추가 (숨겨진 클래스는 이름 입력)';

  @override
  String get trapDamage => '함정 피해';

  @override
  String get hazardousTerrainDamage => '위험 지형 피해';

  @override
  String get experienceAdded => '경험치 추가';

  @override
  String get goldCoinValue => '금화 가치';

  @override
  String get levelLegendLabel => '레벨';

  @override
  String get saveStateNote =>
      '앱은 매 행동 후 자동으로 저장됩니다. 이 저장 파일들은 백업 또는 여러 캠페인 진행용입니다.';

  @override
  String clientConnectedTo(String address) {
    return '클라이언트 연결됨: $address';
  }

  @override
  String clientError(String error) {
    return '클라이언트 오류: $error';
  }

  @override
  String clientListenError(String error) {
    return '클라이언트 수신 오류: $error';
  }

  @override
  String get lostConnectionToServer => '서버 연결이 끊겼습니다';

  @override
  String get stateMismatch => '상태가 최신이 아닙니다. 다시 시도하세요.';

  @override
  String get serverUnresponsive => '서버가 응답하지 않습니다. 클라이언트 연결 해제.';

  @override
  String get clientDisconnected => '클라이언트 연결 해제';

  @override
  String get serverOffline => '서버 오프라인';

  @override
  String get clientLeft => '클라이언트가 떠났습니다.';

  @override
  String get clientTooOld => '오래된 클라이언트가 연결을 시도했습니다. 앱을 업데이트하세요.';

  @override
  String networkConnection(String status) {
    return '네트워크 연결: $status';
  }

  @override
  String get failedToGetWifiIp => 'IP 주소를 가져오지 못했습니다';

  @override
  String get badOmen => '불길한 징조';

  @override
  String badOmensLeft(int count) {
    return '남은 불길한 징조: $count';
  }

  @override
  String get corrosiveSpew => '부식성 분출';

  @override
  String get empowersOnTop => '강화 카드 맨 위에';

  @override
  String addMinusOneCard(int count) {
    return '-1 카드 추가 (추가됨: $count)';
  }

  @override
  String get removeMinusOneCard => '-1 카드 제거';

  @override
  String get removeMinusTwoCard => '-2 카드 제거';

  @override
  String get minusTwoCardRemoved => '-2 카드 제거됨';

  @override
  String get removePlusZeroCard => '+0 카드 제거';

  @override
  String get plusZeroCardRemoved => '+0 카드 제거됨';

  @override
  String get removeImbue => '주입 제거';

  @override
  String get imbue => '주입';

  @override
  String get advancedImbue => '고급 주입';

  @override
  String get removeHailPerk => '우박 특전 제거';

  @override
  String get addHailPerk => '우박 특전 추가';

  @override
  String get removeCassandraPerk => '카산드라\n특전 제거';

  @override
  String get addCassandraPerk => '카산드라\n특전 추가';

  @override
  String get dontSaveRevealedCards => '공개된 카드\n저장 안 함';

  @override
  String get saveRevealedCards => '공개된 카드\n저장';

  @override
  String removedCountLabel(int count) {
    return '제거됨: $count';
  }

  @override
  String get removeDonation => '기부\n제거';

  @override
  String get donateSanctuary => '성소에\n기부';

  @override
  String get removePartyCard => '그룹 카드\n제거:';

  @override
  String get addPartyCard => '그룹 카드\n추가:';

  @override
  String get perks => '특전';

  @override
  String get revealCards => '카드\n공개:';

  @override
  String get revealAll => '전체';

  @override
  String get drawExtraCard => '추가 카드 뽑기';

  @override
  String get extraShuffle => '추가 섞기';

  @override
  String get inactivateMonster => '몬스터\n비활성화';

  @override
  String get activateMonster => '몬스터\n활성화';

  @override
  String addEliteStandees(int count, String name) {
    return '엘리트 $name $count개 추가';
  }

  @override
  String addNormalStandees(int count, String name) {
    return '일반 $name $count개 추가';
  }

  @override
  String get characterLoot => '캐릭터 전리품';

  @override
  String addSpecialCard(int nr) {
    return '$nr번 카드 추가';
  }

  @override
  String removeSpecialCard(int nr) {
    return '$nr번 카드 제거';
  }

  @override
  String get enhanceCards => '카드 강화';

  @override
  String get addLootCard => '카드 추가';

  @override
  String get returnToTop => '맨 위로 반환';

  @override
  String get returnToBottom => '맨 아래로 반환';

  @override
  String characterLootTitle(String name) {
    return '$name의 전리품:';
  }

  @override
  String get setLootOwner => '전리품 소유자:';

  @override
  String get lootNameCoin => '동전';

  @override
  String get lootNameHide => '가죽';

  @override
  String get lootNameLumber => '목재';

  @override
  String get lootNameMetal => '금속';

  @override
  String get lootNameArrowvine => '화살나무';

  @override
  String get lootNameAxenut => '도끼열매';

  @override
  String get lootNameCorpsecap => '시체버섯';

  @override
  String get lootNameFlamefruit => '화염과일';

  @override
  String get lootNameRockroot => '암석뿌리';

  @override
  String get lootNameSnowthistle => '눈엉겅퀴';

  @override
  String get lootAmount2For2 => '2인용 2개';

  @override
  String get lootAmount2For23 => '2~3인용 2개';

  @override
  String cmdActivateMonster(String name) {
    return '$name 활성화';
  }

  @override
  String cmdDeactivateMonster(String name) {
    return '$name 비활성화';
  }

  @override
  String cmdAddCharacter(String id) {
    return '$id 추가';
  }

  @override
  String cmdAddCondition(String condition) {
    return '상태 이상 추가: $condition';
  }

  @override
  String cmdRemoveCondition(String condition) {
    return '상태 이상 제거: $condition';
  }

  @override
  String cmdAddPartyCard(String character, String type) {
    return '$character 그룹 카드 $type 추가';
  }

  @override
  String cmdRemovePartyCard(String character) {
    return '$character 그룹 카드 제거';
  }

  @override
  String cmdAddFactionCard(String character) {
    return '$character 파벌 카드 추가';
  }

  @override
  String cmdRemoveFactionCard(String character) {
    return '$character 파벌 카드 제거';
  }

  @override
  String cmdAddLootCard(String type) {
    return '전리품 카드 $type 추가';
  }

  @override
  String cmdAddMonster(String name) {
    return '$name 추가';
  }

  @override
  String cmdAddSpecialLootCard(int nr) {
    return '특수 전리품 카드 $nr 추가';
  }

  @override
  String cmdRemoveSpecialLootCard(int nr) {
    return '특수 전리품 카드 $nr 제거';
  }

  @override
  String get cmdAddMinusOne => '마이너스 원 추가';

  @override
  String get cmdRemoveMinusOne => '마이너스 원 제거';

  @override
  String get cmdRemoveMinusTwo => '마이너스 투 제거';

  @override
  String get cmdAddBackMinusTwo => '마이너스 투 복원';

  @override
  String get cmdRemovePlusZero => '플러스 제로 제거';

  @override
  String get cmdAddBackPlusZero => '플러스 제로 복원';

  @override
  String cmdRevealModifierCards(int count) {
    return '수정 카드 $count장 공개';
  }

  @override
  String cmdCassandraLeaveRevealed(String deck) {
    return '$deck 덱 위에 공개 카드 유지';
  }

  @override
  String cmdCassandraSpecialOff(String deck) {
    return '$deck 덱의 카산드라 특수 비활성화';
  }

  @override
  String get cmdImbueMonsterDeck => '몬스터 덱 주입';

  @override
  String get cmdAdvancedImbueMonsterDeck => '몬스터 덱 고급 주입';

  @override
  String get cmdRemoveImbueMonsterDeck => '주입 제거';

  @override
  String get cmdChangeName => '캐릭터 이름 변경';

  @override
  String get cmdAddBless => '축복 추가';

  @override
  String get cmdRemoveBless => '축복 제거';

  @override
  String get cmdAddCurse => '저주 추가';

  @override
  String get cmdRemoveCurse => '저주 제거';

  @override
  String get cmdAddEmpower => '강화 추가';

  @override
  String get cmdRemoveEmpower => '강화 제거';

  @override
  String get cmdAddEnfeeble => '약화 추가';

  @override
  String get cmdRemoveEnfeeble => '약화 제거';

  @override
  String cmdIncreaseMaxHealth(String owner) {
    return '$owner 최대 HP 증가';
  }

  @override
  String cmdDecreaseMaxHealth(String owner) {
    return '$owner 최대 HP 감소';
  }

  @override
  String get cmdChangeStat => '스탯 변경';

  @override
  String cmdIncreaseXp(String figure, int amount) {
    return '$figure 경험치 $amount 증가';
  }

  @override
  String cmdDecreaseXp(String figure, int amount) {
    return '$figure 경험치 $amount 감소';
  }

  @override
  String get cmdClearUnlockedClasses => '해금된 클래스 초기화';

  @override
  String cmdDonateSanctuary(String character) {
    return '$character 성소에 기부';
  }

  @override
  String cmdRemoveSanctuaryDonation(String character) {
    return '$character 기부 제거';
  }

  @override
  String get cmdDrawExtraAbilityCard => '추가 능력 카드 뽑기';

  @override
  String get cmdDraw => '뽑기';

  @override
  String get cmdDrawLootCard => '전리품 카드 뽑기';

  @override
  String cmdDrawModifierCard(String name) {
    return '$name 수정 카드 뽑기';
  }

  @override
  String get cmdRemoveLootEnhancement => '전리품 강화 제거';

  @override
  String get cmdAddLootEnhancement => '전리품 강화 추가';

  @override
  String get cmdHideAllyDeck => '동맹 덱 숨기기';

  @override
  String get cmdShowAllyDeck => '동맹 덱 표시';

  @override
  String get cmdIceWraithTurnNormal => '얼음 망령 일반으로 전환';

  @override
  String get cmdIceWraithTurnElite => '얼음 망령 엘리트로 전환';

  @override
  String cmdImbueElement(String element) {
    return '$element 원소 주입';
  }

  @override
  String cmdUseElement(String element) {
    return '$element 원소 사용';
  }

  @override
  String cmdLoadCharacter(String name) {
    return '저장된 캐릭터 불러오기: $name';
  }

  @override
  String cmdLoadGame(String name) {
    return '저장된 게임 불러오기: $name';
  }

  @override
  String get cmdNextRound => '다음 라운드';

  @override
  String get cmdRemoveAmdCard => 'AMD 카드 제거';

  @override
  String cmdRemoveCard(String deck, int nr) {
    return '$deck $nr번 카드 제거';
  }

  @override
  String get cmdRemoveAllCharacters => '모든 캐릭터 제거';

  @override
  String cmdRemoveCharacter(String id) {
    return '$id 제거';
  }

  @override
  String get cmdRemoveAllMonsters => '모든 몬스터 제거';

  @override
  String cmdRemoveMonster(String name) {
    return '$name 제거';
  }

  @override
  String get cmdReorderAbilityCards => '능력 카드 순서 변경';

  @override
  String get cmdReorderList => '목록 순서 변경';

  @override
  String get cmdReorderModifierCards => '수정 카드 순서 변경';

  @override
  String get cmdReturnLootCard => '전리품 카드 반환';

  @override
  String get cmdReturnModifierCard => '수정 카드 맨 위로 반환';

  @override
  String get cmdReturnRemovedAmdCard => '제거된 AMD 카드 반환';

  @override
  String get cmdNoAllyDeckInOgGloom => '원본 Gloomhaven에 동맹 덱 없음';

  @override
  String get cmdUseAllyDeckInOgGloom => '원본 Gloomhaven에서 동맹 덱 사용';

  @override
  String cmdMarkAsSummon(String owner) {
    return '$owner를 소환물로 표시';
  }

  @override
  String cmdRemoveSummonMark(String owner) {
    return '$owner의 소환 표시 제거';
  }

  @override
  String get cmdAutoLevelOn => '자동 레벨 업데이트 활성화';

  @override
  String get cmdAutoLevelOff => '자동 레벨 업데이트 비활성화';

  @override
  String cmdSetCampaign(String campaign) {
    return '$campaign 캠페인 설정';
  }

  @override
  String cmdSetCharacterLevel(String character) {
    return '$character 레벨 설정';
  }

  @override
  String cmdSetDifficulty(String difficulty) {
    return '난이도 $difficulty 설정';
  }

  @override
  String cmdSetInitiative(String character) {
    return '$character 선제권 설정';
  }

  @override
  String cmdSetMonsterLevel(String monster) {
    return '$monster 레벨 설정';
  }

  @override
  String get cmdSetLootOwner => '전리품 소유자 설정';

  @override
  String get cmdSetScenario => '시나리오 설정';

  @override
  String get cmdSetSoloOn => '솔로 레벨 추천 활성화';

  @override
  String get cmdSetSoloOff => '솔로 레벨 추천 비활성화';

  @override
  String get cmdExtraAbilityShuffle => '능력 덱 추가 섞기';

  @override
  String get cmdExtraAmdShuffle => 'AMD 덱 추가 섞기';

  @override
  String get cmdDrawnAbilityShuffle => '뽑힌 능력 덱 섞기';

  @override
  String get cmdDontTrackStandees => '스탠디 추적 안 함';

  @override
  String get cmdTrackStandees => '스탠디 추적';

  @override
  String cmdTurnDone(String id) {
    return '$id 턴 완료';
  }

  @override
  String cmdAddPerk(String character, int index) {
    return '\'$character\'의 $index번 특전 추가';
  }

  @override
  String cmdRemovePerk(String character, int index) {
    return '\'$character\'의 $index번 특전 제거';
  }

  @override
  String cmdUnlock(String id) {
    return '$id 잠금 해제';
  }

  @override
  String cmdLock(String id) {
    return '$id 잠금';
  }

  @override
  String get cmdSetLevel => '레벨 설정';

  @override
  String get cmdAddSection => '섹션 추가';

  @override
  String cmdAddStandee(String name, int nr) {
    return '$name $nr 추가';
  }

  @override
  String get cmdDrawMonsterModifierCard => '몬스터 수정 카드 뽑기';

  @override
  String cmdIncreaseHealth(String figure, int amount) {
    return '$figure HP $amount 증가';
  }

  @override
  String cmdKill(String owner) {
    return '$owner 처치';
  }

  @override
  String cmdDecreaseHealth(String owner, int amount) {
    return '$owner HP $amount 감소';
  }

  @override
  String cmdUseFhPerks(String character) {
    return '$character Frosthaven 특전 사용';
  }

  @override
  String cmdDontUseFhPerks(String character) {
    return '$character Frosthaven 특전 미사용';
  }

  @override
  String get cmdRemoveNoCharacters => '제거된 캐릭터 없음';

  @override
  String get cmdRemoveNoMonsters => '제거된 몬스터 없음';
}
