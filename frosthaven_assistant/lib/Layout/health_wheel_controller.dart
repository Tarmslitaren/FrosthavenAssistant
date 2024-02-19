import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/select_health_wheel.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/state/game_state.dart';
import '../services/service_locator.dart';

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class HealthWheelController extends StatefulWidget {
  final String figureId;
  final String ownerId;
  final Widget child;

  const HealthWheelController(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.child});

  @override
  HealthWheelControllerState createState() => HealthWheelControllerState();
}

class HealthWheelControllerState extends State<HealthWheelController> {
  OverlayEntry? entry;

  final wheelDelta = ValueNotifier<double>(0);
  final wheelTimeDelta = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    hideOverlay();
  }

  void hideOverlay() {
    if (entry != null && entry!.mounted) {
      entry!.remove();
      entry!.dispose();
      entry = null;
      getIt<GameState>().updateList.value++;
    }
  }

  void showOverlay(String figureId, double scale, BuildContext context) {
    double dx = context.globalPaintBounds!.topCenter.dx - 100 * scale;
    double dy = context.globalPaintBounds!.topCenter.dy - 40 * scale;
    var selectHealthWheel = SelectHealthWheel(
        key: UniqueKey(),
        data: GameMethods.getFigure(widget.ownerId, widget.figureId)!,
        figureId: figureId,
        ownerId: widget.ownerId,
        delta: wheelDelta,
        time: wheelTimeDelta);
    entry = OverlayEntry(
        builder: (context) => Positioned(
            left: dx,
            top: dy,
            width: 200 * scale,
            height: 50 * scale,
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
