import 'dart:math';

import 'package:flutter/material.dart';

const double maxWidth = 740.0; //todo; scale this from settings
const double referenceWidth = 412.0;

double getScaleByReference(BuildContext context) {
  return _scaleByReference(context, referenceWidth, maxWidth);
}

//not used
double getMainListMargin(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  double fraction = width/referenceWidth;
  if(screenSize.width > referenceWidth) {
    return max((screenSize.width - fraction * referenceWidth)/2, 0);
  }
  return 0.0;
}

double getMainListWidth(BuildContext context) { //wrong
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  return width;// - getMainListMargin(context)*2;
}

double _scaleByReference(BuildContext context, double referenceWidth, double maxWidth) {
  var screenSize = MediaQuery.of(context).size;
  var width = min(screenSize.width, maxWidth);
  double fraction = width/referenceWidth;
  return fraction;
}

