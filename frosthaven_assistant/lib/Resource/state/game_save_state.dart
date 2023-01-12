import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/MonsterAbility.dart';
import '../../Model/scenario.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import 'character.dart';
import 'game_state.dart';
import 'list_item_data.dart';
import 'loot_deck_state.dart';
import 'modifier_deck_state.dart';
import 'monster.dart';
import 'monster_ability_state.dart';

class GameSaveState{

  String getState() {
    return _savedState!;
  }

  String? _savedState;
  void save() {
    _savedState = getIt<GameState>().toString();
  }

  void loadLootDeck(var data) {
    var lootDeckData = data["lootDeck"];
    LootDeck state = LootDeck.empty();

    state.hasCard1418 = lootDeckData["1418"];
    state.hasCard1419 = lootDeckData["1419"];

    state.metalEnhancements = List<bool>.from(lootDeckData['metalEnhancements']);
    state.hideEnhancements = List<bool>.from(lootDeckData["hideEnhancements"]);
    state.lumberEnhancements = List<bool>.from(lootDeckData["lumberEnhancements"]);
    state.addedCards = List<int>.from(lootDeckData["addedCards"]);
    state.arrowvineEnhancements = [false, false];
    state.corpsecapEnhancements = [false, false];
    state.flamefruitEnhancements = [false, false];
    state.axenutEnhancements = [false, false];
    state.snowthistleEnhancements = [false, false];
    state.rockrootEnhancements = [false, false];

    if(lootDeckData.containsKey('arrowvineEnhancements')) {
      state.arrowvineEnhancements = List<bool>.from(lootDeckData["arrowvineEnhancements"]);
    }
    if(lootDeckData.containsKey('corpsecapEnhancements')) {
      state.corpsecapEnhancements = List<bool>.from(lootDeckData["corpsecapEnhancements"]);
    }
    if(lootDeckData.containsKey('flamefruitEnhancements')) {
      state.flamefruitEnhancements = List<bool>.from(lootDeckData["flamefruitEnhancements"]);
    }
    if(lootDeckData.containsKey('axenutEnhancements')) {
      state.axenutEnhancements = List<bool>.from(lootDeckData["axenutEnhancements"]);
    }
    if(lootDeckData.containsKey('snowthistleEnhancements')) {
      state.snowthistleEnhancements = List<bool>.from(lootDeckData["snowthistleEnhancements"]);
    }
    if(lootDeckData.containsKey('rockrootEnhancements')) {
      state.rockrootEnhancements = List<bool>.from(lootDeckData["rockrootEnhancements"]);
    }

    List<LootCard> newDrawList = [];
    List drawPile = lootDeckData["drawPile"] as List;
    for (var item in drawPile) {
      String owner = "";
      String gfx = item["gfx"];
      if(item.containsKey('owner')) {
        owner = item["owner"];
      }
      bool enhanced = item["enhanced"];
      LootBaseValue baseValue = LootBaseValue.values[item["baseValue"]];
      LootType lootType = LootType.values[item["lootType"]];
      LootCard lootCard = LootCard(gfx: gfx, enhanced: enhanced, baseValue: baseValue, lootType: lootType);
      lootCard.owner = owner;
      newDrawList.add(lootCard);
    }
    List<LootCard> newDiscardList = [];
    for (var item in lootDeckData["discardPile"] as List) {
      String gfx = item["gfx"];
      String owner = "";
      if(item.containsKey('owner')) {
        owner = item["owner"];
      }
      bool enhanced = item["enhanced"];
      LootBaseValue baseValue = LootBaseValue.values[item["baseValue"]];
      LootType lootType = LootType.values[item["lootType"]];
      LootCard lootCard = LootCard(gfx: gfx, enhanced: enhanced, baseValue: baseValue, lootType: lootType);
      lootCard.owner = owner;
      newDiscardList.add(lootCard);
    }
    state.drawPile.getList().clear();
    state.discardPile.getList().clear();
    state.drawPile.setList(newDrawList);
    state.discardPile.setList(newDiscardList);
    state.cardCount.value = state.drawPile.size();

    getIt<GameState>().lootDeck = state;

  }

  void loadModifierDeck(String identifier, var data){
    //modifier deck
    String name  = "";
    if (identifier == 'modifierDeckAllies'){
      name = "Allies";
    }
    var modifierDeckData = data[identifier];
    ModifierDeck state = ModifierDeck(name);
    List<ModifierCard> newDrawList = [];
    List drawPile = modifierDeckData["drawPile"] as List;
    for (var item in drawPile) {
      String gfx = item["gfx"];
      if (gfx == "curse") {
        newDrawList.add(ModifierCard(CardType.curse, gfx));
      }
      else if (gfx == "bless") {
        newDrawList.add(ModifierCard(CardType.bless, gfx));
      }
      else if (gfx == "nullAttack" || gfx == "doubleAttack") {
        newDrawList.add(ModifierCard(CardType.multiply, gfx));
      } else {
        newDrawList.add(ModifierCard(CardType.add, gfx));
      }
    }
    List<ModifierCard> newDiscardList = [];
    for (var item in modifierDeckData["discardPile"] as List) {
      String gfx = item["gfx"];
      if (gfx == "curse") {
        newDiscardList.add(ModifierCard(CardType.curse, gfx));
      }
      else if (gfx == "bless") {
        newDiscardList.add(ModifierCard(CardType.bless, gfx));
      }
      else if (gfx == "nullAttack" || gfx == "doubleAttack") {
        newDiscardList.add(ModifierCard(CardType.multiply, gfx));
        state.needsShuffle = true;
      } else {
        newDiscardList.add(ModifierCard(CardType.add, gfx));
      }
    }
    state.drawPile.getList().clear();
    state.discardPile.getList().clear();
    state.drawPile.setList(newDrawList);
    state.discardPile.setList(newDiscardList);
    state.cardCount.value = state.drawPile.size();

    if (modifierDeckData.containsKey("curses")) {
      int curses = modifierDeckData['curses'];
      state.curses.value = curses;
    }
    if (modifierDeckData.containsKey("blesses")) {
      int blesses = modifierDeckData['blesses'];
      state.blesses.value = blesses;
    }

    if (modifierDeckData.containsKey('badOmen')) {
      state.badOmen.value = modifierDeckData["badOmen"] as int;
    }
    if (modifierDeckData.containsKey('addedMinusOnes')) {
      state.addedMinusOnes.value = modifierDeckData["addedMinusOnes"] as int;
    }

    if(identifier == 'modifierDeck') {
      getIt<GameState>().modifierDeck = state;
    } else {
      getIt<GameState>().modifierDeckAllies = state;
    }
  }

