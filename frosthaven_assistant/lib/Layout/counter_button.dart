import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Resource/app_constants.dart';
import '../Resource/commands/change_stat_commands/change_stat_command.dart';
import '../Resource/game_methods.dart';
import '../Resource/state/game_state.dart';
import 'view_models/counter_button_view_model.dart';

class CounterButton extends StatefulWidget {
  static const double _kTextHeight = 0.5;

  const CounterButton(
      {super.key,
      required this.notifier,
      required this.command,
      required this.maxValue,
      required this.image,
      required this.showTotalValue,
      required this.color,
      required this.figureId,
      required this.ownerId,
      required this.scale,
      this.extraImage});

  final ValueListenable<int> notifier;
  final ChangeStatCommand command;
  final int maxValue;
  final String image;
  final String figureId;
  final String? ownerId;
  final bool showTotalValue;
  final Color color;
  final double scale;
  final String? extraImage;

  @override
  State<StatefulWidget> createState() {
    return CounterButtonState();
  }
}

class CounterButtonState extends State<CounterButton> {
  late final CounterButtonViewModel _vm; // ignore: avoid-late-keyword
  final totalChangeValue = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _vm = CounterButtonViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final FigureState? figure =
        GameMethods.getFigure(widget.ownerId, widget.figureId);
    if (figure == null && widget.figureId != "unknown") {
      //in case it dies and was removed from the list
      return Container();
    }
    return RepaintBoundary(child:Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: kButtonSize * widget.scale,
          height: kButtonSize * widget.scale,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
              onPressed: () {
                widget.command.setChange(-1);
                if (widget.notifier.value > 0) {
                  totalChangeValue.value--;
                  _vm.executeCommand(widget.command);
                  if (widget.figureId != "unknown" &&
                      widget.notifier == figure?.health &&
                      figure != null &&
                      figure.health.value <= 0) {
                    {
                      Navigator.pop(context);
                    }
                  }
                }
              })),
      Stack(children: [
        SizedBox(
          width: kIconSize * widget.scale,
          height: kIconSize * widget.scale,
          child: Image(
            color: widget.color,
            colorBlendMode: BlendMode.modulate,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            image: AssetImage(widget.image),
          ),
        ),
        if (widget.extraImage != null)
          SizedBox(
            width: kIconSize * widget.scale,
            height: kIconSize * widget.scale,
            child: Image(
              color: Colors.black54,
              colorBlendMode: BlendMode.modulate,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              image: AssetImage(widget.extraImage!), // ignore: avoid-non-null-assertion
            ),
          ),
        ValueListenableBuilder<int>(
            valueListenable: widget.notifier,
            builder: (context, value, child) {
              String text = "";
              if (totalChangeValue.value > 0) {
                text = "+${totalChangeValue.value.toString()}";
              } else if (totalChangeValue.value != 0) {
                text = totalChangeValue.value.toString();
              }
              if (widget.showTotalValue) {
                text = widget.notifier.value.toString();
              }
              var shadow = Shadow(
                offset: Offset(1 * widget.scale, 1 * widget.scale),
                color: Colors.black,
                blurRadius: 1 * widget.scale,
              );
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    text,
                    style: TextStyle(
                        height: CounterButton._kTextHeight,
                        fontSize: kFontSizeBody * widget.scale,
                        color: Colors.white,
                        shadows: [shadow]),
                  ));
            })
      ]),
      SizedBox(
          width: kButtonSize * widget.scale,
          height: kButtonSize * widget.scale,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
            onPressed: () {
              final value = widget.notifier.value;
              widget.command.setChange(1);
              if (value < widget.maxValue) {
                totalChangeValue.value++;
                _vm.executeCommand(widget.command);
                if (widget.figureId != "unknown" &&
                    widget.notifier.value <= 0 &&
                    widget.notifier == figure?.health) {
                  Navigator.pop(context);
                }
              }
            },
          )),
    ]));
  }
}
