import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

const double _kMaxListWidth = 740.0;
const double _kReferenceMinBarWidth = 370.0;
double maxWidth = (_kMaxListWidth * getIt<Settings>().userScalingMainList.value);
const double referenceWidth = 412.0;

void setMaxWidth({Settings? settings}) {
  settings = settings ?? getIt<Settings>();
  maxWidth = (_kMaxListWidth * settings.userScalingMainList.value);
}

double getScaleByReference(BuildContext context) {
  return _scaleByReference(context, referenceWidth, maxWidth);
}

bool modifiersFitOnBar(BuildContext context, {Settings? settings}) {
  settings = settings ?? getIt<Settings>();
  double screenWidth = MediaQuery.of(context).size.width;
  double referenceMinWidthWithModifiersOnBar = _kReferenceMinBarWidth;
  double barSize = screenWidth / settings.userScalingBars.value;
  if (barSize < referenceMinWidthWithModifiersOnBar) {
    return false;
  }

  return true;
}

double getMainListWidth(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;

  return min(screenSize.width, maxWidth);
}

double _scaleByReference(
    BuildContext context, double referenceWidth, double maxWidth) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);

  return width / referenceWidth;
}

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject =
        findRenderObject(); // Get the RenderObject associated with the widget
    final translation = renderObject
        ?.getTransformTo(null)
        .getTranslation(); // Get its transformation matrix and extract translation

    if (translation != null && renderObject?.paintBounds != null) {
      final offset =
          Offset(translation.x, translation.y); // Convert translation to Offset

      return renderObject!.paintBounds
          .shift(offset); // Shift the paint bounds by the offset
    } else {
      return null;
    }
  }
}
