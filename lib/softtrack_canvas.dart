// import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:ext_storage/ext_storage.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SofttrackCanvas extends CustomPainter {

  late BuildContext context;
  double touchX = 0;
  double touchY = 0;
  List shapes = [];
  double canvasRotation = 0.0;
  var canvasScale = {
    'x': 1.0,
    'y': 1.0
  };

  SofttrackCanvas(context, touchX, touchY, shapes, canvasRotation, canvasScale) {
    this.context = context;
    this.touchX = touchX;
    this.touchY = touchY;
    this.shapes = shapes;
    this.canvasRotation = canvasRotation;
    this.canvasScale = canvasScale;
  }

  getCapture() async {
    var recorder = await new ui.PictureRecorder();
    var origin = new Offset(0.0, 0.0);
    var paintBounds = new Rect.fromPoints(origin, Offset(415, 550));
    var canvas = new Canvas(recorder, paintBounds);
    paint(canvas, Size(415, 550));
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(415, 550);
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
    Uint8List decodedImage = data.buffer.asUint8List();
    String fileName = 'expanded_graphic_editor_render.png';
    Directory? downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    String downloadsDirectoryPath = downloadsDirectory!.path;
    String path = '${downloadsDirectoryPath}/${fileName}';
    final file = File(path);
    await file.writeAsBytes(decodedImage);
    Fluttertoast.showToast(
      msg: 'Сохранение выполнено',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
    );
    return decodedImage;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // var capture = await getCapture(size);
    // print('capture: ${capture}');
    canvas.rotate(canvasRotation);
    double canvasScaleX = canvasScale['x'] as double;
    double canvasScaleY = canvasScale['y'] as double;
    canvas.scale(canvasScaleX, canvasScaleY);
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
        double fontSize = shape['fontSize'];
        double lineHeight = shape['lineHeight'];
        Color color = shape['color'];
        Color outlineColor = shape['outlineColor'];
        double outlineWidth = shape['outlineWidth'];
        print('text: ${content}');
        Paint foregroundPaint = Paint();
        foregroundPaint.style = PaintingStyle.fill;
        foregroundPaint.color = color;
        List<Shadow> shadows = [];
        if (outlineWidth >= 1) {
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
          shadows.add(
              Shadow(
                  color: outlineColor,
                  offset: Offset(0, 0),
                  blurRadius: 1.0
              )
          );
          shadows.add(
            Shadow(
              color: outlineColor,
              offset: Offset(0, 0),
              blurRadius: 1.0
            )
          );
        }
        TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: '$content',
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              height: lineHeight,
              shadows: shadows
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