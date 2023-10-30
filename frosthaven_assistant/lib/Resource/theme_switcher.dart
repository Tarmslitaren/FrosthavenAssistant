import 'package:flutter/material.dart';

import '../Layout/theme.dart';

class ThemeSwitcher extends InheritedWidget {
  final ThemeSwitcherWidgetState data;

  const ThemeSwitcher({
    super.key,
    required this.data,
    required super.child,
  });

  static ThemeSwitcherWidgetState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>()!.data;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) {
    return this != oldWidget;
  }
}

class ThemeSwitcherWidget extends StatefulWidget {
  final ThemeData initialTheme;
  final Widget child;

  const ThemeSwitcherWidget(
      {super.key, required this.initialTheme, required this.child});

  @override
  ThemeSwitcherWidgetState createState() {
    return ThemeSwitcherWidgetState();
  }
}

class ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  ThemeData themeData = theme;

  void switchTheme(ThemeData theme) {
    setState(() {
      themeData = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = themeData;
    return ThemeSwitcher(
      data: this,
      child: widget.child,
    );
  }
}
