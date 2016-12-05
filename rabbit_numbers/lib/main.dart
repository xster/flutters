import 'dart:io' show File;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

String title = 'Rabbit numbers';
GlobalKey<ScaffoldState> _scaffoldKey;

  //make toasts
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

//Entry point
void main() {
  runApp(
    new MaterialApp(
      title: title,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(title: title),
    ),
  );
}

//base stateful widget
class FlutterDemo extends StatefulWidget {
  FlutterDemo({this.title, Key key}) : super(key: key);

  final String title;

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

//base stateful widget's state
class _FlutterDemoState extends State<FlutterDemo> {

  @override
  void initState() {
    super.initState();
    //do stuff when state is initialized
    _scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  //html localhost
  //get data stored to get and save data
  Future<File> _get_data() async {
    // get the path to the document directory.
    String dir = (await PathProvider.getApplicationDocumentsDirectory()).path;
    return new File('$dir/data.txt');
  }

  int move_cost = 20;

  //Put it all together.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text(config.title),
            actions: <Widget>[
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Double up for $move_cost',
                  icon: new Icon(Icons.add)),
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Shuffle for $move_cost',
                  icon: new Icon(Icons.shuffle)),
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Restart',
                  icon: new Icon(Icons.refresh))
            ],
            leading: new Image.asset('assets/nuRabbit.png')),
        body: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Column(children: [
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [new Tile(value: 1)])
            ])),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ));
  }
}

//yay new widget
class Tile extends StatefulWidget {
  Tile({this.value: 0, Key key}) : super(key: key);

  final int value;

  @override
  Tile_state createState() => new Tile_state();
}

class Tile_state extends State<Tile> {

  @override
  void initState() {
    super.initState();
    //do stuff when state is initialized
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new InkWell(onTap:()=>showInSnackBar('hi'),
            child: new Padding(
                padding: const EdgeInsets.all(116.0),
                child: new Text('${config.value}'))));
  }
}
