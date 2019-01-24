import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/animation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  // // 测试列表
  // @override
  // _MyHomePageState createState() => _MyHomePageState();

  // 测试动画
  @override
  _TestAnimationState createState() => _TestAnimationState();
}

// 测试动画
class _TestAnimationState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Animation<EdgeInsets> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = new EdgeInsetsTween(
            begin: EdgeInsets.zero, end: EdgeInsets.only(left: 100))
        .animate(controller)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.forward) {
            } else if (status == AnimationStatus.completed) {
              controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              controller.forward();
            }
          });
    controller.forward();
  }

  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        color: Colors.red,
        margin: animation.value,
        height: 100,
        width: 100,
      ),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List items = [];

  @override
  void initState() {
    super.initState();
    loadDatas();
  }

  void loadDatas() async {
    String data = await rootBundle.loadString('assets/data.json');
    items = json.decode(data);
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return getCell(index);
      },
    ));
  }

  Widget getCell(int index) {
    var item = items[index];
    var row = Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(item['headIcon']),
              ),
              Expanded(
                  child: Container(
                child: Text(item['name']),
                margin: EdgeInsets.only(left: 4),
              ))
            ]),
            Container(
                child: Text(item['text'], textAlign: TextAlign.left),
                margin: EdgeInsets.only(top: 10)),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ));

    return Column(
      children: <Widget>[row, Divider()],
    );
  }
}