  Future<void> load() async {
    if (_savedState != null) {
      GameState gameState = getIt<GameState>();
      Map<String, dynamic> data = jsonDecode(_savedState!);
      gameState.level.value = data['level'] as int;
      gameState.scenario.value = data['scenario']; // as String;
      if(data.containsKey('toastMessage')) {
        gameState.toastMessage.value = data['toastMessage']; // as String;
      }

      if(data.containsKey('scenarioSpecialRules')) {
        var scenarioSpecialRulesList = data['scenarioSpecialRules'] as List;
        gameState.scenarioSpecialRules.clear();
        for (Map<String, dynamic> item in scenarioSpecialRulesList) {
          gameState.scenarioSpecialRules.add(SpecialRule.fromJson(item));
        }
      }
      gameState.currentCampaign.value = data['currentCampaign'];
      //TODO: currentCampaign does not update properly (because changing it is not a command
      gameState.round.value = data['round'] as int;
      gameState.roundState.value = RoundState.values[data['roundState']];
      gameState.solo.value =
      data['solo'] as bool; //TODO: does not update properly (because changing it is not a command

      //main list
      var list = data['currentList'] as List;
      gameState.currentList.clear();
      List<ListItemData> newList = [];
      for (Map<String, dynamic> item in list) {
        if (item["characterClass"] != null) {
          Character character = Character.fromJson(item);
          //is character
          newList.add(character);
        } else if (item["type"] != null) {
          //is monster
          Monster monster = Monster.fromJson(item);
          newList.add(monster);
        }
      }
      gameState.currentList = newList;

      var unlockedClassesList = data['unlockedClasses'] as List;
      gameState.unlockedClasses.clear();
      for (String item in unlockedClassesList) {
        gameState.unlockedClasses.add(item);
      }

      //ability decks
      var decks = data['currentAbilityDecks'] as List;
      gameState.currentAbilityDecks.clear();
      for (Map<String, dynamic> item in decks) {
        MonsterAbilityState state = MonsterAbilityState(item["name"]);

        List<MonsterAbilityCardModel> newDrawList = [];
        List drawPile = item["drawPile"] as List;
        for (var item in drawPile) {
          int nr = item["nr"];
          for (var card in state.drawPile.getList()) {
            if (card.nr == nr) {
              newDrawList.add(card);
            }
          }
        }
        List<MonsterAbilityCardModel> newDiscardList = [];
        for (var item in item["discardPile"] as List) {
          int nr = item["nr"];
          for (var card in state.drawPile.getList()) {
            if (card.nr == nr) {
              newDiscardList.add(card);
            }
          }
        }
        if (item.containsKey("lastRoundDrawn")) {
          state.lastRoundDrawn = item["lastRoundDrawn"];
        }

        state.drawPile.getList().clear();
        state.discardPile.getList().clear();
        state.drawPile.setList(newDrawList);
        state.discardPile.setList(newDiscardList);
        gameState.currentAbilityDecks.add(state);
      }

      loadModifierDeck('modifierDeck', data);
      loadModifierDeck('modifierDeckAllies', data);
      loadLootDeck(data);

      //////elements
      Map elementData = data['elementState'];
      Map<Elements, ElementState> newMap = {};
      newMap[Elements.fire] =
      ElementState.values[elementData[Elements.fire.index.toString()]];
      newMap[Elements.ice] =
      ElementState.values[elementData[Elements.ice.index.toString()]];
      newMap[Elements.air] =
      ElementState.values[elementData[Elements.air.index.toString()]];
      newMap[Elements.earth] =
      ElementState.values[elementData[Elements.earth.index.toString()]];
      newMap[Elements.light] =
      ElementState.values[elementData[Elements.light.index.toString()]];
      newMap[Elements.dark] =
      ElementState.values[elementData[Elements.dark.index.toString()]];
      gameState.elementState.value = newMap;
    }
  }
  Future<void> saveToDisk() async{
    if(_savedState == null) {
      save();
    }
    const sharedPrefsKey = 'gameState';
    bool _hasError = false;
    bool _isWaiting = true;
    //notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      // save
      // uncomment this to simulate an error-during-save
      // if (_value > 3) throw Exception("Artificial Error");
      await prefs.setString(sharedPrefsKey, _savedState!);
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    //notifyListeners();
  }
  Future<void> loadFromDisk() async {
    //have to call after init or element state overridden

    const sharedPrefsKey = 'gameState';
    bool _hasError = false;
    bool _isWaiting = true;
    //notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedState = prefs.getString(sharedPrefsKey);
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;

    if (_savedState != null){
      load();
    }
  }

  Future<void> loadFromData(String data) async {
    //have to call after init or element state overridden
    _savedState = data;
    load();
  }
}