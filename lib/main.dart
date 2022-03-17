import 'package:flutter/material.dart';
import 'package:graphiceditor/softtrack_canvas.dart';
import 'package:touchable/touchable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Softtrack графический редактор'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double touchX = 0;
  double touchY = 0;
  List shapes = [];
  List<Offset> points = [];
  // int pointsCursor = -1;
  String curve = 'rect';
  String shape = 'rect';
  Color paleteColor = Colors.black;
  String activeTool = 'pen';
  String textToolDialogContent = '';

  onTouchStart(event, context) {
    setState(() {
      touchX = event.globalPosition.dx;
      touchY = event.globalPosition.dy;
      if (activeTool == 'curve') {
        if (curve == 'polygone') {
          shapes.add({
            'points': points,
            'type': 'curve',
            'curveType': curve,
          });
        } else {
          shapes.add({
            'x1': touchX,
            'y1': touchY,
            'x2': touchX,
            'y2': touchY,
            'color': paleteColor,
            'type': 'curve',
            'curveType': curve,
          });
        }
      } else if (activeTool == 'shape') {
        if (shape == 'polygone') {

        } else {
          shapes.add({
            'x1': touchX,
            'y1': touchY,
            'x2': touchX,
            'y2': touchY,
            'color': paleteColor,
            'type': 'shape',
            'shapeType': shape,
          });
        }
      }
    });
  }

  onTouchMove(event, context) {
    print('DragUpdateEvent ${event.globalPosition.dx} ${event.globalPosition.dy}');
    setState(() {
      touchX = event.globalPosition.dx;
      touchY = event.globalPosition.dy;
      if (activeTool == 'pen') {
        shapes.add({
          'x1': touchX,
          'y1': touchY,
          'x2': touchX + 1,
          'y2': touchY + 1,
          'color': paleteColor,
          'type': 'line'
        });
      } else if (activeTool == 'eraser') {
        shapes.add({
          'x1': touchX,
          'y1': touchY,
          'x2': touchX + 50,
          'y2': touchY + 50,
          'type': 'eraser'
        });
      } else if (activeTool == 'curve') {
        shapes[shapes.length - 1]['x2'] = touchX;
        shapes[shapes.length - 1]['y2'] = touchY;
      } else if (activeTool == 'shape') {
        shapes[shapes.length - 1]['x2'] = touchX;
        shapes[shapes.length - 1]['y2'] = touchY;
      }
    });
  }

  onTouchEnd(event, context) {
    setState(() {

      if (activeTool == 'curve') {
        if (curve == 'polygone') {
          if (points.length >= 3) {
            points = [];
          }
          if (points.length <= 0) {
            points = [
              Offset(
                touchX,
                touchY
              )
            ];
            shapes.add({
              'points': points,
              'type': 'curve',
              'curveType': curve
            });
          } else {
            shapes[shapes.length - 1]['points'].add(
              Offset(
                touchX,
                touchY
              )
            );
            points.add(
              Offset(
                touchX,
                touchY
              )
            );
          }
        }
      } else if (activeTool == 'fill') {
        shapes.add({
          'type': 'fill'
        });
      } else if (activeTool == 'gradient') {
        shapes.add({
          'type': 'gradient'
        });
      } else if (activeTool == 'text') {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(''),
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Текст'
                    ),
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 200,
                          child: TextField(
                            onChanged: (value) {
                              textToolDialogContent = value;
                            }
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                              msg: 'В настоящее время фукнция\nголосового набора\nне используется',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0
                            );
                          },
                          child: Icon(
                            Icons.mic
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child:  Icon(
                            Icons.keyboard
                          )
                        ),
                      ]
                    )
                  ]
                )
              )
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    print('добавляю текст');
                    shapes.add({
                      'x': touchX,
                      'y': touchY,
                      'content': textToolDialogContent,
                      'type': 'text'
                    });
                    textToolDialogContent = '';
                  });
                  return Navigator.pop(context, 'OK');
                },
                child: const Text(
                  'Задать'
                )
              ),
              TextButton(
                onPressed: () {
                  return Navigator.pop(context, 'OK');
                },
                child: const Text(
                  'Отмена'
                )
              )
            ]
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 15
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'pen';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.brush
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          activeTool = 'eraser';
                        });
                      },
                      child: Container(
                      child: Icon(
                        Icons.crop_square
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'curve';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.crop_square
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'shape';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.rectangle
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'fill';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.format_color_fill
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'gradient';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.gradient
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTool = 'text';
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.text_fields
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    )
                  )
                ]
              )
            ),
            scrollDirection: Axis.horizontal,
          ),
          Row(
            children: (
              (activeTool == 'pen' || activeTool == 'eraser') ?
                [
                  TextButton(
                    child: Text(
                      'Коррекция 0'
                    ),
                    onPressed: () {

                    }
                  ),
                  Column(
                    children: [
                      Text(
                        'Привязка'
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.grid_3x3
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.more_vert
                            ),
                            onTap: () {

                            }
                          ),
                        ]
                      )
                    ]
                  )
                ]
              : (activeTool == 'curve') ?
                [
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.crop_square
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        curve = 'rect';
                      });
                    }
                  ),
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.circle_outlined
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        curve = 'oval';
                      });
                    }
                  ),
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.pentagon_outlined
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        curve = 'polygone';
                      });
                    }
                  )
                ]
              : (activeTool == 'shape') ?
                [
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.rectangle
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        shape = 'rect';
                      });
                    }
                  ),
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.circle
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        shape = 'oval';
                      });
                    }
                  ),
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.pentagon
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        shape = 'polygone';
                      });
                    }
                  )
                ]
              :
                [

                ]
            )
          ),
          GestureDetector(
            child: Container(
              child: CustomPaint(
                painter: SofttrackCanvas(context, touchX, touchY, shapes)
              ),
              width: 415,
              height: 650
            ),
            onHorizontalDragStart: (event) {
              onTouchStart(event, context);
            },
            onVerticalDragStart: (event) {
              onTouchStart(event, context);
            },
            onHorizontalDragUpdate: (event) {
              onTouchMove(event, context);
            },
            onVerticalDragUpdate: (event) {
              onTouchMove(event, context);
            },
            onHorizontalDragEnd: (event) {
              onTouchEnd(event, context);
            },
            onVerticalDragEnd: (event) {
              onTouchEnd(event, context);
            },
          ),
          Row(
            children: [

            ]
          ),
          Row(
            children: [

            ]
          )
        ]
      ),
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                'Палитра'
              ),
              ColorPicker(
                pickerColor: paleteColor,
                onColorChanged: (Color color) {
                  setState(() {
                    paleteColor = color;
                  });
                },
                pickerAreaBorderRadius: BorderRadius.circular(1000.0),
              )
            ]
          )
        )
      ),
      endDrawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                'Слои'
              )
            ]
          )
        )
      )
    );
  }
}
