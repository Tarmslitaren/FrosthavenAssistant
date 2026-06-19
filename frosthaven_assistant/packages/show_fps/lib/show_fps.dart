import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

extension FPS on Duration {
  double get fps => inMicroseconds > 0 ? (1000000 / inMicroseconds) : 0;
  double get ms => inMicroseconds / 1000;
}

/// A widget that shows the current FPS with advanced monitoring features.
class ShowFPS extends StatefulWidget {
  /// Where the [ShowFPS] should be positioned.
  final Alignment alignment;

  /// Whether to show the [ShowFPS].
  /// ```dart
  /// ShowFPS(
  ///   visible: !kReleaseMode,
  ///   child: MyHomePage(),
  /// )
  /// ```
  final bool visible;

  /// Will the [ShowFPS] show the chart.
  final bool showChart;

  /// Where the [ShowFPS] should be assigned with a main widget to monitor.
  final Widget child;

  /// The border radius of the [ShowFPS].
  final BorderRadius borderRadius;

  /// Whether to show average FPS instead of instantaneous.
  final bool showAverage;

  /// Whether to show min/max FPS values.
  final bool showMinMax;

  /// Whether to show frame time in milliseconds.
  final bool showFrameTime;

  /// Whether to enable color-coded FPS text based on performance.
  final bool colorCodedText;

  /// Target FPS for the target line on the chart (default: 60).
  final double targetFps;

  /// Whether to show the target FPS line on the chart.
  final bool showTargetLine;

  /// Whether to highlight jank frames (frames significantly slower than average).
  final bool showJankIndicators;

  /// Jank threshold multiplier (frames taking this much longer than average are marked as jank).
  final double jankThreshold;

  /// Custom text style for the FPS display.
  final TextStyle? textStyle;

  /// Whether the widget can be dragged around.
  final bool draggable;

  /// Whether the widget can be collapsed/expanded by tapping.
  final bool collapsible;

  /// Sample rate - how many frames to skip between updates (1 = every frame).
  final int sampleRate;

  /// Maximum FPS for chart scale (default: 60).
  final double chartMaxFps;

  /// Whether to show frame budget indicator (percentage of 16.67ms used).
  final bool showFrameBudget;

  /// Whether to show dropped frame counter.
  final bool showDroppedFrames;

  /// FPS threshold for alerts (widget flashes when FPS drops below this).
  final double? alertThreshold;

  /// Whether double-tap hides the widget temporarily.
  final bool doubleTapToHide;

  /// Duration to hide widget after double-tap (default: 3 seconds).
  final Duration hideDuration;

  /// Background color of the FPS display.
  final Color backgroundColor;

  /// Color for good performance (high FPS).
  final Color goodColor;

  /// Color for poor performance (low FPS).
  final Color poorColor;

  /// Callback when FPS drops below alert threshold.
  final VoidCallback? onAlertTriggered;

  const ShowFPS({
    Key? key,
    this.alignment = Alignment.topRight,
    this.visible = true,
    this.showChart = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(11)),
    required this.child,
    this.showAverage = false,
    this.showMinMax = false,
    this.showFrameTime = false,
    this.colorCodedText = true,
    this.targetFps = 60,
    this.showTargetLine = false,
    this.showJankIndicators = true,
    this.jankThreshold = 1.5,
    this.textStyle,
    this.draggable = false,
    this.collapsible = false,
    this.sampleRate = 1,
    this.chartMaxFps = 60,
    this.showFrameBudget = false,
    this.showDroppedFrames = false,
    this.alertThreshold,
    this.doubleTapToHide = false,
    this.hideDuration = const Duration(seconds: 3),
    this.backgroundColor = const Color(0xaa000000),
    this.goodColor = const Color.fromARGB(255, 0, 162, 255),
    this.poorColor = const Color(0xfff44336),
    this.onAlertTriggered,
  }) : super(key: key);

  @override
  ShowFPSState createState() => ShowFPSState();
}

