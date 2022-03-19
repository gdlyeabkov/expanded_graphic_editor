import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {

  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();

}

class _StartPageState extends State<StartPage> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Softtrack Графический редактор'
        ),
        actions: [
          FlatButton(
            child: Icon(
              Icons.notifications
            ),
            onPressed: () {

            }
          ),
          FlatButton(
            child: Icon(
              Icons.account_circle
            ),
            onPressed: () {

            }
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Давайте порисуем!',
            style: TextStyle(
              fontSize: 20
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 100, 255)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.brush,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/canvas/create');
                    },
                  ),
                  Text(
                    'Новый холст'
                  )
                ]
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 100, 255)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.draw,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    )
                  ),
                  Text(
                    'Прошлый'
                  )
                ]
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/gallery');
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 100, 255)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    )
                  ),
                  Text(
                    'Моя галерея'
                  )
                ]
              ),
            ]
          ),
          TextButton(
            child: Text(
              'Библиотека Softtrack Графический редактор'
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

            }
          ),
          Text(
            'Отправить Работу',
            style: TextStyle(
              fontSize: 20
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 100, 0)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.attach_file,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    )
                  ),
                  Text(
                    'Отправить\nработу'
                  )
                ]
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 100, 0)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    )
                  ),
                  Text(
                    'Примите\nучастие в\nконкурсе'
                  )
                ]
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 100, 0)
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Icon(
                        Icons.brush,
                        size: 48,
                        color: Color.fromARGB(255, 255, 255, 255)
                      )
                    )
                  ),
                  Text(
                    'Всеобщее\'ы\nискусство'
                  )
                ]
              ),
            ]
          ),
        ]
      ),
      drawer: Drawer(

      )
    );
  }

}