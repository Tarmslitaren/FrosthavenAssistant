import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

double maxWidth = (740.0 * getIt<Settings>().userScalingMainList.value);
const double referenceWidth = 412.0;

void setMaxWidth() {
  maxWidth = (740.0 * getIt<Settings>().userScalingMainList.value);
}

double getScaleByReference(BuildContext context) {
  return _scaleByReference(context, referenceWidth, maxWidth);
}

//not used
double getMainListMargin(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  double fraction = width / referenceWidth;
  if (screenSize.width > referenceWidth) {
    return max((screenSize.width - fraction * referenceWidth) / 2, 0);
  }
  return 0.0;
}

bool modifiersFitOnBar(BuildContext context) {
  Settings settings = getIt<Settings>();
  double screenWidth = MediaQuery.of(context).size.width;
  double referenceMinWidthWithModifiersOnBar = 370;
  double barSize = screenWidth / settings.userScalingBars.value;
  if (barSize < referenceMinWidthWithModifiersOnBar) {
    return false;
  }
  return true;
}

double getMainListWidth(BuildContext context) {
  //wrong
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);

  return width;
}

double _scaleByReference(
    BuildContext context, double referenceWidth, double maxWidth) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  double fraction = width / referenceWidth;
  return fraction;
}
