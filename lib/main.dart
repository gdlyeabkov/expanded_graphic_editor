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
  late SofttrackCanvas softtrackCanvas;
  // SofttrackCanvas(context, touchX, touchY, shapes);

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
      }
    });
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      softtrackCanvas = SofttrackCanvas(context, touchX, touchY, shapes, canvasRotation, canvasScale);
    });

    return Scaffold(
      key: scaffoldKey,
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
                painter: softtrackCanvas
              ),
              width: 415,
              height: 550
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
                  softtrackCanvas.getCapture();
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
                      canvasScale['x'] = (canvasScale['x'] as double) * -1.0;
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
                    Icons.brush
                  )
                ),
                onTap:() {

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
              )
            ]
          )
        )
      )
    );
  }
}
