// import 'dart:html';
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:ext_storage/ext_storage.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

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
  bool isCanvasFlip = false;
  Color canvasBackgroundColor = Colors.white;
  double canvasWidth = 1007.0;
  double canvasHeight = 1414.0;
  bool isSelectionMode = false;
  List selections = [
    {
      'x1': 0.0,
      'y1': 0.0,
      'x2': 0.0,
      'y2': 0.0,
      'selected': false,
    }
  ];
  String activeTool = 'pen';
  List<Map<String, double>> anchors = [
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    },
    {
      'x': 0.0,
      'y': 0.0
    }
  ];

  SofttrackCanvas(context, touchX, touchY, shapes, canvasRotation, canvasScale, isCanvasFlip, canvasBackgroundColor, canvasWidth, canvasHeight, isSelectionMode, selections, activeTool, List<Map<String, double>> anchors) {
    this.context = context;
    this.touchX = touchX;
    this.touchY = touchY;
    this.shapes = shapes;
    this.canvasRotation = canvasRotation;
    this.canvasScale = canvasScale;
    this.isCanvasFlip = isCanvasFlip;
    this.canvasBackgroundColor = canvasBackgroundColor;
    this.canvasWidth = canvasWidth;
    this.canvasHeight = canvasHeight;
    this.isSelectionMode = isSelectionMode;
    this.selections = selections;
    this.activeTool = activeTool;
    this.anchors = anchors;
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  getCapture(String format) async {
    var recorder = await new ui.PictureRecorder();
    var origin = new Offset(0.0, 0.0);
    var paintBounds = new Rect.fromPoints(origin, Offset(415, 550));
    var canvas = new Canvas(recorder, paintBounds);
    paint(canvas, Size(415, 550));
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(415, 550);
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
    Uint8List decodedImage = data.buffer.asUint8List();
    // String fileName = 'expanded_graphic_editor_render.${format}';
    DateTime currentDateTime = DateTime.now();
    String fileName = '${currentDateTime.millisecondsSinceEpoch}.${format}';
    Directory? downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    String downloadsDirectoryPath = downloadsDirectory!.path;
    // String path = '${downloadsDirectoryPath}/${fileName}';
    String appDir = await _localPath;
    String path = '${appDir}/${fileName}';
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

    if (isSelectionMode) {
      double x1 = selections[0]['x1'];
      double y1 = selections[0]['y1'];
      double x2 = selections[0]['x2'];
      double y2 = selections[0]['y2'];
      bool selected = selections[0]['selected'];
      canvas.drawColor(Color.fromARGB(75, 0, 100, 255), BlendMode.colorBurn);
      if (selected) {
        canvas.clipRect(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)));
      }
      canvas.drawRect(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)), Paint()..style = PaintingStyle.fill..color = Colors.white);
    }

    final double r = sqrt(canvasWidth * canvasWidth + canvasHeight * canvasHeight) / 2;
    final alpha = atan(canvasHeight / canvasWidth);
    final beta = alpha + canvasRotation;
    final shiftY = r * sin(beta);
    final shiftX = r * cos(beta);
    final translateX = canvasWidth / 2 - shiftX;
    final translateY = canvasHeight / 2 - shiftY;
    canvas.translate(translateX, translateY);
    canvas.rotate(canvasRotation);

    double canvasScaleX = canvasScale['x'] as double;
    double canvasScaleY = canvasScale['y'] as double;
    canvas.scale(canvasScaleX, canvasScaleY);

    if (isCanvasFlip) {
      Matrix4Transform matrix = Matrix4Transform().flipHorizontally(origin: Offset(canvasWidth / 2, canvasHeight / 2));
      canvas.transform(matrix.matrix4.storage);
    }

    print('size.width: ${size.width}');
    canvas.drawColor(canvasBackgroundColor, BlendMode.colorBurn);
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

    Float64List matrix4 = Float64List(16);
    // matrix4.add(0.0);
    // matrix4.add(0.2);
    // matrix4.add(0.4);
    // matrix4.add(0.6);
    // matrix4.add(0.8);
    // matrix4.add(0.8);
    // matrix4.add(1.0);
    // matrix4.add(1.2);
    // matrix4.add(1.4);
    // matrix4.add(1.6);
    // matrix4.add(1.8);
    // matrix4.add(2.0);
    // matrix4.add(2.2);
    // matrix4.add(2.4);
    // matrix4.add(2.6);
    // matrix4.add(2.8);
    // canvas.transform(matrix4);

    // final rot2 = RotationMatrix(93.45, 128.85, 0.0, -1, 1, 0.0, math.pi);
    // final mtx2 = rot2.getMatrix();
    // canvas.transform(mtx2);

    // canvas.transform(Matrix4(
    //   1,0,0,0,
    //   0,1,0,0,
    //   0,0,1,0,
    //   0,0,0,1,
    // ));

    // Matrix4Transform matrix = Matrix4Transform().rotateDegrees(180, origin: Offset(canvasWidth / 2, canvasHeight / 2));
    // canvas.transform(matrix.matrix4.storage);

    // Matrix4Transform matrix = Matrix4Transform().upLeft(0).translate(x: 0, y: 0);
    Matrix4Transform matrix = Matrix4Transform();

    // matrix.upLeft(0).translate(x: 0, y: 0);
    // matrix.up(0).translate(x: 0, y: 0);
    // matrix.upRight(0).translate(x: 0, y: 0);
    // matrix.left(0).translate(x: 0, y: 0);
    // matrix.right(0).translate(x: 0, y: 0);
    // matrix.downLeft(0).translate(x: 0, y: 0);
    // matrix.down(0).translate(x: 0, y: 0);
    // matrix.downRight(0).translate(x: 0, y: 0);

    if (activeTool == 'ffd') {
      // touchableCanvas = Touch
      // canvas.drawCircle(Offset(0, 0), 5, Paint());
      // canvas.drawCircle(Offset(canvasWidth / 2, 0), 5, Paint());
      // canvas.drawCircle(Offset(canvasWidth, 0), 5, Paint());
      // canvas.drawCircle(Offset(0, canvasHeight / 2), 5, Paint());
      // canvas.drawCircle(Offset(canvasWidth, canvasHeight / 2), 5, Paint());
      // canvas.drawCircle(Offset(0, canvasHeight), 5, Paint());
      // canvas.drawCircle(Offset(canvasWidth / 2, canvasHeight), 5, Paint());
      // canvas.drawCircle(Offset(canvasWidth, canvasHeight), 5, Paint());

      canvas.drawCircle(Offset((anchors[0]['x'] as double).roundToDouble(), (anchors[0]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[1]['x'] as double).roundToDouble(), (anchors[1]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[2]['x'] as double).roundToDouble(), (anchors[2]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[3]['x'] as double).roundToDouble(), (anchors[3]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[4]['x'] as double).roundToDouble(), (anchors[4]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[5]['x'] as double).roundToDouble(), (anchors[5]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[6]['x'] as double).roundToDouble(), (anchors[6]['y'] as double).roundToDouble()), 5, Paint());
      canvas.drawCircle(Offset((anchors[7]['x'] as double).roundToDouble(), (anchors[7]['y'] as double).roundToDouble()), 5, Paint());

      matrix.upLeft(0).translate(x: (anchors[0]['x'] as double).roundToDouble(), y: (anchors[0]['y'] as double).roundToDouble());
      matrix.up(0).translate(x: (anchors[1]['x'] as double).roundToDouble(), y: (anchors[1]['y'] as double).roundToDouble());
      matrix.upRight(0).translate(x: (anchors[2]['x'] as double).roundToDouble(), y: (anchors[2]['y'] as double).roundToDouble());
      matrix.left(0).translate(x: (anchors[3]['x'] as double).roundToDouble(), y: (anchors[3]['y'] as double).roundToDouble());
      matrix.right(0).translate(x: (anchors[4]['x'] as double).roundToDouble(), y: (anchors[4]['y'] as double).roundToDouble());
      matrix.downLeft(0).translate(x: (anchors[5]['x'] as double).roundToDouble(), y: (anchors[5]['y'] as double).roundToDouble());
      matrix.down(0).translate(x: (anchors[6]['x'] as double).roundToDouble(), y: (anchors[6]['y'] as double).roundToDouble());
      matrix.downRight(0).translate(x: (anchors[7]['x'] as double).roundToDouble(), y: (anchors[7]['y'] as double).roundToDouble());

      canvas.transform(matrix.matrix4.storage);

    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}