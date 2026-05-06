import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/commands/add_condition_command.dart';
import '../../Resource/commands/remove_condition_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/settings.dart';
import '../../Resource/state/game_state.dart';
import '../../services/service_locator.dart';
import '../condition_icon.dart';
import '../view_models/condition_button_view_model.dart';

class ConditionButton extends StatelessWidget {
  static const double _kIconSize = 24.0;
  static const double _kClassTokenScale = 0.65;
  static const double _kDisabledIconSize = 23.1;
  static const double _kImmuneLeft = 15.75;
  static const double _kImmuneTop = 7.35;
  static const double _kImmuneSize = 8.4;

  const ConditionButton(
      {super.key,
      required this.condition,
      required this.figureId,
      required this.ownerId,
      required this.immunities,
      required this.scale,
      this.gameState,
      this.settings});

  // injected for testing
  final GameState? gameState;
  final Settings? settings;

  final Condition condition;
  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final gs = gameState ?? getIt<GameState>();
    final vm = ConditionButtonViewModel(
      condition: condition,
      figureId: figureId,
      ownerId: ownerId,
      immunities: immunities,
      gameState: gs,
      settings: settings ?? getIt<Settings>(),
    );

    final figure = vm.figure;
    if (figure == null) {
      return const SizedBox(width: 0, height: 0);
    }

    return ListenableBuilder(
        listenable: Listenable.merge([figure.conditions, vm.darkModeListenable]),
        builder: (context, child) {
          final isActive = vm.isActive;
          final imagePath = vm.imagePath;
          final enabled = vm.enabled;

          Color color = Colors.transparent;
          if (isActive) {
            color = vm.isDarkMode ? Colors.white : Colors.black;
          }

          Widget inactiveIcon = vm.isCharacter
              ? Stack(alignment: Alignment.center, children: [
                  Image(
                      color: vm.classColor,
                      colorBlendMode: BlendMode.modulate,
                      height: _kIconSize * scale,
                      filterQuality: FilterQuality.medium,
                      image: const AssetImage(
                          "assets/images/psd/class-token-bg.png")),
                  Image(
                      height: _kIconSize * scale * _kClassTokenScale,
                      width: _kIconSize * scale * _kClassTokenScale,
                      image: AssetImage(imagePath),
                      filterQuality: FilterQuality.medium),
                ])
              : Image.asset(
                  filterQuality: FilterQuality.medium,
                  height: _kIconSize * scale,
                  width: _kIconSize * scale,
                  imagePath);

          Widget enabledIcon = isActive
              ? ConditionIcon(
                  condition,
                  _kIconSize * scale,
                  vm.owner,
                  figure,
                  scale: scale,
                )
              : inactiveIcon;

          return Container(
              width: kConditionButtonSize * scale,
              height: kConditionButtonSize * scale,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(1 * scale),
              decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.all(
                      Radius.circular(kRoundButtonBorderRadius * scale))),
              child: IconButton(
                icon: enabled
                    ? enabledIcon
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                              left: 0,
                              top: 0,
                              child: Image(
                                height: _kDisabledIconSize * scale,
                                filterQuality: FilterQuality.medium,
                                image: AssetImage(imagePath),
                              )),
                          Positioned(
                              left: _kImmuneLeft * scale,
                              top: _kImmuneTop * scale,
                              child: Image(
                                height: _kImmuneSize * scale,
                                filterQuality: FilterQuality.medium,
                                image: const AssetImage(
                                    "assets/images/psd/immune.png"),
                              )),
                        ],
                      ),
                onPressed: enabled
                    ? () {
                        if (!isActive) {
                          gs.action(AddConditionCommand(
                              condition, figureId, ownerId,
                              gameState: gs));
                        } else {
                          gs.action(RemoveConditionCommand(
                              condition, figureId, ownerId,
                              gameState: gs));
                        }
                      }
                    : null,
              ));
        });
  }
}
