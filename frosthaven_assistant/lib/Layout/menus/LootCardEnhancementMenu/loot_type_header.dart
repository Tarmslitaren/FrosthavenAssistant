import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../../l10n/app_localizations.dart';

const double _kHeaderImageSize = 30.0;

class LootTypeHeader extends StatelessWidget {
  const LootTypeHeader({super.key, required this.type, required this.amount});

  final String type;
  final String amount;

  static String _displayName(AppLocalizations l10n, String type) =>
      switch (type) {
        'coin' => l10n.lootNameCoin,
        'hide' => l10n.lootNameHide,
        'lumber' => l10n.lootNameLumber,
        'metal' => l10n.lootNameMetal,
        'arrowvine' => l10n.lootNameArrowvine,
        'axenut' => l10n.lootNameAxenut,
        'corpsecap' => l10n.lootNameCorpsecap,
        'flamefruit' => l10n.lootNameFlamefruit,
        'rockroot' => l10n.lootNameRockroot,
        'snowthistle' => l10n.lootNameSnowthistle,
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Image(
          filterQuality: FilterQuality.medium,
          height: _kHeaderImageSize,
          width: _kHeaderImageSize,
          fit: BoxFit.contain,
          image: AssetImage("assets/images/loot/${type}_icon.png"),
        ),
        Text(
          "${_displayName(l10n, type)} $amount",
          style: kBodyStyle,
        ),
      ],
    );
  }
}
