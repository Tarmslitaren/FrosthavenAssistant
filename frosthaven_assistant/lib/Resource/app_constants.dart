/// Shared UI constants for the Frosthaven Assistant app.

/// Font sizes (static, unscaled — multiply by the scale factor where needed)
const double kFontSizeSmall = 14;        // trailing edition labels, small body text
const double kFontSizeBody = 16;         // body text in menus and cards
const double kFontSizeTitle = 18;        // list-tile titles, menu headings
const double kFontSizeButtonLabel = 20;  // action button labels (Close, Send, etc.)
const double kFontSizeHeading = 24;      // section headers, "no results" messages
const double kFontSizeToast = 28;        // toast / snackbar messages

/// Widget dimensions (multiply by the screen scale factor where used as kButtonSize * scale)
const double kButtonSize = 40;   // icon buttons and numpad buttons
const double kIconSize = 30;     // stat icons and list-tile leading images

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
