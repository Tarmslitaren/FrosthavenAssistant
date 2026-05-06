import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../../Resource/game_methods.dart';
import '../view_models/monster_stat_card_view_model.dart';
import 'monster_stat_boss_layout.dart';
import 'monster_stat_normal_layout.dart';

class MonsterStatCardView extends StatelessWidget {
  const MonsterStatCardView({
    super.key,
    required this.data,
    required this.scale,
    required this.viewModel,
    this.settings,
  });

  final Monster data;
  final double scale;
  final MonsterStatCardViewModel viewModel;
  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    final frosthavenStyle = GameMethods.isFrosthavenStyle(data.type);

    return ValueListenableBuilder<int>(
        valueListenable: data.level,
        builder: (context, value, child) {
          final isBoss = data.type.levels[data.level.value].boss != null;

          return Container(
              decoration: BoxDecoration(
                boxShadow: [cardBoxShadow(scale)],
              ),
              margin: EdgeInsets.all(kMonsterCardMargin * scale),
              child: isBoss
                  ? MonsterStatBossLayout(
                      data: data,
                      scale: scale,
                      frosthavenStyle: frosthavenStyle,
                      viewModel: viewModel,
                      settings: settings)
                  : MonsterStatNormalLayout(
                      data: data,
                      scale: scale,
                      frosthavenStyle: frosthavenStyle,
                      settings: settings));
        });
  }
}
