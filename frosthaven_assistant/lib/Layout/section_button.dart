import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import '../Resource/commands/set_scenario_command.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

class SectionButton extends StatefulWidget {
  final String data;

  const SectionButton({Key? key, required this.data}) : super(key: key);

  @override
  SectionButtonState createState() => SectionButtonState();
}

class SectionButtonState extends State<SectionButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scale = getIt<Settings>().userScalingBars.value;
    return ValueListenableBuilder<int>(
        valueListenable: getIt<GameState>().commandIndex,
        builder: (context, value, child) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.blueGrey,
              fixedSize: Size(55 * scale, 25 * scale),
              backgroundColor: Colors.white70,
              elevation: 4,
            ),
            onPressed:
                !getIt<GameState>().scenarioSectionsAdded.contains(widget.data)
                    ? () {
                        setState(() {
                          getIt<GameState>()
                              .action(SetScenarioCommand(widget.data, true));
                        });
                      }
                    : null,
            child: Text(
              widget.data.split(" ")[0],
              style: getTitleTextStyle(scale),
              maxLines: 1,
            ),
          );
        });
  }
}
