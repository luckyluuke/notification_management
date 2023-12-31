import 'package:flutter/material.dart';

class TwoFlyingDots extends StatelessWidget {
  final double? dotsSize;
  final Color firstColor;
  final Color secondColor;
  TwoFlyingDots({required this.dotsSize, required this.firstColor, required this.secondColor});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlyingDot(color: firstColor, dotsSize: this.dotsSize),
      FlyingDot(color: secondColor, reverse: true, dotsSize: this.dotsSize),
    ]);
  }
}
class FlyingDot extends StatefulWidget {
  final Color? color;
  final bool? reverse;
  final double? dotsSize;
  const FlyingDot({Key? key, this.color, this.reverse, this.dotsSize}) : super(key: key);
  @override
  _FlyingDotState createState() => _FlyingDotState();
}
class _FlyingDotState extends State<FlyingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;
  late Animation<Offset> _position2;
  late Animation<Offset> _position3;
  late bool _reverse;
  double rangeX = 10.0;
  double rangeY = 5.0;

  @override
  void initState() {
    _reverse = widget.reverse ?? false;
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    Tween<Offset> start = _reverse
        ? Tween<Offset>(begin: Offset(-rangeX, 0), end: Offset(0, rangeY))
        : Tween<Offset>(begin: Offset(rangeX, 0), end: Offset(0, rangeY));
    Tween<Offset> middle = _reverse
        ? Tween<Offset>(begin: Offset(0, rangeY), end: Offset(rangeX, 0))
        : Tween<Offset>(begin: Offset(0, rangeY), end: Offset(-rangeX, 0));
    Tween<Offset> end = _reverse
        ? Tween<Offset>(begin: Offset(rangeX, 0), end: Offset(-rangeX, 0))
        : Tween<Offset>(begin: Offset(-rangeX, 0), end: Offset(rangeX, 0));
    _position = start.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 0.25),
      ),
    );
    _position2 = middle.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 0.5),
      ),
    );
    _position3 = end.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1),
      ),
    );
    //run animation
    _controller.repeat();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Offset offset = Offset.zero;
          if (_controller.value <= 0.25) {
            offset = _position.value;
          } else if (_controller.value <= 0.5) {
            offset = _position2.value;
          } else {
            offset = _position3.value;
          }
          return Transform.translate(
              offset: offset, child: Icon(Icons.circle, color: widget.color, size: widget.dotsSize));
        });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}