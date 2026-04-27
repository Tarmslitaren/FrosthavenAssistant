import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

class ScrollableMenuCard extends StatelessWidget {
  static const double _kTopSpacing = 20;

  const ScrollableMenuCard({
    super.key,
    required this.child,
    this.maxWidth,
    this.onClose,
  });

  final Widget child;
  final double? maxWidth;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final content = maxWidth != null
        ? Container(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: child,
          )
        : child;
    return Card(
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Stack(children: [
            Column(
              children: [
                const SizedBox(height: _kTopSpacing),
                content,
                const SizedBox(height: kMenuCloseButtonSpacing),
              ],
            ),
            Positioned(
              width: kCloseButtonWidth,
              height: kButtonSize,
              right: 0,
              bottom: 0,
              child: TextButton(
                child: const Text('Close', style: kButtonLabelStyle),
                onPressed: () {
                  Navigator.pop(context);
                  onClose?.call();
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
