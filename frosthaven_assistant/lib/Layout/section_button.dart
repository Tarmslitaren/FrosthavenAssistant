import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../Resource/commands/set_scenario_command.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

class SectionButton extends StatelessWidget {
  final String data;
  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  const SectionButton(
      {super.key, required this.data, this.gameState, this.settings});

  @override
  Widget build(BuildContext context) {
    final gameState = this.gameState ?? getIt<GameState>();
    final settings = this.settings ?? getIt<Settings>();
    double scale = settings.userScalingBars.value;
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, value, child) {
          return RepaintBoundary(
              child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.blueGrey,
              fixedSize: Size(55 * scale, 25 * scale),
              backgroundColor: Colors.white70,
              elevation: 4,
            ),
            onPressed: !gameState.scenarioSectionsAdded.contains(data)
                ? () {
                    gameState.action(
                        SetScenarioCommand(data, true, gameState: gameState));
                  }
                : null,
            child: Text(
              data.split(" ").first,
              style: getTitleTextStyle(scale * 0.8, forceBlack: true),
              maxLines: 1,
            ),
          ));
        });
  }
}
