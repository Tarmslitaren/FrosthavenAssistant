import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class StandeeNrButton extends StatelessWidget {

  const StandeeNrButton({
    super.key,
    required this.nr,
    required this.scale,
    required this.color,
    required this.onPressed,
  });

  final int nr;
  final double scale;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shadow = Shadow(
      offset: Offset(kShadowOffset * scale, kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: kShadowOffset,
    );
    return SizedBox(
      width: kButtonSize * scale,
      height: kButtonSize * scale,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          nr.toString(),
          style: TextStyle(
            color: color,
            fontSize: kFontSizeTitle * scale,
            shadows: [shadow],
          ),
        ),
      ),
    );
  }
}
