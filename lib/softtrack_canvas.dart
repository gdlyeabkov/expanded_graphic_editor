// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class SofttrackCanvas extends CustomPainter {

  late BuildContext context;
  double touchX = 0;
  double touchY = 0;

  SofttrackCanvas(context, touchX, touchY) {
    this.context = context;
    this.touchX = touchX;
    this.touchY = touchY;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var myCanvas = TouchyCanvas(context, canvas);
    Paint paint = Paint();
    paint.color = Colors.transparent;
    paint.color = Colors.red;
    canvas.drawLine(Offset(0, 0), Offset(touchX, touchY), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}