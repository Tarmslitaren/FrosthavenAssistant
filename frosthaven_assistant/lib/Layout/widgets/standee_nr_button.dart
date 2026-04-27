import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class StandeeNrButton extends StatelessWidget {
  static const double _kButtonSize = 40.0;
  static const double _kShadowOffset = 1.0;
  static const double _kShadowBlur = 1.0;

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
      offset: Offset(_kShadowOffset * scale, _kShadowOffset * scale),
      color: Colors.black87,
      blurRadius: _kShadowBlur,
    );
    return SizedBox(
      width: _kButtonSize * scale,
      height: _kButtonSize * scale,
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
