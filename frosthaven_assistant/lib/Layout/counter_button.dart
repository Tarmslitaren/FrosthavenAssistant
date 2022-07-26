import 'package:flutter/material.dart';

import '../Resource/commands/change_stat_commands/change_stat_command.dart';
import '../Resource/game_methods.dart';
import '../Resource/game_state.dart';
import '../services/service_locator.dart';

class CounterButton extends StatefulWidget {
  final ValueNotifier<int> notifier;
  final ChangeStatCommand command;
  final int maxValue;
  final String image;
  final String figureId;
  final String ownerId;
  final bool showTotalValue;
  final Color color;

  CounterButton(this.notifier, this.command, this.maxValue, this.image, this.showTotalValue, this.color, {Key? key, required this.figureId, required this.ownerId}) : super(key: key){}

  @override
  State<StatefulWidget> createState() {
    return CounterButtonState();
  }
}

class CounterButtonState extends State<CounterButton> {
  GameState gameState = getIt<GameState>();
  final totalChangeValue = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    Figure? figure = GameMethods.getFigure(widget.ownerId, widget.figureId);
    if (figure == null) { //in case it dies and was removed from the list
      return Container();
    }
    return Row(children: [
      Container(
          width: 40,
          height: 40,
          child: IconButton(
              icon: Image.asset('assets/images/psd/sub.png'),
//iconSize: 30,
              onPressed: () {

                widget.command.setChange(-1);
                if (widget.notifier.value > 0) {
                  totalChangeValue.value--;
                  gameState.action(widget.command);
                  if ( widget.notifier == figure.health && figure.health.value <= 0) {
                    {
                      Navigator.pop(context);
                    }
                  }
                }
              })),
      Stack(children: [
        Container(
          width: 40,
          height: 40,
          child: Image(
            color: widget.color,
            colorBlendMode: BlendMode.modulate,
            image: AssetImage(widget.image),
          ),
        ),
        ValueListenableBuilder<int>(
            valueListenable: widget.notifier,
            builder: (context, value, child) {
              String text = "";
              if(totalChangeValue.value > 0) {
                text = "+${totalChangeValue.value.toString()}";
              }
              else if(totalChangeValue.value != 0) {
                text = totalChangeValue.value.toString();
              }
              if(widget.showTotalValue) {
                text = widget.notifier.value.toString();
              }
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(text, style: TextStyle(color: widget.color,
                      shadows: const [
                        Shadow(offset: Offset(1, 1), color: Colors.black)]
                  ),)
              );
            })
      ]),
      Container(
          width: 40,
          height: 40,
          child: IconButton(
            icon: Image.asset('assets/images/psd/add.png'),
//iconSize: 30,
            onPressed: () {
              widget.command.setChange(1);
              if (widget.notifier.value < widget.maxValue) {
                totalChangeValue.value++;
                gameState.action(widget.command);
                if (widget.notifier.value <= 0 && widget.notifier == figure.health) {
                  Navigator.pop(context);
                }
              }
//increment
            },
          )),
    ]);
  }

}
