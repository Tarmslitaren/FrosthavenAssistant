import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

final _linuxFallback = !kIsWeb && Platform.isLinux
    ? const ['NotoSans', 'NotoSansKR', 'NotoSansSC', 'NotoSansTC', 'NotoSansThai']
    : const <String>[];

final theme = ThemeData(
  useMaterial3: false,
  primarySwatch: Colors.lightBlue,
  fontFamily: 'Pirata',
  fontFamilyFallback: _linuxFallback,
);

final themeFH = ThemeData(
  useMaterial3: false,
  primarySwatch: Colors.lightBlue,
  fontFamily: 'GermaniaOne',
  fontFamilyFallback: _linuxFallback,
);
