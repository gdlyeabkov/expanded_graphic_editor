// import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class SofttrackCanvas extends CustomPainter {

  late BuildContext context;
  double touchX = 0;
  double touchY = 0;
  List shapes = [];

  SofttrackCanvas(context, touchX, touchY, shapes) {
    this.context = context;
    this.touchX = touchX;
    this.touchY = touchY;
    this.shapes = shapes;
  }

  @override
  void paint(Canvas canvas, Size size) {

    for (var shape in shapes) {
      String type = shape['type'];
      if (type == 'line') {
        double x1 = shape['x1'];
        double y1 = shape['y1'];
        double x2 = shape['x2'];
        double y2 = shape['y2'];
        Color color  = shape['color'];
        Paint linePaint = Paint();
        linePaint.color = color;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      } else if (type == 'eraser') {
        Paint eraserPaint = Paint();
        eraserPaint.color = Colors.white;
        double x1 = shape['x1'];
        double y1 = shape['y1'];
        double x2 = shape['x2'];
        double y2 = shape['y2'];
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), eraserPaint);
      } else if (type == 'curve') {
        Paint curvePaint = Paint();
        curvePaint.style = PaintingStyle.stroke;
        curvePaint.strokeWidth = 1.0;
        String curveType = shape['curveType'];
        if (curveType == 'polygone') {
          Path path = Path();
          // List<Offset> points = [
          //   Offset(100, 500),
          //   Offset(200, 600),
          //   Offset(300, 400),
          // ];
          List<Offset> points = shape['points'];
          print('points: ${points.length}');
          path.addPolygon(points, true);
          canvas.drawPath(path, curvePaint);
        } else {
          double x1 = shape['x1'];
          double y1 = shape['y1'];
          double x2 = shape['x2'];
          double y2 = shape['y2'];
          Color color  = shape['color'];
          curvePaint.color = color;
          if (curveType == 'rect') {
            canvas.drawRect(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)), curvePaint);
          } else if (curveType == 'oval') {
            canvas.drawOval(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)), curvePaint);
          }
        }
      } else if (type == 'shape') {
        String shapeType = shape['shapeType'];
        Paint shapePaint = Paint();
        double x1 = shape['x1'];
        double y1 = shape['y1'];
        double x2 = shape['x2'];
        double y2 = shape['y2'];
        Color color  = shape['color'];
        shapePaint.color = color;
        if (shapeType == 'polygone') {

        } else {
          if (shapeType == 'rect') {
            canvas.drawRect(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)), shapePaint);
          } else if (shapeType == 'oval') {
            canvas.drawOval(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)), shapePaint);
          }
        }
      } else if (type == 'fill') {
        Paint fillPaint = Paint();
        fillPaint.color = Colors.red;
        canvas.drawRect(Rect.fromPoints(Offset(0, 0), Offset(1000, 1000)), fillPaint);
      } else if (type == 'gradient') {
        Paint gradientPaint = Paint();
        gradientPaint.shader = ui.Gradient.linear(Offset(0, 0), Offset(415, 715), [Colors.black, Colors.white]);
        canvas.drawRect(Rect.fromPoints(Offset(0, 0), Offset(415, 715)), gradientPaint);
      } else if (type == 'text') {
        double x = shape['x'];
        double y = shape['y'];
        String content = shape['content'];
        print('text: ${content}');
        TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: '$content',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
            )
          )
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: double.maxFinite,
        );
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}