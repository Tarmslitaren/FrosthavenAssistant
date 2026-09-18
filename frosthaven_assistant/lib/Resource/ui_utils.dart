import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../services/service_locator.dart';
import '../services/translation_service.dart';
import 'state/game_state.dart';

void openDialogOld(BuildContext context, Widget widget) {
  showDialog(context: context, builder: (BuildContext context) => widget);
}

TextStyle getTitleTextStyle(double scale,
    {bool forceBlack = false, Settings? settings}) {
  //note force black since non modal menus are all white even in dark mode.
  return TextStyle(
      fontSize: kFontSizeTitle * scale,
      color: forceBlack || !(settings ?? getIt<Settings>()).darkMode.value
          ? Colors.black
          : Colors.white);
}

TextStyle getSmallTextStyle(double scale,
    {bool forceBlack = false, Settings? settings}) {
  //note force black since non modal menus are all white even in dark mode.
  return TextStyle(
      fontSize: kFontSizeSmall * scale,
      color: forceBlack || !(settings ?? getIt<Settings>()).darkMode.value
          ? Colors.black
          : Colors.white);
}

TextStyle getButtonTextStyle(double scale) {
  return TextStyle(fontSize: kFontSizeSmall * scale, color: Colors.blue);
}

TextStyle getCardTitleStyle(double fontSize, Shadow shadow, bool frosthavenStyle,
    {Color color = Colors.white, double? height}) {
  return TextStyle(
    fontFamily: frosthavenStyle ? 'GermaniaOne' : 'Pirata',
    color: color,
    fontSize: fontSize,
    height: height,
    shadows: [shadow],
  );
}

TextStyle getCardNumberStyle(double fontSize, Shadow shadow, bool frosthavenStyle,
    {Color color = Colors.white, double? height}) {
  return TextStyle(
    fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
    color: color,
    fontSize: fontSize,
    height: height,
    shadows: [shadow],
  );
}

TextStyle getWhiteShadowStyle(double fontSize, Shadow shadow, {double? height}) {
  return TextStyle(
    fontSize: fontSize,
    color: Colors.white,
    shadows: [shadow],
    height: height,
  );
}

Shadow textShadow(double scale) => Shadow(
  offset: Offset(kShadowOffset * scale, kShadowOffset * scale),
  color: Colors.black87,
  blurRadius: kShadowOffset * scale,
);

/// Whether the user has opted into the battery saver. Read through this helper
/// so call sites stay testable and do not each reach into the service locator.
///
/// Falls back to false (full quality) when [Settings] is not registered. These
/// helpers are called from low-level painting code that widget tests exercise
/// without booting the whole service locator, and a rendering-quality flag must
/// never be the reason a widget fails to build.
bool reducePowerEnabled({Settings? settings}) {
  final Settings? resolved =
      settings ?? (getIt.isRegistered<Settings>() ? getIt<Settings>() : null);
  // Deliberately the top tier only. `dimWhenIdle` trades convenience, not
  // visual quality, so it must not switch on the cheaper shadows and filters —
  // the board still renders at full fidelity while you are looking at it.
  return resolved?.powerMode.value == PowerMode.reducePower;
}

/// Whether the app is currently dimmed by [IdleDimmer].
///
/// Lives here rather than beside the widget so painting code can stand down
/// while nothing is visible — notably the looping text shimmer, which would
/// otherwise keep repainting at full rate behind the scrim and spend more power
/// than the dimming saves.
final ValueNotifier<bool> isDimmed = ValueNotifier<bool>(false);

/// Whether the app should dim itself after a period without input.
///
/// True for [PowerMode.dimWhenIdle] only: [PowerMode.reducePower] hands the
/// display to the system, which dims and sleeps it more aggressively than this
/// ever would, so running both would just fight.
bool dimWhenIdleEnabled({Settings? settings}) {
  final Settings? resolved =
      settings ?? (getIt.isRegistered<Settings>() ? getIt<Settings>() : null);
  return resolved?.powerMode.value == PowerMode.dimWhenIdle;
}

/// A blurred shadow normally; a hard offset shadow in reduce-power mode.
///
/// A non-zero [BoxShadow.blurRadius] makes the GPU run a real blur pass. This
/// shadow is applied to every card and monster box, so dropping the blur is the
/// single largest per-frame saving available without changing layout.
BoxShadow cardBoxShadow(double scale, {Settings? settings}) => BoxShadow(
  color: Colors.black45,
  blurRadius: reducePowerEnabled(settings: settings) ? 0 : kCardShadowBlur * scale,
  offset: Offset(kCardShadowOffsetX * scale, kCardShadowOffsetY * scale),
);

/// Applies a gaussian blur to [child], or skips it in reduce-power mode.
///
/// Used for the fake drop shadows behind class icons. A real blur is a full
/// GPU pass; skipping it leaves the offset silhouette, so the shadow is still
/// there, just hard-edged instead of soft.
Widget powerAwareBlur(
    {required double sigma, required Widget child, Settings? settings}) {
  if (reducePowerEnabled(settings: settings)) {
    return child;
  }
  return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child);
}

