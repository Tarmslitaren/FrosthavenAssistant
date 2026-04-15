import 'dart:convert';

/// A typed, machine-readable signal describing what transition just occurred.
///
/// Produced by [Command.event], stored in [ActionHandler.lastEvent], and
/// transmitted alongside every game-state snapshot so that both local and
/// network clients can trigger animations from the same code path.
sealed class GameEvent {
  const GameEvent();

  Map<String, dynamic> toJson();

  String toJsonString() => json.encode(toJson());

  static GameEvent fromJson(Map<String, dynamic> data) {
    switch (data['type'] as String? ?? '') {
      case 'lootCardDrawn':
        return const LootCardDrawnEvent();
      case 'modifierCardDrawn':
        return ModifierCardDrawnEvent(data['deck'] as String? ?? '');
      default:
        return const NoEvent();
    }
  }

  static GameEvent fromJsonString(String jsonString) {
    try {
      return fromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return const NoEvent();
    }
  }
}

/// Default: no UI transition to signal.
class NoEvent extends GameEvent {
  const NoEvent();

  @override
  Map<String, dynamic> toJson() => {'type': 'none'};
}

/// A loot card was drawn from the draw pile to the discard pile.
class LootCardDrawnEvent extends GameEvent {
  const LootCardDrawnEvent();

  @override
  Map<String, dynamic> toJson() => {'type': 'lootCardDrawn'};
}

/// A modifier card was drawn for the named deck.
/// [deckName] is empty for the monster modifier deck.
class ModifierCardDrawnEvent extends GameEvent {
  const ModifierCardDrawnEvent(this.deckName);

  final String deckName;

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'modifierCardDrawn', 'deck': deckName};
}
