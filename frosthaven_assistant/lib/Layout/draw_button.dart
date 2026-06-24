import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../Resource/app_constants.dart';
import '../Resource/enums.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import 'view_models/draw_button_view_model.dart';

class DrawButton extends StatefulWidget {
  const DrawButton({super.key, this.gameState});

  final GameState? gameState;

  @override
  DrawButtonState createState() => DrawButtonState();
}

class DrawButtonState extends State<DrawButton> {
  static const double _kRoundTextBottom = 2.0;
  static const double _kRoundTextLeft = 45.0;
  static const double _kButtonPadding = 10.0;
  static const double _kTextHeight = 0.8;

  // Lockout window applied when the button's underlying action changes
  // (roundState flips). Guards against stale-intent taps where the button
  // morphs between Draw and Next Round under the user's finger — either
  // from another client over the network or from a local double-tap.
  // Tuned against ~100ms typical LAN latency: 300ms ≈ 3× headroom without
  // feeling sluggish. See manual §9.5 ("Draw / Next Round button lockout").
  static const Duration _kSyncLockoutDuration = Duration(milliseconds: 300);
  static const Duration _kSyncFadeDuration = Duration(milliseconds: 120);

  DrawButtonViewModel? _vmInstance;
  DrawButtonViewModel get _vm =>
      _vmInstance ??= DrawButtonViewModel(gameState: widget.gameState);

  RoundState? _lastObservedRoundState;
  bool _isLockedOut = false;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _lastObservedRoundState = _vm.roundState.value;
    _vm.roundState.addListener(_onRoundStateChanged);
  }

  @override
  void dispose() {
    _vm.roundState.removeListener(_onRoundStateChanged);
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _onRoundStateChanged() {
    final next = _vm.roundState.value;
    if (next == _lastObservedRoundState) return;
    _lastObservedRoundState = next;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(_kSyncLockoutDuration, () {
      if (!mounted) return;
      setState(() {
        _isLockedOut = false;
      });
    });
    if (!mounted) return;
    setState(() {
      _isLockedOut = true;
    });
  }

  void _onPressed() {
    final blockedMessage = _vm.runAction();
    if (blockedMessage != null) {
      showToast(context, blockedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final scaling = _vm.userScalingBars.value;
          final shadow = textShadow(scaling);
          final locked = _isLockedOut;

          return RepaintBoundary(
              child: Stack(alignment: Alignment.centerLeft, children: [
            ValueListenableBuilder<int>(
              valueListenable: _vm.round,
              builder: (context, value, child) {
                return Positioned(
                    bottom: _kRoundTextBottom * scaling,
                    left: _kRoundTextLeft * scaling,
                    child: Text(_vm.roundText,
                        style: getWhiteShadowStyle(
                            kFontSizeSmall * scaling, shadow)));
              },
            ),
            ListenableBuilder(
              listenable: Listenable.merge([_vm.roundState, _vm.totalRounds]),
              builder: (context, child) {
                return AnimatedOpacity(
                    opacity: locked ? 0.5 : 1.0,
                    duration: _kSyncFadeDuration,
                    child: Container(
                        margin: EdgeInsets.zero,
                        height: kBarHeight * scaling,
                        width: _vm.buttonWidth * scaling,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.only(
                                    left: _kButtonPadding * scaling,
                                    right: _kButtonPadding * scaling),
                                alignment: Alignment.center),
                            onPressed: locked ? null : _onPressed,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _vm.isDrawPhase
                                    ? AppLocalizations.of(context)!.draw
                                    : AppLocalizations.of(context)!.nextRound,
                                style: getWhiteShadowStyle(
                                    kFontSizeBody * scaling, shadow,
                                    height: _kTextHeight),
                              )))));
              },
            )
          ]));
        });
  }
}
