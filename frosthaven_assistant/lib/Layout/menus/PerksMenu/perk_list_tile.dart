import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/line_builder/token_applier.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../../Layout/view_models/perk_list_tile_view_model.dart';
import '../../../services/service_locator.dart';

class PerkListTile extends StatefulWidget {
  const PerkListTile({
    super.key,
    required this.character,
    required this.index,
    required this.perk,
    this.gameState,
  });

  final Character character;
  final int index;
  final PerkModel perk;
  final GameState? gameState;

  @override
  State<StatefulWidget> createState() => PerkListTileState();
}

class PerkListTileState extends State<PerkListTile> {
  GameState get _gameState => widget.gameState ?? getIt<GameState>();

  @override
  Widget build(BuildContext context) {
    final vm = PerkListTileViewModel(
      character: widget.character,
      index: widget.index,
      perk: widget.perk,
    );

    return CheckboxListTile(
      title: TokenApplier.applyTokensForPerks(vm.description),
      enabled: vm.enabled,
      onChanged: (bool? value) {
        setState(() {
          _gameState.action(AddPerkCommand(widget.character.id, widget.index));
        });
      },
      value: vm.added,
    );
  }
}
