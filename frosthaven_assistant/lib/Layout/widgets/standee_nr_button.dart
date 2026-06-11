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
    // Stack-based shadow avoids TextStyle.shadows, which Impeller renders at the
    // Dialog's save-layer origin instead of the text's position on iOS.
    return SizedBox(
      width: kButtonSize * scale,
      height: kButtonSize * scale,
      child: TextButton(
        onPressed: onPressed,
        child: Stack(
          children: [
            Positioned(
              left: kShadowOffset * scale,
              top: kShadowOffset * scale,
              child: Text(
                nr.toString(),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: kFontSizeTitle * scale,
                ),
              ),
            ),
            Text(
              nr.toString(),
              style: TextStyle(
                color: color,
                fontSize: kFontSizeTitle * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
