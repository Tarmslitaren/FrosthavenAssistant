part of 'state/game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class DeckMethods {
  static void drawAbilityCardFromInactiveDeck(_StateModifier stateModifier, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (MonsterAbilityState deck in gs.currentAbilityDecks) {
      for (var item in gs.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.isActive &&
                !GameMethods.isInactiveForRule(item.type.name)) {
              if (deck.lastRoundDrawn != gs.totalRounds.value) {
                //do not draw new card in case drawn already this round
                deck.draw(stateModifier);
                break;
              }
            }
          }
        }
      }
    }
  }

  static void drawAbilityCards(_StateModifier stateModifier, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (MonsterAbilityState deck in gs.currentAbilityDecks) {
      for (var item in gs.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            bool specialInactive =
                GameMethods.isInactiveForRule(item.type.name);
            if ((item.monsterInstances.isNotEmpty && !specialInactive) ||
                (item.isActive && !specialInactive)) {
              deck.draw(stateModifier);
              //only draw once from each deck
              break;
            }
          }
        }
      }
    }
  }

  static void shuffleDecksIfNeeded(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (var deck in gs.currentAbilityDecks) {
      if (deck.discardPileIsNotEmpty && deck.discardPileTop.shuffle ||
          deck.drawPileIsEmpty) {
        deck._shuffle();
      }
    }
  }

  static void shuffleDecks(_StateModifier _, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (var deck in gs.currentAbilityDecks) {
      deck._shuffle();
    }
  }

  static void returnModifierCard(_StateModifier s, String name, {GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    final deck = GameMethods.getModifierDeck(name, gs);
    deck.returnCardToDrawPile(s);
  }
}
