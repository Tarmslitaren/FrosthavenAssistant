import 'dart:math';

import 'package:flutter/material.dart';

double getScaleByReference(BuildContext context) {
  return _scaleByReference(context, 495.0, 640.0);
}

double _scaleByReference(BuildContext context, double referenceWidth, double maxWidth) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  double fraction = width/referenceWidth;
  return fraction;
}

