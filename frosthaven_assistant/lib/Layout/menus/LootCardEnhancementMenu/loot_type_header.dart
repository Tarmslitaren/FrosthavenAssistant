import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

const double _kHeaderImageSize = 30.0;

class LootTypeHeader extends StatelessWidget {
  const LootTypeHeader({super.key, required this.type, required this.amount});

  final String type;
  final String amount;

  @override
  Widget build(BuildContext context) {
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
          "$type $amount",
          style: kBodyStyle,
        ),
      ],
    );
  }
}
