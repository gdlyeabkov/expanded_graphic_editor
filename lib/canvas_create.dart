import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'models.dart';

class CanvasCreatePage extends StatefulWidget {
  const CanvasCreatePage({Key? key}) : super(key: key);

  @override
  State<CanvasCreatePage> createState() => _CanvasCreatePageState();

}

class _CanvasCreatePageState extends State<CanvasCreatePage> {

  String width = '1007';
  String height = '1414';
  List<String> measures = [
    'px',
    'cm'
  ];
  String widthMeasure = 'px';
  String heightMeasure = 'px';
  String dpi = '350';
  String paperSize = '';
  List<String> sizes = [
    '',
    'A4(210 * 297 мм)',
    'A5(148 * 210 мм)',
    'A6(105 * 148 мм)',
    'B5(182 * 257 мм)',
    'B6(128 * 182 мм)',
    'Стикер ЛИНИЯ(x1)',
    'Стикер ЛИНИЯ(x2)',
    'Стикер ЛИНИЯ(x4)',
    'Twitter',
    'Заголовок Twitter',
    'Значок Twitter',
    'История(Персонажи)',
    'История(Клип-арт)'
  ];
  BackgroundColorType selectedBackgroundColor = BackgroundColorType.color;
  Color backgroundColor = Colors.white;
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController dpiController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Новый холст'
        ),
        leading: GestureDetector(
          child: Icon(
              Icons.close
          ),
          onTap: () {
            Navigator.of(context).pop();
          }
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Размер холста',
            style: TextStyle(
              fontSize: 20
            )
          ),
          Text(
            'Ширина ${width} px'
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Высота ${height} px'
                  ),
                  Text(
                    'точек на дюйм 350'
                  )
                ]
              ),
              TextButton(
                child: Text(
                  'РЕДАКТИРОВАТЬ'
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 100, 100, 100)
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 255, 255, 255)
                  )
                ),
                onPressed: () {
                  setState(() {
                    width = '1007';
                    widthController.text = width;
                    height = '1414';
                    heightController = TextEditingController(
                      text: height
                    );
                    widthMeasure = 'px';
                    heightMeasure = 'px';
                    dpi = '350';
                    dpiController = TextEditingController(
                      text: dpi
                    );
                    paperSize = '';
                    selectedBackgroundColor = BackgroundColorType.color;
                    backgroundColor = Colors.white;
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) =>  AlertDialog(
                        content: Container(
                          height: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ширина'
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child:  Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 215,
                                      height: 35,
                                      child: TextField(
                                        controller: widthController,
                                        onChanged: (value) {
                                          setState(() {
                                            width = value;
                                            widthController.text = width;
                                            widthController.selection = TextSelection(
                                              baseOffset: width.length,
                                              extentOffset: width.length
                                            );
                                          });
                                        },
                                      )
                                    ),
                                    Container(
                                      child: DropdownButton<String>(
                                        value: widthMeasure,
                                        icon: const Icon(
                                          Icons.arrow_drop_down
                                        ),
                                        isExpanded: true,
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            widthMeasure = newValue!;
                                          });
                                        },
                                        items: measures.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList()
                                      ),
                                      width: 50,
                                      height: 35
                                    )
                                  ]
                                ),
                                height: 35,
                              ),
                              Text(
                                'Высота'
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 215,
                                      height: 35,
                                      child: TextField(
                                        controller: heightController,
                                        onChanged: (value) {
                                          setState(() {
                                            height = value;
                                            heightController.text = height;
                                            heightController.selection = TextSelection(
                                              baseOffset: height.length,
                                              extentOffset: height.length
                                            );
                                          });
                                        },
                                      )
                                    ),
                                    Container(
                                      child: DropdownButton<String>(
                                        value: heightMeasure,
                                        icon: const Icon(
                                            Icons.arrow_drop_down
                                        ),
                                        isExpanded: true,
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            heightMeasure = newValue!;
                                          });
                                        },
                                        items: measures.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList()
                                      ),
                                      height: 35,
                                      width: 50
                                    )
                                  ]
                                )
                              ),
                              Text(
                                'точек на дюйм'
                              ),
                              Container(
                                width: 250,
                                height: 35,
                                child: TextField(
                                  controller: dpiController,
                                  onChanged: (value) {
                                    setState(() {
                                      dpi = value;
                                      dpiController.text = dpi;
                                      dpiController.selection = TextSelection(
                                        baseOffset: dpi.length,
                                        extentOffset: dpi.length
                                      );
                                    });
                                  },
                                )
                              ),
                              Text(
                                'Размер бумаги'
                              ),
                              Container(
                                width: 250,
                                height: 35,
                                child: DropdownButton<String>(
                                  value: paperSize,
                                  icon: const Icon(
                                      Icons.arrow_drop_down
                                  ),
                                  isExpanded: true,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      paperSize = newValue!;
                                    });
                                  },
                                  menuMaxHeight: 375,
                                  items: sizes.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList()
                                )
                              ),
                              Text(
                                'Цвет фона'
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Radio<BackgroundColorType>(
                                        value: BackgroundColorType.color,
                                        groupValue: selectedBackgroundColor,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBackgroundColor = value!;
                                          });
                                        }
                                      ),
                                      Text(
                                        'Спец. цвета'
                                      )
                                    ]
                                  ),
                                  Row(
                                    children: [
                                      Radio<BackgroundColorType>(
                                          value: BackgroundColorType.transparent,
                                          groupValue: selectedBackgroundColor,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedBackgroundColor = value!;
                                            });
                                          }
                                      ),
                                      Text(
                                        'Очистить'
                                      )
                                    ]
                                  )
                                ]
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.check_box_outline_blank_outlined
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      content: ColorPicker(
                                        pickerColor: backgroundColor,
                                        onColorChanged: (Color color) {
                                          setState(() {
                                            backgroundColor = color;
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
                                return Navigator.pop(context, 'OK');
                              }
                          ),
                        ]
                      )
                    )
                  );
                }
              )
            ]
          ),
          Divider(

          ),
          TextButton(
            child: Text(
              'СОЗД'
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 0, 100, 255)
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 255, 255, 255)
              ),
              fixedSize: MaterialStateProperty.all<Size>(
                Size(
                  225, 25
                )
              ),
              alignment: Alignment.centerLeft
            ),
            onPressed: () {
              double parsedWidth = double.parse(width);
              double parsedHeight = double.parse(height);
              int parsedDpi = int.parse(dpi);
              Color canvasBackgroundColor = backgroundColor;
              if (selectedBackgroundColor == BackgroundColorType.transparent) {
                canvasBackgroundColor = Colors.transparent;
              }
              Navigator.pushNamed(
                context,
                '/main',
                arguments: {
                  'width': parsedWidth,
                  'height': parsedHeight,
                  'dpi': parsedDpi,
                  'backgroundColor': canvasBackgroundColor,
                  'paperSize': 'A4'
                }
              );
            }
          )
        ]
      ),
    );
  }

}