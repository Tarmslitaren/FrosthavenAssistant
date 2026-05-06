import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';

import '../set_loot_owner_menu.dart';
import '../../loot_card_widget.dart';

const double _kItemMaxWidth = 200.0;
const double _kMaxScale = 3.0;
const double _kItemMargin = 2.0;

class LootCardListItem extends StatelessWidget {
  const LootCardListItem({super.key, required this.data});

  final LootCard data;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = min(_kMaxScale, screenWidth / _kItemMaxWidth);

    return Container(
        margin: EdgeInsets.all(_kItemMargin * scale),
        child: InkWell(
            onTap: () {
              openDialog(context, SetLootOwnerMenu(card: data));
            },
            child: LootCardFront(card: data, scale: scale)));
  }
}
