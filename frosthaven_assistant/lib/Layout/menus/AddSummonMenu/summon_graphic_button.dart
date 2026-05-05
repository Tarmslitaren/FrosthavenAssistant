import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class SummonGraphicButton extends StatelessWidget {
  const SummonGraphicButton({
    super.key,
    required this.summonGfx,
    required this.scale,
    required this.isSelected,
    required this.darkMode,
    required this.onPressed,
  });

  final String summonGfx;
  final double scale;
  final bool isSelected;
  final bool darkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Color color = isSelected
        ? (darkMode ? Colors.white : Colors.black)
        : Colors.transparent;
    return SizedBox(
      width: kConditionButtonSize * scale,
      height: kConditionButtonSize * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.all(
                  Radius.circular(kRoundButtonBorderRadius * scale))),
          child: IconButton(
            onPressed: isSelected ? null : onPressed,
            icon: Image.asset(
              'assets/images/summon/$summonGfx.png',
              cacheHeight: kMonsterImageCacheHeight,
            ),
          )),
    );
  }
}
