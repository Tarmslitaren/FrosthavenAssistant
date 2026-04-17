part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class RoundMethods {
  static const int _kMaxLevel = 7;
  static const int _kMinLevel = 0;
  static void setRoundState(_StateModifier _, RoundState state, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._roundState.value = state;
  }

  static void setRound(_StateModifier _, int round, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._round.value = round;
    gs._totalRounds.value++;
  }

  static void resetRound(_StateModifier _, int round, bool resetTotal, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._round.value = round;
    if (resetTotal) {
      gs._totalRounds.value = round;
    }
  }

  static void sortCharactersFirst(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }

      bool aIsChar = false;
      bool bIsChar = false;
      if (a is Character) {
        aIsChar = true;
      }
      if (b is Character) {
        bIsChar = true;
      }
      if (aIsChar && bIsChar) {
        return 0;
      }
      if (bIsChar) {
        return 1;
      }

      //inactive at bottom
      if (a is Monster) {
        if (b is Monster) {
          if (!b.isActive) {
            return -1;
          }
        }
        if (!a.isActive) {
          return 1;
        }
      }
      if (b is Monster) {
        if (!b.isActive) {
          return -1;
        }
        if (a is Monster) {
          if (!a.isActive) {
            return 1;
          }
        }
      }

      return -1;
    });
  }

  static void sortItemToPlace(_StateModifier _, String id, int initiative, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    var newList = gs.currentList.toList();
    ListItemData? item;
    int currentTurnItemIndex = 0;
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].turnState.value == TurnsState.current) {
        currentTurnItemIndex = i;
      }
      if (newList[i].id == id) {
        item = newList.removeAt(i);
      }
    }
    if (item == null) {
      return;
    }

    int init = 0;
    for (int i = 0; i < newList.length; i++) {
      ListItemData currentItem = newList[i];
      int currentItemInitiative = GameMethods.getInitiative(currentItem);
      if (currentItemInitiative > initiative && currentItemInitiative > init) {
        if (i > currentTurnItemIndex) {
          newList.insert(i, item);
          gs._currentList = newList;
          gs._notifyCurrentList();
          return;
        } else {
          //in case initiative is earlier than current turn, ignore anything current turn, and earlier and place later
          int insertIndex = currentTurnItemIndex + 1;
          for (int j = currentTurnItemIndex + 1; j < newList.length; j++) {
            if (GameMethods.getInitiative(newList[j]) >= initiative) {
              insertIndex = j;
              break;
            }
          }
          newList.insert(insertIndex, item);
          gs._currentList = newList;
          gs._notifyCurrentList();
          return;
        }
      }
      init =
          currentItemInitiative; //this check is for the case user has moved items around the order may be off
    }

    newList.add(item);
    gs._currentList = newList;
    gs._notifyCurrentList();
  }

  static void sortByInitiative(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }
      int aInitiative = 0;
      int bInitiative = 0;
      if (a is Character) {
        aInitiative = a.characterState.initiative.value;
      } else if (a is Monster) {
        if (!a.isActive) {
          if (b is Monster && !b.isActive) {
            return -1;
          }
          return 1; //inactive at bottom
        }

        //find the deck
        for (var item in gs.currentAbilityDecks) {
          if (item.name == a.type.deck && item.discardPileIsNotEmpty) {
            aInitiative = item.discardPileTop.initiative;
          }
        }
      }
      if (b is Character) {
        bInitiative = b.characterState.initiative.value;
      } else if (b is Monster) {
        if (!b.isActive) {
          if (a is Monster && !a.isActive) {
            return 1;
          }
          return -1; //inactive at bottom
        }
        //find the deck
        for (var item in gs.currentAbilityDecks) {
          if (item.name == b.type.deck && item.discardPileIsNotEmpty) {
            bInitiative = item.discardPileTop.initiative;
          }
        }
      }
      return aInitiative.compareTo(bInitiative);
    });
  }

  static void sortMonsterInstances(
      _StateModifier _, List<MonsterInstance> instances) {
    instances.sort((a, b) {
      if (a.type == MonsterType.elite && b.type != MonsterType.elite) {
        return -1;
      }
      if (b.type == MonsterType.elite && a.type != MonsterType.elite) {
        return 1;
      }
      return a.standeeNr.compareTo(b.standeeNr);
    });
  }

  static void addToMainList(_StateModifier _, int? index, ListItemData item, {GameState? gameState}) {
    List<ListItemData> newList = [];
    final gs = gameState ?? getIt<GameState>();
    for (var item in gs.currentList) {
      newList.add(item);
    }
    if (index != null) {
      newList.insert(index, item);
    } else {
      newList.add(item);
    }
    gs._currentList = newList;
    gs._notifyCurrentList();
  }

  static void reorderMainList(_StateModifier _, int newIndex, int oldIndex, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    gs._currentList
        .insert(newIndex, gs._currentList.removeAt(oldIndex));
    gs._notifyCurrentList();
  }

  static void updateForSpecialRules(_StateModifier _,
      {GameState? gameState, GameData? gameData}) {
    final gs = gameState ?? getIt<GameState>();
    final gd = gameData ?? getIt<GameData>();
    List<SpecialRule>? rules = gd
        .modelData
        .value[gs.currentCampaign.value]
        ?.scenarios[gs.scenario.value]
        ?.specialRules;
    if (rules != null) {
      for (SpecialRule rule in rules) {
        if (rule.type == "Objective" || rule.type == "Escort") {
          Character? character = gs.currentList
                  .firstWhereOrNull((element) => element.id == rule.name)
              as Character?;
          if (character != null) {
            int? newHealth =
                StatCalculator.calculateFormula(rule.health.toString());
            if (newHealth != character.characterState.maxHealth.value &&
                newHealth != null) {
              character.characterState._maxHealth.value = newHealth;
              character.characterState._health.value = newHealth;
            }
          }
        } else if (rule.type == "LevelAdjust") {
          Monster? monster = gs.currentList
                  .firstWhereOrNull((element) => element.id == rule.name)
              as Monster?;
          if (monster != null) {
            if (gs.level.value == monster.level.value) {
              int newLevel = (monster.level.value + rule.level).clamp(_kMinLevel, _kMaxLevel);
              monster._level.value = newLevel;
              for (MonsterInstance instance in monster._monsterInstances) {
                instance._setLevel(monster);
              }
            }
          }
        }
      }
    }
  }

  static void clearTurnStateConditions(
      _StateModifier _, FigureState figure, bool clearLastTurnToo) {
    if (!clearLastTurnToo) {
      figure._conditionsAddedPreviousTurn.clear();
      figure._conditionsAddedPreviousTurn
          .addAll(figure.conditionsAddedThisTurn.toSet());
    } else {
      figure._conditionsAddedPreviousTurn.clear();
    }
    if (!clearLastTurnToo) {
      if (figure.conditionsAddedThisTurn.contains(Condition.chill)) {
        figure._chill.value--;
        if (figure.chill.value > 0) {
          figure._conditionsAddedPreviousTurn.clear();
          figure._conditionsAddedThisTurn.add(Condition.chill);
        } else {
          figure._conditionsAddedThisTurn.clear();
        }
      } else {
        figure._conditionsAddedThisTurn.clear();
      }
    } else {
      figure._conditionsAddedThisTurn.clear();
    }
  }

  static void clearTurnState(
      _StateModifier stateModifier, bool clearLastTurnToo,
      {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (var item in gs._currentList) {
      item._turnState.value = TurnsState.notDone;
      if (item is Character) {
        clearTurnStateConditions(
            stateModifier, item.characterState, clearLastTurnToo);
        for (var instance in item.characterState._summonList) {
          clearTurnStateConditions(stateModifier, instance, clearLastTurnToo);
        }
      } else if (item is Monster) {
        for (var instance in item._monsterInstances) {
          clearTurnStateConditions(stateModifier, instance, clearLastTurnToo);
        }
      }
    }
  }

  static void removeExpiringConditions(_StateModifier _, FigureState figure,
      {Settings? settings}) {
    if ((settings ?? getIt<Settings>()).expireConditions.value) {
      bool chillRemoved = false;
      final conditions = figure._conditions.value;
      for (int i = conditions.length - 1; i >= 0; i--) {
        Condition item = conditions[i];
        if (GameMethods.canExpire(item)) {
          if (item != Condition.chill || !chillRemoved) {
            if (!figure.conditionsAddedThisTurn.contains(item)) {
              conditions.removeAt(i);
              figure._conditionsAddedPreviousTurn.add(item);
            }
            if (item == Condition.chill) {
              figure._chill.value--;
              chillRemoved = true;
            }
          }
        }
      }
    }
  }

  static void removeExpiringConditionsFromListItem(
      _StateModifier s, ListItemData item) {
    if (item is Character) {
      removeExpiringConditions(s, item.characterState);
      for (var summon in item.characterState._summonList) {
        removeExpiringConditions(s, summon);
      }
    } else if (item is Monster) {
      for (var instance in item._monsterInstances) {
        removeExpiringConditions(s, instance);
      }
    }
  }

  static void reapplyConditions(_StateModifier _, FigureState figure) {
    for (var condition in figure.conditionsAddedPreviousTurn) {
      final conditions = figure._conditions.value;
      if (!conditions.contains(condition) || condition == Condition.chill) {
        conditions.add(condition);
        figure._conditionsAddedThisTurn.remove(condition);
      }
      if (condition == Condition.chill) {
        figure._chill.value++;
      }
    }
  }

  static void reapplyConditionsFromListItem(
      _StateModifier s, ListItemData item) {
    if (item is Character) {
      reapplyConditions(s, item.characterState);
      for (var summon in item.characterState.summonList) {
        reapplyConditions(s, summon);
      }
    } else if (item is Monster) {
      for (var instance in item._monsterInstances) {
        reapplyConditions(s, instance);
      }
    }
  }

  //1 if item WAS done OR not done, then set it to current, all before to done, and all after to not done
  //2 if item was current: set item to done, all before to done, next to current and rest to not done
  static void setTurnDone(_StateModifier s, int index, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    //set all before to done.
    for (int i = 0; i < index; i++) {
      if (gs.currentList[i].turnState.value != TurnsState.done) {
        gs.currentList[i]._turnState.value = TurnsState.done;
        removeExpiringConditionsFromListItem(s, gs.currentList[i]);
      }
    }
    //if on index is NOT current then set to current else set to done
    int newIndex = index + 1;
    if (gs.currentList[index].turnState.value == TurnsState.current) {
      gs.currentList[index]._turnState.value = TurnsState.done;
      removeExpiringConditionsFromListItem(s, gs.currentList[index]);
      //remove expiring conditions
    } else {
      newIndex = index;
    }

    //get next active item and set to current
    for (; newIndex < gs.currentList.length; newIndex++) {
      ListItemData data = gs.currentList[newIndex];
      if (data is Monster) {
        if (data.isActive && !GameMethods.isInactiveForRule(data.type.name)) {
          if (data.turnState.value == TurnsState.done) {
            reapplyConditionsFromListItem(s, data);
          }
          data._turnState.value = TurnsState.current;
          break;
        }
      } else if (data is Character) {
        if (data.characterState.health.value > 0) {
          if (data.turnState.value == TurnsState.done) {
            reapplyConditionsFromListItem(s, data);
          }
          data._turnState.value = TurnsState.current;
          break;
        }
      }
    }
    //set rest to not done
    for (int i = newIndex + 1; i < gs.currentList.length; i++) {
      if (gs.currentList[i].turnState.value == TurnsState.done) {
        reapplyConditionsFromListItem(s, gs.currentList[i]);
      }
      gs.currentList[i]._turnState.value = TurnsState.notDone;
    }
  }
}
