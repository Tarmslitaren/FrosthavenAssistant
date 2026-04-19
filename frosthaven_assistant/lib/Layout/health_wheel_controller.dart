import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/select_health_wheel.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/game_methods.dart';
import '../Resource/state/game_state.dart';
import 'view_models/health_wheel_controller_view_model.dart';

class HealthWheelController extends StatefulWidget {
  const HealthWheelController(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.child,
      this.gameState});

  final String figureId;
  final String? ownerId;
  final Widget child;
  final GameState? gameState;

  @override
  HealthWheelControllerState createState() => HealthWheelControllerState();
}

class HealthWheelControllerState extends State<HealthWheelController> {
  static const double _kOverlayXOffset = 100.0;
  static const double _kOverlayYOffset = 40.0;
  static const double _kOverlayWidth = 200.0;
  static const double _kOverlayHeight = 50.0;

  OverlayEntry? entry;
  HealthWheelControllerViewModel? _vmInstance;
  HealthWheelControllerViewModel get _vm => _vmInstance ??= HealthWheelControllerViewModel(gameState: widget.gameState);

  final wheelDelta = ValueNotifier<double>(0);
  final wheelTimeDelta = ValueNotifier<int>(0);


  @override
  void dispose() {
    super.dispose();
    hideOverlay();
  }

  void hideOverlay() {
    if (entry != null && entry!.mounted) {
      entry?.remove();
      entry?.dispose();
      entry = null;
      _vm.triggerListUpdate();
    }
  }

  void showOverlay(String figureId, double scale, BuildContext context) {
    final figure = GameMethods.getFigure(widget.ownerId, widget.figureId);
    if (figure == null) return;
    double dx = context.globalPaintBounds!.topCenter.dx - _kOverlayXOffset * scale;
    double dy = context.globalPaintBounds!.topCenter.dy - _kOverlayYOffset * scale;
    var selectHealthWheel = SelectHealthWheel(
        key: UniqueKey(),
        data: figure,
        figureId: figureId,
        ownerId: widget.ownerId,
        delta: wheelDelta,
        time: wheelTimeDelta);
    entry = OverlayEntry(
        builder: (context) => Positioned(
            left: dx,
            top: dy,
            width: _kOverlayWidth * scale,
            height: _kOverlayHeight * scale,
            child:
                Material(color: Colors.transparent, child: selectHealthWheel)));
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    int? lastTimeStamp;

    return GestureDetector(
        onHorizontalDragStart: (details) {
          hideOverlay();
          final overlay = Overlay.of(context);
          overlay
              .deactivate(); //this removes prior popup if it ended up hanging around for some reason
          showOverlay(widget.figureId, scale, context);
        },
        onHorizontalDragCancel: () {
          hideOverlay();
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          int timeDiff = 0;
          if (lastTimeStamp != null) {
            timeDiff = details.sourceTimeStamp!.inMicroseconds - lastTimeStamp!;
          }

          wheelTimeDelta.value = timeDiff;
          wheelDelta.value = details.delta.dx;

          lastTimeStamp = details.sourceTimeStamp!.inMicroseconds;
        },
        onHorizontalDragEnd: (details) {
          //close scrollview and run changeHeath command
          hideOverlay();
        },
        child: widget.child);
  }
}
