import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/select_health_wheel.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import '../Resource/state/figure_state.dart';

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
      {Key? key,
        required this.figureId,
        required this.ownerId,
        required this.child})
      : super(key: key);


  @override
  HealthWheelControllerState createState() => HealthWheelControllerState();
}

class HealthWheelControllerState extends State<HealthWheelController> {
  late FigureState data;
  OverlayEntry? entry;
  SelectHealthWheel? selectHealthWheel;

  final wheelDelta = ValueNotifier<double>(0);
  final wheelTimeDelta = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    data = GameMethods.getFigure(widget.ownerId, widget.figureId)!;
  }


  void hideOverlay() {
    if (entry != null && entry!.mounted) {
      entry!.remove();
      entry!.dispose();
    }
  }

  void showOverlay(String figureId, double scale, BuildContext context) {
    double dx = context.globalPaintBounds!.topCenter.dx - 100 * scale;
    double dy = context.globalPaintBounds!.topCenter.dy - 100; //TODO: why is this not correct?
    selectHealthWheel ??= SelectHealthWheel(
        data: data,
        figureId: figureId,
        ownerId: widget.ownerId,
        delta: wheelDelta,
        time: wheelTimeDelta);
    entry = OverlayEntry(
        builder: (context) => Positioned(
            left: dx,
            top: dy,
            width: 200 * scale,
            child: Material(
                color: Colors.transparent, child: selectHealthWheel!)));
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    int? lastTimeStamp;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        showOverlay(widget.figureId, scale, context);
      },
      onHorizontalDragCancel: () {
        hideOverlay();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (selectHealthWheel != null) {
          int timeDiff = 0;
          if (lastTimeStamp != null) {
            timeDiff = details.sourceTimeStamp!.inMicroseconds - lastTimeStamp!;
          }

          wheelTimeDelta.value = timeDiff;
          wheelDelta.value = details.delta.dx;

          lastTimeStamp = details.sourceTimeStamp!.inMicroseconds;
        }
      },
      onHorizontalDragEnd: (details) {
        //close scrollview and run changeHeath command
        hideOverlay();
      },
      child: widget.child);
  }
}