class ShowFPSState extends State<ShowFPS> with SingleTickerProviderStateMixin {
  Duration? previous;
  List<Duration> timings = [];
  double width = 50;
  double height = 30;
  double chartWidth = 150;
  double chartHeight = 80;
  late int framesToDisplay = chartWidth ~/ 5;

  // New state variables
  bool _isCollapsed = false;
  bool _isHidden = false;
  Offset _dragOffset = Offset.zero;
  int _frameCounter = 0;
  int _droppedFrames = 0;
  double _minFps = double.infinity;
  double _maxFps = 0;
  bool _isAlertActive = false;
  Timer? _hideTimer;
  late AnimationController _alertController;

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    SchedulerBinding.instance.addPostFrameCallback(update);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _alertController.dispose();
    super.dispose();
  }

  /// Updates the FPS counter with the current frame duration.
  void update(Duration duration) {
    // Guard against callbacks firing after disposal. Without this, the
    // unconditional addPostFrameCallback at the end of this method would
    // keep the callback chain alive past dispose(), causing setState to be
    // called on a dead element (null-check crash in framework.dart:1219).
    if (!mounted) return;

    _frameCounter++;

    if (_frameCounter % widget.sampleRate == 0) {
      setState(() {
        if (previous != null) {
          final frameDuration = duration - previous!;
          timings.add(frameDuration);

          if (timings.length > framesToDisplay) {
            timings = timings.sublist(timings.length - framesToDisplay);
          }

          // Update min/max
          final currentFps = frameDuration.fps;
          if (currentFps < _minFps && currentFps > 0) _minFps = currentFps;
          if (currentFps > _maxFps) _maxFps = currentFps;

          // Check for dropped frames (frames taking more than target frame time)
          final targetFrameTime = 1000 / widget.targetFps;
          if (frameDuration.ms > targetFrameTime * 1.5) {
            _droppedFrames++;
          }

          // Alert check
          if (widget.alertThreshold != null &&
              currentFps < widget.alertThreshold!) {
            if (!_isAlertActive) {
              _isAlertActive = true;
              _alertController.repeat(reverse: true);
              widget.onAlertTriggered?.call();
            }
          } else {
            if (_isAlertActive) {
              _isAlertActive = false;
              _alertController.stop();
              _alertController.value = 0;
            }
          }
        }

        previous = duration;
      });
    } else {
      previous ??= duration;
    }

    SchedulerBinding.instance.addPostFrameCallback(update);
  }

  @override
  void didUpdateWidget(covariant ShowFPS oldWidget) {
    if (oldWidget.visible && !widget.visible) {
      previous = null;
    }

    if (!oldWidget.visible && widget.visible) {
      SchedulerBinding.instance.addPostFrameCallback(update);
    }

    super.didUpdateWidget(oldWidget);
  }

  double get _averageFps {
    if (timings.isEmpty) return 0;
    final total = timings.fold<double>(0, (sum, t) => sum + t.fps);
    return total / timings.length;
  }

  double get _currentFps {
    if (timings.isEmpty) return 0;
    return timings.last.fps;
  }

  double get _currentMs {
    if (timings.isEmpty) return 0;
    return timings.last.ms;
  }

  double get _frameBudgetUsed {
    final targetMs = 1000 / widget.targetFps;
    return (_currentMs / targetMs * 100).clamp(0, 200);
  }

  Color _getFpsColor(double fps) {
    if (!widget.colorCodedText) {
      return const Color(0xffffffff);
    }
    final p = (fps / widget.targetFps).clamp(0.0, 1.0);
    return Color.lerp(widget.poorColor, widget.goodColor, p)!;
  }

  bool _isJankFrame(Duration timing) {
    if (!widget.showJankIndicators || timings.length < 5) return false;
    final avgMs =
        timings.fold<double>(0, (sum, t) => sum + t.ms) / timings.length;
    return timing.ms > avgMs * widget.jankThreshold;
  }

  void _handleDoubleTap() {
    if (!widget.doubleTapToHide) return;
    setState(() => _isHidden = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.hideDuration, () {
      if (mounted) setState(() => _isHidden = false);
    });
  }

  void _handleTap() {
    if (widget.collapsible) {
      setState(() => _isCollapsed = !_isCollapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fpsWidget;

    if (_isHidden) {
      fpsWidget = const SizedBox.shrink();
    } else if (_isCollapsed) {
      fpsWidget = _buildCollapsedView();
    } else if (widget.showChart) {
      fpsWidget = _buildChartView();
    } else {
      fpsWidget = _buildSimpleView();
    }

    if (widget.draggable) {
      fpsWidget = Positioned(
        left: widget.alignment == Alignment.topLeft ||
                widget.alignment == Alignment.centerLeft ||
                widget.alignment == Alignment.bottomLeft
            ? 8 + _dragOffset.dx
            : null,
        right: widget.alignment == Alignment.topRight ||
                widget.alignment == Alignment.centerRight ||
                widget.alignment == Alignment.bottomRight
            ? 8 - _dragOffset.dx
            : null,
        top: widget.alignment == Alignment.topLeft ||
                widget.alignment == Alignment.topCenter ||
                widget.alignment == Alignment.topRight
            ? 8 + _dragOffset.dy
            : null,
        bottom: widget.alignment == Alignment.bottomLeft ||
                widget.alignment == Alignment.bottomCenter ||
                widget.alignment == Alignment.bottomRight
            ? 8 - _dragOffset.dy
            : null,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _dragOffset += details.delta;
            });
          },
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          child: fpsWidget,
        ),
      );

      return Stack(
        children: [
          widget.child,
          if (widget.visible) fpsWidget,
        ],
      );
    }

    return Stack(
      alignment: widget.alignment,
      children: [
        widget.child,
        if (widget.visible)
          GestureDetector(
            onTap: _handleTap,
            onDoubleTap: _handleDoubleTap,
            child: fpsWidget,
          ),
      ],
    );
  }

  Widget _buildCollapsedView() {
    final displayFps = widget.showAverage ? _averageFps : _currentFps;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: _alertController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isAlertActive
                  ? Color.lerp(widget.backgroundColor, widget.poorColor,
                      _alertController.value)
                  : widget.backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: Text(
              displayFps.toStringAsFixed(0),
              style: widget.textStyle ??
                  TextStyle(
                    color: _getFpsColor(displayFps),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleView() {
    final displayFps = widget.showAverage ? _averageFps : _currentFps;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: _alertController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: _isAlertActive
                  ? Color.lerp(widget.backgroundColor, widget.poorColor,
                      _alertController.value)
                  : widget.backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (timings.isNotEmpty) ...[
                  Text(
                    'FPS: ${displayFps.toStringAsFixed(0)}',
                    style: widget.textStyle ??
                        TextStyle(
                          color: _getFpsColor(displayFps),
                          fontSize: 14,
                        ),
                  ),
                  if (widget.showFrameTime)
                    Text(
                      '${_currentMs.toStringAsFixed(2)}ms',
                      style: widget.textStyle ??
                          const TextStyle(
                            color: Color(0xaaffffff),
                            fontSize: 12,
                          ),
                    ),
                  if (widget.showMinMax && _minFps != double.infinity)
                    Text(
                      'Min: ${_minFps.toStringAsFixed(0)} Max: ${_maxFps.toStringAsFixed(0)}',
                      style: widget.textStyle ??
                          const TextStyle(
                            color: Color(0xaaffffff),
                            fontSize: 10,
                          ),
                    ),
                  if (widget.showFrameBudget)
                    Text(
                      'Budget: ${_frameBudgetUsed.toStringAsFixed(0)}%',
                      style: widget.textStyle ??
                          TextStyle(
                            color: _frameBudgetUsed > 100
                                ? widget.poorColor
                                : const Color(0xaaffffff),
                            fontSize: 10,
                          ),
                    ),
                  if (widget.showDroppedFrames)
                    Text(
                      'Dropped: $_droppedFrames',
                      style: widget.textStyle ??
                          TextStyle(
                            color: _droppedFrames > 0
                                ? widget.poorColor
                                : const Color(0xaaffffff),
                            fontSize: 10,
                          ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartView() {
    final displayFps = widget.showAverage ? _averageFps : _currentFps;
    final effectiveChartHeight = chartHeight - 24;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: _alertController,
        builder: (context, child) {
          return Container(
            width: chartWidth + 17,
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: _isAlertActive
                  ? Color.lerp(widget.backgroundColor, widget.poorColor,
                      _alertController.value)
                  : widget.backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (timings.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FPS: ${displayFps.toStringAsFixed(0)}',
                        style: widget.textStyle ??
                            TextStyle(
                              color: _getFpsColor(displayFps),
                              fontSize: 14,
                            ),
                      ),
                      if (widget.showFrameTime)
                        Text(
                          '${_currentMs.toStringAsFixed(1)}ms',
                          style: widget.textStyle ??
                              const TextStyle(
                                color: Color(0xaaffffff),
                                fontSize: 12,
                              ),
                        ),
                    ],
                  ),
                  if (widget.showMinMax && _minFps != double.infinity)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Min: ${_minFps.toStringAsFixed(0)} | Max: ${_maxFps.toStringAsFixed(0)}',
                        style: widget.textStyle ??
                            const TextStyle(
                              color: Color(0xaaffffff),
                              fontSize: 10,
                            ),
                      ),
                    ),
                  if (widget.showFrameBudget || widget.showDroppedFrames)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (widget.showFrameBudget)
                            Text(
                              'Budget: ${_frameBudgetUsed.toStringAsFixed(0)}%',
                              style: widget.textStyle ??
                                  TextStyle(
                                    color: _frameBudgetUsed > 100
                                        ? widget.poorColor
                                        : const Color(0xaaffffff),
                                    fontSize: 10,
                                  ),
                            ),
                          if (widget.showFrameBudget && widget.showDroppedFrames)
                            const Text(
                              ' | ',
                              style: TextStyle(
                                color: Color(0xaaffffff),
                                fontSize: 10,
                              ),
                            ),
                          if (widget.showDroppedFrames)
                            Text(
                              'Dropped: $_droppedFrames',
                              style: widget.textStyle ??
                                  TextStyle(
                                    color: _droppedFrames > 0
                                        ? widget.poorColor
                                        : const Color(0xaaffffff),
                                    fontSize: 10,
                                  ),
                            ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 4),
                SizedBox(
                  height: effectiveChartHeight,
                  width: chartWidth,
                  child: Stack(
                    children: [
                      // Target line
                      if (widget.showTargetLine)
                        Positioned(
                          bottom: (widget.targetFps / widget.chartMaxFps)
                                  .clamp(0.0, 1.0) *
                              effectiveChartHeight,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: const Color(0x88ffffff),
                          ),
                        ),
                      // Bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ...timings.map((timing) {
                            final p =
                                (timing.fps / widget.chartMaxFps).clamp(0.0, 1.0);
                            final isJank = _isJankFrame(timing);

                            return Padding(
                              padding: const EdgeInsets.only(right: 1.0),
                              child: Container(
                                width: 4,
                                height: p * effectiveChartHeight,
                                decoration: BoxDecoration(
                                  color: isJank
                                      ? widget.poorColor
                                      : Color.lerp(
                                          widget.poorColor,
                                          widget.goodColor,
                                          p,
                                        ),
                                  borderRadius: BorderRadius.circular(2),
                                  border: isJank
                                      ? Border.all(
                                          color: const Color(0xffffffff),
                                          width: 1,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A builder widget that provides animation state.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    Key? key,
    required this.animation,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder2(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder2({
    Key? key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
