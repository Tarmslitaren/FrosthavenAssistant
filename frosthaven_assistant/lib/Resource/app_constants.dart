import 'package:flutter/material.dart';

// Shared UI constants for the Frosthaven Assistant app.

// Font sizes (static, unscaled — multiply by the scale factor where needed)
const double kFontSizeSmall = 14;        // trailing edition labels, small body text
const double kFontSizeBody = 16;         // body text in menus and cards
const double kFontSizeTitle = 18;        // list-tile titles, menu headings
const double kFontSizeButtonLabel = 20;  // action button labels (Close, Send, etc.)
const double kFontSizeHeading = 24;      // section headers, "no results" messages
const double kFontSizeToast = 28;        // toast / snackbar messages

/// Widget dimensions (multiply by the screen scale factor where used as kButtonSize * scale)
const double kButtonSize = 40;   // icon buttons and numpad buttons
const double kIconSize = 30;     // stat icons and list-tile leading images

/// Bar and toolbar height (multiply by userScalingBars where needed)
const double kBarHeight = 40.0;

/// Background image opacity for dark/light mode
const double kDarkModeOpacity = 0.4;
const double kLightModeOpacity = 0.7;

/// Standard text/icon shadow — offset and blur are equal; multiply by scale factor
const double kShadowOffset = 1.0;

/// Card box-shadow (multiply by scale where needed)
const double kCardShadowBlur = 4.0;
const double kCardShadowOffsetX = 2.0;
const double kCardShadowOffsetY = 4.0;

/// Menu layout
const double kMenuCloseButtonSpacing = 34; // bottom padding that clears the positioned close button
const double kCloseButtonWidth = 100;      // width of the positioned close button

/// Image cache heights
const int kMonsterImageCacheHeight = 75;   // cache height for monster list-tile images
const int kCharacterIconCacheHeight = 80;  // cache height for character class icon images

/// Screen breakpoints (shortest dimension compared against orientation-corrected value)
const double kPhoneScreenMaxDimension = 600;
const double kLargeTabletMinDimension = 1200;

/// Modal menu scale factors
const double kModalScaleTablet = 1.5;
const double kModalScaleLargeTablet = 2.0;

/// Modal background opacity
const double kModalBackgroundOpacity = 0.8;

/// Dialog inset padding
const double kDialogInsetPadding = 18;

// Static TextStyles (no scale factor — use as-is or pass to style: parameter)
const TextStyle kButtonLabelStyle = TextStyle(fontSize: kFontSizeButtonLabel);
const TextStyle kTitleStyle = TextStyle(fontSize: kFontSizeTitle);
const TextStyle kHeadingStyle = TextStyle(fontSize: kFontSizeHeading);
const TextStyle kBodyStyle = TextStyle(fontSize: kFontSizeBody);
const TextStyle kSubtitleStyle = TextStyle(fontSize: kFontSizeSmall, color: Colors.grey);
const TextStyle kBodyBlackStyle = TextStyle(fontSize: kFontSizeBody, color: Colors.black);
