import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class SummonNrButton extends StatelessWidget {
  const SummonNrButton({
    super.key,
    required this.nr,
    required this.scale,
    required this.isSelected,
    required this.darkMode,
    required this.onPressed,
  });

  final int nr;
  final double scale;
  final bool isSelected;
  final bool darkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Color selectedTextColor = darkMode ? Colors.white : Colors.black;
    Color textColor = isSelected ? selectedTextColor : Colors.grey;
    return SizedBox(
      width: kConditionButtonSize * scale,
      height: kConditionButtonSize * scale,
      child: Container(
          decoration: BoxDecoration(
              border: Border.fromBorderSide(
                  const BorderSide(color: Colors.transparent)),
              borderRadius:
                  BorderRadius.all(Radius.circular(kRoundButtonBorderRadius))),
          child: TextButton(
            onPressed: isSelected ? null : onPressed,
            child: Text(
              nr.toString(),
              style:
                  TextStyle(fontSize: kFontSizeTitle * scale, color: textColor),
            ),
          )),
    );
  }
}
