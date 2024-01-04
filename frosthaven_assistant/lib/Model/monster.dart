import 'package:flutter/foundation.dart';

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

    final levels = data['levels'] as List<dynamic>;
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
  final dynamic health;
  final dynamic move;
  final dynamic attack;
  final int range;
  final List<String> attributes;
  final List<String> immunities;
  final List<String> special1;
  final List<String> special2;

  factory MonsterStatsModel.fromJson(Map<String, dynamic> data) {
    final health = data['health'];
    final move = data['move'] as int;
    final attack = data['attack'];
    int range = 0;
    if (data.containsKey('range')) {
      range = data['range'] as int;
    }
    List<String> attributes = [];
    if (data.containsKey('attributes')) {
      attributes = (data['attributes'] as List<dynamic>).cast<String>();
    }
    List<String> immunities = [];
    if (data.containsKey('immunities')) {
      immunities = (data['immunities'] as List<dynamic>).cast<String>();
    }
    List<String> special1 = [];
    if (data.containsKey('special1')) {
      special1 = (data['special1'] as List<dynamic>).cast<String>();
    }
    List<String> special2 = [];
    if (data.containsKey('special2')) {
      special2 = (data['special2'] as List<dynamic>).cast<String>();
    }
    return MonsterStatsModel(health, move, attack, range, attributes,
        immunities, special1, special2);
  }
}
