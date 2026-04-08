import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.cardMargin,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? cardMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        margin: cardMargin,
        child: Stack(children: [
          child,
          Positioned(
            width: 100,
            height: 40,
            right: 0,
            bottom: 0,
            child: TextButton(
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
