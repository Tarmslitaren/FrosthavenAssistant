import 'package:flutter/material.dart';

import '../Layout/theme.dart';

class ThemeSwitcher extends InheritedWidget {
  final ThemeSwitcherWidgetState data;

  const ThemeSwitcher({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

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
      {Key? key, required this.initialTheme, required this.child})
      : super(key: key);

  @override
  ThemeSwitcherWidgetState createState() {
    return ThemeSwitcherWidgetState();
  }
}

class ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  ThemeData themeData = theme;

  void switchTheme(ThemeData themee) {
    setState(() {
      themeData = themee;
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
