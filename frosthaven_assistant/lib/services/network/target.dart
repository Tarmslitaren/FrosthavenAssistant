import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/state/figure_state.dart';

class Target {
  MonsterStatsModel? model;
  FigureState state;
  String ownerId;
  String id;

  Target(this.model, this.state, this.ownerId, this.id);
}