import 'package:flutter/foundation.dart';

/// A monster stat that is either a plain integer or a formula string.
///
/// Formulas may contain `C` (number of characters) and `L` (scenario level)
/// and are evaluated by [StatCalculator.calculateFormula]. Named formulas such
/// as `"Hollowpact"` or `"Incarnate"` have special handling in [MonsterInstance].
///
/// Use [StatValue.fromJson] when parsing JSON — it throws [FormatException] for
/// values that are neither int nor String, catching data errors at load time
/// instead of silently producing wrong results at runtime.
sealed class StatValue { // ignore: prefer-match-file-name, file contains multiple monster model types
  const StatValue();

  static StatValue fromJson(Object? value) {
    if (value is int) return IntStatValue(value);
    if (value is String) return FormulaStatValue(value);
    throw FormatException(
        'Stat value must be int or String, got ${value?.runtimeType}: $value');
  }

  /// Returns a constant representing zero.
  static const StatValue zero = IntStatValue(0);
}

/// A stat whose value is a fixed integer (e.g. `"health": 3`).
final class IntStatValue extends StatValue {
  const IntStatValue(this.value);
  final int value;
  @override
  String toString() => value.toString();
}

/// A stat whose value is a formula string (e.g. `"health": "C+1"`).
final class FormulaStatValue extends StatValue {
  const FormulaStatValue(this.formula);
  final String formula;
  @override
  String toString() => formula;
}

@immutable
class MonsterModel {
  const MonsterModel(
      this.name,
      this.display,
      this.gfx,
      this.hidden,
      this.flying,
      this.deck,
      this.count,
      this.levels,
      this.edition,
      this.capture);
  final String name; //id
  final String deck;
  final String display; //same as name. most of the time
  final String gfx; //same as name. most of the time
  final bool hidden;
  final bool flying;
  final int count;
  final bool capture;
  final String edition;
  final List<MonsterLevelModel> levels;

  factory MonsterModel.fromJson(
      Map<String, dynamic> data, String name, String edition) {
    String anEdition = edition;
    if (data.containsKey('edition')) {
      anEdition = data['edition'] as String;
    }

    String display = name;
    if (data.containsKey('display')) {
      display = data['display'] as String;
    }
    String gfx = display;
    if (data.containsKey('gfx')) {
      gfx = data['gfx'] as String;
    }
    bool hidden = false;
    if (data.containsKey('hidden')) {
      hidden = data['hidden'] as bool;
    }
    bool flying = false;
    if (data.containsKey('flying')) {
      flying = data['flying'] as bool;
    }
    bool capture = false;
    if (data.containsKey('capture')) {
      capture = data['capture'] as bool;
    }
    final deck = data['deck'] as String;
    final count = data['count'] as int;

    final levels = (data['levels'] as List<Object?>).cast<Map<String, dynamic>>();
    List<MonsterLevelModel> monsterLevelDataList = [];
    for (var item in levels) {
      monsterLevelDataList.add(MonsterLevelModel.fromJson(item));
    }
    return MonsterModel(name, display, gfx, hidden, flying, deck, count,
        monsterLevelDataList, anEdition, capture);
  }
}

@immutable
class MonsterLevelModel {
  const MonsterLevelModel(this.level, this.normal, this.elite, this.boss);
  final int level;
  final MonsterStatsModel? normal;
  final MonsterStatsModel? elite;
  final MonsterStatsModel? boss;

  factory MonsterLevelModel.fromJson(Map<String, dynamic> data) {
    final level = data['level'] as int;
    MonsterStatsModel normal;
    MonsterStatsModel elite;
    if (data.containsKey('normal') && data.containsKey('elite')) {
      normal = MonsterStatsModel.fromJson(data['normal']);
      elite = MonsterStatsModel.fromJson(data['elite']);
      return MonsterLevelModel(level, normal, elite, null);
    } else {
      return MonsterLevelModel(
          level, null, null, MonsterStatsModel.fromJson(data));
    }
  }
}

@immutable
class MonsterStatsModel {
  const MonsterStatsModel(this.health, this.move, this.attack, this.range,
      this.attributes, this.immunities, this.special1, this.special2);
  final StatValue health;
  final StatValue move;
  final StatValue attack;
  final int range;
  final List<String> attributes;
  final List<String> immunities;
  final List<String> special1;
  final List<String> special2;

  factory MonsterStatsModel.fromJson(Map<String, dynamic> data) {
    final health = StatValue.fromJson(data['health']);
    StatValue move = StatValue.zero;
    if (data.containsKey('move')) {
      move = StatValue.fromJson(data['move']);
    }
    StatValue attack = StatValue.zero;
    if (data.containsKey('attack')) {
      attack = StatValue.fromJson(data['attack']);
    }
    int range = 0;
    if (data.containsKey('range')) {
      range = data['range'] as int;
    }
    List<String> attributes = [];
    if (data.containsKey('attributes')) {
      attributes = (data['attributes'] as List<Object?>).cast<String>();
    }
    List<String> immunities = [];
    if (data.containsKey('immunities')) {
      immunities = (data['immunities'] as List<Object?>).cast<String>();
    }
    List<String> special1 = [];
    if (data.containsKey('special1')) {
      special1 = (data['special1'] as List<Object?>).cast<String>();
    }
    List<String> special2 = [];
    if (data.containsKey('special2')) {
      special2 = (data['special2'] as List<Object?>).cast<String>();
    }
    return MonsterStatsModel(health, move, attack, range, attributes,
        immunities, special1, special2);
  }
}
