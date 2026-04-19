part of 'game_state.dart';

class GameSaveState {
  String? _savedState;

  String getState() {
    final state = _savedState;
    if (state == null) throw StateError('GameSaveState: no saved state');
    return state;
  }

  void save(GameState gameState) {
    _savedState = gameState.toString();
  }

  void load(GameState gameState) {
    if (_savedState != null) {
      try {
        var data = json.decode(_savedState ?? '') as Map<String, dynamic>;

        gameState._level.value = data['level'] as int;
        gameState._scenario.value = data['scenario']; // as String;
        if (data.containsKey('toastMessage')) {
          gameState._toastMessage.value = data['toastMessage']; // as String;
        }

        if (data.containsKey('scenarioSectionsAdded')) {
          List<Object?> scenarioSectionsAdded =
              data['scenarioSectionsAdded'] as List<Object?>;
          gameState._scenarioSectionsAdded.clear();
          for (var item in scenarioSectionsAdded) {
            gameState._scenarioSectionsAdded.add(item as String);
          }
        }

        if (data.containsKey('scenarioSpecialRules')) {
          var scenarioSpecialRulesList = data['scenarioSpecialRules'] as List;
          gameState._scenarioSpecialRules.clear();
          for (Map<String, dynamic> item in scenarioSpecialRulesList) {
            gameState._scenarioSpecialRules.add(SpecialRule.fromJson(item));
          }
        }
        gameState._currentCampaign.value = data['currentCampaign'];
        gameState._round.value = data['round'] as int;
        if (data.containsKey('totalRounds')) {
          gameState._totalRounds.value = data['totalRounds'] as int;
        } else {
          gameState._totalRounds.value = gameState._round.value;
        }
        final roundStateIdx = data['roundState'] as int?;
        if (roundStateIdx != null &&
            roundStateIdx >= 0 &&
            roundStateIdx < RoundState.values.length) {
          gameState._roundState.value = RoundState.values[roundStateIdx];
        }
        gameState._solo.value = data['solo'] as bool;

        if (data.containsKey('autoScenarioLevel')) {
          gameState._autoScenarioLevel.value =
              data['autoScenarioLevel'] as bool;
        } else {
          gameState._autoScenarioLevel.value = true;
        }

        if (data.containsKey("allyDeckInOGGloom")) {
          gameState._allyDeckInOGGloom.value =
              data["allyDeckInOGGloom"] as bool;
        } else {
          gameState._allyDeckInOGGloom.value = true;
        }

        if (data.containsKey('difficulty')) {
          gameState._difficulty.value = data['difficulty'] as int;
        } else {
          gameState._difficulty.value = 0;
        }

        //main list — update existing objects in-place to preserve VLB subscriptions
        var list = data['currentList'] as List;
        List<ListItemData> newList = [];
        for (Map<String, dynamic> item in list) {
          if (item["characterClass"] != null) {
            final String itemId = item["id"] as String;
            final Character? existing = gameState._currentList
                .whereType<Character>()
                .firstWhereOrNull((e) => e.id == itemId);
            if (existing != null) {
              existing.updateFromJson(item);
              newList.add(existing);
            } else {
              newList.add(Character.fromJson(item));
            }
          } else if (item["type"] != null) {
            final String itemId = item["id"] as String;
            final Monster? existing = gameState._currentList
                .whereType<Monster>()
                .firstWhereOrNull((e) => e.id == itemId);
            if (existing != null) {
              existing.updateFromJson(item);
              newList.add(existing);
            } else {
              newList.add(Monster.fromJson(item));
            }
          }
        }
        gameState._currentList = newList;
        gameState._notifyCurrentList();

        var unlockedClassesList = data['unlockedClasses'] as List;
        gameState._unlockedClasses.clear();
        for (String item in unlockedClassesList) {
          gameState._unlockedClasses.add(item);
        }

        //ability decks
        var decks = data['currentAbilityDecks'] as List;
        gameState._currentAbilityDecks.clear();
        for (Map<String, dynamic> item in decks) {
          MonsterAbilityState state = MonsterAbilityState(item["name"]);

          List<MonsterAbilityCardModel> newDrawList = [];
          List drawPile = item["drawPile"] as List;
          for (var item in drawPile) {
            int nr = item["nr"];
            for (var card in state._drawPile.getList()) {
              if (card.nr == nr) {
                newDrawList.add(card);
                break;
              }
            }
          }
          List<MonsterAbilityCardModel> newDiscardList = [];
          for (var item in item["discardPile"] as List) {
            int nr = item["nr"];
            for (var card in state._drawPile.getList()) {
              if (card.nr == nr) {
                newDiscardList.add(card);
                break;
              }
            }
          }
          if (item.containsKey("lastRoundDrawn")) {
            state._lastRoundDrawn = item["lastRoundDrawn"];
          }

          state._drawPile.clear();
          state._discardPile.clear();
          state._drawPile.setList(newDrawList);
          state._discardPile.setList(newDiscardList);
          gameState._currentAbilityDecks.add(state);
        }

        _loadModifierDeck('modifierDeck', data, gameState);
        _loadModifierDeck('modifierDeckAllies', data, gameState);
        _loadLootDeck(data, gameState);

        if (data["sanctuaryDeck"] != null) {
          gameState._sanctuaryDeck =
              SanctuaryDeck.fromJson(data["sanctuaryDeck"]);
        }

        //this is not really a setting, but a scenario command?
        if (data["showAllyDeck"] != null) {
          gameState._showAllyDeck.value = data["showAllyDeck"];
        }

        //////elements
        Map elementData = data['elementState'];
        gameState._elementState.clear();
        for (final element in Elements.values) {
          final raw = elementData[element.index.toString()] as int?;
          final idx = (raw != null && raw >= 0 && raw < ElementState.values.length)
              ? raw
              : ElementState.inert.index;
          gameState._elementState[element] = ElementState.values[idx];
        }
      } catch (e, stack) {
        // Deserialization failure: log always (not just debug) so it surfaces
        // in release builds and can be caught by crash-reporting tools.
        debugPrint('GameSaveState.load error: $e\n$stack');
      }
    }
  }

  Future<void> saveToDisk(GameState gameState) async {
    if (_savedState == null) {
      save(gameState);
    }
    const sharedPrefsKey = 'gameState';
    try {
      final prefs = await SharedPreferences.getInstance();
      // save
      await prefs.setString(sharedPrefsKey, _savedState ?? '');
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> loadFromDisk(GameState gameState) async {
    //have to call after init or element state overridden

    const sharedPrefsKey = 'gameState';
    //bool hasError = false;
    //bool isWaiting = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedState = prefs.getString(sharedPrefsKey);
      //hasError = false;
    } catch (error) {
      //hasError = true;
    }
    //isWaiting = false;

    if (_savedState != null) {
      load(gameState);
    } else {
      save(gameState);
    }
  }

  void loadFromData(String data, GameState gameState) {
    //have to call after init or element state overridden
    _savedState = data;
    load(gameState);
  }

  void _loadLootDeck(Map<String, dynamic> data, GameState gameState) {
    gameState._lootDeck.updateFromJson(data["lootDeck"]);
  }

  void _loadModifierDeck(String identifier, Map<String, dynamic> data, GameState gameState) {
    final modifierDeckData = data[identifier] as Map<String, dynamic>;
    if (identifier == 'modifierDeck') {
      gameState._modifierDeck.updateFromJson(modifierDeckData);
    } else {
      gameState._modifierDeckAllies.updateFromJson(modifierDeckData);
    }
  }
}
