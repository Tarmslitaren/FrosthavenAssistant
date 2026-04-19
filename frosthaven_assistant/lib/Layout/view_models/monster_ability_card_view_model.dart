import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/enums.dart';
import '../../Resource/ui_utils.dart';
import '../menus/ability_card_zoom.dart';
import '../menus/ability_cards_menu.dart';

class MonsterAbilityCardViewModel {
  MonsterAbilityCardViewModel(this.monster,
      {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Monster monster;
  final GameState _gameState;
  // ignore: unused_field - reserved for future settings-dependent logic
  final Settings _settings;

  // Notifier the widget subscribes to
  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  bool get shouldShowFront {
    if (_gameState.roundState.value != RoundState.playTurns) return false;
    if (!monster.isActive) return false;
    if (GameMethods.isInactiveForRule(monster.type.name)) return false;
    final deck = GameMethods.getDeck(monster.type.deck);
    return deck != null && deck.discardPileIsNotEmpty;
  }

  MonsterAbilityCardModel? get currentCard {
    if (!shouldShowFront) return null;
    return GameMethods.getDeck(monster.type.deck)?.discardPileTop;
  }

  int get deckSize => GameMethods.getDeck(monster.type.deck)?.drawPileSize ?? 0;

  MonsterAbilityState get deck => GameMethods.getDeck(monster.type.deck)!;

  void openDeckMenu(BuildContext context) {
    openDialog(
        context,
        AbilityCardsMenu(
          monsterAbilityState: deck,
          monsterData: monster,
        ));
  }

  void openZoom(BuildContext context) {
    final card = currentCard;
    if (card != null) {
      openDialog(context,
          AbilityCardZoom(card: card, monster: monster, calculateAll: false));
    }
  }
}
