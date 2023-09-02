import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphiceditor/canvas_create.dart';
import 'package:graphiceditor/softtrack_canvas.dart';
import 'package:graphiceditor/start.dart';
import 'package:touchable/touchable.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'gallery.dart';
import 'models.dart';

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
      home: StartPage(),
      routes: {
        '/welcome': (context) => StartPage(),
        '/canvas/create': (context) => const CanvasCreatePage(),
        '/main': (context) => const MyHomePage(
          title: 'Softtrack Графический редактор'
        ),
        '/gallery': (context) => GalleryPage()
      }
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
  String curve = 'rect';
  String shape = 'rect';
  Color paleteColor = Colors.black;
  String activeTool = 'pen';
  String textToolDialogContent = '';
  double textToolDialogFontSize = 18;
  double textToolDialogTextSpace = 0;
  double textToolDialogLineHeight = 0;
  String textToolDialogRotationContent = '';
  double textToolDialogOutlineWidth = 0;
  bool isTextToolDialogOutlineRound = true;
  Color textToolDialogOutlineColor = Colors.black;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var menuContextMenuItems = {
    'Сохранить',
    'Сохранить как',
    'Экспорт PNG / JPG файлы',
    'Настройки',
    'Справка',
    'Синхронизация',
    'аннотирование',
    'Start using the sonar pen.',
    'Калибровка гидролокатора пера',
    'Войти',
    'Выход'
  };
  var editContextMenuItems = {
    'Копия',
    'Вырезать',
    'Вставить',
    'Повернуть холст влево',
    'Повернуть холст',
    'Повернуть холст по',
    'Настройки холста',
    'Обрезка'
  };
  var selectionContextMenuItems = {
    'Сохранить все',
    'Отменить выбор',
    'Инвертировать',
    'Выбрать область',
    'Уменьшить/Увеличть',
    'Свободная трансформация',
    'Преобразование',
    'Создать границу'
  };
  var toggleOrientationContextMenuItems = {
    'Поворот влево',
    'Поворот вправо',
    'Отразить по горизонтали',
    'Сброс'
  };
  double canvasRotation = 0.0;
  var canvasScale = {
    'x': 1.0,
    'y': 1.0
  };
  bool isCanvasFlip = false;
  double canvasWidth = 1007;
  double canvasHeight = 1414;
  int canvasDpi = 350;
  String canvasPaperSize = 'A4';
  Color canvasBackgroundColor = Colors.white;
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
  late SofttrackCanvas softtrackCanvas;
  FileFormatType selectedFileFormat = FileFormatType.png;
  Row prefooter = Row();
  bool isPrefooterDraged = false;
  double preffoterDragLeft = 0;
  double preffoterDragTop = 0;
  int activeLayer = 0;
  List<Widget> layers = [

  ];
  int minTouches = 2;
  bool isToolBarVisible = true;

  Future<List<Widget>> get getLayers async {
    return layers;
  }

  void onTap(bool correctNumberOfTouches) {
    print("Tapped with $correctNumberOfTouches finger(s)");

  }


  addLayer(int layerIndexS) {
      int layerIndex = layers.length;
      layers.add(
        GestureDetector(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.remove_red_eye
                    ),
                    Icon(
                      Icons.rectangle
                    ),
                    Text(
                      'Слой 1'
                    )
                  ]
                ),
                Icon(
                  Icons.settings
                )
              ]
            ),
            decoration: BoxDecoration(
              color: (
                activeLayer == layerIndex ?
                  Color.fromARGB(255, 200, 200, 200)
                :
                  Color.fromARGB(255, 255, 255, 255)
              )
            )
          ),
          onTap: () {
            print('layerIndex: ${layerIndex}');
            activeLayer = layerIndex;
            print('activeLayer: ${activeLayer}');
          }
        )
      );
  }

  onTouchStart(event, context) {
    setState(() {
      touchX = event.localPosition.dx;
      touchY = event.localPosition.dy;
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
      } else if (activeTool == 'selection') {
        selections[0] = {
          'x1': touchX,
          'y1': touchY,
          'x2': touchX,
          'y2': touchY,
          'selected': false
        };
      } else if (activeTool == 'ffd') {
        int activeAnchor = 0;
        if (touchX <= 50 && touchY <= 50) {
          activeAnchor = 0;
        } else if (touchX <= canvasWidth / 2 + 50 && touchX >= canvasWidth /2 - 50 && touchY <= 50) {
          activeAnchor = 1;
        } else if (touchX >= canvasWidth - 50 && touchY <= 50) {
          activeAnchor = 2;
        } else if (touchX <= 50 && touchY >= canvasHeight / 2 - 50 && touchY <= canvasHeight / 2 + 50) {
          activeAnchor = 3;
        } else if (touchX >= canvasWidth - 50 && touchY >= canvasHeight / 2 - 50 && touchY <= canvasHeight / 2 + 50) {
          activeAnchor = 4;
        } else if (touchX <= 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 5;
        } else if (touchX <= canvasWidth / 2 + 50 && touchX >= canvasWidth /2 - 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 6;
        } else if (touchX >= canvasWidth - 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 7;
        }
        print('activeAnchor: ${activeAnchor}');
      }
    });
  }

  onTouchMove(event, context) {
    setState(() {
      touchX = event.localPosition.dx;
      touchY = event.localPosition.dy;
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
      } else if (activeTool == 'selection') {
        selections[0]['x2'] = touchX;
        selections[0]['y2'] = touchY;
      } else if (activeTool == 'ffd') {
        int activeAnchor = 0;
        if (touchX <= 50 && touchY <= 50) {
          activeAnchor = 0;
        } else if (touchX <= canvasWidth / 2 + 50 && touchX >= canvasWidth /2 - 50 && touchY <= 50) {
          activeAnchor = 1;
        } else if (touchX >= canvasWidth - 50 && touchY <= 50) {
          activeAnchor = 2;
        } else if (touchX <= 50 && touchY >= canvasHeight / 2 - 50 && touchY <= canvasHeight / 2 + 50) {
          activeAnchor = 3;
        } else if (touchX >= canvasWidth - 50 && touchY >= canvasHeight / 2 - 50 && touchY <= canvasHeight / 2 + 50) {
          activeAnchor = 4;
        } else if (touchX <= 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 5;
        } else if (touchX <= canvasWidth / 2 + 50 && touchX >= canvasWidth /2 - 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 6;
        } else if (touchX >= canvasWidth - 50 && touchY >= canvasHeight - 50) {
          activeAnchor = 7;
        }
        print('activeAnchor: ${activeAnchor}');
        anchors[activeAnchor] = {
          'x': touchX,
          'y': touchY
        };
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
        setState(() {
          textToolDialogFontSize = 18;
          textToolDialogTextSpace = 0;
          textToolDialogLineHeight = 0;
        });
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => AlertDialog(
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
                              },
                              minLines: null,
                              maxLines: null
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
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
                      ),
                      Text(
                        'Шрифт'
                      ),
                      Text(
                        'Размер текста ${textToolDialogFontSize.round()} pt'
                      ),
                      Slider(
                        value: textToolDialogFontSize,
                        onChanged: (double value) {
                          setState(() {
                            textToolDialogFontSize = value;
                          });
                        },
                        min: 0,
                        max: 100
                      ),
                      Text(
                        'Текстовое пространство ${textToolDialogTextSpace.round()}'
                      ),
                      Slider(
                        value: textToolDialogTextSpace,
                        onChanged: (double value) {
                          setState(() {
                            textToolDialogTextSpace = value;
                          });
                        },
                        divisions: 100,
                        min: 0,
                        max: 100
                      ),
                      Text(
                        'Межстрочный интервал ${textToolDialogLineHeight.round()}'
                      ),
                      Slider(
                        value: textToolDialogLineHeight,
                        onChanged: (double value) {
                          setState(() {
                            textToolDialogLineHeight = value;
                          });
                        },
                        divisions: 100,
                        min: 0,
                        max: 100
                      ),
                      Text(
                        'Градус поворота'
                      ),
                      Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            child: TextField(
                              controller: TextEditingController(
                                text: '0'
                              ),
                              onChanged: (value) {
                                setState(() {
                                  textToolDialogRotationContent = value;
                                });
                              },
                            )
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.text_rotation_none
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.text_rotation_down
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.text_rotation_none
                            ),
                            onTap: () {

                            }
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.text_rotate_up
                            ),
                            onTap: () {

                            }
                          ),
                        ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Цвет края'
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.check_box_outline_blank
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      content: ColorPicker(
                                        pickerColor: textToolDialogOutlineColor,
                                        onColorChanged: (Color color) {
                                          setState(() {
                                            textToolDialogOutlineColor = color;
                                          });
                                        },
                                        pickerAreaBorderRadius: BorderRadius.circular(1000.0),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            'Отмена'
                                          ),
                                          onPressed: () {
                                            return Navigator.pop(context, 'Cancel');
                                          }
                                        ),
                                        TextButton(
                                          child: Text(
                                            'ОК'
                                          ),
                                          onPressed: () {
                                            return Navigator.pop(context, 'OK');
                                          }
                                        ),
                                      ]
                                    )
                                  );
                                }
                              )
                            ]
                          ),
                          Column(
                            children: [
                              Text(
                                'Ширина края ${textToolDialogOutlineWidth.round()} px'
                              ),
                              Slider(
                                onChanged: (double value) {
                                  setState(() {
                                    textToolDialogOutlineWidth = value;
                                  });
                                },
                                value: textToolDialogOutlineWidth,
                                min: 0,
                                max: 100
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isTextToolDialogOutlineRound,
                                    onChanged: (value) {
                                      setState(() {
                                        isTextToolDialogOutlineRound = !isTextToolDialogOutlineRound;
                                      });
                                    }
                                  ),
                                  Text(
                                    'Круглые края'
                                  )
                                ]
                              )
                            ]
                          )
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
                        'fontSize': textToolDialogFontSize,
                        'lineHeight': textToolDialogLineHeight,
                        'color': paleteColor,
                        'outlineColor': textToolDialogOutlineColor,
                        'outlineWidth': textToolDialogOutlineWidth,
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
          )
        );
      } else if (activeTool == 'selection') {
        setState(() {
          selections[0]['x2'] = touchX;
          selections[0]['y2'] = touchY;
          selections[0]['selected'] = true;
        });
      }
    });
  }

  @override
  initState() {
    super.initState();
    prefooter = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Icon(
              Icons.undo
            )
          )
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Icon(
              Icons.redo
            )
          )
        ),
        GestureDetector(
            child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 10
                ),
                child: Icon(
                    Icons.drive_file_rename_outline
                )
            )
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Icon(
              Icons.brush
            )
          ),
          onTap: () {
            setState(() {
              activeTool = 'pen';
            });
          }
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Icon(
              Icons.check_box_outline_blank
            )
          ),
          onTap: () {
            setState(() {
              activeTool = 'eraser';
            });
          }
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10
            ),
            child: Icon(
              Icons.check_box_outline_blank
            )
          )
        ),
        TextButton(
            child: Text(
                'Сохр.'
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 0, 100, 255)
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 255, 255, 255)
              ),
            ),
            onPressed: () {
              softtrackCanvas.getCapture('png');
            }
        ),
        GestureDetector(
            child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 10
                ),
                child: Icon(
                    Icons.apps
                )
            )
        ),
      ]
    );
    int layerIndex = 0;
    layers.add(
      GestureDetector(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.remove_red_eye
                  ),
                  Icon(
                    Icons.rectangle
                  ),
                  Text(
                    'Слой 1'
                  )
                ]
              ),
              Icon(
                Icons.settings
              )
            ]
          ),
          decoration: BoxDecoration(
            color: (
              activeLayer == layerIndex ?
                Color.fromARGB(255, 200, 200, 200)
              :
                Color.fromARGB(255, 255, 255, 255)
            )
          )
        ),
        onTap: () {
          print('layerIndex: ${layerIndex}');
          activeLayer = layerIndex;
          print('activeLayer: ${activeLayer}');
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      if (arguments != null) {
        print(arguments['width']);
        print(arguments['height']);
        print(arguments['dpi']);
        print(arguments['paperSize']);
        print(arguments['backgroundColor']);
        canvasWidth = arguments['width'];
        canvasHeight = arguments['height'];
        canvasDpi = arguments['dpi'];
        canvasPaperSize = arguments['paperSize'];
        canvasBackgroundColor = arguments['backgroundColor'];
      }
      softtrackCanvas = SofttrackCanvas(context, touchX, touchY, shapes, canvasRotation, canvasScale, isCanvasFlip, canvasBackgroundColor, canvasWidth, canvasHeight, isSelectionMode, selections, activeTool, anchors);
    });

    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (
              isToolBarVisible ?
                Column(
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
                    )
                  ]
                )
              :
                Row()
            ),
            GestureDetector(
              onScaleUpdate: (event) {
                print('onScaleUpdate: ${event.scale}');
                setState(() {
                  canvasScale = {
                    'x': event.scale,
                    'y': event.scale
                  };
                });
              },
              child: RawGestureDetector(
                gestures: {
                  MultiTouchGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                      MultiTouchGestureRecognizer>(
                        () => MultiTouchGestureRecognizer(),
                        (MultiTouchGestureRecognizer instance) {
                      instance.minNumberOfTouches = this.minTouches;
                      instance.onMultiTap = (correctNumberOfTouches) => this.onTap(correctNumberOfTouches);
                    },
                  )
                },
                child: GestureDetector(
                  child: Container(
                    child: CustomPaint(
                      size: Size(
                        canvasWidth,
                        canvasHeight
                      ),
                      child: (
                        isSelectionMode ?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isSelectionMode = false;
                                    selections[0] = {
                                      'x1': 0.0,
                                      'y1': 0.0,
                                      'x2': 0.0,
                                      'y2': 0.0,
                                      'selected': false
                                    };
                                  });
                                },
                                child: Text(
                                  'Отменить выделение'
                                ),
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 255, 255, 255)
                                  ),
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 150, 150, 150)
                                  ),
                                )
                              )
                            ]
                          )
                        : activeTool == 'ffd' ?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    activeTool = 'pen';
                                    anchors = [
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
                                  });
                                },
                                child: Text(
                                  'Отменить деформацию'
                                ),
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 255, 255, 255)
                                  ),
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 150, 150, 150)
                                  ),
                                )
                              )
                            ]
                          )
                        :
                          Row()
                      ),
                      painter: softtrackCanvas
                    ),
                    width: canvasWidth,
                    height: canvasHeight
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
                )
              )
            ),
            Draggable(
              onDragEnd: (event) {
                setState(() {
                  isPrefooterDraged = false;
                  preffoterDragLeft = event.offset.dx;
                  preffoterDragTop = event.offset.dy;
                  print('preffoterDragLeft: ${preffoterDragLeft}');
                  print('preffoterDragTop: ${preffoterDragTop}');
                });
              },
              onDragStarted: () {
                setState(() {
                  isPrefooterDraged = true;
                });
              },
              feedback: prefooter,
              child: (
                isPrefooterDraged ?
                  Row()
                :
                  Positioned(
                    left: preffoterDragLeft,
                    top: preffoterDragTop,
                    child: prefooter
                  )
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.menu
                    )
                  ),
                  itemBuilder: (BuildContext context) {
                    return menuContextMenuItems.map((String menuContextMenuItem) {
                      return  PopupMenuItem<String>(
                        value: menuContextMenuItem,
                        child: Text(menuContextMenuItem),
                      );}
                    ).toList();
                  },
                  onSelected: (item) async {
                   if (item == 'Сохранить') {
                      softtrackCanvas.getCapture('png');
                   } else if (item == 'Сохранить как') {
                     showDialog(
                       context: context,
                       builder: (BuildContext context) => AlertDialog(
                         title: Text(
                           'Пункт назначения'
                         ),
                         content: Container(
                           height: 100,
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               TextButton(
                                 child: Text(
                                   'Сохранять локально'
                                 ),
                                 style: ButtonStyle(
                                   foregroundColor: MaterialStateProperty.all<Color>(
                                     Colors.black
                                   )
                                 ),
                                 onPressed: () {
                                   softtrackCanvas.getCapture('png');
                                   return Navigator.pop(context, 'OK');
                                 },
                               ),
                               TextButton(
                                 child: Text(
                                   'Сохранять онлайн'
                                 ),
                                 style: ButtonStyle(
                                   foregroundColor: MaterialStateProperty.all<Color>(
                                     Colors.black
                                   )
                                 ),
                                 onPressed: () {
                                   Navigator.pushNamed(context, '/welcome');
                                 }
                               )
                             ]
                           )
                         ),
                         actions: [
                           TextButton(
                             child: Text(
                               'Отмена'
                             ),
                             onPressed: () {
                               return Navigator.pop(context, 'Cancel');
                             }
                           )
                         ],
                       )
                     );
                   } else if (item == 'Экспорт PNG / JPG файлы') {
                     showDialog(
                       context: context,
                       builder: (BuildContext context) => StatefulBuilder(
                         builder: (BuildContext context, StateSetter setState) =>  AlertDialog(
                           title: Text(
                            'Формат файла'
                           ),
                           content: Container(
                             height: 150,
                             child: Column(
                               children: [
                                 Row(
                                   children: [
                                    Radio<FileFormatType>(
                                     value: FileFormatType.png,
                                     groupValue: selectedFileFormat,
                                     onChanged: (value) {
                                       setState(() {
                                         selectedFileFormat = value!;
                                       });
                                     }
                                    ),
                                    Text(
                                      'PNG'
                                    )
                                  ]
                                 ),
                                 Row(
                                   children: [
                                     Radio<FileFormatType>(
                                       value: FileFormatType.pngTransparency,
                                       groupValue: selectedFileFormat,
                                       onChanged: (value) {
                                         setState(() {
                                           selectedFileFormat = value!;
                                         });
                                       }
                                     ),
                                     Text(
                                       'PNG (прозрачный)'
                                     )
                                   ]
                                 ),
                                 Row(
                                   children: [
                                     Radio<FileFormatType>(
                                       value: FileFormatType.jpg,
                                       groupValue: selectedFileFormat,
                                       onChanged: (value) {
                                         setState(() {
                                           selectedFileFormat = value!;
                                         });
                                       }
                                     ),
                                     Text(
                                       'JPG'
                                     )
                                   ]
                                 ),
                               ]
                             )
                           ),
                           actions: [
                             TextButton(
                               child: Text(
                                 'Отмена'
                               ),
                               onPressed: () {
                                 return Navigator.pop(context, 'Cancel');
                               }
                             ),
                             TextButton(
                               child: Text(
                                 'ОК'
                               ),
                               onPressed: () {
                                 String format = 'png';
                                 if (selectedFileFormat == FileFormatType.png) {
                                   format = 'png';
                                 } else if (selectedFileFormat == FileFormatType.pngTransparency) {
                                   format = 'png';
                                 } else if (selectedFileFormat == FileFormatType.jpg) {
                                   format = 'jpg';
                                 }
                                 softtrackCanvas.getCapture(format);
                                 return Navigator.pop(context, 'OK');
                               }
                             ),
                           ]
                         )
                       )
                     );
                   }
                  }
                ),
                PopupMenuButton(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.edit
                    )
                  ),
                  itemBuilder: (BuildContext context) {
                    return editContextMenuItems.map((String editContextMenuItem) {
                      return PopupMenuItem<String>(
                        value: editContextMenuItem,
                        child: Text(editContextMenuItem)
                      );}
                    ).toList();
                  },
                ),
                PopupMenuButton(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.select_all
                    )
                  ),
                  itemBuilder: (BuildContext context) {
                    return selectionContextMenuItems.map((String selectionContextMenuItem) {
                      return PopupMenuItem<String>(
                        value: selectionContextMenuItem,
                        child: Text(selectionContextMenuItem)
                      );}
                    ).toList();
                  },
                  onSelected: (item) {
                    if (item == 'Выбрать область') {
                      setState(() {
                        activeTool = 'selection';
                        isSelectionMode = true;
                      });
                    } else if (item == 'Свободная трансформация') {
                      setState(() {
                        activeTool = 'ffd';
                        anchors = [
                          {
                            'x': 0.0,
                            'y': 0.0
                          },
                          {
                            'x': canvasWidth / 2,
                            'y': 0.0
                          },
                          {
                            'x': canvasWidth,
                            'y': 0.0
                          },
                          {
                            'x': 0.0,
                            'y': canvasHeight / 2
                          },
                          {
                            'x': canvasWidth,
                            'y': canvasHeight / 2
                          },
                          {
                            'x': 0.0,
                            'y': canvasHeight
                          },
                          {
                            'x': canvasWidth / 2,
                            'y': canvasHeight
                          },
                          {
                            'x': canvasWidth,
                            'y': canvasHeight
                          }
                        ];
                      });
                    }
                  },
                ),
                PopupMenuButton(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.screen_rotation
                    )
                  ),
                  itemBuilder: (BuildContext context) {
                    return toggleOrientationContextMenuItems.map((String toggleOrientationContextMenuItem) {
                      return PopupMenuItem<String>(
                        value: toggleOrientationContextMenuItem,
                        child: Text(toggleOrientationContextMenuItem)
                      );}
                    ).toList();
                  },
                  onSelected: (item) {
                    if (item == 'Поворот влево') {
                      setState(() {
                        canvasRotation += 15.0;
                      });
                    } else if (item == 'Поворот вправо') {
                      setState(() {
                        canvasRotation -= 15.0;
                      });
                    } else if (item == 'Отразить по горизонтали') {
                      setState(() {
                        isCanvasFlip = !isCanvasFlip;
                      });
                    } else if (item == 'Сброс') {
                      setState(() {
                        canvasRotation = 0.0;
                        canvasScale = {
                          'x': 1.0,
                          'y': 1.0
                        };
                      });
                    }
                  }
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      (
                        activeTool == 'pen' ?
                          Icons.brush
                        : activeTool == 'eraser' ?
                          Icons.crop_square
                        : activeTool == 'curve' ?
                          Icons.crop_square
                        : activeTool == 'shape' ?
                          Icons.rectangle
                        : activeTool == 'fill' ?
                          Icons.format_color_fill
                        : activeTool == 'gradient' ?
                          Icons.gradient
                        : Icons.text_fields
                      )
                    )
                  ),
                  onTap:() {
                    setState(() {
                      isToolBarVisible = !isToolBarVisible;
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10
                      ),
                      child: Icon(
                        Icons.palette
                      )
                  ),
                  onTap:() {
                    scaffoldKey.currentState!.openDrawer();
                  },
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.layers
                    )
                  ),
                  onTap:() {
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    child: Icon(
                      Icons.circle_outlined
                    )
                  ),
                  onTap:() {

                  },
                ),
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
                ),
                FutureBuilder(
                  future: getLayers,
                  builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                    int snapshotsCount = 0;
                    if (snapshot.data != null) {
                      snapshotsCount = snapshot.data!.length;
                      layers = [];
                      for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                        int layerIndex = snapshotIndex;
                          layers.add(
                              GestureDetector(
                                  child: Container(
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                      Icons.remove_red_eye
                                                  ),
                                                  Icon(
                                                      Icons.rectangle
                                                  ),
                                                  Text(
                                                      'Слой 1'
                                                  )
                                                ]
                                            ),
                                            Icon(
                                                Icons.settings
                                            )
                                          ]
                                      ),
                                      decoration: BoxDecoration(
                                          color: (
                                              activeLayer == layerIndex ?
                                              Color.fromARGB(255, 200, 200, 200)
                                                  :
                                              Color.fromARGB(255, 255, 255, 255)
                                          )
                                      )
                                  ),
                                  onTap: () {
                                    print('layerIndex: ${layerIndex}');
                                    activeLayer = layerIndex;
                                    print('activeLayer: ${activeLayer}');
                                  }
                              )
                          );
                      }
                    }
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              25
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: layers
                              )
                            )
                          )
                        ]
                      );
                    } else {
                      return Column(

                      );
                    }
                    return Column(

                    );
                  }
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.add
                      ),
                      onTap: () {
                        addLayer(layers.length);
                      }
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.delete
                      ),
                      onTap: () {

                      }
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_upward
                      ),
                      onTap: () {

                      }
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_upward
                      ),
                      onTap: () {

                      }
                    ),
                    GestureDetector(
                        child: Icon(
                          Icons.lock
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
          )
        )
      ),
      onWillPop: () {
        return Future<bool>(() {
          if (isToolBarVisible) {
            setState(() {
              isToolBarVisible = false;
            });
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  'Вы закончили?'
                ),
                content: Container(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        child: Text(
                          'Сохранить'
                        ),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black
                          )
                        ),
                        onPressed: () {
                          softtrackCanvas.getCapture('png');
                          return Navigator.pop(context, 'OK');
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Закрыть без сохранения'
                        ),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black
                          )
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/welcome');
                        }
                      ),
                      TextButton(
                        child: Text(
                          'Отмена'
                        ),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.black
                          )
                        ),
                        onPressed: () {
                          return Navigator.pop(context, 'Cancel');
                        }
                      )
                    ]
                  )
                )
              )
            );
          }
          return false;
        });
      }
    );
  }
}

typedef MultiTouchGestureRecognizerCallback = void Function(bool correctNumberOfTouches);

class MultiTouchGestureRecognizer extends MultiTapGestureRecognizer {

  MultiTouchGestureRecognizerCallback onMultiTap = (pointer) {
    print("Tapped with correctNumberOfTouches finger(s)");
  };
  var numberOfTouches = 0;
  int minNumberOfTouches = 0;

  MultiTouchGestureRecognizer() {
    super.onTapDown = (pointer, details) => this.addTouch(pointer, details);
    super.onTapUp = (pointer, details) => this.removeTouch(pointer, details);
    super.onTapCancel = (pointer) => this.cancelTouch(pointer);
    super.onTap = (pointer) => this.captureDefaultTap(pointer);
  }

  void addTouch(int pointer, TapDownDetails details) {
    this.numberOfTouches++;
  }

  void removeTouch(int pointer, TapUpDetails details) {
    this.numberOfTouches = 0;
  }

  void cancelTouch(int pointer) {
    this.numberOfTouches = 0;
  }

  void captureDefaultTap(int pointer) {}

}