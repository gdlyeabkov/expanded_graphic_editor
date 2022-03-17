import 'package:flutter/material.dart';
import 'package:graphiceditor/softtrack_canvas.dart';
import 'package:touchable/touchable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

            ]
          ),
          Row(
            children: [

            ]
          ),
          // CanvasTouchDetector(
          //   builder: (BuildContext context) => CustomPaint(
          //     painter: SofttrackCanvas(context)
          //   ),
          // ),
          GestureDetector(
            child: Container(
              child: CustomPaint(
                painter: SofttrackCanvas(context, touchX, touchY)
              ),
              width: 415,
              height: 750
            ),
            onHorizontalDragUpdate: (event) {
              print('onHorizontalDragUpdateEvent ${event.globalPosition.dx} ${event.globalPosition.dy}');
              setState(() {
                touchX = event.globalPosition.dx;
                touchY = event.globalPosition.dy;
              });
            },
            onVerticalDragUpdate: (event) {
              print('onVerticalDragUpdateEvent ${event.globalPosition.dx} ${event.globalPosition.dy}');
              setState(() {
                touchX = event.globalPosition.dx;
                touchY = event.globalPosition.dy;
              });
            }
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
