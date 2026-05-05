import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsCheckbox extends StatelessWidget {
  const SettingsCheckbox({
    super.key,
    required this.title,
    required this.notifier,
    required this.onChanged,
  });

  final String title;
  final ValueListenable<bool> notifier;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, _) => CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
      ),
    );
  }
}
