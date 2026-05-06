import 'package:flutter/material.dart';

import '../../../Resource/game_methods.dart';
import '../../../Resource/settings.dart';
import '../../../Resource/state/game_state.dart';
import '../../../Resource/ui_utils.dart';
import '../../../services/service_locator.dart';
import '../../view_models/status_menu_view_model.dart';
import '../../widgets/modal_background.dart';
import 'status_menu_condition_panel.dart';
import 'status_menu_header.dart';
import 'status_menu_stat_column.dart';

class StatusMenu extends StatefulWidget {
  static const double _kMenuWidth = 340.0;

  const StatusMenu(
      {super.key,
      required this.figureId,
      this.characterId,
      this.monsterId,
      this.gameState,
      this.settings});

  final String figureId;
  final String? monsterId;
  final String? characterId;

  final GameState? gameState;
  final Settings? settings;

  @override
  StatusMenuState createState() => StatusMenuState();
}

class StatusMenuState extends State<StatusMenu> {
  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  Settings get _settings => widget.settings ?? getIt<Settings>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = StatusMenuViewModel(
      figureId: widget.figureId,
      monsterId: widget.monsterId,
      characterId: widget.characterId,
      gameState: _gameState,
      settings: _settings,
    );

    final figure = vm.figure;
    if (figure == null) {
      Navigator.pop(context);
      return const SizedBox(height: 0, width: 0);
    }

    final owner = vm.owner;
    if (owner == null) {
      Navigator.pop(context);
      return const SizedBox(height: 0, width: 0);
    }

    double scale = getModalMenuScale(context);
    int nrOfCharacters = GameMethods.getCurrentCharacterAmount();

    return Wrap(children: [
      ModalBackground(
          width: StatusMenu._kMenuWidth * scale,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            StatusMenuHeader(
              name: vm.name,
              figure: figure,
              scale: scale,
              hasShield: vm.hasShield,
              hasRetaliate: vm.hasRetaliate,
              owner: owner,
              figureId: widget.figureId,
              ownerId: vm.ownerId,
              isIceWraith: vm.isIceWraith,
              isElite: vm.isElite,
              gameState: _gameState,
              onIceWraithSwitch: () => setState(() {}),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              StatusMenuStatColumn(
                figure: figure,
                scale: scale,
                isMonster: vm.isMonster,
                isCharacter: vm.isCharacter,
                isSummon: vm.isSummon,
                characterId: widget.characterId,
                monsterId: widget.monsterId,
                immunities: vm.immunities,
                hasVimthreader: vm.hasVimthreader,
                hasLifespeaker: vm.hasLifespeaker,
                hasIncarnate: vm.hasIncarnate,
                character: vm.character,
                hasPlagueHerald: vm.hasPlagueHerald,
                figureId: widget.figureId,
                ownerId: vm.ownerId,
                monster: vm.monster,
                showCustomContent: vm.showCustomContent,
                gameState: _gameState,
                settings: _settings,
              ),
              StatusMenuConditionPanel(
                figureId: widget.figureId,
                ownerId: vm.ownerId,
                immunities: vm.immunities,
                scale: scale,
                isMonster: vm.isMonster,
                isCharacter: vm.isCharacter,
                isSummon: vm.isSummon,
                nrOfCharacters: nrOfCharacters,
                showCustomContent: vm.showCustomContent,
                hasMireFoot: vm.hasMireFoot,
                gameState: _gameState,
                settings: _settings,
              ),
            ])
          ]))
    ]);
  }
}