/// `medium` enables mipmapping; `low` is plain bilinear and cheaper to sample.
/// The difference is hard to see on the small icons this is used for.
FilterQuality powerAwareFilterQuality({Settings? settings}) =>
    reducePowerEnabled(settings: settings)
        ? FilterQuality.low
        : FilterQuality.medium;

bool isLargeTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth < screenHeight && screenHeight > kLargeTabletMinDimension) {
    return true;
  }
  if (screenWidth > screenHeight && screenWidth > kLargeTabletMinDimension) {
    return true;
  }
  return false;
}

bool isPhoneScreen(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  if (screenWidth > screenHeight && screenHeight < kPhoneScreenMaxDimension) {
    return true;
  }
  if (screenWidth < screenHeight && screenWidth < kPhoneScreenMaxDimension) {
    return true;
  }
  return false;
}

double getModalMenuScale(BuildContext context) {
  double scale = 1;
  if (!isPhoneScreen(context)) {
    scale = kModalScaleTablet;
    if (isLargeTablet(context)) {
      scale = kModalScaleLargeTablet;
    }
  }
  return scale;
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

void openDialog(BuildContext context, Widget widget) {
  openDialogWithDismissOption(context, widget, true);
}

void openDialogWithDismissOption(
    BuildContext context, Widget widget, bool dismissible) {
  // Guard against contexts with no Navigator ancestor (e.g. widget deactivated
  // mid-gesture: _parent is null before dispose() cancels the recognizer).
  // In release mode navigator! would throw TypeError; this early-outs safely.
  if (Navigator.maybeOf(context) == null) return;
  //could potentially modify edge insets based on screen width.
  Widget innerWidget = Stack(children: [
    Positioned(
      child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(kDialogInsetPadding),
          child: widget),
    )
  ]);
  showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (BuildContext context) => innerWidget);
}

//used to get transparent background when dragging in re-orderable widgets
const double _kDraggableElevation = 6.0;

Widget defaultBuildDraggableFeedback( // ignore: avoid-returning-widgets, top-level utility function for draggable feedback
    BuildContext _, BoxConstraints constraints, Widget child) {
  return Transform(
    transform: Matrix4.rotationZ(0),
    alignment: FractionalOffset.topLeft,
    child: Material(
      elevation: _kDraggableElevation,
      color: Colors.transparent,
      borderRadius: BorderRadius.zero,
      child: Card(
          color: Colors.transparent,
          child: ConstrainedBox(constraints: constraints, child: child)),
    ),
  );
}

final Set<String> _ghVersionSet = {
  "attack",
  "damage",
  "disarm",
  "flying",
  "heal",
  "immobilize",
  "invisible",
  "jump",
  "loot",
  "move",
  "pierce",
  "poison",
  "push",
  "pull",
  "stun",
  "target",
  "range",
  "retaliate",
  "shield",
  "strengthen",
  "teleport",
  "use",
  "wound"
};

bool hasGHVersion(String name) {
  return _ghVersionSet.contains(name);
}

const TextStyle toastTextStyle =
    TextStyle(fontFamily: "markazi", fontSize: kFontSizeToast);

String _translateToastText(String text) {
  if (!getIt.isRegistered<TranslationService>()) return text;
  final ts = getIt<TranslationService>();
  return text.split('\n').map((line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return line;
    final translated = ts.t(trimmed);
    if (translated != trimmed) {
      return line.replaceFirst(trimmed, translated);
    }
    return line;
  }).join('\n');
}

GestureDetector createToastContent(BuildContext context, String text) { // ignore: avoid-returning-widgets, top-level utility function for toast content
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
    child: Text(_translateToastText(text), style: toastTextStyle),
  );
}

void showToast(BuildContext context, String text) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.teal,
      content: createToastContent(context, text),
    ));
  }
}

Future<void> showToastSticky(BuildContext context, String text,
    {GameState? gameState}) async {
  if (context.mounted) {
    await ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          duration: const Duration(days: 1),
          backgroundColor: Colors.teal,
          content: createToastContent(context, text),
        ))
        .closed;
    if ((gameState ?? getIt<GameState>()).toastMessage.value == text) {
      GameUtilMethods.setToastMessage("");
    }
  }
}

Future<void> showErrorToastStickyWithRetry(
    BuildContext context, String text, Function() retry,
    {GameState? gameState}) async {
  ScaffoldMessenger.of(context).clearSnackBars();
  await ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        duration: const Duration(days: 1),
        backgroundColor: Colors.redAccent,
        content: Row(
          children: [
            Expanded(child: createToastContent(context, text)),
            TextButton(
                onPressed: () {
                  retry();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text(AppLocalizations.of(context)!.retry,
                    style: const TextStyle(
                        fontFamily: "markazi",
                        fontSize: kFontSizeToast,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ))
      .closed;
  if ((gameState ?? getIt<GameState>()).toastMessage.value == text) {
    GameUtilMethods.setToastMessage("");
  }
}
