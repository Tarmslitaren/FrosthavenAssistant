import 'package:flutter/material.dart';

class ElementButton extends StatefulWidget {
  final String icon;
  final double width;
  final Color color;
  final double borderWidth = 2;
  const ElementButton({Key? key, required this.icon, this.width = 40, required this.color }) : super(key: key);

  @override
  _AnimatedContainerButtonState createState() => _AnimatedContainerButtonState();
}


class _AnimatedContainerButtonState extends State<ElementButton> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  bool _half = false;
  bool _full = true;
  late double _height;
  late Color _color;
  late BorderRadiusGeometry _borderRadius;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    _height = widget.width;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width-widget.borderWidth)
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: () {
          setState(() {
            _full = false;
            _half = true;
            _color = widget.color;
            _height = widget.width/2;
            _borderRadius = BorderRadius.only(
                bottomLeft: Radius.circular(widget.width/2-widget.borderWidth),
                bottomRight: Radius.circular(widget.width/2-widget.borderWidth)
            );

          });
        },
        onTap: () {
          // Use setState to rebuild the widget with new values.
          setState(() {
            // Create a random number generator.
            if(_full) {
              _full = false;
              _half = false;
            } else if(_half) {
              _half = false;
            } else {
              _full = true;
            }
            if(_half) {
              _height = widget.width/2;
              _color = widget.color;
              _borderRadius = BorderRadius.only(
                  bottomLeft: Radius.circular(_height-widget.borderWidth),
                  bottomRight: Radius.circular(_height-widget.borderWidth)
              );
            }
            else if(_full) {
              _height = widget.width;
              _color = widget.color;
              _borderRadius = BorderRadius.all(
                  Radius.circular(widget.width-widget.borderWidth)
              );
            } else {
              _height = widget.width;
              _color = Colors.transparent;
              _borderRadius = BorderRadius.all(
                  Radius.circular(widget.width-widget.borderWidth)
              );
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            /*Container(
              width: widget.width,
              height: widget.width,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),*/
            /*Container(
              width: widget.width-widget.borderWidth,
              height: widget.width-widget.borderWidth,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),*/

            //TODO: alingment bottom center mkaes the color overlop the border.
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                // Use the properties stored in the State class.
                width: widget.width-widget.borderWidth,
                height: _height-widget.borderWidth,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: _color,
                  borderRadius: _borderRadius,
                  boxShadow: [
                    _full || _half? BoxShadow(
                      //spreadRadius: 2
                      blurRadius: 2
                    ) :
                    BoxShadow(
                      color: Colors.transparent,
                    )
                  ]
                ),
                // Define how long the animation should take.
                duration: const Duration(seconds: 1),
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.fastOutSlowIn,
              ),
            ),

            Image(
              //fit: BoxFit.contain,
              height: widget.width*0.8,
              image: AssetImage(widget.icon),
              width: widget.width*0.8,

            ),
          ],
        )
    );
  }
}